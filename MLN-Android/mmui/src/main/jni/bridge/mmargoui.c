//
// Created by Generator on 2021-03-03
//

#include <jni.h>
#include "lauxlib.h"
#include "cache.h"
#include "statistics.h"
#include "jinfo.h"
#include "jtable.h"

#define PRE JNIEnv *env;                                                        \
            getEnv(&env);                                                       \
            if (!lua_istable(L, 1)) {                                           \
                lua_pushstring(L, "use ':' instead of '.' to call method!!");   \
                setErrorType(L, lua);                                           \
                return lua_error(L);                                            \
            }

#define REMOVE_TOP(L) while (lua_gettop(L) > 0 && lua_isnil(L, -1)) lua_pop(L, 1);


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
#define LUA_CLASS_NAME "ArgoUI"

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID attachUIPageID;
static int _attachUIPage(lua_State *L);
static jmethodID dettachUIPageID;
static int _dettachUIPage(lua_State *L);
static jmethodID mapToTableID;
static int _mapToTable(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L) {
    static const luaL_Reg _methohds[] = {
            {"attachUIPage", _attachUIPage},
            {"dettachUIPage", _dettachUIPage},
            {"mapToTable", _mapToTable},
            {NULL, NULL}
    };
    const luaL_Reg *lib = _methohds;
    for (; lib->func; lib++) {
        lua_pushstring(L, lib->name);
        lua_pushcfunction(L, lib->func);
        lua_rawset(L, -3);
    }
}
//<editor-fold desc="JNI methods">
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_sbridge_ArgoUI_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    attachUIPageID = (*env)->GetStaticMethodID(env, clz, "attachUIPage", "(JLorg/luaj/vm2/LuaValue;Ljava/lang/String;)Z");
    dettachUIPageID = (*env)->GetStaticMethodID(env, clz, "dettachUIPage", "(JLjava/lang/String;)V");
    mapToTableID = (*env)->GetStaticMethodID(env, clz, "mapToTable", "(JLcom/immomo/mls/fun/ud/UDMap;)J");
}
/**
 * java层需要将此ud注册到虚拟机里
 * @param l 虚拟机
 * @param parent 父类，可为空
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1register)
        (JNIEnv *env, jclass o, jlong l, jstring parent) {
    lua_State *L = (lua_State *)l;

    lua_getglobal(L, LUA_CLASS_NAME);
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
    }
    /// -1:table
    const char *luaParent = GetString(env, parent);
    if (luaParent) {
        lua_getglobal(L, luaParent);
        if (!lua_istable(L, -1)) {
            lua_pop(L, 1);
            lua_newtable(L);
            lua_pushvalue(L, -1);
            lua_setglobal(L, luaParent);
        }
        /// -1:parent -2:mytable
        setParentTable(L, -2, -1);
        lua_pop(L, 1);
        ReleaseChar(env, parent, luaParent);
    }
    /// -1:table
    fillUDMetatable(L);
    lua_setglobal(L, LUA_CLASS_NAME);
}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * static boolean attachUIPage(long,org.luaj.vm2.LuaValue,java.lang.String)
 */
static int _attachUIPage(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jobject p2 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    jstring p3 = lua_isnil(L, 3) ? NULL : newJString(env, lua_tostring(L, 3));
    jboolean ret = (*env)->CallStaticBooleanMethod(env, _globalClass, attachUIPageID, p1, p2, p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".attachUIPage")) {
        FREE(env, p2);
        FREE(env, p3);
        return lua_error(L);
    }
    FREE(env, p2);
    FREE(env, p3);
    lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "attachUIPage", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static void dettachUIPage(long,java.lang.String)
 */
static int _dettachUIPage(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallStaticVoidMethod(env, _globalClass, dettachUIPageID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".dettachUIPage")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "dettachUIPage", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static long mapToTable(long,com.immomo.mls.fun.ud.UDMap)
 */
static int _mapToTable(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jobject p2 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    jlong ret = (*env)->CallStaticLongMethod(env, _globalClass, mapToTableID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".mapToTable")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    getValueFromGNV(L, (ptrdiff_t) ret, LUA_TTABLE);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "mapToTable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>
