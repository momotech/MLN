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

#include <sys/time.h>
#include "debug_info.h"
#include "m_mem.h"
#include "llimits.h"
#include "jinfo.h"
#include "lauxlib.h"
#include "juserdata.h"
#include "jtable.h"
#include "statistics.h"

/// 判断是否是JavaUserdata的子类，由java控制内存(存储在)
#define clearException(env) if ((*env)->ExceptionCheck(env)) (*env)->ExceptionClear(env);
#define _get_milli_second(t) ((t)->tv_sec*1000.0 + (t)->tv_usec / 1000.0)

extern jclass JavaUserdata;
extern jmethodID LuaUserdata_memoryCast;
extern jclass StringClass;

//<editor-fold desc="define function">
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
 * 对应execute_new_ud_lazy
 */
static void push_lazy_init(JNIEnv *env, lua_State *L, jclass clz, const char *metaname, const char *p_metaname);

/**
 * 对应 push_lazy_init
 * upvalue顺序为:1: metaname
 */
static int execute_new_ud_lazy(lua_State *L);
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

/**
 * -1: metatable
 * return void with -1: metatable
 */
static void fillUDMetatable(JNIEnv *env, lua_State *LS, jclass clz, const char *self, const char *parent_mn);

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
//</editor-fold>

//<editor-fold desc="jni">

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
//</editor-fold>

//<editor-fold desc="other function">
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
        push_lazy_init(env, L, clz, metaname, p_metaname);
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
    if (isStrongUserdata(env, clz)) {
        setUDFlag(ud, JUD_FLAG_STRONG);
        copyUDToGNV(env, L, ud, -1, javaObj);
    }
    FREE(env, javaObj);
    ud->refCount = 0;

    ud->name = lua_pushstring(L, metaname);
    lua_pop(L, 1);
    return 0;
}

int u_newmetatable(lua_State *L, const char *tname) {
    luaL_getmetatable(L, tname);  /* try to get metatable */
    if (!lua_isnil(L, -1))  /* name already in use? */
        return 0;  /* leave previous value on top, but return 0 */
    lua_pop(L, 1);
    lua_createtable(L, 0, 3);
    lua_pushvalue(L, -1);
    lua_setfield(L, LUA_REGISTRYINDEX, tname);  /* registry.name = metatable */
    return 1;
}
//</editor-fold>

//<editor-fold desc="init lazy">
#define CLZ_KEY_IN_TABLE  "__clz"
#define PARENT_META "__P_META"
#define METATABLE_INIT "__INIT"
/**
 * 对应execute_new_ud_lazy
 */
static void push_lazy_init(JNIEnv *env, lua_State *L, jclass clz, const char *metaname, const char *p_metaname) {
    /// 注册表中已有相关metatable，则填充metatable
    if (!u_newmetatable(L, metaname)) {
        fillUDMetatable(env, L, clz, metaname, p_metaname);
    }
    ///metatable
    ///metatable.__clz=clz(userdata)
    ///metatable.__P_META=p_metaname
    lua_pushstring(L, CLZ_KEY_IN_TABLE);
    UDjclass udj = (UDjclass) lua_newuserdata(L, sizeof(jclass));
    *udj = clz;
    lua_rawset(L, -3);
    lua_pushstring(L, PARENT_META);
    lua_pushstring(L, p_metaname);
    lua_rawset(L, -3);

    lua_pop(L, 1);

    lua_pushstring(L, metaname);
    lua_pushcclosure(L, execute_new_ud_lazy, 1);
}

/**
 * -1: metatable
 * return class 如果不是lazy，则返回NULL
 */
static jclass init_lazy_metatable(JNIEnv *env, lua_State *L, const char *self) {
    lua_lock(L);
    /// metatable.__clz
    lua_pushstring(L, CLZ_KEY_IN_TABLE);
    lua_rawget(L, -2);
    /// 这个metatable不是lazy的，不需要做后续设置
    if (!lua_isuserdata(L, -1)) {
        lua_pop(L, 1);
        return NULL;
    }
    jclass clz = getuserdata((UDjclass) lua_touserdata(L, -1));
    lua_pop(L, 1);
    /// metatable.__INIT
    lua_pushstring(L, METATABLE_INIT);
    lua_rawget(L, -2);
    int isInit = lua_toboolean(L, -1);
    lua_pop(L, 1);
    /// 已经初始化了，返回
    if (isInit) {
        return clz;
    }
    /// metatable.__PARENT
    lua_pushstring(L, PARENT_META);
    lua_rawget(L, -2);
    const char *parent = lua_tostring(L, -1);
    lua_pop(L, 1);

    fillUDMetatable(env, L, clz, self, parent);
    /// metatable.__INIT = true
    lua_pushstring(L, METATABLE_INIT);
    lua_pushboolean(L, 1);
    lua_rawset(L, -3);
    lua_unlock(L);
    return clz;
}

/**
 * 对应 push_lazy_init
 * upvalue顺序为: 1: metaname
 */
static int execute_new_ud_lazy(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    JNIEnv *env;
    int need = getEnv(&env);
    lua_lock(L);
    const char *metaname = lua_tostring(L, lua_upvalueindex(1));
    u_newmetatable(L, metaname);
    ///metatable
    jclass clz = init_lazy_metatable(env, L, metaname);
    ///metatable
    jmethodID con = getConstructor(env, clz);
    if (new_java_obj(env, L, clz, con, metaname, 1)) {
        if (need) detachEnv();
        lua_unlock(L);
        lua_error(L);
        return 1;
    }
    /// -1:userdata -2:metatable
    ///setmetatable(userdata)
    lua_pushvalue(L, -2);
    lua_setmetatable(L, -2);
    /// -1:userdata -2:metatable
    lua_remove(L, -2);

    if (need) detachEnv();
    lua_unlock(L);

#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    double offset = _get_milli_second(&end) - _get_milli_second(&start);
    userdataMethodCall(metaname + strlen(METATABLE_PREFIX), InitMethodName, offset);
#endif

    return 1;
}
//</editor-fold>

//<editor-fold desc="new userdata">
/**
 * 对应execute_new_ud
 */
static void
push_init(JNIEnv *env, lua_State *L, jclass clz, const char *metaname, const char *p_metaname) {
    u_newmetatable(L, metaname);
    fillUDMetatable(env, L, clz, metaname, p_metaname);
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
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif

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

#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    double offset = _get_milli_second(&end) - _get_milli_second(&start);
    userdataMethodCall(metaname + strlen(METATABLE_PREFIX), InitMethodName, offset);
#endif

    return 1;
}
//</editor-fold>

//<editor-fold desc="fill metatable">

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
 * 给当前table设置父类
 * @param L -1: metatable
 * @param parent 父类的metatable名称
 */
void setParentMetatable(JNIEnv *env, lua_State *L, const char *parent) {
    /// 不考虑返回值，如果是新table，说明父类还未注册，等父类注册时填充
    /// 如果已注册，且是lazy，则通过init_lazy_metatable填充
    u_newmetatable(L, parent);
    ///-1:parent metatable -2 my metatable
    init_lazy_metatable(env, L, parent);
    /// -1:parent metatable -2 my metatable
    if (!lua_rawequal(L, -1, -2))
        lua_setmetatable(L, -2);
    else
        lua_pop(L, 1);
}
/**
 * -1: metatable
 * return void with -1: metatable
 */
static void fillUDMetatable(JNIEnv *env, lua_State *LS, jclass clz, const char *self, const char *parent_mn) {
    /// get metatable.__index
    lua_pushstring(LS, LUA_INDEX);
    lua_rawget(LS, -2);
    /// 未初始化过，创建并设置metatable.__index
    if (!lua_istable(LS, -1)) {
        lua_pop(LS, 1);
        lua_pushvalue(LS, -1);
        lua_pushstring(LS, LUA_INDEX);
        lua_pushvalue(LS, -2);
        /// -1:nt -2:__index -3:nt -4:mt
        /// mt.__index=nt
        lua_rawset(LS, -4);
    }
    /// -1:newtable    -2:metatable
    if (parent_mn) {
        setParentMetatable(env, LS, parent_mn);
    }

    /// -1:newtable    -2:metatable
    /// 设置gc方法
    pushUserdataGcClosure(env, LS, clz);
    /// 设置需要返回bool的方法，比如__eq
    pushUserdataBoolClosure(env, LS, clz);
    /// 设置__tostring
    pushUserdataTostringClosure(env, LS, clz);

    /// 设置空方法
    lua_getglobal(LS, EMPTY_METHOD_TABLE);
    if (lua_istable(LS, -1)) {
        /// -1: empty table -2 nt -3 metatable
        copyTable(LS, -1, -2);
    }
    lua_pop(LS, 1);

    /// -1:newtable    -2:metatable
    traverseAllMethods(clz, traverse_listener, LS);
    lua_pop(LS, 1);
}
//</editor-fold>

//<editor-fold desc="special function">
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
//</editor-fold>

//<editor-fold desc="exe java method">
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
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
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
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    double offset = _get_milli_second(&end) - _get_milli_second(&start);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), n, offset);
#endif
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
//</editor-fold>