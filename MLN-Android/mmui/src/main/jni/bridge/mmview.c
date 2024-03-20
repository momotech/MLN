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
#define LUA_CLASS_NAME "__BaseView"
#define META_NAME METATABLE_PREFIX "" LUA_CLASS_NAME

static jclass _globalClass;
//<editor-fold desc="method definition">
static jmethodID setMinWidthID;
static jmethodID getMinWidthID;
static int _minWidth(lua_State *L);
static jmethodID setMinWidthPercentID;
static jmethodID getMinWidthPercentID;
static int _minWidthPercent(lua_State *L);
static jmethodID setMaxWidthID;
static jmethodID getMaxWidthID;
static int _maxWidth(lua_State *L);
static jmethodID setMaxWidthPercentID;
static jmethodID getMaxWidthPercentID;
static int _maxWidthPercent(lua_State *L);
static jmethodID setMinHeightID;
static jmethodID getMinHeightID;
static int _minHeight(lua_State *L);
static jmethodID setMinHeightPercentID;
static jmethodID getMinHeightPercentID;
static int _minHeightPercent(lua_State *L);
static jmethodID setMaxHeightID;
static jmethodID getMaxHeightID;
static int _maxHeight(lua_State *L);
static jmethodID setMaxHeightPercentID;
static jmethodID getMaxHeightPercentID;
static int _maxHeightPercent(lua_State *L);
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
static jmethodID transformIdentityID;
static int _transformIdentity(lua_State *L);
static jmethodID rotation0ID;
static jmethodID rotation1ID;
static int _rotation(lua_State *L);
static jmethodID translation0ID;
static jmethodID translation1ID;
static int _translation(lua_State *L);
static jmethodID scale0ID;
static jmethodID scale1ID;
static int _scale(lua_State *L);
static jmethodID setAlphaID;
static jmethodID getAlphaID;
static int _alpha(lua_State *L);
static jmethodID onClickID;
static int _onClick(lua_State *L);
static jmethodID onLongPressID;
static int _onLongPress(lua_State *L);
static jmethodID bgImageID;
static int _bgImage(lua_State *L);
static jmethodID setBgColorID;
static jmethodID getBgColorID;
static int _bgColor(lua_State *L);
static jmethodID setGradientColorWithDirectionID;
static int _setGradientColorWithDirection(lua_State *L);
static jmethodID setGradientColorID;
static int _setGradientColor(lua_State *L);
static jmethodID setBorderWidthID;
static jmethodID getBorderWidthID;
static int _borderWidth(lua_State *L);
static jmethodID setBorderColorID;
static jmethodID getBorderColorID;
static int _borderColor(lua_State *L);
static jmethodID setCornerRadiusID;
static jmethodID getCornerRadiusID;
static int _cornerRadius(lua_State *L);
static jmethodID setCornerRadiusWithDirectionID;
static int _setCornerRadiusWithDirection(lua_State *L);
static jmethodID getCornerRadiusWithDirectionID;
static int _getCornerRadiusWithDirection(lua_State *L);
static jmethodID setShadow0ID;
static jmethodID setShadow1ID;
static jmethodID setShadow2ID;
static int _setShadow(lua_State *L);
static jmethodID addCornerMask0ID;
static jmethodID addCornerMask1ID;
static int _addCornerMask(lua_State *L);
static jmethodID clipToBoundsID;
static int _clipToBounds(lua_State *L);
static jmethodID clipToChildrenID;
static int _clipToChildren(lua_State *L);
static jmethodID convertPointToID;
static int _convertPointTo(lua_State *L);
static jmethodID convertPointFromID;
static int _convertPointFrom(lua_State *L);
static jmethodID touchBeginID;
static int _touchBegin(lua_State *L);
static jmethodID touchMoveID;
static int _touchMove(lua_State *L);
static jmethodID touchEndID;
static int _touchEnd(lua_State *L);
static jmethodID touchCancelID;
static int _touchCancel(lua_State *L);
static jmethodID scaleBeginID;
static int _scaleBegin(lua_State *L);
static jmethodID scalingID;
static int _scaling(lua_State *L);
static jmethodID scaleEndID;
static int _scaleEnd(lua_State *L);
static jmethodID nSetNotDispatchID;
static jmethodID nIsNotDispatchID;
static int _notDispatch(lua_State *L);
static jmethodID resetTouchTargetID;
static int _resetTouchTarget(lua_State *L);
static jmethodID anchorPointID;
static int _anchorPoint(lua_State *L);
static jmethodID removeFromSuperID;
static int _removeFromSuper(lua_State *L);
static jmethodID superviewID;
static int _superview(lua_State *L);
static jmethodID addBlurEffectID;
static int _addBlurEffect(lua_State *L);
static jmethodID removeBlurEffectID;
static int _removeBlurEffect(lua_State *L);
static jmethodID openRippleID;
static int _openRipple(lua_State *L);
static jmethodID canEndEditingID;
static int _canEndEditing(lua_State *L);
static jmethodID keyboardDismissID;
static int _keyboardDismiss(lua_State *L);
static jmethodID layoutCompleteID;
static int _layoutComplete(lua_State *L);
static jmethodID setEnabledID;
static jmethodID isEnabledID;
static int _enabled(lua_State *L);
static jmethodID setHiddenID;
static jmethodID isHiddenID;
static int _hidden(lua_State *L);
static jmethodID hasFocusID;
static int _hasFocus(lua_State *L);
static jmethodID canFocusID;
static int _canFocus(lua_State *L);
static jmethodID requestFocusID;
static int _requestFocus(lua_State *L);
static jmethodID cancelFocusID;
static int _cancelFocus(lua_State *L);
static jmethodID onDetachedViewID;
static int _onDetachedView(lua_State *L);
static jmethodID snapshotID;
static int _snapshot(lua_State *L);
//</editor-fold>
/**
 * -1: metatable
 */
static void fillUDMetatable(lua_State *L, const char *parentMeta) {
    static const luaL_Reg _methohds[] = {
            {"minWidth", _minWidth},
            {"minWidthPercent", _minWidthPercent},
            {"maxWidth", _maxWidth},
            {"maxWidthPercent", _maxWidthPercent},
            {"minHeight", _minHeight},
            {"minHeightPercent", _minHeightPercent},
            {"maxHeight", _maxHeight},
            {"maxHeightPercent", _maxHeightPercent},
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
            {"transformIdentity", _transformIdentity},
            {"rotation", _rotation},
            {"translation", _translation},
            {"scale", _scale},
            {"alpha", _alpha},
            {"onClick", _onClick},
            {"onLongPress", _onLongPress},
            {"bgImage", _bgImage},
            {"bgColor", _bgColor},
            {"setGradientColorWithDirection", _setGradientColorWithDirection},
            {"setGradientColor", _setGradientColor},
            {"borderWidth", _borderWidth},
            {"borderColor", _borderColor},
            {"cornerRadius", _cornerRadius},
            {"setCornerRadiusWithDirection", _setCornerRadiusWithDirection},
            {"getCornerRadiusWithDirection", _getCornerRadiusWithDirection},
            {"setShadow", _setShadow},
            {"addCornerMask", _addCornerMask},
            {"clipToBounds", _clipToBounds},
            {"clipToChildren", _clipToChildren},
            {"convertPointTo", _convertPointTo},
            {"convertPointFrom", _convertPointFrom},
            {"touchBegin", _touchBegin},
            {"touchMove", _touchMove},
            {"touchEnd", _touchEnd},
            {"touchCancel", _touchCancel},
            {"scaleBegin", _scaleBegin},
            {"scaling", _scaling},
            {"scaleEnd", _scaleEnd},
            {"notDispatch", _notDispatch},
            {"resetTouchTarget", _resetTouchTarget},
            {"anchorPoint", _anchorPoint},
            {"removeFromSuper", _removeFromSuper},
            {"superview", _superview},
            {"addBlurEffect", _addBlurEffect},
            {"removeBlurEffect", _removeBlurEffect},
            {"openRipple", _openRipple},
            {"canEndEditing", _canEndEditing},
            {"keyboardDismiss", _keyboardDismiss},
            {"layoutComplete", _layoutComplete},
            {"enabled", _enabled},
            {"hidden", _hidden},
            {"hasFocus", _hasFocus},
            {"canFocus", _canFocus},
            {"requestFocus", _requestFocus},
            {"cancelFocus", _cancelFocus},
            {"onDetachedView", _onDetachedView},
            {"snapshot", _snapshot},
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
    setMinWidthID = (*env)->GetMethodID(env, clz, "setMinWidth", "(F)V");
    getMinWidthID = (*env)->GetMethodID(env, clz, "getMinWidth", "()F");
    setMinWidthPercentID = (*env)->GetMethodID(env, clz, "setMinWidthPercent", "(F)V");
    getMinWidthPercentID = (*env)->GetMethodID(env, clz, "getMinWidthPercent", "()F");
    setMaxWidthID = (*env)->GetMethodID(env, clz, "setMaxWidth", "(F)V");
    getMaxWidthID = (*env)->GetMethodID(env, clz, "getMaxWidth", "()F");
    setMaxWidthPercentID = (*env)->GetMethodID(env, clz, "setMaxWidthPercent", "(F)V");
    getMaxWidthPercentID = (*env)->GetMethodID(env, clz, "getMaxWidthPercent", "()F");
    setMinHeightID = (*env)->GetMethodID(env, clz, "setMinHeight", "(F)V");
    getMinHeightID = (*env)->GetMethodID(env, clz, "getMinHeight", "()F");
    setMinHeightPercentID = (*env)->GetMethodID(env, clz, "setMinHeightPercent", "(F)V");
    getMinHeightPercentID = (*env)->GetMethodID(env, clz, "getMinHeightPercent", "()F");
    setMaxHeightID = (*env)->GetMethodID(env, clz, "setMaxHeight", "(F)V");
    getMaxHeightID = (*env)->GetMethodID(env, clz, "getMaxHeight", "()F");
    setMaxHeightPercentID = (*env)->GetMethodID(env, clz, "setMaxHeightPercent", "(F)V");
    getMaxHeightPercentID = (*env)->GetMethodID(env, clz, "getMaxHeightPercent", "()F");
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
    transformIdentityID = (*env)->GetMethodID(env, clz, "transformIdentity", "()V");
    rotation0ID = (*env)->GetMethodID(env, clz, "rotation", "(F)V");
    rotation1ID = (*env)->GetMethodID(env, clz, "rotation", "(FZ)V");
    translation0ID = (*env)->GetMethodID(env, clz, "translation", "(DD)V");
    translation1ID = (*env)->GetMethodID(env, clz, "translation", "(DDZ)V");
    scale0ID = (*env)->GetMethodID(env, clz, "scale", "(FF)V");
    scale1ID = (*env)->GetMethodID(env, clz, "scale", "(FFZ)V");
    setAlphaID = (*env)->GetMethodID(env, clz, "setAlpha", "(F)V");
    getAlphaID = (*env)->GetMethodID(env, clz, "getAlpha", "()F");
    onClickID = (*env)->GetMethodID(env, clz, "onClick", "(Lorg/luaj/vm2/LuaFunction;)V");
    onLongPressID = (*env)->GetMethodID(env, clz, "onLongPress", "(Lorg/luaj/vm2/LuaFunction;)V");
    bgImageID = (*env)->GetMethodID(env, clz, "bgImage", "(Ljava/lang/String;)V");
    setBgColorID = (*env)->GetMethodID(env, clz, "setBgColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    getBgColorID = (*env)->GetMethodID(env, clz, "getBgColor", "()Lcom/immomo/mmui/ud/UDColor;");
    setGradientColorWithDirectionID = (*env)->GetMethodID(env, clz, "setGradientColorWithDirection", "(Lcom/immomo/mmui/ud/UDColor;Lcom/immomo/mmui/ud/UDColor;I)V");
    setGradientColorID = (*env)->GetMethodID(env, clz, "setGradientColor", "(Lcom/immomo/mmui/ud/UDColor;Lcom/immomo/mmui/ud/UDColor;Z)V");
    setBorderWidthID = (*env)->GetMethodID(env, clz, "setBorderWidth", "(F)V");
    getBorderWidthID = (*env)->GetMethodID(env, clz, "getBorderWidth", "()F");
    setBorderColorID = (*env)->GetMethodID(env, clz, "setBorderColor", "(Lcom/immomo/mmui/ud/UDColor;)V");
    getBorderColorID = (*env)->GetMethodID(env, clz, "getBorderColor", "()Lcom/immomo/mmui/ud/UDColor;");
    setCornerRadiusID = (*env)->GetMethodID(env, clz, "setCornerRadius", "(F)V");
    getCornerRadiusID = (*env)->GetMethodID(env, clz, "getCornerRadius", "()F");
    setCornerRadiusWithDirectionID = (*env)->GetMethodID(env, clz, "setCornerRadiusWithDirection", "(FI)V");
    getCornerRadiusWithDirectionID = (*env)->GetMethodID(env, clz, "getCornerRadiusWithDirection", "(I)F");
    setShadow0ID = (*env)->GetMethodID(env, clz, "setShadow", "(FF)V");
    setShadow1ID = (*env)->GetMethodID(env, clz, "setShadow", "(FFF)V");
    setShadow2ID = (*env)->GetMethodID(env, clz, "setShadow", "(FFFF)V");
    addCornerMask0ID = (*env)->GetMethodID(env, clz, "addCornerMask", "(FLcom/immomo/mmui/ud/UDColor;)V");
    addCornerMask1ID = (*env)->GetMethodID(env, clz, "addCornerMask", "(FLcom/immomo/mmui/ud/UDColor;I)V");
    clipToBoundsID = (*env)->GetMethodID(env, clz, "clipToBounds", "(Z)V");
    clipToChildrenID = (*env)->GetMethodID(env, clz, "clipToChildren", "(Z)V");
    convertPointToID = (*env)->GetMethodID(env, clz, "convertPointTo", "(Lcom/immomo/mmui/ud/UDView;Lcom/immomo/mmui/ud/UDPoint;)Lcom/immomo/mmui/ud/UDPoint;");
    convertPointFromID = (*env)->GetMethodID(env, clz, "convertPointFrom", "(Lcom/immomo/mmui/ud/UDView;Lcom/immomo/mmui/ud/UDPoint;)Lcom/immomo/mmui/ud/UDPoint;");
    touchBeginID = (*env)->GetMethodID(env, clz, "touchBegin", "(J)V");
    touchMoveID = (*env)->GetMethodID(env, clz, "touchMove", "(J)V");
    touchEndID = (*env)->GetMethodID(env, clz, "touchEnd", "(J)V");
    touchCancelID = (*env)->GetMethodID(env, clz, "touchCancel", "(J)V");
    scaleBeginID = (*env)->GetMethodID(env, clz, "scaleBegin", "(J)V");
    scalingID = (*env)->GetMethodID(env, clz, "scaling", "(J)V");
    scaleEndID = (*env)->GetMethodID(env, clz, "scaleEnd", "(J)V");
    nSetNotDispatchID = (*env)->GetMethodID(env, clz, "nSetNotDispatch", "(Z)V");
    nIsNotDispatchID = (*env)->GetMethodID(env, clz, "nIsNotDispatch", "()Z");
    resetTouchTargetID = (*env)->GetMethodID(env, clz, "resetTouchTarget", "(I)V");
    anchorPointID = (*env)->GetMethodID(env, clz, "anchorPoint", "(FF)V");
    removeFromSuperID = (*env)->GetMethodID(env, clz, "removeFromSuper", "()V");
    superviewID = (*env)->GetMethodID(env, clz, "superview", "()Lcom/immomo/mmui/ud/UDView;");
    addBlurEffectID = (*env)->GetMethodID(env, clz, "addBlurEffect", "()V");
    removeBlurEffectID = (*env)->GetMethodID(env, clz, "removeBlurEffect", "()V");
    openRippleID = (*env)->GetMethodID(env, clz, "openRipple", "(Z)V");
    canEndEditingID = (*env)->GetMethodID(env, clz, "canEndEditing", "(Z)V");
    keyboardDismissID = (*env)->GetMethodID(env, clz, "keyboardDismiss", "(Z)V");
    layoutCompleteID = (*env)->GetMethodID(env, clz, "layoutComplete", "(Lorg/luaj/vm2/LuaFunction;)V");
    setEnabledID = (*env)->GetMethodID(env, clz, "setEnabled", "(Z)V");
    isEnabledID = (*env)->GetMethodID(env, clz, "isEnabled", "()Z");
    setHiddenID = (*env)->GetMethodID(env, clz, "setHidden", "(Z)V");
    isHiddenID = (*env)->GetMethodID(env, clz, "isHidden", "()Z");
    hasFocusID = (*env)->GetMethodID(env, clz, "hasFocus", "()Z");
    canFocusID = (*env)->GetMethodID(env, clz, "canFocus", "()Z");
    requestFocusID = (*env)->GetMethodID(env, clz, "requestFocus", "()V");
    cancelFocusID = (*env)->GetMethodID(env, clz, "cancelFocus", "()V");
    onDetachedViewID = (*env)->GetMethodID(env, clz, "onDetachedView", "(Lorg/luaj/vm2/LuaFunction;)V");
    snapshotID = (*env)->GetMethodID(env, clz, "snapshot", "(Ljava/lang/String;)Ljava/lang/String;");
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
 * float getMinWidth()
 * void setMinWidth(float)
 */
static int _minWidth(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getMinWidthID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMinWidth")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMinWidth", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMinWidthID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMinWidth")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMinWidth", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getMinWidthPercent()
 * void setMinWidthPercent(float)
 */
static int _minWidthPercent(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getMinWidthPercentID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMinWidthPercent")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMinWidthPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMinWidthPercentID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMinWidthPercent")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMinWidthPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getMaxWidth()
 * void setMaxWidth(float)
 */
static int _maxWidth(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getMaxWidthID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMaxWidth")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMaxWidth", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMaxWidthID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMaxWidth")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMaxWidth", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getMaxWidthPercent()
 * void setMaxWidthPercent(float)
 */
static int _maxWidthPercent(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getMaxWidthPercentID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMaxWidthPercent")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMaxWidthPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMaxWidthPercentID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMaxWidthPercent")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMaxWidthPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getMinHeight()
 * void setMinHeight(float)
 */
static int _minHeight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getMinHeightID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMinHeight")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMinHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMinHeightID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMinHeight")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMinHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getMinHeightPercent()
 * void setMinHeightPercent(float)
 */
static int _minHeightPercent(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getMinHeightPercentID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMinHeightPercent")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMinHeightPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMinHeightPercentID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMinHeightPercent")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMinHeightPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getMaxHeight()
 * void setMaxHeight(float)
 */
static int _maxHeight(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getMaxHeightID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMaxHeight")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMaxHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMaxHeightID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMaxHeight")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMaxHeight", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getMaxHeightPercent()
 * void setMaxHeightPercent(float)
 */
static int _maxHeightPercent(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getMaxHeightPercentID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getMaxHeightPercent")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getMaxHeightPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setMaxHeightPercentID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setMaxHeightPercent")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setMaxHeightPercent", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setPositionBottom", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void transformIdentity()
 */
static int _transformIdentity(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, transformIdentityID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".transformIdentity")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "transformIdentity", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void rotation(float)
 * void rotation(float,boolean)
 */
static int _rotation(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_isboolean(L, 3)) {
            lua_Number p1 = luaL_checknumber(L, 2);
            int p2 = lua_toboolean(L, 3);
            (*env)->CallVoidMethod(env, jobj, rotation1ID, (jfloat)p1, (jboolean)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".rotation")) {
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "rotation", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".rotation函数2个参数有: (float,boolean)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    if (lua_gettop(L) == 2) {
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            (*env)->CallVoidMethod(env, jobj, rotation0ID, (jfloat)p1);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".rotation")) {
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "rotation", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".rotation函数1个参数有: (float)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
    return 1;
}
/**
 * void translation(double,double)
 * void translation(double,double,boolean)
 */
static int _translation(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER&&lua_isboolean(L, 4)) {
            lua_Number p1 = luaL_checknumber(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            int p3 = lua_toboolean(L, 4);
            (*env)->CallVoidMethod(env, jobj, translation1ID, (jdouble)p1, (jdouble)p2, (jboolean)p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".translation")) {
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "translation", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".translation函数3个参数有: (double,double,boolean)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            (*env)->CallVoidMethod(env, jobj, translation0ID, (jdouble)p1, (jdouble)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".translation")) {
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "translation", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".translation函数2个参数有: (double,double)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
    return 1;
}
/**
 * void scale(float,float)
 * void scale(float,float,boolean)
 */
static int _scale(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER&&lua_isboolean(L, 4)) {
            lua_Number p1 = luaL_checknumber(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            int p3 = lua_toboolean(L, 4);
            (*env)->CallVoidMethod(env, jobj, scale1ID, (jfloat)p1, (jfloat)p2, (jboolean)p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".scale")) {
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scale", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".scale函数3个参数有: (float,float,boolean)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            (*env)->CallVoidMethod(env, jobj, scale0ID, (jfloat)p1, (jfloat)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".scale")) {
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scale", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".scale函数2个参数有: (float,float)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
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
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setAlpha", _get_milli_second(&end) - _get_milli_second(&start));
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "onLongPress", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void bgImage(java.lang.String)
 */
static int _bgImage(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    (*env)->CallVoidMethod(env, jobj, bgImageID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".bgImage")) {
        FREE(env, p1);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "bgImage", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDColor getBgColor()
 * void setBgColor(com.immomo.mmui.ud.UDColor)
 */
static int _bgColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getBgColorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getBgColor")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getBgColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setBgColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBgColor")) {
        FREE(env, p1);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBgColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setGradientColorWithDirection(com.immomo.mmui.ud.UDColor,com.immomo.mmui.ud.UDColor,int)
 */
static int _setGradientColorWithDirection(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    lua_Integer p3 = luaL_checkinteger(L, 4);
    (*env)->CallVoidMethod(env, jobj, setGradientColorWithDirectionID, p1, p2, (jint)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setGradientColorWithDirection")) {
        FREE(env, p1);
        FREE(env, p2);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setGradientColorWithDirection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setGradientColor(com.immomo.mmui.ud.UDColor,com.immomo.mmui.ud.UDColor,boolean)
 */
static int _setGradientColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    int p3 = lua_toboolean(L, 4);
    (*env)->CallVoidMethod(env, jobj, setGradientColorID, p1, p2, (jboolean)p3);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setGradientColor")) {
        FREE(env, p1);
        FREE(env, p2);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setGradientColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getBorderWidth()
 * void setBorderWidth(float)
 */
static int _borderWidth(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getBorderWidthID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getBorderWidth")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getBorderWidth", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setBorderWidthID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBorderWidth")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBorderWidth", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDColor getBorderColor()
 * void setBorderColor(com.immomo.mmui.ud.UDColor)
 */
static int _borderColor(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jobject ret = (*env)->CallObjectMethod(env, jobj, getBorderColorID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getBorderColor")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        pushJavaValue(env, L, ret);
        FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getBorderColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, setBorderColorID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setBorderColor")) {
        FREE(env, p1);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setBorderColor", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getCornerRadius()
 * void setCornerRadius(float)
 */
static int _cornerRadius(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jfloat ret = (*env)->CallFloatMethod(env, jobj, getCornerRadiusID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".getCornerRadius")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getCornerRadius", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    lua_Number p1 = luaL_checknumber(L, 2);
    (*env)->CallVoidMethod(env, jobj, setCornerRadiusID, (jfloat)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setCornerRadius")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setCornerRadius", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setCornerRadiusWithDirection(float,int)
 */
static int _setCornerRadiusWithDirection(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Integer p2 = luaL_checkinteger(L, 3);
    (*env)->CallVoidMethod(env, jobj, setCornerRadiusWithDirectionID, (jfloat)p1, (jint)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setCornerRadiusWithDirection")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setCornerRadiusWithDirection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * float getCornerRadiusWithDirection(int)
 */
static int _getCornerRadiusWithDirection(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    jfloat ret = (*env)->CallFloatMethod(env, jobj, getCornerRadiusWithDirectionID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".getCornerRadiusWithDirection")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    push_number(L, (jdouble) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "getCornerRadiusWithDirection", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void setShadow(float,float)
 * void setShadow(float,float,float)
 * void setShadow(float,float,float,float)
 */
static int _setShadow(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 5) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER&&lua_type(L, 4) == LUA_TNUMBER&&lua_type(L, 5) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            lua_Number p3 = luaL_checknumber(L, 4);
            lua_Number p4 = luaL_checknumber(L, 5);
            (*env)->CallVoidMethod(env, jobj, setShadow2ID, (jfloat)p1, (jfloat)p2, (jfloat)p3, (jfloat)p4);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".setShadow")) {
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setShadow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".setShadow函数4个参数有: (float,float,float,float)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER&&lua_type(L, 4) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            lua_Number p3 = luaL_checknumber(L, 4);
            (*env)->CallVoidMethod(env, jobj, setShadow1ID, (jfloat)p1, (jfloat)p2, (jfloat)p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".setShadow")) {
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setShadow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".setShadow函数3个参数有: (float,float,float)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 3) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            lua_Number p2 = luaL_checknumber(L, 3);
            (*env)->CallVoidMethod(env, jobj, setShadow0ID, (jfloat)p1, (jfloat)p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".setShadow")) {
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setShadow", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".setShadow函数2个参数有: (float,float)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
    return 1;
}
/**
 * void addCornerMask(float,com.immomo.mmui.ud.UDColor)
 * void addCornerMask(float,com.immomo.mmui.ud.UDColor,int)
 */
static int _addCornerMask(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    REMOVE_TOP(L)
    if (lua_gettop(L) == 4) {
        if (lua_type(L, 2) == LUA_TNUMBER&&lua_type(L, 4) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            jobject p2 = toJavaValue(env, L, 3);
            lua_Integer p3 = luaL_checkinteger(L, 4);
            (*env)->CallVoidMethod(env, jobj, addCornerMask1ID, (jfloat)p1, p2, (jint)p3);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".addCornerMask")) {
                FREE(env, p2);
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, p2);
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "addCornerMask", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".addCornerMask函数3个参数有: (float,UDColor,int)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    if (lua_gettop(L) == 3) {
        if (lua_type(L, 2) == LUA_TNUMBER) {
            lua_Number p1 = luaL_checknumber(L, 2);
            jobject p2 = toJavaValue(env, L, 3);
            (*env)->CallVoidMethod(env, jobj, addCornerMask0ID, (jfloat)p1, p2);
            if (catchJavaException(env, L, LUA_CLASS_NAME ".addCornerMask")) {
                FREE(env, p2);
                FREE(env, jobj);
                return lua_error(L);
            }
            FREE(env, p2);
            FREE(env, jobj);
            lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
            gettimeofday(&end, NULL);
            userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "addCornerMask", _get_milli_second(&end) - _get_milli_second(&start));
#endif
            return 1;
        }
        dumpParams(L, 2);
        lua_pushfstring(L, LUA_CLASS_NAME ".addCornerMask函数2个参数有: (float,UDColor)  ，当前参数不匹配 (%s)", lua_tostring(L, -1));
        setErrorType(L, lua);
         return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
    return 1;
}
/**
 * void clipToBounds(boolean)
 */
static int _clipToBounds(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, clipToBoundsID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".clipToBounds")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "clipToBounds", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void clipToChildren(boolean)
 */
static int _clipToChildren(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, clipToChildrenID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".clipToChildren")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "clipToChildren", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDPoint convertPointTo(com.immomo.mmui.ud.UDView,com.immomo.mmui.ud.UDPoint)
 */
static int _convertPointTo(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    jobject ret = (*env)->CallObjectMethod(env, jobj, convertPointToID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".convertPointTo")) {
        FREE(env, p1);
        FREE(env, p2);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    FREE(env, jobj);
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "convertPointTo", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDPoint convertPointFrom(com.immomo.mmui.ud.UDView,com.immomo.mmui.ud.UDPoint)
 */
static int _convertPointFrom(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    jobject p2 = lua_isnil(L, 3) ? NULL : toJavaValue(env, L, 3);
    jobject ret = (*env)->CallObjectMethod(env, jobj, convertPointFromID, p1, p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".convertPointFrom")) {
        FREE(env, p1);
        FREE(env, p2);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, p2);
    FREE(env, jobj);
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "convertPointFrom", _get_milli_second(&end) - _get_milli_second(&start));
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "touchCancel", _get_milli_second(&end) - _get_milli_second(&start));
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
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
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "scaleEnd", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean nIsNotDispatch()
 * void nSetNotDispatch(boolean)
 */
static int _notDispatch(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, nIsNotDispatchID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".nIsNotDispatch")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nIsNotDispatch", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, nSetNotDispatchID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".nSetNotDispatch")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "nSetNotDispatch", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void resetTouchTarget(int)
 */
static int _resetTouchTarget(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Integer p1 = luaL_checkinteger(L, 2);
    (*env)->CallVoidMethod(env, jobj, resetTouchTargetID, (jint)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".resetTouchTarget")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "resetTouchTarget", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void anchorPoint(float,float)
 */
static int _anchorPoint(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    lua_Number p1 = luaL_checknumber(L, 2);
    lua_Number p2 = luaL_checknumber(L, 3);
    (*env)->CallVoidMethod(env, jobj, anchorPointID, (jfloat)p1, (jfloat)p2);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".anchorPoint")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "anchorPoint", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void removeFromSuper()
 */
static int _removeFromSuper(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, removeFromSuperID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeFromSuper")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeFromSuper", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * com.immomo.mmui.ud.UDView superview()
 */
static int _superview(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject ret = (*env)->CallObjectMethod(env, jobj, superviewID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".superview")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    pushJavaValue(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "superview", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void addBlurEffect()
 */
static int _addBlurEffect(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, addBlurEffectID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".addBlurEffect")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "addBlurEffect", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void removeBlurEffect()
 */
static int _removeBlurEffect(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, removeBlurEffectID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".removeBlurEffect")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "removeBlurEffect", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void openRipple(boolean)
 */
static int _openRipple(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, openRippleID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".openRipple")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "openRipple", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void canEndEditing(boolean)
 */
static int _canEndEditing(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, canEndEditingID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".canEndEditing")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "canEndEditing", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void keyboardDismiss(boolean)
 */
static int _keyboardDismiss(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, keyboardDismissID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".keyboardDismiss")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "keyboardDismiss", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void layoutComplete(org.luaj.vm2.LuaFunction)
 */
static int _layoutComplete(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, layoutCompleteID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".layoutComplete")) {
        FREE(env, p1);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "layoutComplete", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isEnabled()
 * void setEnabled(boolean)
 */
static int _enabled(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isEnabledID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isEnabled")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isEnabled", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setEnabledID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setEnabled")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setEnabled", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean isHidden()
 * void setHidden(boolean)
 */
static int _hidden(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    if (lua_gettop(L) == 1) {
        jboolean ret = (*env)->CallBooleanMethod(env, jobj, isHiddenID);
        if (catchJavaException(env, L, LUA_CLASS_NAME ".isHidden")) {
            FREE(env, jobj);
            return lua_error(L);
        }
        FREE(env, jobj);
        lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
        gettimeofday(&end, NULL);
        userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "isHidden", _get_milli_second(&end) - _get_milli_second(&start));
#endif
        return 1;
    }
    int p1 = lua_toboolean(L, 2);
    (*env)->CallVoidMethod(env, jobj, setHiddenID, (jboolean)p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".setHidden")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "setHidden", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean hasFocus()
 */
static int _hasFocus(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jboolean ret = (*env)->CallBooleanMethod(env, jobj, hasFocusID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".hasFocus")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "hasFocus", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * boolean canFocus()
 */
static int _canFocus(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jboolean ret = (*env)->CallBooleanMethod(env, jobj, canFocusID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".canFocus")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_pushboolean(L, (int) ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "canFocus", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void requestFocus()
 */
static int _requestFocus(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, requestFocusID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".requestFocus")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "requestFocus", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void cancelFocus()
 */
static int _cancelFocus(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    (*env)->CallVoidMethod(env, jobj, cancelFocusID);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".cancelFocus")) {
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "cancelFocus", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * void onDetachedView(org.luaj.vm2.LuaFunction)
 */
static int _onDetachedView(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jobject p1 = lua_isnil(L, 2) ? NULL : toJavaValue(env, L, 2);
    (*env)->CallVoidMethod(env, jobj, onDetachedViewID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".onDetachedView")) {
        FREE(env, p1);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, jobj);
    lua_settop(L, 1);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "onDetachedView", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
/**
 * java.lang.String snapshot(java.lang.String)
 */
static int _snapshot(lua_State *L) {
#ifdef STATISTIC_PERFORMANCE
    struct timeval start = {0};
    struct timeval end = {0};
    gettimeofday(&start, NULL);
#endif
    PRE
    jstring p1 = lua_isnil(L, 2) ? NULL : newJString(env, lua_tostring(L, 2));
    jstring ret = (*env)->CallObjectMethod(env, jobj, snapshotID, p1);
    if (catchJavaException(env, L, LUA_CLASS_NAME ".snapshot")) {
        FREE(env, p1);
        FREE(env, jobj);
        return lua_error(L);
    }
    FREE(env, p1);
    FREE(env, jobj);
    pushJavaString(env, L, ret);
    FREE(env, ret);
#ifdef STATISTIC_PERFORMANCE
    gettimeofday(&end, NULL);
    userdataMethodCall(ud->name + strlen(METATABLE_PREFIX), "snapshot", _get_milli_second(&end) - _get_milli_second(&start));
#endif
    return 1;
}
//</editor-fold>
