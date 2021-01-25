/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by Generator on 2020-10-16
//

#include <jni.h>
#include "lauxlib.h"
#include "cache.h"
#include "statistics.h"
#include "jinfo.h"
#include "jtable.h"
#include "juserdata.h"
#include "m_mem.h"

#define PRE if (!lua_isuserdata(L, 1)) {                            \
        lua_pushstring(L, "use ':' instead of '.' to call method!!");\
        lua_error(L);                                               \
        return 1;                                                   \
    }                                                               \
            JNIEnv *env;                                            \
            getEnv(&env);                                           \
            UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);  \
            jobject jobj = getUserdata(env, L, ud);                 \
            if (!jobj) {                                            \
                lua_pushfstring(L, "get java object from java failed, id: %d", ud->id); \
                lua_error(L);                                       \
                return 1;                                           \
            }

#define REMOVE_TOP(L) while (lua_gettop(L) > 0 && lua_isnil(L, -1)) lua_pop(L, 1);

static inline void push_number(lua_State *L, jdouble num) {
    lua_Integer li1 = (lua_Integer) num;
    if (li1 == num) {
        lua_pushinteger(L, li1);
    } else {
        lua_pushnumber(L, num);
    }
}

static inline void push_string(JNIEnv *env, lua_State *L, jstring s) {
    const char *str = GetString(env, s);
    if (str)
        lua_pushstring(L, str);
    else
        lua_pushnil(L);
    ReleaseChar(env, s, str);
}

static inline void dumpParams(lua_State *L, int from) {
    const int SIZE = 100;
    const int MAX = SIZE - 4;
    char type[SIZE] = {0};
    int top = lua_gettop(L);
    int i;
    int idx = 0;
    for (i = from; i <= top; ++i) {
        const char *n = lua_typename(L, lua_type(L, i));
        size_t len = strlen(n);
        if (len + idx >= MAX) {
            memcpy(type + idx, "...", 3);
            break;
        }
        if (i != from) {
            type[idx ++] = ',';
        }
        memcpy(type + idx, n, len);
        idx += len;
    }
    lua_pushstring(L, type);
}
#ifdef STATISTIC_PERFORMANCE
#include <time.h>
#define _get_milli_second(t) ((t)->tv_sec*1000.0 + (t)->tv_usec / 1000.0)
#endif
#define LUA_CLASS_NAME "__Link"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
//<editor-fold desc="method definition">
static jmethodID link0ID;
static jmethodID link1ID;
static jmethodID link2ID;
static int _link(lua_State *L);
static jmethodID close0ID;
static jmethodID close1ID;
static jmethodID close2ID;
static int _close(lua_State *L);
static jmethodID linkLuaID;
static int _linkLua(lua_State *L);
static jmethodID registerID;
static int _register(lua_State *L);
static jmethodID getParamsID;
static int _getParams(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"link", _link},
            {"close", _close},
            {"linkLua", _linkLua},
            {"register", _register},
            {"getParams", _getParams},
            {NULL, NULL}
    };
    const luaL_Reg *lib = _methohds;
    for (; lib->func; lib++) {
        lua_pushstring(L, lib->name);
        lua_pushcfunction(L, lib->func);
        lua_rawset(L, -3);
    }

    if (parentMeta) {
        JNIEnv *env;
        getEnv(&env);
        setParentMetatable(env, L, parentMeta);
    }
}

static int _execute_new_ud(lua_State *L);
static int _new_java_obj(JNIEnv *env, lua_State *L);
//<editor-fold desc="JNI methods">
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_SIPageLink_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    link0ID = (*env)->GetMethodID(env, clz, "link", "(Ljava/lang/String;Lorg/luaj/vm2/LuaValue;)V");
    link1ID = (*env)->GetMethodID(env, clz, "link", "(Ljava/lang/String;Lorg/luaj/vm2/LuaValue;I)V");
    link2ID = (*env)->GetMethodID(env, clz, "link", "(Ljava/lang/String;Lorg/luaj/vm2/LuaValue;ILorg/luaj/vm2/LuaFunction;)V");
    close0ID = (*env)->GetMethodID(env, clz, "close", "()V");
    close1ID = (*env)->GetMethodID(env, clz, "close", "(I)V");
    close2ID = (*env)->GetMethodID(env, clz, "close", "(ILorg/luaj/vm2/LuaValue;)V");
    linkLuaID = (*env)->GetMethodID(env, clz, "linkLua", "(Ljava/lang/String;Lorg/luaj/vm2/LuaValue;ILorg/luaj/vm2/LuaFunction;)V");
    registerID = (*env)->GetMethodID(env, clz, "register", "(Ljava/lang/String;Ljava/lang/String;)V");
    getParamsID = (*env)->GetMethodID(env, clz, "getParams", "()Lorg/luaj/vm2/LuaValue;");
}
/**
 * java层需要将此ud注册到虚拟机里
 * @param l 虚拟机
 * @param parent 父类，可为空
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1register)
        (JNIEnv *env, jclass o, jlong l, jstring parent) {
    lua_State *L = (lua_State *)l;

    u_newmetatable(L, META_NAME);
    /// get metatable.__index
    lua_pushstring(L, LUA_INDEX);
    lua_rawget(L, -2);
    /// 未初始化过，创建并设置metatable.__index
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_pushvalue(L, -1);
        lua_pushstring(L, LUA_INDEX);
        lua_pushvalue(L, -2);
        /// -1:nt -2:__index -3:nt -4:mt
        /// mt.__index=nt
        lua_rawset(L, -4);
    }
    /// -1:nt -2: metatable
    const char *luaParent = GetString(env, parent);
    if (luaParent) {
        char *parentMeta = getUDMetaname(luaParent);
        fillUDMetatable(L, parentMeta);
#if defined(J_API_INFO)
        m_malloc(parentMeta, (strlen(parentMeta) + 1) * sizeof(char), 0);
#else
        free(parentMeta);
#endif
        ReleaseChar(env, parent, luaParent);
    } else {
        fillUDMetatable(L, NULL);
    }

    jclass clz = _globalClass;

    /// 设置gc方法
    pushUserdataGcClosure(env, L, clz);
    /// 设置需要返回bool的方法，比如__eq
    pushUserdataBoolClosure(env, L, clz);
    /// 设置__tostring
    pushUserdataTostringClosure(env, L, clz);
    lua_pop(L, 2);

    lua_pushcfunction(L, _execute_new_ud);
    lua_setglobal(L, LUA_CLASS_NAME);
}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * void link(java.lang.String,org.luaj.vm2.LuaValue)
 * void link(java.lang.String,org.luaj.vm2.LuaValue,int)
 * void link(java.lang.String,org.luaj.vm2.LuaValue,int,org.luaj.vm2.LuaFunction)
 */
static int _link(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 5) {
        if (lua_type(L, 2) == LUA_TSTRING&&lua_type(L, 4) == LUA_TNUMBER) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            jobject p2 = toJavaValue(env, L, 3);
            lua_Integer p3 = luaL_checkinteger(L, 4);
            jobject p4 = toJavaValue(env, L, 5);
            (*env)->CallVoidMethod(env, jobj, link2ID, p1, p2, (jint)p3, p4);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".link")) {
                FREE(env, p1);
                FREE(env, p2);
                FREE(env, p4);
                return lua_error(L);
            }
            FREE(env, p1);
            FREE(env, p2);
            FREE(env, p4);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "link", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".link函数4个参数有: (String,any,int,LuaFunction)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TSTRING&&lua_type(L, 4) == LUA_TNUMBER) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            jobject p2 = toJavaValue(env, L, 3);
            lua_Integer p3 = luaL_checkinteger(L, 4);
            (*env)->CallVoidMethod(env, jobj, link1ID, p1, p2, (jint)p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".link")) {
                FREE(env, p1);
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p1);
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "link", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".link函数3个参数有: (String,any,int)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TSTRING) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            jobject p2 = toJavaValue(env, L, 3);
            (*env)->CallVoidMethod(env, jobj, link0ID, p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".link")) {
                FREE(env, p1);
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p1);
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "link", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".link函数2个参数有: (String,any)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void close()
 * void close(int)
 * void close(int,org.luaj.vm2.LuaValue)
 */
static int _close(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            jobject p2 = toJavaValue(env, L, 3);
            (*env)->CallVoidMethod(env, jobj, close2ID, (jint)p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".close")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "close", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".close函数2个参数有: (int,any)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    REMOVE_TOP(L)
    if (lua_gettop(L) == 2) {
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            (*env)->CallVoidMethod(env, jobj, close1ID, (jint)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".close")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "close", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".close函数1个参数有: (int)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 1) {
        (*env)->CallVoidMethod(env, jobj, close0ID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".close")) {
            return lua_error(L);
        }
        lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "close", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void linkLua(java.lang.String,org.luaj.vm2.LuaValue,int,org.luaj.vm2.LuaFunction)
 */
static int _linkLua(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    jobject p4 = lua_isnil(L, 5) ? NULL : toJavaValue(env, L, 5);
    (*env)->CallVoidMethod(env, jobj, linkLuaID, p1, p2, (jint)p3, p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".linkLua")) {
        FREE(env, p1);
        FREE(env, p2);
        FREE(env, p4);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    FREE(env, p4);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "linkLua", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void register(java.lang.String,java.lang.String)
 */
static int _register(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jstring p2 = lua_isnil(L, 3) ? NULL : newJString(env, lua_tostring(L, 3));
    (*env)->CallVoidMethod(env, jobj, registerID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".register")) {
        FREE(env, p1);
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "register", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * org.luaj.vm2.LuaValue getParams()
 */
static int _getParams(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject ret = (*env)->CallObjectMethod(env, jobj, getParamsID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getParams")) {
        return lua_error(L);
    }
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getParams", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>

static int _execute_new_ud(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif

    JNIEnv *env;
    int need = getEnv(&env);

    if (_new_java_obj(env, L)) {
        if (need) detachEnv();
        lua_error(L);
        return 1;
    }

    luaL_getmetatable(L, META_NAME);
    lua_setmetatable(L, -2);

    if (need) detachEnv();

#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    double offset = _get_milli_second(&end) - _get_milli_second(&start);
    userdataMethodCall(LUA_CLASS_NAME, InitMethodName, offset);
#endif

    return 1;
}
static int _new_java_obj(JNIEnv *env, lua_State *L) {
    jobject javaObj = NULL;
    javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L);

    char *info = joinstr(LUA_CLASS_NAME, InitMethodName);

    if (catchJavaException(env, L, info)) {
        if (info)
            m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);
        FREE(env, javaObj);
        return 1;
    }
    if (info)
        m_malloc(info, sizeof(char) * (1 + strlen(info)), 0);

    UDjavaobject ud = (UDjavaobject) lua_newuserdata(L, sizeof(javaUserdata));
    ud->id = getUserdataId(env, javaObj);
    if (isStrongUserdata(env, _globalClass)) {
        setUDFlag(ud, JUD_FLAG_STRONG);
        copyUDToGNV(env, L, ud, -1, javaObj);
    }
    FREE(env, javaObj);
    ud->refCount = 0;

    ud->name = lua_pushstring(L, META_NAME);
    lua_pop(L, 1);
    return 0;
}