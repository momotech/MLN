/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
//
// Created by Xiong.Fangyu 2019/03/13.
//

#include "debug_info.h"
#include "m_mem.h"
#include "llimits.h"
#include "jinfo.h"
#include "lauxlib.h"
#include "juserdata.h"
#include "jtable.h"

#define LUA_NEWINDEX "__newindex"

/// 判断是否是JavaUserdata的子类，由java控制内存(存储在)
#define IS_STRONG_REF(env, clz) (*env)->IsAssignableFrom(env, clz, JavaUserdata)
#define clearException(env) if ((*env)->ExceptionCheck(env)) (*env)->ExceptionClear(env);

extern jclass JavaUserdata;
extern jmethodID LuaUserdata_memoryCast;
extern jclass StringClass;

/**
 * 对应executeLuaIndexFunction
 * 查找类中 LuaValue[] __index(String name, LuaValue[] args)方法
 */
static void pushUserdataIndexClosure(JNIEnv *env, lua_State *L, jclass clz);

/**
 * 对应pushUserdataIndexClosure
 * upvalues: 1: class 2: method
 * push executeJavaIndexFunction 并返回
 */
static int executeLuaIndexFunction(lua_State *L);

/**
 * 真正执行java __index方法
 * upvalue: 1: class 2: method 3: name
 */
static int executeJavaIndexFunction(lua_State *L);

/**
 * 对应pushUserdataTostringClosure
 * upvalue顺序为:
 *              1:UDjmethod
 */
static int userdata_tostring_fun(lua_State *L);

/**
 * 对应pushUserdataBoolClosure
 * upvalue顺序为:
 *              1:UDjmethod
 */
static int userdata_bool_fun(lua_State *L);

/**
 * 对应pushUserdataGcClosure
 * upvalue顺序为:
 *              1:UDjmethod gcmethod
 */
static int gc_userdata(lua_State *L);

/**
 * 对应executeJavaUDFunction
 */
static void pushMethodClosure(lua_State *L, jmethodID m, const char *mn);

/**
 * 对应pushMethodClosure
 * upvalue顺序为:
 *              1:UDjmethod
 *              2:string methodname
 */
static int executeJavaUDFunction(lua_State *L);

/**
 * 生成jms，要和释放对应j_ms_gc
 */
static char **get_methods_str(JNIEnv *env, jobjectArray ams, int methodCount, int methodStartIndex);
//// ----------------------------------------------------------------------------------------------------
//// ---------------------------------------------lazy---------------------------------------------------
//// ----------------------------------------------------------------------------------------------------
#define J_MS_METANAME "__J_MS_"
typedef struct j_ms {
    jclass clz;
    const char *p_meta;
} __LID;

/**
 * 释放j_ms相关内存
 * 需要和get_methods_str对应
 */
static int j_ms_gc(lua_State *L);

/**
 * 对应execute_new_ud_lazy
 */
static void push_lazy_init(lua_State *L, jclass clz, const char *metaname, const char *p_metaname);

/**
 * 对应 push_lazy_init
 * upvalue顺序为:1: metaname
 */
static int execute_new_ud_lazy(lua_State *L);
//// ----------------------------------------------------------------------------------------------------
//// ----------------------------------------------------------------------------------------------------
/**
 * 对应execute_new_ud
 */
static void
push_init(JNIEnv *env, lua_State *L, jclass clz, const char *metaname, const char *p_metaname);

/**
 * 对应push_init
 * upvalue顺序为:
 *              1:UDjclass
 *              2:constructor(UDjmethod)
 *              3:metaname(string)
 */
static int execute_new_ud(lua_State *L);

static void fillUDMetatable(JNIEnv *env, lua_State *LS, jclass clz, const char *parent_mn);

/**
 * 注册ud
 * lcn: lua class name          nonnull
 * lpcn: lua parent class name  nullable
 * jcn: java class name         nonnull
 * jms: java methods            nullable
 * mc:  java methods count      >=0
 * lazy: 是否懒注册
 */
static void
register_ud(JNIEnv *env, lua_State *L, const char *lcn, const char *lpcn, const char *jcn,
            int lazy);

static int u_newmetatable(lua_State *L, const char *tname) {
    luaL_getmetatable(L, tname);  /* try to get metatable */
    if (!lua_isnil(L, -1))  /* name already in use? */
        return 0;  /* leave previous value on top, but return 0 */
    lua_pop(L, 1);
    lua_createtable(L, 0, 3);
    lua_pushvalue(L, -1);
    lua_setfield(L, LUA_REGISTRYINDEX, tname);  /* registry.name = metatable */
    return 1;
}

void
jni_registerAllUserdata(JNIEnv *env, jobject jobj, jlong L, jobjectArray lcns, jobjectArray lpcns,
                        jobjectArray jcns, jbooleanArray lazy) {
    int len = GetArrLen(env, lcns);
    int i;
    jboolean *lz = (*env)->GetBooleanArrayElements(env, lazy, 0);
    for (i = 0; i < len; i++) {
        jstring lcn = (*env)->GetObjectArrayElement(env, lcns, i);
        jstring lpcn = (*env)->GetObjectArrayElement(env, lpcns, i);
        jstring jcn = (*env)->GetObjectArrayElement(env, jcns, i);

        const char *_lcn = GetString(env, lcn);
        const char *_lpcn = GetString(env, lpcn);
        const char *_jcn = GetString(env, jcn);
        register_ud(env, (lua_State *) L, _lcn, _lpcn, _jcn, lz[i]);
        ReleaseChar(env, lcn, _lcn);
        FREE(env, lcn);
        ReleaseChar(env, jcn, _jcn);
        FREE(env, jcn);
        if (lpcn) {
            ReleaseChar(env, lpcn, _lpcn);
            FREE(env, lpcn);
        }
    }
    (*env)->ReleaseBooleanArrayElements(env, lazy, lz, 0);
}

void
jni_registerUserdata(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jstring lpcn, jstring jcn) {
    const char *_lcn = GetString(env, lcn);
    const char *_lpcn = GetString(env, lpcn);
    const char *_jcn = GetString(env, jcn);

    register_ud(env, (lua_State *) L, _lcn, _lpcn, _jcn, 0);
    ReleaseChar(env, lcn, _lcn);
    ReleaseChar(env, jcn, _jcn);
    if (lpcn) {
        ReleaseChar(env, lpcn, _lpcn);
    }
}

void
jni_registerUserdataLazy(JNIEnv *env, jobject jobj, jlong L, jstring lcn, jstring lpcn,
                         jstring jcn) {
    const char *_lcn = GetString(env, lcn);
    const char *_lpcn = GetString(env, lpcn);
    const char *_jcn = GetString(env, jcn);

    register_ud(env, (lua_State *) L, _lcn, _lpcn, _jcn, 1);
    ReleaseChar(env, lcn, _lcn);
    ReleaseChar(env, jcn, _jcn);
    if (lpcn) {
        ReleaseChar(env, lpcn, _lpcn);
    }
}

jobject jni_createUserdataAndSet(JNIEnv *env, jobject jobj, jlong L, jstring key, jstring lcn,
                                 jobjectArray p) {
    const char *kstr = GetString(env, key);
    const char *name = GetString(env, lcn);
    lua_State *LS = (lua_State *) L;
    lua_lock(LS);

    lua_getglobal(LS, name);
    if (!lua_isfunction(LS, -1)) {
        char *em = joinstr(name, "not registed!");
        throwRuntimeError(env, em);
        m_malloc(em, (strlen(em) + 1) * sizeof(char), 0);
        ReleaseChar(env, key, kstr);
        ReleaseChar(env, lcn, name);
        lua_pop(LS, 1);
        lua_unlock(LS);
        return NULL;
    }

    int c = pushJavaArray(env, LS, p);
    if (lua_pcall(LS, c, 1, 0)) {
        const char *errmsg;
        if (lua_isstring(LS, -1))
            errmsg = lua_pushfstring(LS, "create %s error, msg: %s", name, lua_tostring(LS, -1));
        else
            errmsg = lua_pushfstring(LS, "create %s error, unknown msg", name);

        clearException(env);
        throwRuntimeError(env, errmsg);
        lua_pop(LS, 1);
        ReleaseChar(env, key, kstr);
        ReleaseChar(env, lcn, name);
        lua_pop(LS, 1);
        lua_unlock(LS);
        return NULL;
    }
    if (!lua_isuserdata(LS, -1)) {
        throwRuntimeError(env, lua_pushfstring(LS, "create %s error, not a userdata!", name));
        ReleaseChar(env, key, kstr);
        ReleaseChar(env, lcn, name);
        lua_pop(LS, 1);
        lua_unlock(LS);
        return NULL;
    }
    UDjavaobject ud = (UDjavaobject) lua_touserdata(LS, -1);
    lua_setglobal(LS, kstr);
    ReleaseChar(env, key, kstr);
    ReleaseChar(env, lcn, name);
    lua_unlock(LS);
    return getUserdata(env, LS, ud);
}
//// ----------------------------------------------------------------------------------------------------
//// -------------------------------------------jni end--------------------------------------------------
//// ----------------------------------------------------------------------------------------------------

/**
 * 注册ud
 * lcn: lua class name          nonnull
 * lpcn: lua parent class name  nullable
 * jcn: java class name         nonnull
 * jms: java methods            nullable
 * mc:  java methods count      >=0
 * lazy: 是否懒注册
 */
static void
register_ud(JNIEnv *env, lua_State *L, const char *lcn, const char *lpcn, const char *jcn,
            int lazy) {
    jclass clz = getClassByName(env, jcn);

    char *metaname = getUDMetaname(lcn);
    char *p_metaname = NULL;
    if (lpcn) {
        p_metaname = getUDMetaname(lpcn);
    }

    lua_lock(L);
    if (lazy) {
        push_lazy_init(L, clz, metaname, p_metaname);
    } else {
        push_init(env, L, clz, metaname, p_metaname);
    }
    lua_setglobal(L, lcn);
    lua_unlock(L);

#if defined(J_API_INFO)
    if (p_metaname) m_malloc(p_metaname, (strlen(p_metaname) + 1) * sizeof(char), 0);
    m_malloc(metaname, (strlen(metaname) + 1) * sizeof(char), 0);
#else
    if (p_metaname) free(p_metaname);
    free(metaname);
#endif
}

/**
 * 生成jms，要和释放对应j_ms_gc
 */
static char **
get_methods_str(JNIEnv *env, jobjectArray ams, int methodCount, int methodStartIndex) {
    char **jms = (char **) m_malloc(NULL, 0, sizeof(char *) * methodCount);
    memset(jms, 0, sizeof(char *) * methodCount);
    int j;
    size_t byte_size = sizeof(char);
    for (j = 0; j < methodCount; j++) {
        jstring m = (*env)->GetObjectArrayElement(env, ams, methodStartIndex + j);
        // jms[j] = GetString(env, m);

        const char *s = GetString(env, m);
        int len = (*env)->GetStringUTFLength(env, m) + 1;
        jms[j] = (char *) m_malloc(NULL, 0, byte_size * len);
        strcpy(jms[j], s);
        ReleaseChar(env, m, s);

        FREE(env, m);
    }
    return jms;
}

/**
 * 通过堆栈生成java对象，并push到栈顶
 * 若错误返回1
 * 正确返回0
 * return : -1: ud or errorstring
 */
static int new_java_obj(JNIEnv *env, lua_State *L, jclass clz, jmethodID con, const char *metaname,
                        int offset) {
    int pc = lua_gettop(L) - offset;
    jobjectArray p = newLuaValueArrayFromStack(env, L, pc, 1);
    jobject javaObj = (*env)->NewObject(env, clz, con, (jlong) L, p);
    char *info = joinstr(metaname + strlen(METATABLE_PREFIX), "<init>");
    if (catchJavaException(env, L, info)) {
        if (info)
            m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);
        FREE(env, p);
        FREE(env, javaObj);
        return 1;
    }
    if (info)
        m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);
    FREE(env, p);

    jlong mem = (*env)->CallLongMethod(env, javaObj, LuaUserdata_memoryCast);
    clearException(env);
    mem = mem < 0 ? 0 : (mem >> 10);

    UDjavaobject ud = (UDjavaobject) lua_newuserdata(L, sizeof(javaUserdata));
    lua_gc(L, LUA_GCSTEP, (int) mem);
    ud->id = getUserdataId(env, javaObj);
    if (IS_STRONG_REF(env, clz)) {
        setUDFlag(ud, JUD_FLAG_STRONG);
        copyUDToGNV(env, L, ud, -1, javaObj);
    }
    FREE(env, javaObj);
    ud->refCount = 0;

    ud->name = lua_pushstring(L, metaname);
    lua_pop(L, 1);
    return 0;
}
//// ----------------------------------------------------------------------------------------------------
//// ---------------------------------------------lazy---------------------------------------------------
//// ----------------------------------------------------------------------------------------------------

#define CLZ_KEY_IN_TABLE  "__clz"

/**
 * 对应execute_new_ud_lazy
 */
static void push_lazy_init(lua_State *L, jclass clz, const char *metaname, const char *p_metaname) {
    /// 若第一次创建metatable，创建__LID，且metaname[__LID]=__LID
    u_newmetatable(L, metaname);                                //metatable
    lua_getfield(L, -1, J_MS_METANAME);                         //metatable[__LID] --metatable
    __LID *lid;
    if (lua_isuserdata(L, -1)) {
        lid = lua_touserdata(L, -1);
        lid->clz = clz;
        lid->p_meta = lua_pushstring(L, p_metaname);
        lua_pop(L, 2);                                          //metatable
    } else {
        lua_pop(L, 1);
        lua_pushstring(L, J_MS_METANAME);                       //__LID --metatable
        lid = (__LID *) lua_newuserdata(L, sizeof(__LID));      //lid --__LID-metatable
        lua_rawset(L, -3);                                      //metatable[__LID]=lid  metatable

        lid->clz = clz;
        lid->p_meta = lua_pushstring(L, p_metaname);
        lua_pop(L, 1);                                          //metatable
    }
    //// metatable

    lua_pushstring(L, CLZ_KEY_IN_TABLE);                        //key --metatable
    UDjclass udj = (UDjclass) lua_newuserdata(L, sizeof(jclass));   //clz --key-metatable
    *udj = clz;
    lua_rawset(L, -3);                                          //metatable[__clz]=clz  metatable
    lua_pop(L, 1);

    lua_pushstring(L, metaname);                                //metaname
    lua_pushcclosure(L, execute_new_ud_lazy, 1);                //closure
}

/**
 * -1: lid -2: metatable
 * return class with -1: metatable
 */
static jclass init_lazy_metatable(JNIEnv *env, lua_State *L) {
    lua_lock(L);
    __LID *lid = (__LID *) lua_touserdata(L, -1);
    lua_pop(L, 1);                                      // metatable
    jclass clz = lid->clz;
    fillUDMetatable(env, L, clz, lid->p_meta);          // metatable
    lua_pushnil(L);
    lua_setfield(L, -2, J_MS_METANAME);                 //metatable[__LID] = nil
    lua_unlock(L);
    return clz;
}

/**
 * 对应 push_lazy_init
 * upvalue顺序为: 1: metaname
 */
static int execute_new_ud_lazy(lua_State *L) {
    JNIEnv *env;
    int need = getEnv(&env);
    lua_lock(L);
    const char *metaname = lua_tostring(L, lua_upvalueindex(1));
    u_newmetatable(L, metaname);            //metatable
    lua_pushstring(L, J_MS_METANAME);       //__LID --metatable
    lua_rawget(L, -2);                      //metatable[__LID] --metatable

    jclass clz;
    /// 第一次设置的情况
    if (lua_isuserdata(L, -1)) {
        clz = init_lazy_metatable(env, L);      //metatable
    }
        /// 之后创建
    else {
        lua_pop(L, 1);                          //metatable
        lua_pushstring(L, CLZ_KEY_IN_TABLE);    //key --metatable
        lua_rawget(L, -2);                      //metatable[key] --metatable
        UDjclass udj = lua_touserdata(L, -1);
        clz = getuserdata(udj);
        lua_pop(L, 1);                          //metatable
    }

    jmethodID con = getConstructor(env, clz);

    if (new_java_obj(env, L, clz, con, metaname, 1)) { //ud --metatable
        if (need) detachEnv();
        lua_unlock(L);
        lua_error(L);
        return 1;
    }

    lua_pushvalue(L, -2);       //metatable --ud-metatable
    lua_setmetatable(L, -2);    //ud --metatable
    lua_remove(L, -2);          //ud

    if (need) detachEnv();
    lua_unlock(L);
    return 1;
}
//// ----------------------------------------------------------------------------------------------------
//// ----------------------------------------------------------------------------------------------------
//// ----------------------------------------------------------------------------------------------------
//// ----------------------------------------------------------------------------------------------------
/**
 * 对应execute_new_ud
 */
static void
push_init(JNIEnv *env, lua_State *L, jclass clz, const char *metaname, const char *p_metaname) {
    /// 如果是JavaInstance或JavaClass，只注册方法，因为对象由java创建
    if (strcmp(metaname, JAVA_INSTANCE_META) == 0 || strcmp(metaname, JAVA_CLASS_META) == 0) {
        u_newmetatable(L, metaname);                                        // table
        fillUDMetatable(env, L, clz, p_metaname);
        lua_pop(L, 1);
        lua_pushnil(L);
        return;
    }

    u_newmetatable(L, metaname);
    fillUDMetatable(env, L, clz, p_metaname);
    lua_pop(L, 1);

    jmethodID cons = getConstructor(env, clz);
    pushConstructorMethod(L, clz, cons, metaname);
}

void pushConstructorMethod(lua_State *L, jclass clz, jmethodID con, const char *metaname) {
    UDjclass udclz = (UDjclass) lua_newuserdata(L, sizeof(jclass));      // clz
    *udclz = clz;

    UDjmethod udm = (UDjmethod) lua_newuserdata(L, sizeof(jmethodID));   // con,clz
    *udm = con;

    lua_pushstring(L, metaname);                                        // metaname,con,clz
    lua_pushcclosure(L, execute_new_ud, 3);
}

/**
 * 对应push_init
 * upvalue顺序为:
 *              1:UDjclass 
 *              2:constructor(UDjmethod)
 *              3:metaname(string)
 */
static int execute_new_ud(lua_State *L) {
    JNIEnv *env;
    int need = getEnv(&env);
    lua_lock(L);

    /// 第1个参数
    int idx = lua_upvalueindex(1);
    jclass clz = getuserdata((UDjclass) lua_touserdata(L, idx));

    /// 第2个参数
    idx = lua_upvalueindex(2);
    jmethodID con = getuserdata((UDjmethod) lua_touserdata(L, idx));

    /// 第3个参数
    idx = lua_upvalueindex(3);
    const char *metaname = lua_tostring(L, idx);

    if (new_java_obj(env, L, clz, con, metaname, 0)) {
        if (need) detachEnv();
        lua_unlock(L);
        lua_error(L);
        return 1;
    }

    luaL_getmetatable(L, metaname);
    lua_setmetatable(L, -2);

    if (need) detachEnv();
    lua_unlock(L);
    return 1;
}

static int traverse_listener(const void *key, const void *value, void *ud) {
    const char *m = (const char *) key;

    const char **lsm = special_methods;
    while (*lsm) {
        if (strcmp(*lsm, m) == 0) {
            return 0;
        }
        lsm++;
    }
    jmethodID method = (jmethodID) value;
    lua_State *L = (lua_State *) ud;
    lua_pushstring(L, m);
    pushMethodClosure(L, method, m);
    lua_rawset(L, -3); //metatable.m = closure

    return 0;
}

/**
 * -1: metatable
 * return void with -1: metatable
 */
static void fillUDMetatable(JNIEnv *env, lua_State *LS, jclass clz, const char *parent_mn) {
    SET_METATABLE(LS);
    if (parent_mn) {
        luaL_getmetatable(LS, parent_mn);
        if (lua_istable(LS, -1)) {                  //metatable
            lua_getfield(LS, -1, J_MS_METANAME);    //metatable[__LID] --metatable
            /// 说明父类是lazy注册的
            if (lua_isuserdata(LS, -1)) {
                __LID *lid = (__LID *) lua_touserdata(LS, -1);
                /// 父类和自身不同，则注册
                if (lid->clz != clz)
                    init_lazy_metatable(env, LS);   //metatable
                    /// 父类就是自身，不用管
                else
                    lua_pop(LS, 1);                 //metatable
            }
                /// 说明父类不是lazy注册
            else {
                lua_pop(LS, 1);                     //metatable
            }
            /// 如果是相同的table，表示parent的名称和自己相同，则不用拷贝
            if (!lua_rawequal(LS, -1, -2))
                copyTable(LS, -1, -2);
        }
        lua_pop(LS, 1);
    }

    traverseAllMethods(clz, traverse_listener, LS);

    if (!parent_mn) {
        /// 设置gc方法
        pushUserdataGcClosure(env, LS, clz);
        /// 设置需要返回bool的方法，比如__eq
        pushUserdataBoolClosure(env, LS, clz);
        /// 设置__tostring
        pushUserdataTostringClosure(env, LS, clz);
    }
    /// 设置__index
    pushUserdataIndexClosure(env, LS, clz);
}


//// ----------------------------------------------------------------------------------------------------
//// ----------------------------------------------------------------------------------------------------
//// ----------------------------------------------------------------------------------------------------
//// ----------------------------------------------------------------------------------------------------

#define INDEX_METATABLE 1
#define INDEX_FUNCTION  (1 << 1)
#define NEWINDEX_FUNCTION (1 << 2)

static int check_metatable(lua_State *L) {
    /// -1: table
    int ret = 0;
    if (lua_getmetatable(L, -1)) {
        ret |= INDEX_METATABLE;
        /// -1: mt  table
        lua_pushstring(L, LUA_INDEX);
        lua_rawget(L, -2);              //-1: mt[__index] mt table
        if (lua_isfunction(L, -1)) ret |= INDEX_FUNCTION;
        lua_pop(L, 2);
    }

    /// -1: table
    lua_pushstring(L, LUA_NEWINDEX);
    lua_rawget(L, -2);
    if (lua_isfunction(L, -1)) ret |= NEWINDEX_FUNCTION;

    lua_pop(L, 1);
    return ret;
}

/**
 * 对应executeLuaIndexFunction
 */
static void pushUserdataIndexOrNewindexClosure(lua_State *L, jmethodID m, int getter) {
    /// -1: table
    const char *name = getter ? LUA_INDEX : LUA_NEWINDEX;

    lua_pushstring(L, name);        //-1: name   table

    UDjmethod udm = (UDjmethod) lua_newuserdata(L, sizeof(jmethodID));
    *udm = m;
    lua_pushboolean(L, getter);

    lua_pushcclosure(L, executeLuaIndexFunction, 2);    //-1: closure  name   table
    lua_rawset(L, -3);              //-1: table
}

/**
 * 对应executeLuaIndexFunction
 * 查找类中 LuaValue[] __index(String name, LuaValue[] args)方法
 * 或 void __newindex(String name, LuaValue arg)
 */
static void pushUserdataIndexClosure(JNIEnv *env, lua_State *L, jclass clz) {
    /// -1: metatable
    int flag = check_metatable(L);
    if (!(flag & INDEX_FUNCTION)) {
        jmethodID _index = getSpecialMethod(env, clz, METHOD_INDEX);
        if (_index) {
            if (!(flag & INDEX_METATABLE)) {
                lua_createtable(L, 0, 2);
                lua_pushvalue(L, -1);
                lua_setmetatable(L, -3);
            } else {
                lua_getmetatable(L, -1);
            }
            /// -1: table metatable
            pushUserdataIndexOrNewindexClosure(L, _index, 1);
            lua_pop(L, 1);
        }
    }
    /// -1: metatable
    if (!(flag & NEWINDEX_FUNCTION)) {
        jmethodID _newindex = getSpecialMethod(env, clz, METHOD_NEWINDEX);
        if (_newindex) pushUserdataIndexOrNewindexClosure(L, _newindex, 0);
    }
}

static int
executeJavaIndexOrNewindexFunction(JNIEnv *env, lua_State *L, jmethodID m, const char *mn,
                                   int getter);

/**
 * 对应pushUserdataIndexClosure
 * upvalues: 1: method 2: getter
 * push executeJavaIndexFunction 并返回
 */
static int executeLuaIndexFunction(lua_State *L) {
    lua_lock(L);
    /// 第2个参数为bool
    int idx = lua_upvalueindex(2);
    int getter = lua_toboolean(L, idx);
    if (getter) {
        lua_pushvalue(L, lua_upvalueindex(1));
        lua_pushvalue(L, idx);
        lua_pushvalue(L, 2);    //method name
        lua_pushcclosure(L, executeJavaIndexFunction, 3);
        lua_unlock(L);
        return 1;
    } else {
        JNIEnv *env;
        getEnv(&env);
        /// 第1个参数为Java方法
        idx = lua_upvalueindex(1);
        UDjmethod udmethod = (UDjmethod) lua_touserdata(L, idx);
        const char *mn = lua_tostring(L, 2);
        lua_remove(L, 2);

        executeJavaIndexOrNewindexFunction(env, L, getuserdata(udmethod), mn, 0);
        lua_unlock(L);
        return 0;
    }
}

static int
executeJavaIndexOrNewindexFunction(JNIEnv *env, lua_State *L, jmethodID m, const char *mn,
                                   int getter) {
    UDjavaobject udjobj = (UDjavaobject) lua_touserdata(L, 1);
    jobject jobj = getUserdata(env, L, udjobj);
    if (!jobj) {
        lua_pushfstring(L, "get java object from java failed, id: %d", udjobj->id);
        lua_error(L);
        return 1;
    }
    int paramCount = lua_gettop(L) - 1;
    jobject p = NULL;
    jstring jmn = newJString(env, mn);
    jobjectArray result = NULL;
    if (getter) {
        p = newLuaValueArrayFromStack(env, L, paramCount, 2);
        result = (jobjectArray) (*env)->CallObjectMethod(env, jobj, m, jmn, p);
    } else {
        p = toJavaValue(env, L, 2);
        (*env)->CallVoidMethod(env, jobj, m, jmn, p);
    }
    FREE(env, jobj);
    char *info = join3str(udjobj->name + strlen(METATABLE_PREFIX), ".", mn);
    if (catchJavaException(env, L, info)) {
        if (info)
            m_malloc(info, sizeof(char) * (strlen(info) + 1), 0);
        FREE(env, p);
        FREE(env, jmn);
        const char *msg = lua_tostring(L, -1);
        lua_pop(L, 1);
        lua_pushfstring(L, "call method %s failed---%s", mn, msg);
        lua_error(L);
        return 1;
    }
    if (info)
        m_malloc(info, sizeof(char) * (strlen(info) + 1), 0);
    FREE(env, p);
    FREE(env, jmn);
    if (!result) {
        return 0;
    }

    int rc = pushJavaArray(env, L, result);
    FREE(env, result);
    return rc;
}

/**
 * 真正执行java __index方法
 * upvalue: 1: method 2: getter 3: name
 */
static int executeJavaIndexFunction(lua_State *L) {
    lua_lock(L);
    if (!lua_isuserdata(L, 1)) {
        lua_pushstring(L, "use ':' instead of '.' to call method!!");
        lua_unlock(L);
        lua_error(L);
        return 1;
    }

    JNIEnv *env;
    getEnv(&env);

    /// 第1个参数为Java方法
    int idx = lua_upvalueindex(1);
    UDjmethod udmethod = (UDjmethod) lua_touserdata(L, idx);

    /// 第2个参数为getter
    idx = lua_upvalueindex(2);
    int getter = lua_toboolean(L, idx);

    /// 第3个参数为函数名称
    idx = lua_upvalueindex(3);
    const char *mn = NULL;
    if (lua_isstring(L, idx)) {
        mn = lua_tostring(L, idx);
    }

    if (!mn) {
        lua_pushstring(L, "no method name");
        return lua_error(L);
    }

    jmethodID method = getuserdata(udmethod);

    int rc = executeJavaIndexOrNewindexFunction(env, L, method, mn, getter);
    lua_unlock(L);
    return rc;
}

/**
 * 对应userdata_tostring_fun
 */
void pushUserdataTostringClosure(JNIEnv *env, lua_State *L, jclass clz) {
    jmethodID m = getSpecialMethod(env, clz, METHOD_TOSTRING);
    lua_pushstring(L, "__tostring");

    UDjmethod udm = (UDjmethod) lua_newuserdata(L, sizeof(jmethodID));
    *udm = m;

    lua_pushcclosure(L, userdata_tostring_fun, 1);

    lua_rawset(L, -3);
}

/**
 * 对应pushUserdataTostringClosure
 * upvalue顺序为:
 *              1:UDjmethod
 */
static int userdata_tostring_fun(lua_State *L) {
    lua_lock(L);
    if (!lua_isuserdata(L, 1)) {
        lua_pushstring(L, "use ':' instead of '.' to call method!!");
        lua_unlock(L);
        lua_error(L);
        return 1;
    }

    JNIEnv *env;
    int need = getEnv(&env);

    UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);
    jobject jobj = getUserdata(env, L, ud);
    if (!jobj) {
        lua_pushfstring(L, "get java object from java failed, id: %d", ud->id);
        lua_error(L);
        return 1;
    }

    jmethodID m = getuserdata((UDjmethod) lua_touserdata(L, lua_upvalueindex(1)));

    jstring r = (*env)->CallObjectMethod(env, jobj, m);

    FREE(env, jobj);
    clearException(env);
    const char *str = GetString(env, r);
    if (str) {
        lua_pushstring(L, str);
        ReleaseChar(env, r, str);
        FREE(env, r);
        if (need) detachEnv();
        lua_unlock(L);
        return 1;
    }
    lua_pushstring(L, "call tostring exception");
    if (need) detachEnv();
    lua_unlock(L);
    return 1;
}

/**
 * 对应userdata_bool_fun
 */
void pushUserdataBoolClosure(JNIEnv *env, lua_State *L, jclass clz) {
    jmethodID m = getSpecialMethod(env, clz, METHOD_EQAULS);
    lua_pushstring(L, "__eq");
    UDjmethod udm = (UDjmethod) lua_newuserdata(L, sizeof(jmethodID));
    *udm = m;
    lua_pushcclosure(L, userdata_bool_fun, 1);
    lua_rawset(L, -3);
}

/**
 * 对应pushUserdataBoolClosure
 * upvalue顺序为:
 *              1:UDjmethod
 */
static int userdata_bool_fun(lua_State *L) {
    lua_lock(L);
    if (!lua_isuserdata(L, 1) || !lua_isuserdata(L, 2)) {
        lua_pushboolean(L, 0);
        lua_unlock(L);
        return 1;
    }
    UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);
    UDjavaobject other = (UDjavaobject) lua_touserdata(L, 2);
    if (ud == other) {
        lua_pushboolean(L, 1);
        lua_unlock(L);
        return 1;
    } else if (!isJavaUserdata(other)) {
        lua_pushboolean(L, 0);
        lua_unlock(L);
        return 1;
    }

    JNIEnv *env;
    int need = getEnv(&env);
    jobject jobj1 = getUserdata(env, L, ud);
    if (!jobj1) {
        lua_pushfstring(L, "get java object from java failed, id: %d", ud->id);
        lua_error(L);
        return 1;
    }
    jobject jobj2 = getUserdata(env, L, other);
    if (!jobj2) {
        lua_pushfstring(L, "get java object from java failed, id: %d", other->id);
        lua_error(L);
        return 1;
    }

    jmethodID m = getuserdata((UDjmethod) lua_touserdata(L, lua_upvalueindex(1)));

    jboolean r = (*env)->CallBooleanMethod(env, jobj1, m, jobj2);
    FREE(env, jobj1);
    FREE(env, jobj2);
    clearException(env);
    lua_pushboolean(L, r);

    if (need) detachEnv();
    lua_unlock(L);
    return 1;
}

/**
 * 对应gc_userdata
 */
void pushUserdataGcClosure(JNIEnv *env, lua_State *L, jclass clz) {
    lua_pushstring(L, "__gc");

    jmethodID gc = getSpecialMethod(env, clz, METHOD_GC);

    UDjmethod udm = (UDjmethod) lua_newuserdata(L, sizeof(jmethodID));
    *udm = gc;

    lua_pushcclosure(L, gc_userdata, 1);

    lua_rawset(L, -3);
}

/**
 * 对应pushUserdataGcClosure
 * upvalue顺序为:
 *              1:UDjmethod gcmethod nilable
 */
static int gc_userdata(lua_State *L) {
    lua_lock(L);
    if (!lua_isuserdata(L, 1)) {
        lua_pushstring(L, "use ':' instead of '.' to call method!!");
        lua_unlock(L);
        lua_error(L);
        return 0;
    }
    JNIEnv *env;
    int need = getEnv(&env);

    UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);
    jobject jobj = getUserdata(env, L, ud);
    if (!jobj) {
        if (need) detachEnv();
        return 0;
    }

    int idx = lua_upvalueindex(1);
    jmethodID gcm = getuserdata((UDjmethod) lua_touserdata(L, idx));
    lua_unlock(L);

    (*env)->CallVoidMethod(env, jobj, gcm);
    clearException(env);
    FREE(env, jobj);
    if (need) detachEnv();
    return 0;
}

/**
 * 对应executeJavaUDFunction
 */
static void pushMethodClosure(lua_State *L, jmethodID m, const char *mn) {
    UDjmethod udm = (UDjmethod) lua_newuserdata(L, sizeof(jmethodID));
    *udm = m;

    lua_pushstring(L, mn);

    lua_pushcclosure(L, executeJavaUDFunction, 2);
}

/**
 * 对应pushMethodClosure
 * upvalue顺序为:
 *              1:UDjmethod
 *              2:string methodname
 */
static int executeJavaUDFunction(lua_State *L) {
    lua_lock(L);
    if (!lua_isuserdata(L, 1)) {
        lua_pushstring(L, "use ':' instead of '.' to call method!!");
        lua_unlock(L);
        lua_error(L);
        return 1;
    }

    JNIEnv *env;
    int need = getEnv(&env);

    /// 第1个参数为方法
    int idx = lua_upvalueindex(1);
    UDjmethod udm = (UDjmethod) lua_touserdata(L, idx);
    jmethodID m = getuserdata(udm);

    /// 第2个参数为方法名称
    idx = lua_upvalueindex(2);
    const char *n = lua_tostring(L, idx);

    if (!m) {
        lua_pushfstring(L, "no method implement for %s", n);
        lua_unlock(L);
        lua_error(L);
        return 1;
    }

    int pc = lua_gettop(L) - 1; //去掉底部userdata
    UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);
    jobject jobj = getUserdata(env, L, ud);
    if (!jobj) {
        lua_pushfstring(L, "get java object from java failed, id: %d", ud->id);
        lua_error(L);
        return 1;
    }

    jobjectArray p = newLuaValueArrayFromStack(env, L, pc, 2);
    jobjectArray r = (*env)->CallObjectMethod(env, jobj, m, p);
    char *info = join3str(ud->name + strlen(METATABLE_PREFIX), ".", n);
    if (catchJavaException(env, L, info)) {
        if (info)
            m_malloc(info, sizeof(char) * (strlen(info) + 1), 0);
        FREE(env, jobj);
        FREE(env, r);
        FREE(env, p);
        if (need) detachEnv();
        lua_unlock(L);
        lua_error(L);
        return 1;
    }
    if (info)
        m_malloc(info, sizeof(char) * (strlen(info) + 1), 0);
    FREE(env, jobj);

    FREE(env, p);
    if (!r) {
        lua_settop(L, 1);
        if (need) detachEnv();
        lua_unlock(L);
        return 1;
    }
    int ret = pushJavaArray(env, L, r);
    FREE(env, r);
    if (need) detachEnv();
    lua_unlock(L);
    return ret;
}