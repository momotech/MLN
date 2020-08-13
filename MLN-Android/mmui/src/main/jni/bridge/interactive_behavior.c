/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by Generator on 2020-08-11
//

#include <jni.h>
#include "lauxlib.h"
#include "cache.h"
#include "jinfo.h"
#include "juserdata.h"
#include "m_mem.h"

#define PRE JNIEnv *env;                                            \
            getEnv(&env);                                           \
            UDjavaobject ud = (UDjavaobject) lua_touserdata(L, 1);  \
            jobject jobj = getUserdata(env, L, ud);                 \
            if (!jobj) {                                            \
                lua_pushfstring(L, "get java object from java failed, id: %d", ud->id); \
                lua_error(L);                                       \
                return 1;                                           \
            }


#ifdef STATISTIC_PERFORMANCE
#include <time.h>
#define _get_milli_second(t) ((t)->tv_sec*1000.0 + (t)->tv_usec / 1000.0)
#endif
#define LUA_CLASS_NAME "InteractiveBehavior"

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID setDirectionID;
static jmethodID getDirectionID;
static int _direction(lua_State *L);
static jmethodID setEndDistanceID;
static jmethodID getEndDistanceID;
static int _endDistance(lua_State *L);
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
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L) {
    static const luaL_Reg _methohds[] = {
            {"direction", _direction},
            {"endDistance", _endDistance},
            {"overBoundary", _overBoundary},
            {"enable", _enable},
            {"followEnable", _followEnable},
            {"touchBlock", _touchBlock},
            {"targetView", _targetView},
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
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL Java_com_immomo_mmui_ud_anim_InteractiveBehavior__1init
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    setDirectionID = (*env)->GetMethodID(env, clz, "setDirection", "(I)V");
    getDirectionID = (*env)->GetMethodID(env, clz, "getDirection", "()I");
    setEndDistanceID = (*env)->GetMethodID(env, clz, "setEndDistance", "(D)V");
    getEndDistanceID = (*env)->GetMethodID(env, clz, "getEndDistance", "()D");
    setOverBoundaryID = (*env)->GetMethodID(env, clz, "setOverBoundary", "(Z)V");
    isOverBoundaryID = (*env)->GetMethodID(env, clz, "isOverBoundary", "()Z");
    setEnableID = (*env)->GetMethodID(env, clz, "setEnable", "(Z)V");
    isEnableID = (*env)->GetMethodID(env, clz, "isEnable", "()Z");
    setFollowEnableID = (*env)->GetMethodID(env, clz, "setFollowEnable", "(Z)V");
    isFollowEnableID = (*env)->GetMethodID(env, clz, "isFollowEnable", "()Z");
    touchBlockID = (*env)->GetMethodID(env, clz, "touchBlock", "(J)V");
    targetViewID = (*env)->GetMethodID(env, clz, "targetView", "(Lcom/immomo/mmui/ud/UDView;)V");
}
/**
 * java层需要将此ud注册到虚拟机里
 * @param l 虚拟机
 */
JNIEXPORT void JNICALL Java_com_immomo_mmui_ud_anim_InteractiveBehavior__1register
        (JNIEnv *env, jclass o, jlong l) {
    lua_State *L = (lua_State *)l;

    char *metaname = getUDMetaname(LUA_CLASS_NAME);
    luaL_newmetatable(L, metaname);
    SET_METATABLE(L);
    /// -1: metatable
    fillUDMetatable(L);

    jclass clz = _globalClass;

    /// 设置gc方法
    pushUserdataGcClosure(env, L, clz);
    /// 设置需要返回bool的方法，比如__eq
    pushUserdataBoolClosure(env, L, clz);
    /// 设置__tostring
    pushUserdataTostringClosure(env, L, clz);
    lua_pop(L, 1);

    pushConstructorMethod(L, clz, getConstructor(env, clz), metaname);
    lua_setglobal(L, LUA_CLASS_NAME);

#if defined(J_API_INFO)
    m_malloc(metaname, (strlen(metaname) + 1) * sizeof(char), 0);
#else
    free(metaname);
#endif
}
//</editor-fold>
//<editor-fold desc="lua method implementation">
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
    if (lua_isnil(L, 2)) {
        jint ret = (*env)->CallIntMethod(env, jobj, getDirectionID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getDirection")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "getDirection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setDirectionID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setDirection")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "setDirection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getEndDistance()
 * void setEndDistance(double)
 */
static int _endDistance(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_isnil(L, 2)) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getEndDistanceID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getEndDistance")) {
            return lua_error(L);
        }
        lua_pushnumber(L, (lua_Number) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "getEndDistance", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setEndDistanceID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setEndDistance")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "setEndDistance", _get_milli_second(&end) - _get_milli_second(&start));
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
    if (lua_isnil(L, 2)) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isOverBoundaryID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isOverBoundary")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "isOverBoundary", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setOverBoundaryID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setOverBoundary")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "setOverBoundary", _get_milli_second(&end) - _get_milli_second(&start));
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
    if (lua_isnil(L, 2)) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isEnableID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isEnable")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "isEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setEnableID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setEnable")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "setEnable", _get_milli_second(&end) - _get_milli_second(&start));
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
    if (lua_isnil(L, 2)) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isFollowEnableID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isFollowEnable")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "isFollowEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setFollowEnableID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setFollowEnable")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "setFollowEnable", _get_milli_second(&end) - _get_milli_second(&start));
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
    jlong p1 = lua_isfunction(L, 2) ? (jlong) copyValueToGNV(L, 2) : 0;
    (*env)->CallVoidMethod(env, jobj, touchBlockID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchBlock")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "touchBlock", _get_milli_second(&end) - _get_milli_second(&start));
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
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(LUA_CLASS_NAME, "targetView", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>
