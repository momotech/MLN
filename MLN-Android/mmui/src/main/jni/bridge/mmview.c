/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
//
// Created by Generator on 2020-10-22
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
#define LUA_CLASS_NAME "__BaseView"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID getXID;
static int _getX(lua_State *L);
static jmethodID getYID;
static int _getY(lua_State *L);
static jmethodID nSetWidthID;
static jmethodID nGetWidthID;
static int _width(lua_State *L);
static jmethodID setWidthPercentID;
static jmethodID getWidthPercentID;
static int _widthPercent(lua_State *L);
static jmethodID widthAutoID;
static int _widthAuto(lua_State *L);
static jmethodID nSetHeightID;
static jmethodID nGetHeightID;
static int _height(lua_State *L);
static jmethodID setHeightPercentID;
static jmethodID getHeightPercentID;
static int _heightPercent(lua_State *L);
static jmethodID heightAutoID;
static int _heightAuto(lua_State *L);
static jmethodID getMarginLeftID;
static jmethodID setMarginLeftID;
static int _marginLeft(lua_State *L);
static jmethodID getMarginTopID;
static jmethodID setMarginTopID;
static int _marginTop(lua_State *L);
static jmethodID getMarginRightID;
static jmethodID setMarginRightID;
static int _marginRight(lua_State *L);
static jmethodID getMarginBottomID;
static jmethodID setMarginBottomID;
static int _marginBottom(lua_State *L);
static jmethodID marginID;
static int _margin(lua_State *L);
static jmethodID nGetPaddingLeftID;
static jmethodID nSetPaddingLeftID;
static int _paddingLeft(lua_State *L);
static jmethodID nGetPaddingTopID;
static jmethodID nSetPaddingTopID;
static int _paddingTop(lua_State *L);
static jmethodID nGetPaddingRightID;
static jmethodID nSetPaddingRightID;
static int _paddingRight(lua_State *L);
static jmethodID nGetPaddingBottomID;
static jmethodID nSetPaddingBottomID;
static int _paddingBottom(lua_State *L);
static jmethodID paddingID;
static int _padding(lua_State *L);
static jmethodID getCrossSelfID;
static jmethodID setCrossSelfID;
static int _crossSelf(lua_State *L);
static jmethodID getBasisID;
static jmethodID setBasisID;
static int _basis(lua_State *L);
static jmethodID getGrowID;
static jmethodID setGrowID;
static int _grow(lua_State *L);
static jmethodID getShrinkID;
static jmethodID setShrinkID;
static int _shrink(lua_State *L);
static jmethodID isDisplayID;
static jmethodID setDisplayID;
static int _display(lua_State *L);
static jmethodID getPositionTypeID;
static jmethodID setPositionTypeID;
static int _positionType(lua_State *L);
static jmethodID getPositionLeftID;
static jmethodID setPositionLeftID;
static int _positionLeft(lua_State *L);
static jmethodID getPositionTopID;
static jmethodID setPositionTopID;
static int _positionTop(lua_State *L);
static jmethodID getPositionRightID;
static jmethodID setPositionRightID;
static int _positionRight(lua_State *L);
static jmethodID getPositionBottomID;
static jmethodID setPositionBottomID;
static int _positionBottom(lua_State *L);
static jmethodID rotationID;
static int _rotation(lua_State *L);
static jmethodID translationID;
static int _translation(lua_State *L);
static jmethodID scaleID;
static int _scale(lua_State *L);
static jmethodID setAlphaID;
static jmethodID getAlphaID;
static int _alpha(lua_State *L);
static jmethodID viewWidthID;
static int _viewWidth(lua_State *L);
static jmethodID viewHeightID;
static int _viewHeight(lua_State *L);
static jmethodID onClickID;
static int _onClick(lua_State *L);
static jmethodID onLongPressID;
static int _onLongPress(lua_State *L);
static jmethodID childFirstHandlePointersID;
static int _childFirstHandlePointers(lua_State *L);
static jmethodID touchBeginID;
static int _touchBegin(lua_State *L);
static jmethodID touchMoveID;
static int _touchMove(lua_State *L);
static jmethodID touchEndID;
static int _touchEnd(lua_State *L);
static jmethodID touchCancelID;
static int _touchCancel(lua_State *L);
static jmethodID touchBeginExtensionID;
static int _touchBeginExtension(lua_State *L);
static jmethodID touchMoveExtensionID;
static int _touchMoveExtension(lua_State *L);
static jmethodID touchEndExtensionID;
static int _touchEndExtension(lua_State *L);
static jmethodID touchCancelExtensionID;
static int _touchCancelExtension(lua_State *L);
static jmethodID scaleBeginID;
static int _scaleBegin(lua_State *L);
static jmethodID scalingID;
static int _scaling(lua_State *L);
static jmethodID scaleEndID;
static int _scaleEnd(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"getX", _getX},
            {"getY", _getY},
            {"width", _width},
            {"widthPercent", _widthPercent},
            {"widthAuto", _widthAuto},
            {"height", _height},
            {"heightPercent", _heightPercent},
            {"heightAuto", _heightAuto},
            {"marginLeft", _marginLeft},
            {"marginTop", _marginTop},
            {"marginRight", _marginRight},
            {"marginBottom", _marginBottom},
            {"margin", _margin},
            {"paddingLeft", _paddingLeft},
            {"paddingTop", _paddingTop},
            {"paddingRight", _paddingRight},
            {"paddingBottom", _paddingBottom},
            {"padding", _padding},
            {"crossSelf", _crossSelf},
            {"basis", _basis},
            {"grow", _grow},
            {"shrink", _shrink},
            {"display", _display},
            {"positionType", _positionType},
            {"positionLeft", _positionLeft},
            {"positionTop", _positionTop},
            {"positionRight", _positionRight},
            {"positionBottom", _positionBottom},
            {"rotation", _rotation},
            {"translation", _translation},
            {"scale", _scale},
            {"alpha", _alpha},
            {"viewWidth", _viewWidth},
            {"viewHeight", _viewHeight},
            {"onClick", _onClick},
            {"onLongPress", _onLongPress},
            {"childFirstHandlePointers", _childFirstHandlePointers},
            {"touchBegin", _touchBegin},
            {"touchMove", _touchMove},
            {"touchEnd", _touchEnd},
            {"touchCancel", _touchCancel},
            {"touchBeginExtension", _touchBeginExtension},
            {"touchMoveExtension", _touchMoveExtension},
            {"touchEndExtension", _touchEndExtension},
            {"touchCancelExtension", _touchCancelExtension},
            {"scaleBegin", _scaleBegin},
            {"scaling", _scaling},
            {"scaleEnd", _scaleEnd},
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
//<editor-fold desc="JNI methods">
#define JNIMETHODDEFILE(s) Java_com_immomo_mmui_ud_UDView_ ## s
/**
 * java层需要初始化的class静态调用
 * 初始化各种jmethodID
 */
JNIEXPORT void JNICALL JNIMETHODDEFILE(_1init)
        (JNIEnv *env, jclass clz) {
    _globalClass = GLOBAL(env, clz);
    getXID = (*env)->GetMethodID(env, clz, "getX", "()D");
    getYID = (*env)->GetMethodID(env, clz, "getY", "()D");
    nSetWidthID = (*env)->GetMethodID(env, clz, "nSetWidth", "(D)V");
    nGetWidthID = (*env)->GetMethodID(env, clz, "nGetWidth", "()D");
    setWidthPercentID = (*env)->GetMethodID(env, clz, "setWidthPercent", "(F)V");
    getWidthPercentID = (*env)->GetMethodID(env, clz, "getWidthPercent", "()F");
    widthAutoID = (*env)->GetMethodID(env, clz, "widthAuto", "()V");
    nSetHeightID = (*env)->GetMethodID(env, clz, "nSetHeight", "(D)V");
    nGetHeightID = (*env)->GetMethodID(env, clz, "nGetHeight", "()D");
    setHeightPercentID = (*env)->GetMethodID(env, clz, "setHeightPercent", "(F)V");
    getHeightPercentID = (*env)->GetMethodID(env, clz, "getHeightPercent", "()F");
    heightAutoID = (*env)->GetMethodID(env, clz, "heightAuto", "()V");
    getMarginLeftID = (*env)->GetMethodID(env, clz, "getMarginLeft", "()D");
    setMarginLeftID = (*env)->GetMethodID(env, clz, "setMarginLeft", "(D)V");
    getMarginTopID = (*env)->GetMethodID(env, clz, "getMarginTop", "()D");
    setMarginTopID = (*env)->GetMethodID(env, clz, "setMarginTop", "(D)V");
    getMarginRightID = (*env)->GetMethodID(env, clz, "getMarginRight", "()D");
    setMarginRightID = (*env)->GetMethodID(env, clz, "setMarginRight", "(D)V");
    getMarginBottomID = (*env)->GetMethodID(env, clz, "getMarginBottom", "()D");
    setMarginBottomID = (*env)->GetMethodID(env, clz, "setMarginBottom", "(D)V");
    marginID = (*env)->GetMethodID(env, clz, "margin", "(DDDD)V");
    nGetPaddingLeftID = (*env)->GetMethodID(env, clz, "nGetPaddingLeft", "()D");
    nSetPaddingLeftID = (*env)->GetMethodID(env, clz, "nSetPaddingLeft", "(D)V");
    nGetPaddingTopID = (*env)->GetMethodID(env, clz, "nGetPaddingTop", "()D");
    nSetPaddingTopID = (*env)->GetMethodID(env, clz, "nSetPaddingTop", "(D)V");
    nGetPaddingRightID = (*env)->GetMethodID(env, clz, "nGetPaddingRight", "()D");
    nSetPaddingRightID = (*env)->GetMethodID(env, clz, "nSetPaddingRight", "(D)V");
    nGetPaddingBottomID = (*env)->GetMethodID(env, clz, "nGetPaddingBottom", "()D");
    nSetPaddingBottomID = (*env)->GetMethodID(env, clz, "nSetPaddingBottom", "(D)V");
    paddingID = (*env)->GetMethodID(env, clz, "padding", "(DDDD)V");
    getCrossSelfID = (*env)->GetMethodID(env, clz, "getCrossSelf", "()I");
    setCrossSelfID = (*env)->GetMethodID(env, clz, "setCrossSelf", "(I)V");
    getBasisID = (*env)->GetMethodID(env, clz, "getBasis", "()F");
    setBasisID = (*env)->GetMethodID(env, clz, "setBasis", "(F)V");
    getGrowID = (*env)->GetMethodID(env, clz, "getGrow", "()F");
    setGrowID = (*env)->GetMethodID(env, clz, "setGrow", "(F)V");
    getShrinkID = (*env)->GetMethodID(env, clz, "getShrink", "()F");
    setShrinkID = (*env)->GetMethodID(env, clz, "setShrink", "(F)V");
    isDisplayID = (*env)->GetMethodID(env, clz, "isDisplay", "()Z");
    setDisplayID = (*env)->GetMethodID(env, clz, "setDisplay", "(Z)V");
    getPositionTypeID = (*env)->GetMethodID(env, clz, "getPositionType", "()I");
    setPositionTypeID = (*env)->GetMethodID(env, clz, "setPositionType", "(I)V");
    getPositionLeftID = (*env)->GetMethodID(env, clz, "getPositionLeft", "()D");
    setPositionLeftID = (*env)->GetMethodID(env, clz, "setPositionLeft", "(D)V");
    getPositionTopID = (*env)->GetMethodID(env, clz, "getPositionTop", "()D");
    setPositionTopID = (*env)->GetMethodID(env, clz, "setPositionTop", "(D)V");
    getPositionRightID = (*env)->GetMethodID(env, clz, "getPositionRight", "()D");
    setPositionRightID = (*env)->GetMethodID(env, clz, "setPositionRight", "(D)V");
    getPositionBottomID = (*env)->GetMethodID(env, clz, "getPositionBottom", "()D");
    setPositionBottomID = (*env)->GetMethodID(env, clz, "setPositionBottom", "(D)V");
    rotationID = (*env)->GetMethodID(env, clz, "rotation", "(FZ)V");
    translationID = (*env)->GetMethodID(env, clz, "translation", "(DDZ)V");
    scaleID = (*env)->GetMethodID(env, clz, "scale", "(FFZ)V");
    setAlphaID = (*env)->GetMethodID(env, clz, "setAlpha", "(F)V");
    getAlphaID = (*env)->GetMethodID(env, clz, "getAlpha", "()F");
    viewWidthID = (*env)->GetMethodID(env, clz, "viewWidth", "(D)V");
    viewHeightID = (*env)->GetMethodID(env, clz, "viewHeight", "(D)V");
    onClickID = (*env)->GetMethodID(env, clz, "onClick", "(Lorg/luaj/vm2/LuaFunction;)V");
    onLongPressID = (*env)->GetMethodID(env, clz, "onLongPress", "(Lorg/luaj/vm2/LuaFunction;)V");
    childFirstHandlePointersID = (*env)->GetMethodID(env, clz, "childFirstHandlePointers", "(Z)V");
    touchBeginID = (*env)->GetMethodID(env, clz, "touchBegin", "(J)V");
    touchMoveID = (*env)->GetMethodID(env, clz, "touchMove", "(J)V");
    touchEndID = (*env)->GetMethodID(env, clz, "touchEnd", "(J)V");
    touchCancelID = (*env)->GetMethodID(env, clz, "touchCancel", "(J)V");
    touchBeginExtensionID = (*env)->GetMethodID(env, clz, "touchBeginExtension", "(J)V");
    touchMoveExtensionID = (*env)->GetMethodID(env, clz, "touchMoveExtension", "(J)V");
    touchEndExtensionID = (*env)->GetMethodID(env, clz, "touchEndExtension", "(J)V");
    touchCancelExtensionID = (*env)->GetMethodID(env, clz, "touchCancelExtension", "(J)V");
    scaleBeginID = (*env)->GetMethodID(env, clz, "scaleBegin", "(J)V");
    scalingID = (*env)->GetMethodID(env, clz, "scaling", "(J)V");
    scaleEndID = (*env)->GetMethodID(env, clz, "scaleEnd", "(J)V");
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

}
//</editor-fold>
//<editor-fold desc="lua method implementation">
/**
 * double getX()
 */
static int _getX(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jdouble ret = (*env)->CallDoubleMethod(env, jobj, getXID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getX")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getX", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getY()
 */
static int _getY(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jdouble ret = (*env)->CallDoubleMethod(env, jobj, getYID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getY")) {
        return lua_error(L);
    }
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getY", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double nGetWidth()
 * void nSetWidth(double)
 */
static int _width(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, nGetWidthID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".nGetWidth")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nGetWidth", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, nSetWidthID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".nSetWidth")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nSetWidth", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getWidthPercent()
 * void setWidthPercent(float)
 */
static int _widthPercent(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getWidthPercentID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getWidthPercent")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getWidthPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setWidthPercentID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setWidthPercent")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setWidthPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void widthAuto()
 */
static int _widthAuto(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, widthAutoID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".widthAuto")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "widthAuto", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double nGetHeight()
 * void nSetHeight(double)
 */
static int _height(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, nGetHeightID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".nGetHeight")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nGetHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, nSetHeightID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".nSetHeight")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nSetHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getHeightPercent()
 * void setHeightPercent(float)
 */
static int _heightPercent(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getHeightPercentID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getHeightPercent")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getHeightPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setHeightPercentID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setHeightPercent")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setHeightPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void heightAuto()
 */
static int _heightAuto(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, heightAutoID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".heightAuto")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "heightAuto", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getMarginLeft()
 * void setMarginLeft(double)
 */
static int _marginLeft(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getMarginLeftID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMarginLeft")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMarginLeft", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMarginLeftID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMarginLeft")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMarginLeft", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getMarginTop()
 * void setMarginTop(double)
 */
static int _marginTop(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getMarginTopID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMarginTop")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMarginTop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMarginTopID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMarginTop")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMarginTop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getMarginRight()
 * void setMarginRight(double)
 */
static int _marginRight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getMarginRightID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMarginRight")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMarginRight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMarginRightID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMarginRight")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMarginRight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getMarginBottom()
 * void setMarginBottom(double)
 */
static int _marginBottom(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getMarginBottomID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMarginBottom")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMarginBottom", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMarginBottomID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMarginBottom")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMarginBottom", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void margin(double,double,double,double)
 */
static int _margin(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    lua_Number p3 = luaL_checknumber(L, 4);
    lua_Number p4 = luaL_checknumber(L, 5);
    (*env)->CallVoidMethod(env, jobj, marginID, (jdouble)p1, (jdouble)p2, (jdouble)p3, (jdouble)p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".margin")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "margin", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double nGetPaddingLeft()
 * void nSetPaddingLeft(double)
 */
static int _paddingLeft(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, nGetPaddingLeftID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".nGetPaddingLeft")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nGetPaddingLeft", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, nSetPaddingLeftID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".nSetPaddingLeft")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nSetPaddingLeft", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double nGetPaddingTop()
 * void nSetPaddingTop(double)
 */
static int _paddingTop(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, nGetPaddingTopID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".nGetPaddingTop")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nGetPaddingTop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, nSetPaddingTopID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".nSetPaddingTop")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nSetPaddingTop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double nGetPaddingRight()
 * void nSetPaddingRight(double)
 */
static int _paddingRight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, nGetPaddingRightID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".nGetPaddingRight")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nGetPaddingRight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, nSetPaddingRightID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".nSetPaddingRight")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nSetPaddingRight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double nGetPaddingBottom()
 * void nSetPaddingBottom(double)
 */
static int _paddingBottom(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, nGetPaddingBottomID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".nGetPaddingBottom")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nGetPaddingBottom", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, nSetPaddingBottomID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".nSetPaddingBottom")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nSetPaddingBottom", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void padding(double,double,double,double)
 */
static int _padding(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    lua_Number p3 = luaL_checknumber(L, 4);
    lua_Number p4 = luaL_checknumber(L, 5);
    (*env)->CallVoidMethod(env, jobj, paddingID, (jdouble)p1, (jdouble)p2, (jdouble)p3, (jdouble)p4);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".padding")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "padding", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getCrossSelf()
 * void setCrossSelf(int)
 */
static int _crossSelf(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getCrossSelfID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getCrossSelf")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getCrossSelf", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setCrossSelfID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setCrossSelf")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setCrossSelf", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getBasis()
 * void setBasis(float)
 */
static int _basis(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getBasisID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getBasis")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getBasis", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setBasisID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBasis")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBasis", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getGrow()
 * void setGrow(float)
 */
static int _grow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getGrowID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getGrow")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getGrow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setGrowID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setGrow")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setGrow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getShrink()
 * void setShrink(float)
 */
static int _shrink(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getShrinkID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getShrink")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getShrink", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setShrinkID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setShrink")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setShrink", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isDisplay()
 * void setDisplay(boolean)
 */
static int _display(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isDisplayID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isDisplay")) {
            return lua_error(L);
        }
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isDisplay", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setDisplayID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setDisplay")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setDisplay", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * int getPositionType()
 * void setPositionType(int)
 */
static int _positionType(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jint ret = (*env)->CallIntMethod(env, jobj, getPositionTypeID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPositionType")) {
            return lua_error(L);
        }
        lua_pushinteger(L, (lua_Integer) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPositionType", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, setPositionTypeID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPositionType")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPositionType", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getPositionLeft()
 * void setPositionLeft(double)
 */
static int _positionLeft(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getPositionLeftID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPositionLeft")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPositionLeft", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setPositionLeftID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPositionLeft")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPositionLeft", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getPositionTop()
 * void setPositionTop(double)
 */
static int _positionTop(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getPositionTopID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPositionTop")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPositionTop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setPositionTopID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPositionTop")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPositionTop", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getPositionRight()
 * void setPositionRight(double)
 */
static int _positionRight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getPositionRightID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPositionRight")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPositionRight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setPositionRightID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPositionRight")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPositionRight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * double getPositionBottom()
 * void setPositionBottom(double)
 */
static int _positionBottom(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jdouble ret = (*env)->CallDoubleMethod(env, jobj, getPositionBottomID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getPositionBottom")) {
            return lua_error(L);
        }
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getPositionBottom", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setPositionBottomID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setPositionBottom")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPositionBottom", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void rotation(float,boolean)
 */
static int _rotation(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    int p2 = lua_toboolean(L, 3);
    (*env)->CallVoidMethod(env, jobj, rotationID, (jfloat)p1, (jboolean)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".rotation")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "rotation", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void translation(double,double,boolean)
 */
static int _translation(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    int p3 = lua_toboolean(L, 4);
    (*env)->CallVoidMethod(env, jobj, translationID, (jdouble)p1, (jdouble)p2, (jboolean)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".translation")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "translation", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void scale(float,float,boolean)
 */
static int _scale(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    int p3 = lua_toboolean(L, 4);
    (*env)->CallVoidMethod(env, jobj, scaleID, (jfloat)p1, (jfloat)p2, (jboolean)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".scale")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scale", _get_milli_second(&end) - _get_milli_second(&start));
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
 * void viewWidth(double)
 */
static int _viewWidth(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, viewWidthID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".viewWidth")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "viewWidth", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void viewHeight(double)
 */
static int _viewHeight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, viewHeightID, (jdouble)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".viewHeight")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "viewHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void onClick(org.luaj.vm2.LuaFunction)
 */
static int _onClick(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, onClickID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".onClick")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "onClick", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void onLongPress(org.luaj.vm2.LuaFunction)
 */
static int _onLongPress(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, onLongPressID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".onLongPress")) {
        FREE(env, p1);
        return lua_error(L);
    }
    FREE(env, p1);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "onLongPress", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void childFirstHandlePointers(boolean)
 */
static int _childFirstHandlePointers(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, childFirstHandlePointersID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".childFirstHandlePointers")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "childFirstHandlePointers", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchBegin(long)
 */
static int _touchBegin(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, touchBeginID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchBegin")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchBegin", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchMove(long)
 */
static int _touchMove(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, touchMoveID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchMove")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchMove", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchEnd(long)
 */
static int _touchEnd(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, touchEndID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchEnd")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchEnd", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchCancel(long)
 */
static int _touchCancel(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, touchCancelID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchCancel")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchCancel", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchBeginExtension(long)
 */
static int _touchBeginExtension(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, touchBeginExtensionID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchBeginExtension")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchBeginExtension", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchMoveExtension(long)
 */
static int _touchMoveExtension(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, touchMoveExtensionID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchMoveExtension")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchMoveExtension", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchEndExtension(long)
 */
static int _touchEndExtension(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, touchEndExtensionID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchEndExtension")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchEndExtension", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void touchCancelExtension(long)
 */
static int _touchCancelExtension(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, touchCancelExtensionID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".touchCancelExtension")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchCancelExtension", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void scaleBegin(long)
 */
static int _scaleBegin(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, scaleBeginID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".scaleBegin")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scaleBegin", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void scaling(long)
 */
static int _scaling(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, scalingID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".scaling")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scaling", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void scaleEnd(long)
 */
static int _scaleEnd(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    luaL_checktype(L, 2, LUA_TFUNCTION);
    jlong p1 = (jlong) copyValueToGNV(L, 2);
    (*env)->CallVoidMethod(env, jobj, scaleEndID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".scaleEnd")) {
        return lua_error(L);
    }
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scaleEnd", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>
