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
#define LUA_CLASS_NAME "Color"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
static jmethodID _constructor1;
static jmethodID _constructor2;
//<editor-fold desc="method definition">
static jmethodID getHexID;
static jmethodID setHexID;
static int _hex(lua_State *L);
static jmethodID getAlphaID;
static jmethodID setAlphaID;
static int _alpha(lua_State *L);
static jmethodID getRedID;
static jmethodID setRedID;
static int _red(lua_State *L);
static jmethodID getGreenID;
static jmethodID setGreenID;
static int _green(lua_State *L);
static jmethodID getBlueID;
static jmethodID setBlueID;
static int _blue(lua_State *L);
static jmethodID setHexAID;
static int _setHexA(lua_State *L);
static jmethodID setRGBAID;
static int _setRGBA(lua_State *L);
static jmethodID clearID;
static int _clear(lua_State *L);
static jmethodID setAColorID;
static int _setAColor(lua_State *L);
static jmethodID setColorID;
static int _setColor(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"hex", _hex},
            {"alpha", _alpha},
            {"red", _red},
            {"green", _green},
            {"blue", _blue},
            {"setHexA", _setHexA},
            {"setRGBA", _setRGBA},
            {"clear", _clear},
            {"setAColor", _setAColor},
            {"setColor", _setColor},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_UDColor_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JIIIF)V");
    _constructor1 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JIII)V");
    _constructor2 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    getHexID = (*env)->GetMethodID(env, clz, "getHex", "()I");
    setHexID = (*env)->GetMethodID(env, clz, "setHex", "(I)V");
    getAlphaID = (*env)->GetMethodID(env, clz, "getAlpha", "()F");
    setAlphaID = (*env)->GetMethodID(env, clz, "setAlpha", "(F)V");
    getRedID = (*env)->GetMethodID(env, clz, "getRed", "()I");
    setRedID = (*env)->GetMethodID(env, clz, "setRed", "(I)V");
    getGreenID = (*env)->GetMethodID(env, clz, "getGreen", "()I");
    setGreenID = (*env)->GetMethodID(env, clz, "setGreen", "(I)V");
    getBlueID = (*env)->GetMethodID(env, clz, "getBlue", "()I");
    setBlueID = (*env)->GetMethodID(env, clz, "setBlue", "(I)V");
    setHexAID = (*env)->GetMethodID(env, clz, "setHexA", "(IF)V");
    setRGBAID = (*env)->GetMethodID(env, clz, "setRGBA", "(IIIF)V");
    clearID = (*env)->GetMethodID(env, clz, "clear", "()V");
    setAColorID = (*env)->GetMethodID(env, clz, "setAColor", "(Ljava/lang/String;)V");
    setColorID = (*env)->GetMethodID(env, clz, "setColor", "(Ljava/lang/String;)V");
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
 * int getHex()
 * void setHex(int)
 */
static int _hex(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getHexID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getHex")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getHex", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setHexID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setHex")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setHex", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getAlpha()
 * void setAlpha(float)
 */
static int _alpha(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getAlphaID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getAlpha")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getAlpha", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setAlphaID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setAlpha")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setAlpha", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getRed()
 * void setRed(int)
 */
static int _red(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getRedID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getRed")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getRed", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setRedID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setRed")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setRed", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getGreen()
 * void setGreen(int)
 */
static int _green(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getGreenID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getGreen")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getGreen", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setGreenID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setGreen")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setGreen", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getBlue()
 * void setBlue(int)
 */
static int _blue(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getBlueID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getBlue")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getBlue", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setBlueID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBlue")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBlue", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setHexA(int,float)
 */
static int _setHexA(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    (*env)->CallVoidMethod(env, jobj, setHexAID, (jint)p1, (jfloat)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setHexA")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setHexA", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setRGBA(int,int,int,float)
 */
static int _setRGBA(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    lua_Number p4 = luaL_checknumber(L, 5);
    (*env)->CallVoidMethod(env, jobj, setRGBAID, (jint)p1, (jint)p2, (jint)p3, (jfloat)p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setRGBA")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setRGBA", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void clear()
 */
static int _clear(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, clearID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".clear")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "clear", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setAColor(java.lang.String)
 */
static int _setAColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallVoidMethod(env, jobj, setAColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setAColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setAColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setColor(java.lang.String)
 */
static int _setColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallVoidMethod(env, jobj, setColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setColor", _get_milli_second(&end) - _get_milli_second(&start));
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
    if (pc == 4) {
        lua_Integer p1 = luaL_checkinteger(L, 1);
        lua_Integer p2 = luaL_checkinteger(L, 2);
        lua_Integer p3 = luaL_checkinteger(L, 3);
        lua_Number p4 = luaL_checknumber(L, 4);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L, (jint)p1, (jint)p2, (jint)p3, (jfloat)p4);
    } else if (pc == 3) {
        lua_Integer p1 = luaL_checkinteger(L, 1);
        lua_Integer p2 = luaL_checkinteger(L, 2);
        lua_Integer p3 = luaL_checkinteger(L, 3);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor1, (jlong) L, (jint)p1, (jint)p2, (jint)p3);
    } else if (pc == 0) {
        javaObj = (*env)->NewObject(env, _globalClass, _constructor2, (jlong) L);
    } else {
        lua_pushstring(L, LUA_CLASS_NAME "构造函数有: Color(int,int,int,float);Color(int,int,int);Color()，当前参数个数不支持任意一种");
        return lua_error(L);
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