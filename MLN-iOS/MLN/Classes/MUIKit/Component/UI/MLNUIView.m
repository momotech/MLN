//
//  MLNUIView.m
//  Pods
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNUIView.h"
#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUIKit.h"

@implementation MLNUIView

- (instancetype)initMLNUIViewWithMLNUILuaCore:(MLNUILuaCore *)luaCore {
    if (self = [super init]) {
        MLNUIError(luaCore, @"The View class is deprecated, please use HStack or VStack instead.")
    }
    return self;
}

#pragma mark - Override

- (BOOL)luaui_canClick
{
    return YES;
}

- (BOOL)luaui_canLongPress
{
    return YES;
}

- (BOOL)mlnui_layoutEnable
{
    return YES;
}

- (BOOL)luaui_isContainer
{
    return YES;
}

#pragma mark - Export For Lua

LUAUI_EXPORT_VIEW_BEGIN(MLNUIView)
// layout
LUAUI_EXPORT_VIEW_METHOD(getX, "luaui_getX",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(getY, "luaui_getY",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(layoutComplete, "luaui_layoutComplete:", MLNUIView)

LUAUI_EXPORT_VIEW_PROPERTY(display, "setLuaui_display:","luaui_display", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(mainAxis, "setLuaui_mainAxis:","luaui_mainAxis", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(crossSelf, "setLuaui_crossSelf:","luaui_crossSelf", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(crossAxis, "setLuaui_crossAxis:","luaui_crossAxis", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(crossContent, "setLuaui_crossContent:","luaui_crossContent", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(wrap, "setLuaui_wrap:","luaui_wrap", MLNUIView)

LUAUI_EXPORT_VIEW_PROPERTY(width, "setLuaui_width:","luaui_width", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(widthAuto, "setLuaui_widthAuto", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(viewWidth, "setLuaui_viewWidth:", "luaui_viewWidth", MLNUIView) // 业务不可使用，仅供LuaSDK使用
LUAUI_EXPORT_VIEW_PROPERTY(minWidth, "setLuaui_minWidth:","luaui_minWidth", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(maxWidth, "setLuaui_maxWidth:","luaui_maxWidth", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(widthPercent, "setLuaui_widthPercent:","luaui_widthPercent", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(minWidthPercent, "setLuaui_minWidthPercent:","luaui_minWidthPercent", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(maxWidthPercent, "setLuaui_maxWidthPercent:","luaui_maxWidthPercent", MLNUIView)

LUAUI_EXPORT_VIEW_PROPERTY(height, "setLuaui_height:","luaui_height", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(heightAuto, "setLuaui_heightAuto", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(minHeight, "setLuaui_minHeight:","luaui_minHeight", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(maxHeight, "setLuaui_maxHeight:","luaui_maxHeight", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(heightPercent, "setLuaui_heightPercent:","luaui_heightPercent", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(minHeightPercent, "setLuaui_minHeightPercent:","luaui_minHeightPercent", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(maxHeightPercent, "setLuaui_maxHeightPercent:","luaui_maxHeightPercent", MLNUIView)

LUAUI_EXPORT_VIEW_METHOD(padding, "luaui_setPaddingWithTop:right:bottom:left:", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(paddingTop, "setLuaui_paddingTop:","luaui_paddingTop", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(paddingLeft, "setLuaui_paddingLeft:","luaui_paddingLeft", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(paddingBottom, "setLuaui_paddingBottom:","luaui_paddingBottom", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(paddingRight, "setLuaui_paddingRight:","luaui_paddingRight", MLNUIView)

LUAUI_EXPORT_VIEW_METHOD(margin, "luaui_setMarginWithTop:right:bottom:left:", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(marginTop, "setLuaui_marginTop:","luaui_marginTop", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(marginLeft, "setLuaui_marginLeft:","luaui_marginLeft", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(marginBottom, "setLuaui_marginBottom:","luaui_marginBottom", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(marginRight, "setLuaui_marginRight:","luaui_marginRight", MLNUIView)

LUAUI_EXPORT_VIEW_PROPERTY(basis, "setLuaui_basis:","luaui_basis", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(grow, "setLuaui_grow:","luaui_grow", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(shrink, "setLuaui_shrink:","luaui_shrink", MLNUIView)

LUAUI_EXPORT_VIEW_PROPERTY(positionType, "setLuaui_positionType:","luaui_positionType", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(positionTop, "setLuaui_positionTop:","luaui_positionTop", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(positionLeft, "setLuaui_positionLeft:","luaui_positionLeft", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(positionBottom, "setLuaui_positionBottom:","luaui_positionBottom", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(positionRight, "setLuaui_positionRight:","luaui_positionRight", MLNUIView)

LUAUI_EXPORT_VIEW_METHOD(superview, "luaui_superview",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(addView, "luaui_addSubview:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(insertView, "luaui_insertSubview:atIndex:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(removeFromSuper, "luaui_removeFromSuperview",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(removeAllSubviews, "luaui_removeAllSubViews",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(convertPointTo, "luaui_convertToView:point:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(convertPointFrom, "luaui_convertFromView:point:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(convertRelativePointTo, "luaui_convertRelativePointToView:point:",MLNUIView)

// render
LUAUI_EXPORT_VIEW_PROPERTY(hidden, "setHidden:","isHidden", MLNView)
LUAUI_EXPORT_VIEW_PROPERTY(alpha, "setAlpha:","alpha", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(borderWidth, "luaui_setBorderWidth:","luaui_borderWidth", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(borderColor, "luaui_setBorderColor:","luaui_borderColor", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(bgColor, "luaui_setBackgroundColor:", "backgroundColor", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(cornerRadius, "luaui_setCornerRadius:","luaui_cornerRadius", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(refresh, "luaui_setNeedsDisplay", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setCornerRadiusWithDirection, "luaui_setCornerRadius:byRoundingCorners:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(getCornerRadiusWithDirection, "luaui_getCornerRadiusWithDirection:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(clipToChildren, "luaui_setClipsToChildren:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(clipToBounds, "luaui_setClipsToBounds:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(notClip, "luaui_setNotClip:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(addCornerMask, "luaui_addCornerMaskWithRadius:maskColor:corners:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setGradientColor, "luaui_setGradientColor:endColor:vertical:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setGradientColorWithDirection, "luaui_setGradientColor:endColor:direction:",MLNUIView)
// user interaction
LUAUI_EXPORT_VIEW_PROPERTY(enabled, "setLuaui_enable:","luaui_enable", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(onClick, "luaui_addClick:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(onLongPress, "luaui_addLongPress:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(onTouch, "luaui_addTouch:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(hasFocus, "isFirstResponder",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(canFocus, "canBecomeFirstResponder",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(requestFocus, "luaui_requestFocus",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(cancelFocus, "resignFirstResponder",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(touchBegin, "luaui_setTouchesBeganCallback:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(touchMove, "luaui_setTouchesMovedCallback:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(touchEnd, "luaui_setTouchesEndedCallback:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(touchCancel, "luaui_setTouchesCancelledCallback:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(touchBeginExtension, "luaui_setTouchesBeganExtensionCallback:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(touchMoveExtension, "luaui_setTouchesMovedExtensionCallback:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(touchEndExtension, "luaui_setTouchesEndedExtensionCallback:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(touchCancelExtension, "luaui_setTouchesCancelledExtensionCallback:",MLNUIView)
// transform
LUAUI_EXPORT_VIEW_METHOD(anchorPoint, "luaui_anchorPoint:y:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(transform, "luaui_transform:adding:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(rotation, "luaui_rotation:notNeedAdding:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(scale, "luaui_scale:sy:notNeedAdding:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(translation, "luaui_translation:ty:notNeedAdding:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(transformIdentity, "luaui_transformIdentity", MLNUIView)
// animation
LUAUI_EXPORT_VIEW_METHOD(removeAllAnimation, "luaui_removeAllAnimation",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(startAnimation, "luaui_startAnimation:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(clearAnimation, "luaui_clearAnimation",MLNUIView)
// screen capture
LUAUI_EXPORT_VIEW_METHOD(snapshot, "luaui_snapshotWithFileName:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(addBlurEffect, "luaui_addBlurEffect", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(removeBlurEffect, "luaui_removeBlurEffect", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(openRipple, "luaui_openRipple:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(canEndEditing, "luaui_endEditing:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(keyboardDismiss, "luaui_keyboardDismiss:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(bringSubviewToFront, "luaui_bringSubviewToFront:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(sendSubviewToBack, "luaui_sendSubviewToBack:", MLNUIView)
//view的背景图片
LUAUI_EXPORT_VIEW_METHOD(bgImage, "luaui_setBgImage:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(addShadow, "luaui_addShadow:shadowOffset:shadowRadius:shadowOpacity:isOval:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setShadow, "luaui_setShadowWithShadowOffset:shadowRadius:shadowOpacity:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(onDetachedView, "luaui_onDetachedFromWindowCallback:", MLNUIView)
LUAUI_EXPORT_VIEW_END(MLNUIView, View, NO, NULL, "initMLNUIViewWithMLNUILuaCore:")

@end
