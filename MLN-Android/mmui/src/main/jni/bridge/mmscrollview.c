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
#define LUA_CLASS_NAME "ScrollView"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
static jmethodID _constructor1;
static jmethodID _constructor2;
//<editor-fold desc="method definition">
static jmethodID getContentSizeID;
static jmethodID setContentSizeID;
static int _contentSize(lua_State *L);
static jmethodID getContentOffsetID;
static jmethodID setContentOffsetID;
static int _contentOffset(lua_State *L);
static jmethodID isScrollEnabledID;
static jmethodID setScrollEnabledID;
static int _scrollEnabled(lua_State *L);
static jmethodID isShowsHorizontalScrollIndicatorID;
static jmethodID setShowsHorizontalScrollIndicatorID;
static int _showsHorizontalScrollIndicator(lua_State *L);
static jmethodID isShowsVerticalScrollIndicatorID;
static jmethodID setShowsVerticalScrollIndicatorID;
static int _showsVerticalScrollIndicator(lua_State *L);
static jmethodID setScrollEnableID;
static int _setScrollEnable(lua_State *L);
static jmethodID i_bouncesID;
static int _i_bounces(lua_State *L);
static jmethodID i_bounceHorizontalID;
static int _i_bounceHorizontal(lua_State *L);
static jmethodID i_bounceVerticalID;
static int _i_bounceVertical(lua_State *L);
static jmethodID i_pagingEnabledID;
static int _i_pagingEnabled(lua_State *L);
static jmethodID setScrollBeginCallbackID;
static int _setScrollBeginCallback(lua_State *L);
static jmethodID setScrollingCallbackID;
static int _setScrollingCallback(lua_State *L);
static jmethodID setScrollEndCallbackID;
static int _setScrollEndCallback(lua_State *L);
static jmethodID setContentInsetID;
static int _setContentInset(lua_State *L);
static jmethodID setOffsetWithAnimID;
static int _setOffsetWithAnim(lua_State *L);
static jmethodID setEndDraggingCallbackID;
static int _setEndDraggingCallback(lua_State *L);
static jmethodID touchBeginID;
static int _touchBegin(lua_State *L);
static jmethodID setStartDeceleratingCallbackID;
static int _setStartDeceleratingCallback(lua_State *L);
static jmethodID getContentInsetID;
static int _getContentInset(lua_State *L);
static jmethodID addViewID;
static int _addView(lua_State *L);
static jmethodID insertViewID;
static int _insertView(lua_State *L);
static jmethodID removeAllSubviewsID;
static int _removeAllSubviews(lua_State *L);
static jmethodID a_flingSpeedID;
static int _a_flingSpeed(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"contentSize", _contentSize},
            {"contentOffset", _contentOffset},
            {"scrollEnabled", _scrollEnabled},
            {"showsHorizontalScrollIndicator", _showsHorizontalScrollIndicator},
            {"showsVerticalScrollIndicator", _showsVerticalScrollIndicator},
            {"setScrollEnable", _setScrollEnable},
            {"i_bounces", _i_bounces},
            {"i_bounceHorizontal", _i_bounceHorizontal},
            {"i_bounceVertical", _i_bounceVertical},
            {"i_pagingEnabled", _i_pagingEnabled},
            {"setScrollBeginCallback", _setScrollBeginCallback},
            {"setScrollingCallback", _setScrollingCallback},
            {"setScrollEndCallback", _setScrollEndCallback},
            {"setContentInset", _setContentInset},
            {"setOffsetWithAnim", _setOffsetWithAnim},
            {"setEndDraggingCallback", _setEndDraggingCallback},
            {"touchBegin", _touchBegin},
            {"setStartDeceleratingCallback", _setStartDeceleratingCallback},
            {"getContentInset", _getContentInset},
            {"addView", _addView},
            {"insertView", _insertView},
            {"removeAllSubviews", _removeAllSubviews},
            {"a_flingSpeed", _a_flingSpeed},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_UDScrollView_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JZZ)V");
    _constructor1 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(JZ)V");
    _constructor2 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    getContentSizeID = (*env)->GetMethodID(env, clz, "getContentSize", "()Lcom/immomo/mls/fun/ud/UDSize;");
    setContentSizeID = (*env)->GetMethodID(env, clz, "setContentSize", "(Lcom/immomo/mls/fun/ud/UDSize;)V");
    getContentOffsetID = (*env)->GetMethodID(env, clz, "getContentOffset", "()Lcom/immomo/mls/fun/ud/UDPoint;");
    setContentOffsetID = (*env)->GetMethodID(env, clz, "setContentOffset", "(Lcom/immomo/mls/fun/ud/UDPoint;)V");
    isScrollEnabledID = (*env)->GetMethodID(env, clz, "isScrollEnabled", "()Z");
    setScrollEnabledID = (*env)->GetMethodID(env, clz, "setScrollEnabled", "(Z)V");
    isShowsHorizontalScrollIndicatorID = (*env)->GetMethodID(env, clz, "isShowsHorizontalScrollIndicator", "()Z");
    setShowsHorizontalScrollIndicatorID = (*env)->GetMethodID(env, clz, "setShowsHorizontalScrollIndicator", "(Z)V");
    isShowsVerticalScrollIndicatorID = (*env)->GetMethodID(env, clz, "isShowsVerticalScrollIndicator", "()Z");
    setShowsVerticalScrollIndicatorID = (*env)->GetMethodID(env, clz, "setShowsVerticalScrollIndicator", "(Z)V");
    setScrollEnableID = (*env)->GetMethodID(env, clz, "setScrollEnable", "(Z)V");
    i_bouncesID = (*env)->GetMethodID(env, clz, "i_bounces", "()V");
    i_bounceHorizontalID = (*env)->GetMethodID(env, clz, "i_bounceHorizontal", "()V");
    i_bounceVerticalID = (*env)->GetMethodID(env, clz, "i_bounceVertical", "()V");
    i_pagingEnabledID = (*env)->GetMethodID(env, clz, "i_pagingEnabled", "()V");
    setScrollBeginCallbackID = (*env)->GetMethodID(env, clz, "setScrollBeginCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setScrollingCallbackID = (*env)->GetMethodID(env, clz, "setScrollingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setScrollEndCallbackID = (*env)->GetMethodID(env, clz, "setScrollEndCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    setContentInsetID = (*env)->GetMethodID(env, clz, "setContentInset", "()V");
    setOffsetWithAnimID = (*env)->GetMethodID(env, clz, "setOffsetWithAnim", "(Lcom/immomo/mls/fun/ud/UDPoint;)V");
    setEndDraggingCallbackID = (*env)->GetMethodID(env, clz, "setEndDraggingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    touchBeginID = (*env)->GetMethodID(env, clz, "touchBegin", "(Lorg/luaj/vm2/LuaFunction;)V");
    setStartDeceleratingCallbackID = (*env)->GetMethodID(env, clz, "setStartDeceleratingCallback", "(Lorg/luaj/vm2/LuaFunction;)V");
    getContentInsetID = (*env)->GetMethodID(env, clz, "getContentInset", "()V");
    addViewID = (*env)->GetMethodID(env, clz, "addView", "(Lcom/immomo/mmui/ud/UDView;)V");
    insertViewID = (*env)->GetMethodID(env, clz, "insertView", "(Lcom/immomo/mmui/ud/UDView;I)V");
    removeAllSubviewsID = (*env)->GetMethodID(env, clz, "removeAllSubviews", "()V");
    a_flingSpeedID = (*env)->GetMethodID(env, clz, "a_flingSpeed", "(F)V");
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
 * com.immomo.mls.fun.ud.UDSize getContentSize()
 * void setContentSize(com.immomo.mls.fun.ud.UDSize)
 */
static int _contentSize(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getContentSizeID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getContentSize")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getContentSize", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setContentSizeID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setContentSize")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setContentSize", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mls.fun.ud.UDPoint getContentOffset()
 * void setContentOffset(com.immomo.mls.fun.ud.UDPoint)
 */
static int _contentOffset(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getContentOffsetID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getContentOffset")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getContentOffset", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setContentOffsetID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setContentOffset")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setContentOffset", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isScrollEnabled()
 * void setScrollEnabled(boolean)
 */
static int _scrollEnabled(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isScrollEnabledID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isScrollEnabled")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isScrollEnabled", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollEnabledID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollEnabled")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollEnabled", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isShowsHorizontalScrollIndicator()
 * void setShowsHorizontalScrollIndicator(boolean)
 */
static int _showsHorizontalScrollIndicator(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isShowsHorizontalScrollIndicatorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isShowsHorizontalScrollIndicator")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isShowsHorizontalScrollIndicator", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setShowsHorizontalScrollIndicatorID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setShowsHorizontalScrollIndicator")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setShowsHorizontalScrollIndicator", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isShowsVerticalScrollIndicator()
 * void setShowsVerticalScrollIndicator(boolean)
 */
static int _showsVerticalScrollIndicator(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isShowsVerticalScrollIndicatorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isShowsVerticalScrollIndicator")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isShowsVerticalScrollIndicator", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setShowsVerticalScrollIndicatorID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setShowsVerticalScrollIndicator")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setShowsVerticalScrollIndicator", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setScrollEnable(boolean)
 */
static int _setScrollEnable(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollEnableID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollEnable")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollEnable", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void i_bounces()
 */
static int _i_bounces(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, i_bouncesID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".i_bounces")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "i_bounces", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void i_bounceHorizontal()
 */
static int _i_bounceHorizontal(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, i_bounceHorizontalID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".i_bounceHorizontal")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "i_bounceHorizontal", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void i_bounceVertical()
 */
static int _i_bounceVertical(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, i_bounceVerticalID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".i_bounceVertical")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "i_bounceVertical", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void i_pagingEnabled()
 */
static int _i_pagingEnabled(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, i_pagingEnabledID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".i_pagingEnabled")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "i_pagingEnabled", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setScrollBeginCallback(org.luaj.vm2.LuaFunction)
 */
static int _setScrollBeginCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollBeginCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollBeginCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollBeginCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setScrollingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setScrollingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setScrollEndCallback(org.luaj.vm2.LuaFunction)
 */
static int _setScrollEndCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setScrollEndCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setScrollEndCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setScrollEndCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setContentInset()
 */
static int _setContentInset(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, setContentInsetID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setContentInset")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setContentInset", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setOffsetWithAnim(com.immomo.mls.fun.ud.UDPoint)
 */
static int _setOffsetWithAnim(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setOffsetWithAnimID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setOffsetWithAnim")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setOffsetWithAnim", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setEndDraggingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setEndDraggingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setEndDraggingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setEndDraggingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setEndDraggingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchBegin(org.luaj.vm2.LuaFunction)
 */
static int _touchBegin(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, touchBeginID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchBegin")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchBegin", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setStartDeceleratingCallback(org.luaj.vm2.LuaFunction)
 */
static int _setStartDeceleratingCallback(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setStartDeceleratingCallbackID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setStartDeceleratingCallback")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setStartDeceleratingCallback", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void getContentInset()
 */
static int _getContentInset(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, getContentInsetID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getContentInset")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getContentInset", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void addView(com.immomo.mmui.ud.UDView)
 */
static int _addView(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, addViewID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".addView")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "addView", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void insertView(com.immomo.mmui.ud.UDView,int)
 */
static int _insertView(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    (*env)->CallVoidMethod(env, jobj, insertViewID, p1, (jint)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".insertView")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "insertView", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void removeAllSubviews()
 */
static int _removeAllSubviews(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, removeAllSubviewsID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeAllSubviews")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeAllSubviews", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void a_flingSpeed(float)
 */
static int _a_flingSpeed(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, a_flingSpeedID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".a_flingSpeed")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "a_flingSpeed", _get_milli_second(&end) - _get_milli_second(&start));
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
    if (pc == 2) {
        int p1 = lua_toboolean(L, 1);
        int p2 = lua_toboolean(L, 2);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor0, (jlong) L, (jboolean)p1, (jboolean)p2);
    } else if (pc == 1) {
        int p1 = lua_toboolean(L, 1);
        javaObj = (*env)->NewObject(env, _globalClass, _constructor1, (jlong) L, (jboolean)p1);
    } else {
        javaObj = (*env)->NewObject(env, _globalClass, _constructor2, (jlong) L);
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