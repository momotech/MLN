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
#define LUA_CLASS_NAME "__WINDOW"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
static jmethodID _constructor0;
//<editor-fold desc="method definition">
static jmethodID getLuaVersionID;
static int _getLuaVersion(lua_State *L);
static jmethodID viewAppearID;
static int _viewAppear(lua_State *L);
static jmethodID viewDisappearID;
static int _viewDisappear(lua_State *L);
static jmethodID backKeyPressedID;
static int _backKeyPressed(lua_State *L);
static jmethodID isBackKeyEnabledID;
static jmethodID setBackKeyEnabledID;
static int _backKeyEnabled(lua_State *L);
static jmethodID keyBoardHeightChangeID;
static int _keyBoardHeightChange(lua_State *L);
static jmethodID sizeChangedID;
static int _sizeChanged(lua_State *L);
static jmethodID keyboardShowingID;
static int _keyboardShowing(lua_State *L);
static jmethodID getExtraID;
static int _getExtra(lua_State *L);
static jmethodID getLuaSourceID;
static int _getLuaSource(lua_State *L);
static jmethodID onDestroyID;
static int _onDestroy(lua_State *L);
static jmethodID setPageColorID;
static int _setPageColor(lua_State *L);
static jmethodID setStatusBarStyleID;
static int _setStatusBarStyle(lua_State *L);
static jmethodID nGetStatusBarStyleID;
static int _getStatusBarStyle(lua_State *L);
static jmethodID setStatusBarModeID;
static jmethodID getStatusBarModeID;
static int _statusBarMode(lua_State *L);
static jmethodID setStatusBarColorID;
static jmethodID getStatusBarColorID;
static int _statusBarColor(lua_State *L);
static jmethodID statusBarHeightID;
static int _statusBarHeight(lua_State *L);
static jmethodID navBarHeightID;
static int _navBarHeight(lua_State *L);
static jmethodID tabBarHeightID;
static int _tabBarHeight(lua_State *L);
static jmethodID homeHeightID;
static int _homeHeight(lua_State *L);
static jmethodID homeBarHeightID;
static int _homeBarHeight(lua_State *L);
static jmethodID safeArea0ID;
static jmethodID safeArea1ID;
static int _safeArea(lua_State *L);
static jmethodID safeAreaInsetsTopID;
static int _safeAreaInsetsTop(lua_State *L);
static jmethodID safeAreaInsetsBottomID;
static int _safeAreaInsetsBottom(lua_State *L);
static jmethodID safeAreaInsetsLeftID;
static int _safeAreaInsetsLeft(lua_State *L);
static jmethodID safeAreaInsetsRightID;
static int _safeAreaInsetsRight(lua_State *L);
static jmethodID safeAreaAdapterID;
static int _safeAreaAdapter(lua_State *L);
static jmethodID cachePushViewID;
static int _cachePushView(lua_State *L);
static jmethodID clearPushViewID;
static int _clearPushView(lua_State *L);
static jmethodID sizeChangeEnableID;
static int _sizeChangeEnable(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"getLuaVersion", _getLuaVersion},
            {"viewAppear", _viewAppear},
            {"viewDisappear", _viewDisappear},
            {"backKeyPressed", _backKeyPressed},
            {"backKeyEnabled", _backKeyEnabled},
            {"keyBoardHeightChange", _keyBoardHeightChange},
            {"sizeChanged", _sizeChanged},
            {"keyboardShowing", _keyboardShowing},
            {"getExtra", _getExtra},
            {"getLuaSource", _getLuaSource},
            {"onDestroy", _onDestroy},
            {"setPageColor", _setPageColor},
            {"setStatusBarStyle", _setStatusBarStyle},
            {"getStatusBarStyle", _getStatusBarStyle},
            {"statusBarMode", _statusBarMode},
            {"statusBarColor", _statusBarColor},
            {"statusBarHeight", _statusBarHeight},
            {"navBarHeight", _navBarHeight},
            {"tabBarHeight", _tabBarHeight},
            {"homeHeight", _homeHeight},
            {"homeBarHeight", _homeBarHeight},
            {"safeArea", _safeArea},
            {"safeAreaInsetsTop", _safeAreaInsetsTop},
            {"safeAreaInsetsBottom", _safeAreaInsetsBottom},
            {"safeAreaInsetsLeft", _safeAreaInsetsLeft},
            {"safeAreaInsetsRight", _safeAreaInsetsRight},
            {"safeAreaAdapter", _safeAreaAdapter},
            {"cachePushView", _cachePushView},
            {"clearPushView", _clearPushView},
            {"sizeChangeEnable", _sizeChangeEnable},
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
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_globals_UDLuaView_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    _constructor0 = (*env)->GetMethodID(env, clz, JAVA_CONSTRUCTOR, "(J)V");
    getLuaVersionID = (*env)->GetMethodID(env, clz, "getLuaVersion", "()Ljava/lang/String;");
    viewAppearID = (*env)->GetMethodID(env, clz, "viewAppear", "(Lorg/luaj/vm2/LuaFunction;)V");
    viewDisappearID = (*env)->GetMethodID(env, clz, "viewDisappear", "(Lorg/luaj/vm2/LuaFunction;)V");
    backKeyPressedID = (*env)->GetMethodID(env, clz, "backKeyPressed", "(Lorg/luaj/vm2/LuaFunction;)V");
    isBackKeyEnabledID = (*env)->GetMethodID(env, clz, "isBackKeyEnabled", "()Z");
    setBackKeyEnabledID = (*env)->GetMethodID(env, clz, "setBackKeyEnabled", "(Z)V");
    keyBoardHeightChangeID = (*env)->GetMethodID(env, clz, "keyBoardHeightChange", "(Lorg/luaj/vm2/LuaFunction;)V");
    sizeChangedID = (*env)->GetMethodID(env, clz, "sizeChanged", "(Lorg/luaj/vm2/LuaFunction;)V");
    keyboardShowingID = (*env)->GetMethodID(env, clz, "keyboardShowing", "(Lorg/luaj/vm2/LuaFunction;)V");
    getExtraID = (*env)->GetMethodID(env, clz, "getExtra", "()Lcom/immomo/mls/fun/ud/UDMap;");
    getLuaSourceID = (*env)->GetMethodID(env, clz, "getLuaSource", "()Ljava/lang/String;");
    onDestroyID = (*env)->GetMethodID(env, clz, "onDestroy", "(Lorg/luaj/vm2/LuaFunction;)V");
    setPageColorID = (*env)->GetMethodID(env, clz, "setPageColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    setStatusBarStyleID = (*env)->GetMethodID(env, clz, "setStatusBarStyle", "(I)V");
    nGetStatusBarStyleID = (*env)->GetMethodID(env, clz, "nGetStatusBarStyle", "()I");
    setStatusBarModeID = (*env)->GetMethodID(env, clz, "setStatusBarMode", "(I)V");
    getStatusBarModeID = (*env)->GetMethodID(env, clz, "getStatusBarMode", "()I");
    setStatusBarColorID = (*env)->GetMethodID(env, clz, "setStatusBarColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    getStatusBarColorID = (*env)->GetMethodID(env, clz, "getStatusBarColor", "()Lcom/immomo/mmui/ud/UDColor;");
    statusBarHeightID = (*env)->GetMethodID(env, clz, "statusBarHeight", "()F");
    navBarHeightID = (*env)->GetMethodID(env, clz, "navBarHeight", "()F");
    tabBarHeightID = (*env)->GetMethodID(env, clz, "tabBarHeight", "()F");
    homeHeightID = (*env)->GetMethodID(env, clz, "homeHeight", "()F");
    homeBarHeightID = (*env)->GetMethodID(env, clz, "homeBarHeight", "()F");
    safeArea0ID = (*env)->GetMethodID(env, clz, "safeArea", "()V");
    safeArea1ID = (*env)->GetMethodID(env, clz, "safeArea", "(I)V");
    safeAreaInsetsTopID = (*env)->GetMethodID(env, clz, "safeAreaInsetsTop", "()F");
    safeAreaInsetsBottomID = (*env)->GetMethodID(env, clz, "safeAreaInsetsBottom", "()F");
    safeAreaInsetsLeftID = (*env)->GetMethodID(env, clz, "safeAreaInsetsLeft", "()F");
    safeAreaInsetsRightID = (*env)->GetMethodID(env, clz, "safeAreaInsetsRight", "()F");
    safeAreaAdapterID = (*env)->GetMethodID(env, clz, "safeAreaAdapter", "(Lcom/immomo/mmui/ud/UDSafeAreaRect;)V");
    cachePushViewID = (*env)->GetMethodID(env, clz, "cachePushView", "(Lcom/immomo/mmui/ud/UDView;)V");
    clearPushViewID = (*env)->GetMethodID(env, clz, "clearPushView", "()V");
    sizeChangeEnableID = (*env)->GetMethodID(env, clz, "sizeChangeEnable", "(Z)V");
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
 * java.lang.String getLuaVersion()
 */
static int _getLuaVersion(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring ret = (*env)->CallObjectMethod(env, jobj, getLuaVersionID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getLuaVersion")) {
        return lua_error(L);
    }
    pushJavaString(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getLuaVersion", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void viewAppear(org.luaj.vm2.LuaFunction)
 */
static int _viewAppear(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, viewAppearID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".viewAppear")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "viewAppear", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void viewDisappear(org.luaj.vm2.LuaFunction)
 */
static int _viewDisappear(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, viewDisappearID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".viewDisappear")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "viewDisappear", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void backKeyPressed(org.luaj.vm2.LuaFunction)
 */
static int _backKeyPressed(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, backKeyPressedID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".backKeyPressed")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "backKeyPressed", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isBackKeyEnabled()
 * void setBackKeyEnabled(boolean)
 */
static int _backKeyEnabled(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isBackKeyEnabledID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isBackKeyEnabled")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isBackKeyEnabled", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setBackKeyEnabledID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBackKeyEnabled")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBackKeyEnabled", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void keyBoardHeightChange(org.luaj.vm2.LuaFunction)
 */
static int _keyBoardHeightChange(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, keyBoardHeightChangeID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".keyBoardHeightChange")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "keyBoardHeightChange", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void sizeChanged(org.luaj.vm2.LuaFunction)
 */
static int _sizeChanged(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, sizeChangedID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".sizeChanged")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "sizeChanged", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void keyboardShowing(org.luaj.vm2.LuaFunction)
 */
static int _keyboardShowing(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, keyboardShowingID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".keyboardShowing")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "keyboardShowing", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mls.fun.ud.UDMap getExtra()
 */
static int _getExtra(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject ret = (*env)->CallObjectMethod(env, jobj, getExtraID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getExtra")) {
        return lua_error(L);
    }
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getExtra", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * java.lang.String getLuaSource()
 */
static int _getLuaSource(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring ret = (*env)->CallObjectMethod(env, jobj, getLuaSourceID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getLuaSource")) {
        return lua_error(L);
    }
    pushJavaString(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getLuaSource", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void onDestroy(org.luaj.vm2.LuaFunction)
 */
static int _onDestroy(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, onDestroyID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".onDestroy")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "onDestroy", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setPageColor(com.immomo.mmui.ud.UDColor)
 */
static int _setPageColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setPageColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPageColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPageColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setStatusBarStyle(int)
 */
static int _setStatusBarStyle(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setStatusBarStyleID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setStatusBarStyle")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setStatusBarStyle", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int nGetStatusBarStyle()
 */
static int _getStatusBarStyle(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jint ret = (*env)->CallIntMethod(env, jobj, nGetStatusBarStyleID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".nGetStatusBarStyle")) {
        return lua_error(L);
    }
    lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nGetStatusBarStyle", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getStatusBarMode()
 * void setStatusBarMode(int)
 */
static int _statusBarMode(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getStatusBarModeID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getStatusBarMode")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getStatusBarMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setStatusBarModeID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setStatusBarMode")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setStatusBarMode", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDColor getStatusBarColor()
 * void setStatusBarColor(com.immomo.mmui.ud.UDColor)
 */
static int _statusBarColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getStatusBarColorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getStatusBarColor")) {
            return lua_error(L);
        }
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getStatusBarColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setStatusBarColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setStatusBarColor")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setStatusBarColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float statusBarHeight()
 */
static int _statusBarHeight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jfloat ret = (*env)->CallFloatMethod(env, jobj, statusBarHeightID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".statusBarHeight")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "statusBarHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float navBarHeight()
 */
static int _navBarHeight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jfloat ret = (*env)->CallFloatMethod(env, jobj, navBarHeightID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".navBarHeight")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "navBarHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float tabBarHeight()
 */
static int _tabBarHeight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jfloat ret = (*env)->CallFloatMethod(env, jobj, tabBarHeightID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".tabBarHeight")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "tabBarHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float homeHeight()
 */
static int _homeHeight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jfloat ret = (*env)->CallFloatMethod(env, jobj, homeHeightID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".homeHeight")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "homeHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float homeBarHeight()
 */
static int _homeBarHeight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jfloat ret = (*env)->CallFloatMethod(env, jobj, homeBarHeightID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".homeBarHeight")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "homeBarHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void safeArea()
 * void safeArea(int)
 */
static int _safeArea(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 2) {
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Integer p1 = luaL_checkinteger(L, 2);
            (*env)->CallVoidMethod(env, jobj, safeArea1ID, (jint)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".safeArea")) {
                return lua_error(L);
            }
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "safeArea", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".safeArea函数1个参数有: (int)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        return lua_error(L);
    }
    if (lua_gettop(L) == 1) {
        (*env)->CallVoidMethod(env, jobj, safeArea0ID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".safeArea")) {
            return lua_error(L);
        }
        lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "safeArea", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_settop(L, 1);
    return 1;
}
/**
 * float safeAreaInsetsTop()
 */
static int _safeAreaInsetsTop(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jfloat ret = (*env)->CallFloatMethod(env, jobj, safeAreaInsetsTopID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".safeAreaInsetsTop")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "safeAreaInsetsTop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float safeAreaInsetsBottom()
 */
static int _safeAreaInsetsBottom(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jfloat ret = (*env)->CallFloatMethod(env, jobj, safeAreaInsetsBottomID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".safeAreaInsetsBottom")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "safeAreaInsetsBottom", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float safeAreaInsetsLeft()
 */
static int _safeAreaInsetsLeft(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jfloat ret = (*env)->CallFloatMethod(env, jobj, safeAreaInsetsLeftID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".safeAreaInsetsLeft")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "safeAreaInsetsLeft", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float safeAreaInsetsRight()
 */
static int _safeAreaInsetsRight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jfloat ret = (*env)->CallFloatMethod(env, jobj, safeAreaInsetsRightID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".safeAreaInsetsRight")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "safeAreaInsetsRight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void safeAreaAdapter(com.immomo.mmui.ud.UDSafeAreaRect)
 */
static int _safeAreaAdapter(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, safeAreaAdapterID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".safeAreaAdapter")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "safeAreaAdapter", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void cachePushView(com.immomo.mmui.ud.UDView)
 */
static int _cachePushView(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, cachePushViewID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".cachePushView")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "cachePushView", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void clearPushView()
 */
static int _clearPushView(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, clearPushViewID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".clearPushView")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "clearPushView", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void sizeChangeEnable(boolean)
 */
static int _sizeChangeEnable(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, sizeChangeEnableID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".sizeChangeEnable")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "sizeChangeEnable", _get_milli_second(&end) - _get_milli_second(&start));
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