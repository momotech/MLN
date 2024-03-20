/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by Generator on 2021-03-03
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
        setErrorType(L, lua);                                       \
        lua_error(L);                                               \
        return 1;                                                   \
    }                                                               \
            JNIEnv *env;                                            \
            getEnv(&env);                                           \
            UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);  \
            jobject jobj = getUserdata(env, L, ud);                 \
            if (!jobj) {                                            \
                lua_pushfstring(L, "get java object from java failed, id: %d", ud->id); \
                setErrorType(L, bridge);                            \
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
#define LUA_CLASS_NAME "InteractiveBehavior"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
//<editor-fold desc="method definition">
static jmethodID setMaxID;
static jmethodID getMaxID;
static int _max(lua_State *L);
static jmethodID setOverBoundaryID;
static jmethodID isOverBoundaryID;
static int _overBoundary(lua_State *L);
static jmethodID setEnableID;
static jmethodID isEnableID;
static int _enable(lua_State *L);
static jmethodID setFollowEnableID;
static jmethodID isFollowEnableID;
static int _followEnable(lua_State *L);
static jmethodID touchBlockID;
static int _touchBlock(lua_State *L);
static jmethodID targetViewID;
static int _targetView(lua_State *L);
static jmethodID setDirectionID;
static jmethodID getDirectionID;
static int _direction(lua_State *L);
static jmethodID clearAnimID;
static int _clearAnim(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"max", _max},
            {"overBoundary", _overBoundary},
            {"enable", _enable},
            {"followEnable", _followEnable},
            {"touchBlock", _touchBlock},
            {"targetView", _targetView},
            {"direction", _direction},
            {"clearAnim", _clearAnim},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_anim_InteractiveBehavior_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JI)V");
    setMaxID = (*env)->GetMethodID(env, clz, "setMax", "(D)V");
    getMaxID = (*env)->GetMethodID(env, clz, "getMax", "()D");
    setOverBoundaryID = (*env)->GetMethodID(env, clz, "setOverBoundary", "(Z)V");
    isOverBoundaryID = (*env)->GetMethodID(env, clz, "isOverBoundary", "()Z");
    setEnableID = (*env)->GetMethodID(env, clz, "setEnable", "(Z)V");
    isEnableID = (*env)->GetMethodID(env, clz, "isEnable", "()Z");
    setFollowEnableID = (*env)->GetMethodID(env, clz, "setFollowEnable", "(Z)V");
    isFollowEnableID = (*env)->GetMethodID(env, clz, "isFollowEnable", "()Z");
    touchBlockID = (*env)->GetMethodID(env, clz, "touchBlock", "(J)V");
    targetViewID = (*env)->GetMethodID(env, clz, "targetView", "(Lcom/immomo/mmui/ud/UDView;)V");
    setDirectionID = (*env)->GetMethodID(env, clz, "setDirection", "(I)V");
    getDirectionID = (*env)->GetMethodID(env, clz, "getDirection", "()I");
    clearAnimID = (*env)->GetMethodID(env, clz, "clearAnim", "()V");
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
 * double getMax()
 * void setMax(double)
 */
static int _max(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getMaxID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMax")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMax", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMaxID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMax")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMax", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isOverBoundary()
 * void setOverBoundary(boolean)
 */
static int _overBoundary(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isOverBoundaryID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isOverBoundary")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isOverBoundary", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setOverBoundaryID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setOverBoundary")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setOverBoundary", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isEnable()
 * void setEnable(boolean)
 */
static int _enable(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isEnableID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isEnable")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setEnableID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setEnable")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isFollowEnable()
 * void setFollowEnable(boolean)
 */
static int _followEnable(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isFollowEnableID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isFollowEnable")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isFollowEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setFollowEnableID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFollowEnable")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setFollowEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchBlock(long)
 */
static int _touchBlock(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, touchBlockID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchBlock")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchBlock", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void targetView(com.immomo.mmui.ud.UDView)
 */
static int _targetView(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, targetViewID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".targetView")) {
        FREE(env, p1);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "targetView", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getDirection()
 * void setDirection(int)
 */
static int _direction(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getDirectionID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getDirection")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getDirection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setDirectionID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setDirection")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setDirection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void clearAnim()
 */
static int _clearAnim(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, clearAnimID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".clearAnim")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "clearAnim", _get_milli_second(&end) - _get_milli_second(&start));
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
    lua_Integer p1 = luaL_checkinteger(L, 1);
    javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L, (jint)p1);

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