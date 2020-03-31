//
//  MLNView.m
//  Pods
//
//  Created by MoMo on 2019/8/3.
//

#import "MLNView.h"
#import "MLNViewExporterMacro.h"
#import "UIView+MLNKit.h"

@implementation MLNView

#pragma mark - Override
- (BOOL)lua_canClick
{
    return YES;
}

- (BOOL)lua_canLongPress
{
    return YES;
}

- (BOOL)lua_layoutEnable
{
    return YES;
}

- (BOOL)lua_isContainer
{
    return YES;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNView)
// layout
LUA_EXPORT_VIEW_PROPERTY(x, "setLua_x:","lua_x", MLNView)
LUA_EXPORT_VIEW_PROPERTY(y, "setLua_y:","lua_y", MLNView)
LUA_EXPORT_VIEW_PROPERTY(width, "setLua_width:","lua_width", MLNView)
LUA_EXPORT_VIEW_PROPERTY(height, "setLua_height:","lua_height", MLNView)
LUA_EXPORT_VIEW_PROPERTY(right, "setLua_right:","lua_right", MLNView)
LUA_EXPORT_VIEW_PROPERTY(bottom, "setLua_bottom:","lua_bottom", MLNView)
LUA_EXPORT_VIEW_PROPERTY(centerX, "lua_setCenterX:","lua_centerX", MLNView)
LUA_EXPORT_VIEW_PROPERTY(centerY, "lua_setCenterY:","lua_centerY", MLNView)
LUA_EXPORT_VIEW_PROPERTY(frame, "setLua_frame:","lua_frame", MLNView)
LUA_EXPORT_VIEW_PROPERTY(size, "lua_setSize:","lua_size", MLNView)
LUA_EXPORT_VIEW_PROPERTY(point, "lua_setOrigin:","lua_origin", MLNView)
LUA_EXPORT_VIEW_PROPERTY(marginTop, "setLua_marginTop:","lua_marginTop", MLNView)
LUA_EXPORT_VIEW_PROPERTY(marginLeft, "setLua_marginLeft:","lua_marginLeft", MLNView)
LUA_EXPORT_VIEW_PROPERTY(marginBottom, "setLua_marginBottom:","lua_marginBottom", MLNView)
LUA_EXPORT_VIEW_PROPERTY(marginRight, "setLua_marginRight:","lua_marginRight", MLNView)
LUA_EXPORT_VIEW_PROPERTY(priority, "setLua_priority:","lua_priority", MLNView)
LUA_EXPORT_VIEW_PROPERTY(weight, "setLua_weight:","lua_weight", MLNView)
LUA_EXPORT_VIEW_METHOD(padding, "lua_setPaddingWithTop:right:bottom:left:", MLNView)
LUA_EXPORT_VIEW_METHOD(setMaxWidth, "setLua_maxWidth:",MLNView)
LUA_EXPORT_VIEW_METHOD(setMinWidth, "setLua_minWidth:",MLNView)
LUA_EXPORT_VIEW_METHOD(setMaxHeight, "setLua_maxHieght:",MLNView)
LUA_EXPORT_VIEW_METHOD(setMinHeight, "setLua_minHeight:",MLNView)
LUA_EXPORT_VIEW_METHOD(getCenterX, "lua_centerX", MLNView)
LUA_EXPORT_VIEW_METHOD(getCenterY, "lua_centerY", MLNView)
LUA_EXPORT_VIEW_METHOD(sizeToFit, "lua_sizeToFit",MLNView)
LUA_EXPORT_VIEW_METHOD(superview, "lua_superview",MLNView)
LUA_EXPORT_VIEW_METHOD(addView, "lua_addSubview:",MLNView)
LUA_EXPORT_VIEW_METHOD(insertView, "lua_insertSubview:atIndex:",MLNView)
LUA_EXPORT_VIEW_METHOD(removeFromSuper, "lua_removeFromSuperview",MLNView)
LUA_EXPORT_VIEW_METHOD(removeAllSubviews, "lua_removeAllSubViews",MLNView)
LUA_EXPORT_VIEW_METHOD(layoutIfNeeded, "lua_layoutIfNeed",MLNView)
LUA_EXPORT_VIEW_METHOD(convertPointTo, "lua_convertToView:point:",MLNView)
LUA_EXPORT_VIEW_METHOD(convertPointFrom, "lua_convertFromView:point:",MLNView)
LUA_EXPORT_VIEW_METHOD(setGravity, "setLua_gravity:",MLNView)
LUA_EXPORT_VIEW_METHOD(requestLayout, "lua_requestLayout", MLNView)
LUA_EXPORT_VIEW_METHOD(convertRelativePointTo, "lua_convertRelativePointToView:point:",MLNView)
LUA_EXPORT_VIEW_METHOD(overlay, "lua_overlay:", MLNView)
// render
LUA_EXPORT_VIEW_PROPERTY(alpha, "setAlpha:","alpha", MLNView)
LUA_EXPORT_VIEW_PROPERTY(hidden, "setHidden:","isHidden", MLNView)
LUA_EXPORT_VIEW_PROPERTY(gone, "setLua_gone:","lua_gone", MLNView)
LUA_EXPORT_VIEW_PROPERTY(borderWidth, "lua_setBorderWidth:","lua_borderWidth", MLNView)
LUA_EXPORT_VIEW_PROPERTY(borderColor, "lua_setBorderColor:","lua_borderColor", MLNView)
LUA_EXPORT_VIEW_PROPERTY(bgColor, "lua_setBackgroundColor:", "backgroundColor", MLNView)
LUA_EXPORT_VIEW_PROPERTY(cornerRadius, "lua_setCornerRadius:","lua_cornerRadius", MLNView)
LUA_EXPORT_VIEW_METHOD(refresh, "lua_setNeedsDisplay", MLNView)
LUA_EXPORT_VIEW_METHOD(setCornerRadiusWithDirection, "lua_setCornerRadius:byRoundingCorners:", MLNView)
LUA_EXPORT_VIEW_METHOD(getCornerRadiusWithDirection, "lua_getCornerRadiusWithDirection:", MLNView)
LUA_EXPORT_VIEW_METHOD(clipToBounds, "lua_setClipsToBounds:", MLNView)
LUA_EXPORT_VIEW_METHOD(notClip, "lua_setNotClip:", MLNView)
LUA_EXPORT_VIEW_METHOD(addCornerMask, "lua_addCornerMaskWithRadius:maskColor:corners:", MLNView)
LUA_EXPORT_VIEW_METHOD(setGradientColor, "lua_setGradientColor:endColor:vertical:",MLNView)
LUA_EXPORT_VIEW_METHOD(setGradientColorWithDirection, "lua_setGradientColor:endColor:direction:",MLNView)
// user interaction
LUA_EXPORT_VIEW_PROPERTY(enabled, "setLua_enable:","lua_enable", MLNView)
LUA_EXPORT_VIEW_METHOD(onClick, "lua_addClick:",MLNView)
LUA_EXPORT_VIEW_METHOD(onLongPress, "lua_addLongPress:",MLNView)
LUA_EXPORT_VIEW_METHOD(onTouch, "lua_addTouch:",MLNView)
LUA_EXPORT_VIEW_METHOD(hasFocus, "isFirstResponder",MLNView)
LUA_EXPORT_VIEW_METHOD(canFocus, "canBecomeFirstResponder",MLNView)
LUA_EXPORT_VIEW_METHOD(requestFocus, "lua_requestFocus",MLNView)
LUA_EXPORT_VIEW_METHOD(cancelFocus, "resignFirstResponder",MLNView)
LUA_EXPORT_VIEW_METHOD(touchBegin, "lua_setTouchesBeganCallback:",MLNView)
LUA_EXPORT_VIEW_METHOD(touchMove, "lua_setTouchesMovedCallback:",MLNView)
LUA_EXPORT_VIEW_METHOD(touchEnd, "lua_setTouchesEndedCallback:",MLNView)
LUA_EXPORT_VIEW_METHOD(touchCancel, "lua_setTouchesCancelledCallback:",MLNView)
LUA_EXPORT_VIEW_METHOD(touchBeginExtension, "lua_setTouchesBeganExtensionCallback:",MLNView)
LUA_EXPORT_VIEW_METHOD(touchMoveExtension, "lua_setTouchesMovedExtensionCallback:",MLNView)
LUA_EXPORT_VIEW_METHOD(touchEndExtension, "lua_setTouchesEndedExtensionCallback:",MLNView)
LUA_EXPORT_VIEW_METHOD(touchCancelExtension, "lua_setTouchesCancelledExtensionCallback:",MLNView)
// keyboard
LUA_EXPORT_VIEW_METHOD(setPositionAdjustForKeyboard, "lua_setPositionAdjustForKeyboard:",MLNView)
LUA_EXPORT_VIEW_METHOD(setPositionAdjustForKeyboardAndOffset, "lua_setPositionAdjustForKeyboard:offsetY:",MLNView)
// transform
LUA_EXPORT_VIEW_METHOD(anchorPoint, "lua_anchorPoint:y:", MLNView)
LUA_EXPORT_VIEW_METHOD(transform, "lua_transform:adding:", MLNView)
LUA_EXPORT_VIEW_METHOD(rotation, "lua_rotation:notNeedAdding:", MLNView)
LUA_EXPORT_VIEW_METHOD(scale, "lua_scale:sy:notNeedAdding:", MLNView)
LUA_EXPORT_VIEW_METHOD(translation, "lua_translation:ty:notNeedAdding:", MLNView)
LUA_EXPORT_VIEW_METHOD(transformIdentity, "lua_transformIdentity", MLNView)
// animation
LUA_EXPORT_VIEW_METHOD(removeAllAnimation, "lua_removeAllAnimation",MLNView)
LUA_EXPORT_VIEW_METHOD(startAnimation, "lua_startAnimation:",MLNView)
LUA_EXPORT_VIEW_METHOD(clearAnimation, "lua_clearAnimation",MLNView)
// screen capture
LUA_EXPORT_VIEW_METHOD(snapshot, "lua_snapshotWithFileName:", MLNView)
LUA_EXPORT_VIEW_METHOD(addBlurEffect, "lua_addBlurEffect", MLNView)
LUA_EXPORT_VIEW_METHOD(removeBlurEffect, "lua_removeBlurEffect", MLNView)
LUA_EXPORT_VIEW_METHOD(openRipple, "lua_openRipple:", MLNView)
LUA_EXPORT_VIEW_METHOD(canEndEditing, "lua_endEditing:", MLNView)
LUA_EXPORT_VIEW_METHOD(bringSubviewToFront, "lua_bringSubviewToFront:", MLNView)
LUA_EXPORT_VIEW_METHOD(sendSubviewToBack, "lua_sendSubviewToBack:", MLNView)
//view的背景图片
LUA_EXPORT_VIEW_METHOD(bgImage, "lua_setBgImage:", MLNView)
LUA_EXPORT_VIEW_METHOD(addShadow, "lua_addShadow:shadowOffset:shadowRadius:shadowOpacity:isOval:", MLNView)
LUA_EXPORT_VIEW_METHOD(setShadow, "lua_setShadowWithShadowOffset:shadowRadius:shadowOpacity:", MLNView)
LUA_EXPORT_VIEW_METHOD(onDetachedView, "lua_onDetachedFromWindowCallback:", MLNView)
LUA_EXPORT_VIEW_END(MLNView, View, NO, NULL, NULL)

@end
