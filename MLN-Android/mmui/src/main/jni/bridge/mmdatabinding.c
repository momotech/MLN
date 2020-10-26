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

#define PRE JNIEnv *env;                                                        \
            getEnv(&env);                                                       \
            if (!lua_istable(L, 1)) {                                           \
                lua_pushstring(L, "use ':' instead of '.' to call method!!");   \
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
#define LUA_CLASS_NAME "DataBinding"

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID watch0ID;
static jmethodID watch1ID;
static int _watch(lua_State *L);
static jmethodID watchValue0ID;
static jmethodID watchValue1ID;
static int _watchValue(lua_State *L);
static jmethodID watchValueAllID;
static int _watchValueAll(lua_State *L);
static jmethodID updateID;
static int _update(lua_State *L);
static jmethodID getID;
static int _get(lua_State *L);
static jmethodID insertID;
static int _insert(lua_State *L);
static jmethodID removeID;
static int _remove(lua_State *L);
static jmethodID bindListViewID;
static int _bindListView(lua_State *L);
static jmethodID getSectionCountID;
static int _getSectionCount(lua_State *L);
static jmethodID getRowCountID;
static int _getRowCount(lua_State *L);
static jmethodID bindCellID;
static int _bindCell(lua_State *L);
static jmethodID mockID;
static int _mock(lua_State *L);
static jmethodID mockArrayID;
static int _mockArray(lua_State *L);
static jmethodID arraySizeID;
static int _arraySize(lua_State *L);
static jmethodID removeObserverID;
static int _removeObserver(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L) {
    static const luaL_Reg _methohds[] = {
            {"watch", _watch},
            {"watchValue", _watchValue},
            {"watchValueAll", _watchValueAll},
            {"update", _update},
            {"get", _get},
            {"insert", _insert},
            {"remove", _remove},
            {"bindListView", _bindListView},
            {"getSectionCount", _getSectionCount},
            {"getRowCount", _getRowCount},
            {"bindCell", _bindCell},
            {"mock", _mock},
            {"mockArray", _mockArray},
            {"arraySize", _arraySize},
            {"removeObserver", _removeObserver},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_databinding_LTCDataBinding_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    watch0ID = (*env)->GetStaticMethodID(env, clz, "watch", "(JLjava/lang/String;J)Ljava/lang/String;");
    watch1ID = (*env)->GetStaticMethodID(env, clz, "watch", "(JLjava/lang/String;JJ)Ljava/lang/String;");
    watchValue0ID = (*env)->GetStaticMethodID(env, clz, "watchValue", "(JLjava/lang/String;J)Ljava/lang/String;");
    watchValue1ID = (*env)->GetStaticMethodID(env, clz, "watchValue", "(JLjava/lang/String;JJ)Ljava/lang/String;");
    watchValueAllID = (*env)->GetStaticMethodID(env, clz, "watchValueAll", "(JLjava/lang/String;J)Ljava/lang/String;");
    updateID = (*env)->GetStaticMethodID(env, clz, "update", "(JLjava/lang/String;Lorg/luaj/vm2/LuaValue;)V");
    getID = (*env)->GetStaticMethodID(env, clz, "get", "(JLjava/lang/String;)Lorg/luaj/vm2/LuaValue;");
    insertID = (*env)->GetStaticMethodID(env, clz, "insert", "(JLjava/lang/String;ILorg/luaj/vm2/LuaValue;)V");
    removeID = (*env)->GetStaticMethodID(env, clz, "remove", "(JLjava/lang/String;I)V");
    bindListViewID = (*env)->GetStaticMethodID(env, clz, "bindListView", "(JLjava/lang/String;Lcom/immomo/mmui/ud/UDView;)V");
    getSectionCountID = (*env)->GetStaticMethodID(env, clz, "getSectionCount", "(JLjava/lang/String;)I");
    getRowCountID = (*env)->GetStaticMethodID(env, clz, "getRowCount", "(JLjava/lang/String;I)I");
    bindCellID = (*env)->GetStaticMethodID(env, clz, "bindCell", "(JLjava/lang/String;IILorg/luaj/vm2/LuaTable;)V");
    mockID = (*env)->GetStaticMethodID(env, clz, "mock", "(JLjava/lang/String;Lorg/luaj/vm2/LuaTable;)V");
    mockArrayID = (*env)->GetStaticMethodID(env, clz, "mockArray", "(JLjava/lang/String;Lorg/luaj/vm2/LuaTable;Lorg/luaj/vm2/LuaTable;)V");
    arraySizeID = (*env)->GetStaticMethodID(env, clz, "arraySize", "(JLjava/lang/String;)I");
    removeObserverID = (*env)->GetStaticMethodID(env, clz, "removeObserver", "(JLjava/lang/String;)V");
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
 * static java.lang.String watch(long,java.lang.String,long)
 * static java.lang.String watch(long,java.lang.String,long,long)
 */
static int _watch(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TSTRING&&lua_isfunction(L, 3)&&lua_isfunction(L, 4)) {
            jlong p1 = (jlong) L;
            jstring p2 = newJString(env, lua_tostring(L, 2));
            luaL_checktype(L, 3, LUA_TFUNCTION);
            jlong p3 = (jlong) copyValueToGNV(L, 3);
            luaL_checktype(L, 4, LUA_TFUNCTION);
            jlong p4 = (jlong) copyValueToGNV(L, 4);
            jstring ret = (*env)->CallStaticObjectMethod(env, _globalClass, watch1ID, p1, p2, p3, p4);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".watch")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            pushJavaString(env, L, ret);
            FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            staticMethodCall(LUA_CLASS_NAME, "watch", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".watch函数3个参数有: (String,function,function)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TSTRING&&lua_isfunction(L, 3)) {
            jlong p1 = (jlong) L;
            jstring p2 = newJString(env, lua_tostring(L, 2));
            luaL_checktype(L, 3, LUA_TFUNCTION);
            jlong p3 = (jlong) copyValueToGNV(L, 3);
            jstring ret = (*env)->CallStaticObjectMethod(env, _globalClass, watch0ID, p1, p2, p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".watch")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            pushJavaString(env, L, ret);
            FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            staticMethodCall(LUA_CLASS_NAME, "watch", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".watch函数2个参数有: (String,function)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * static java.lang.String watchValue(long,java.lang.String,long)
 * static java.lang.String watchValue(long,java.lang.String,long,long)
 */
static int _watchValue(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TSTRING&&lua_isfunction(L, 3)&&lua_isfunction(L, 4)) {
            jlong p1 = (jlong) L;
            jstring p2 = newJString(env, lua_tostring(L, 2));
            luaL_checktype(L, 3, LUA_TFUNCTION);
            jlong p3 = (jlong) copyValueToGNV(L, 3);
            luaL_checktype(L, 4, LUA_TFUNCTION);
            jlong p4 = (jlong) copyValueToGNV(L, 4);
            jstring ret = (*env)->CallStaticObjectMethod(env, _globalClass, watchValue1ID, p1, p2, p3, p4);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".watchValue")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            pushJavaString(env, L, ret);
            FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            staticMethodCall(LUA_CLASS_NAME, "watchValue", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".watchValue函数3个参数有: (String,function,function)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TSTRING&&lua_isfunction(L, 3)) {
            jlong p1 = (jlong) L;
            jstring p2 = newJString(env, lua_tostring(L, 2));
            luaL_checktype(L, 3, LUA_TFUNCTION);
            jlong p3 = (jlong) copyValueToGNV(L, 3);
            jstring ret = (*env)->CallStaticObjectMethod(env, _globalClass, watchValue0ID, p1, p2, p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".watchValue")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            pushJavaString(env, L, ret);
            FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            staticMethodCall(LUA_CLASS_NAME, "watchValue", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".watchValue函数2个参数有: (String,function)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * static java.lang.String watchValueAll(long,java.lang.String,long)
 */
static int _watchValueAll(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    luaL_checktype(L, 3, LUA_TFUNCTION);
    jlong p3 = (jlong) copyValueToGNV(L, 3);
    jstring ret = (*env)->CallStaticObjectMethod(env, _globalClass, watchValueAllID, p1, p2, p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".watchValueAll")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    pushJavaString(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "watchValueAll", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static void update(long,java.lang.String,org.luaj.vm2.LuaValue)
 */
static int _update(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p3 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    (*env)->CallStaticVoidMethod(env, _globalClass, updateID, p1, p2, p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".update")) {
        FREE(env, p2);
        FREE(env, p3);
        return lua_error(L);
    }
    FREE(env, p2);
    FREE(env, p3);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "update", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static org.luaj.vm2.LuaValue get(long,java.lang.String)
 */
static int _get(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject ret = (*env)->CallStaticObjectMethod(env, _globalClass, getID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".get")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "get", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static void insert(long,java.lang.String,int,org.luaj.vm2.LuaValue)
 */
static int _insert(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Integer p3 = luaL_checkinteger(L, 3);
    jobject p4 = lua_isnil(L, 4) ? NULL : toJavaValue(env, L, 4);
    (*env)->CallStaticVoidMethod(env, _globalClass, insertID, p1, p2, (jint)p3, p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".insert")) {
        FREE(env, p2);
        FREE(env, p4);
        return lua_error(L);
    }
    FREE(env, p2);
    FREE(env, p4);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "insert", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static void remove(long,java.lang.String,int)
 */
static int _remove(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Integer p3 = luaL_checkinteger(L, 3);
    (*env)->CallStaticVoidMethod(env, _globalClass, removeID, p1, p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".remove")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "remove", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static void bindListView(long,java.lang.String,com.immomo.mmui.ud.UDView)
 */
static int _bindListView(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p3 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    (*env)->CallStaticVoidMethod(env, _globalClass, bindListViewID, p1, p2, p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".bindListView")) {
        FREE(env, p2);
        FREE(env, p3);
        return lua_error(L);
    }
    FREE(env, p2);
    FREE(env, p3);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "bindListView", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static int getSectionCount(long,java.lang.String)
 */
static int _getSectionCount(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jint ret = (*env)->CallStaticIntMethod(env, _globalClass, getSectionCountID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getSectionCount")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "getSectionCount", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static int getRowCount(long,java.lang.String,int)
 */
static int _getRowCount(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Integer p3 = luaL_checkinteger(L, 3);
    jint ret = (*env)->CallStaticIntMethod(env, _globalClass, getRowCountID, p1, p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getRowCount")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "getRowCount", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static void bindCell(long,java.lang.String,int,int,org.luaj.vm2.LuaTable)
 */
static int _bindCell(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    lua_Integer p3 = luaL_checkinteger(L, 3);
    lua_Integer p4 = luaL_checkinteger(L, 4);
    jobject p5 = lua_isnil(L, 5) ? NULL : toJavaValue(env, L, 5);
    (*env)->CallStaticVoidMethod(env, _globalClass, bindCellID, p1, p2, (jint)p3, (jint)p4, p5);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".bindCell")) {
        FREE(env, p2);
        FREE(env, p5);
        return lua_error(L);
    }
    FREE(env, p2);
    FREE(env, p5);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "bindCell", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static void mock(long,java.lang.String,org.luaj.vm2.LuaTable)
 */
static int _mock(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p3 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    (*env)->CallStaticVoidMethod(env, _globalClass, mockID, p1, p2, p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".mock")) {
        FREE(env, p2);
        FREE(env, p3);
        return lua_error(L);
    }
    FREE(env, p2);
    FREE(env, p3);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "mock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static void mockArray(long,java.lang.String,org.luaj.vm2.LuaTable,org.luaj.vm2.LuaTable)
 */
static int _mockArray(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jobject p3 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    jobject p4 = lua_isnil(L, 4) ? NULL : toJavaValue(env, L, 4);
    (*env)->CallStaticVoidMethod(env, _globalClass, mockArrayID, p1, p2, p3, p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".mockArray")) {
        FREE(env, p2);
        FREE(env, p3);
        FREE(env, p4);
        return lua_error(L);
    }
    FREE(env, p2);
    FREE(env, p3);
    FREE(env, p4);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "mockArray", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static int arraySize(long,java.lang.String)
 */
static int _arraySize(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jint ret = (*env)->CallStaticIntMethod(env, _globalClass, arraySizeID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".arraySize")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "arraySize", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * static void removeObserver(long,java.lang.String)
 */
static int _removeObserver(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jlong p1 = (jlong) L;
    jstring p2 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallStaticVoidMethod(env, _globalClass, removeObserverID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeObserver")) {
        FREE(env, p2);
        return lua_error(L);
    }
    FREE(env, p2);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    staticMethodCall(LUA_CLASS_NAME, "removeObserver", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>
