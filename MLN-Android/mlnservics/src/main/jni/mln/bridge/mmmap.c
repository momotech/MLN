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
#define LUA_CLASS_NAME "Map"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
static jmethodID _constructor1;
//<editor-fold desc="method definition">
static jmethodID put0ID;
static jmethodID put1ID;
static jmethodID put2ID;
static jmethodID put3ID;
static jmethodID put4ID;
static jmethodID put5ID;
static jmethodID put6ID;
static jmethodID put7ID;
static jmethodID put8ID;
static int _put(lua_State *L);
static jmethodID putAllID;
static int _putAll(lua_State *L);
static jmethodID remove0ID;
static jmethodID remove1ID;
static jmethodID remove2ID;
static int _remove(lua_State *L);
static jmethodID removeAllID;
static int _removeAll(lua_State *L);
static jmethodID get0ID;
static jmethodID get1ID;
static jmethodID get2ID;
static int _get(lua_State *L);
static jmethodID sizeID;
static int _size(lua_State *L);
static jmethodID allKeysID;
static int _allKeys(lua_State *L);
static jmethodID removeObjectsID;
static int _removeObjects(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"put", _put},
            {"putAll", _putAll},
            {"remove", _remove},
            {"removeAll", _removeAll},
            {"get", _get},
            {"size", _size},
            {"allKeys", _allKeys},
            {"removeObjects", _removeObjects},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mls_fun_ud_UDMap_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JI)V");
    _constructor1 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    put0ID = (*env)->GetMethodID(env, clz, "put", "(Ljava/lang/String;Z)V");
    put1ID = (*env)->GetMethodID(env, clz, "put", "(Ljava/lang/String;D)V");
    put2ID = (*env)->GetMethodID(env, clz, "put", "(Ljava/lang/String;Ljava/lang/String;)V");
    put3ID = (*env)->GetMethodID(env, clz, "put", "(Ljava/lang/String;Lorg/luaj/vm2/LuaValue;)V");
    put4ID = (*env)->GetMethodID(env, clz, "put", "(DZ)V");
    put5ID = (*env)->GetMethodID(env, clz, "put", "(DD)V");
    put6ID = (*env)->GetMethodID(env, clz, "put", "(DLjava/lang/String;)V");
    put7ID = (*env)->GetMethodID(env, clz, "put", "(DLorg/luaj/vm2/LuaValue;)V");
    put8ID = (*env)->GetMethodID(env, clz, "put", "(Lorg/luaj/vm2/LuaValue;Lorg/luaj/vm2/LuaValue;)V");
    putAllID = (*env)->GetMethodID(env, clz, "putAll", "(Lcom/immomo/mls/fun/ud/UDMap;)V");
    remove0ID = (*env)->GetMethodID(env, clz, "remove", "(Ljava/lang/String;)V");
    remove1ID = (*env)->GetMethodID(env, clz, "remove", "(D)V");
    remove2ID = (*env)->GetMethodID(env, clz, "remove", "(Lorg/luaj/vm2/LuaValue;)V");
    removeAllID = (*env)->GetMethodID(env, clz, "removeAll", "()V");
    get0ID = (*env)->GetMethodID(env, clz, "get", "(Ljava/lang/String;)Lorg/luaj/vm2/LuaValue;");
    get1ID = (*env)->GetMethodID(env, clz, "get", "(D)Lorg/luaj/vm2/LuaValue;");
    get2ID = (*env)->GetMethodID(env, clz, "get", "(Lorg/luaj/vm2/LuaValue;)Lorg/luaj/vm2/LuaValue;");
    sizeID = (*env)->GetMethodID(env, clz, "size", "()I");
    allKeysID = (*env)->GetMethodID(env, clz, "allKeys", "()Lcom/immomo/mls/fun/ud/UDArray;");
    removeObjectsID = (*env)->GetMethodID(env, clz, "removeObjects", "(Lcom/immomo/mls/fun/ud/UDArray;)V");
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
 * void put(java.lang.String,boolean)
 * void put(java.lang.String,double)
 * void put(java.lang.String,java.lang.String)
 * void put(java.lang.String,org.luaj.vm2.LuaValue)
 * void put(double,boolean)
 * void put(double,double)
 * void put(double,java.lang.String)
 * void put(double,org.luaj.vm2.LuaValue)
 * void put(org.luaj.vm2.LuaValue,org.luaj.vm2.LuaValue)
 */
static int _put(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_isboolean(L, 3)) {
            lua_Number p1 = luaL_checknumber(L, 2);
            int p2 = lua_toboolean(L, 3);
            (*env)->CallVoidMethod(env, jobj, put4ID, (jdouble)p1, (jboolean)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".put")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "put", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            (*env)->CallVoidMethod(env, jobj, put5ID, (jdouble)p1, (jdouble)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".put")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "put", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TSTRING) {
            lua_Number p1 = luaL_checknumber(L, 2);
            jstring p2 = newJString(env, lua_tostring(L, 3));
            (*env)->CallVoidMethod(env, jobj, put6ID, (jdouble)p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".put")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "put", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            jobject p2 = toJavaValue(env, L, 3);
            (*env)->CallVoidMethod(env, jobj, put7ID, (jdouble)p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".put")) {
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "put", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TSTRING&&lua_isboolean(L, 3)) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            int p2 = lua_toboolean(L, 3);
            (*env)->CallVoidMethod(env, jobj, put0ID, p1, (jboolean)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".put")) {
                FREE(env, p1);
                return lua_error(L);
            }
            FREE(env, p1);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "put", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TSTRING&&lua_type(L, 3) == LUA_TNUMBER) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            lua_Number p2 = luaL_checknumber(L, 3);
            (*env)->CallVoidMethod(env, jobj, put1ID, p1, (jdouble)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".put")) {
                FREE(env, p1);
                return lua_error(L);
            }
            FREE(env, p1);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "put", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TSTRING&&lua_type(L, 3) == LUA_TSTRING) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            jstring p2 = newJString(env, lua_tostring(L, 3));
            (*env)->CallVoidMethod(env, jobj, put2ID, p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".put")) {
                FREE(env, p1);
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p1);
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "put", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TSTRING) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            jobject p2 = toJavaValue(env, L, 3);
            (*env)->CallVoidMethod(env, jobj, put3ID, p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".put")) {
                FREE(env, p1);
                FREE(env, p2);
                return lua_error(L);
            }
            FREE(env, p1);
            FREE(env, p2);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "put", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        jobject p1 = toJavaValue(env, L, 2);
        jobject p2 = toJavaValue(env, L, 3);
        (*env)->CallVoidMethod(env, jobj, put8ID, p1, p2);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".put")) {
            FREE(env, p1);
            FREE(env, p2);
            return lua_error(L);
        }
        FREE(env, p1);
        FREE(env, p2);
        lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "put", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void putAll(com.immomo.mls.fun.ud.UDMap)
 */
static int _putAll(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, putAllID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".putAll")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "putAll", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void remove(java.lang.String)
 * void remove(double)
 * void remove(org.luaj.vm2.LuaValue)
 */
static int _remove(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 2) {
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            (*env)->CallVoidMethod(env, jobj, remove1ID, (jdouble)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".remove")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "remove", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TSTRING) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            (*env)->CallVoidMethod(env, jobj, remove0ID, p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".remove")) {
                FREE(env, p1);
                return lua_error(L);
            }
            FREE(env, p1);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "remove", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        jobject p1 = toJavaValue(env, L, 2);
        (*env)->CallVoidMethod(env, jobj, remove2ID, p1);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".remove")) {
            FREE(env, p1);
            return lua_error(L);
        }
        FREE(env, p1);
        lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "remove", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * void removeAll()
 */
static int _removeAll(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, removeAllID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeAll")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeAll", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * org.luaj.vm2.LuaValue get(java.lang.String)
 * org.luaj.vm2.LuaValue get(double)
 * org.luaj.vm2.LuaValue get(org.luaj.vm2.LuaValue)
 */
static int _get(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 2) {
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            jobject ret = (*env)->CallObjectMethod(env, jobj, get1ID, (jdouble)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".get")) {
                return lua_error(L);
            }
            pushJavaValue(env, L, ret);
            FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "get", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        if (lua_type(L, 2) == LUA_TSTRING) {
            jstring p1 = newJString(env, lua_tostring(L, 2));
            jobject ret = (*env)->CallObjectMethod(env, jobj, get0ID, p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".get")) {
                FREE(env, p1);
                return lua_error(L);
            }
            FREE(env, p1);
            pushJavaValue(env, L, ret);
            FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "get", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        jobject p1 = toJavaValue(env, L, 2);
        jobject ret = (*env)->CallObjectMethod(env, jobj, get2ID, p1);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".get")) {
            FREE(env, p1);
            return lua_error(L);
        }
        FREE(env, p1);
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "get", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * int size()
 */
static int _size(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jint ret = (*env)->CallIntMethod(env, jobj, sizeID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".size")) {
        return lua_error(L);
    }
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "size", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mls.fun.ud.UDArray allKeys()
 */
static int _allKeys(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject ret = (*env)->CallObjectMethod(env, jobj, allKeysID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".allKeys")) {
        return lua_error(L);
    }
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "allKeys", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void removeObjects(com.immomo.mls.fun.ud.UDArray)
 */
static int _removeObjects(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, removeObjectsID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeObjects")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeObjects", _get_milli_second(&end) - _get_milli_second(&start));
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
    int pc = lua_gettop(L);
    jobject javaObj = NULL;
    if (pc == 1) {
        lua_Integer p1 = luaL_checkinteger(L, 1);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L, (jint)p1);
    } else {
        javaObj = (*env)->NewObject(env, _globalClass, _constructor1, (jlong) L);
    }
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