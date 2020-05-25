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
LUA_EXPORT_VIEW_BEGIN(MLNUIView)
// layout
LUA_EXPORT_VIEW_PROPERTY(x, "setLua_x:","lua_x", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(y, "setLua_y:","lua_y", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(width, "setLua_width:","lua_width", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(height, "setLua_height:","lua_height", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(right, "setLua_right:","lua_right", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(bottom, "setLua_bottom:","lua_bottom", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(centerX, "lua_setCenterX:","lua_centerX", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(centerY, "lua_setCenterY:","lua_centerY", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(frame, "setLua_frame:","lua_frame", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(size, "lua_setSize:","lua_size", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(point, "lua_setOrigin:","lua_origin", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(marginTop, "setLua_marginTop:","lua_marginTop", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(marginLeft, "setLua_marginLeft:","lua_marginLeft", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(marginBottom, "setLua_marginBottom:","lua_marginBottom", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(marginRight, "setLua_marginRight:","lua_marginRight", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(priority, "setLua_priority:","lua_priority", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(weight, "setLua_weight:","lua_weight", MLNUIView)
LUA_EXPORT_VIEW_METHOD(padding, "lua_setPaddingWithTop:right:bottom:left:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(setMaxWidth, "setLua_maxWidth:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setMinWidth, "setLua_minWidth:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setMaxHeight, "setLua_maxHieght:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setMinHeight, "setLua_minHeight:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(getCenterX, "lua_centerX", MLNUIView)
LUA_EXPORT_VIEW_METHOD(getCenterY, "lua_centerY", MLNUIView)
LUA_EXPORT_VIEW_METHOD(sizeToFit, "lua_sizeToFit",MLNUIView)
LUA_EXPORT_VIEW_METHOD(superview, "lua_superview",MLNUIView)
LUA_EXPORT_VIEW_METHOD(addView, "lua_addSubview:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(insertView, "lua_insertSubview:atIndex:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(removeFromSuper, "lua_removeFromSuperview",MLNUIView)
LUA_EXPORT_VIEW_METHOD(removeAllSubviews, "lua_removeAllSubViews",MLNUIView)
LUA_EXPORT_VIEW_METHOD(layoutIfNeeded, "lua_layoutIfNeed",MLNUIView)
LUA_EXPORT_VIEW_METHOD(convertPointTo, "lua_convertToView:point:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(convertPointFrom, "lua_convertFromView:point:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setGravity, "setLua_gravity:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(requestLayout, "lua_requestLayout", MLNUIView)
LUA_EXPORT_VIEW_METHOD(convertRelativePointTo, "lua_convertRelativePointToView:point:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(overlay, "lua_overlay:", MLNUIView)
// render
LUA_EXPORT_VIEW_PROPERTY(alpha, "setAlpha:","alpha", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(hidden, "setHidden:","isHidden", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(gone, "setLua_gone:","lua_gone", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(borderWidth, "lua_setBorderWidth:","lua_borderWidth", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(borderColor, "lua_setBorderColor:","lua_borderColor", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(bgColor, "lua_setBackgroundColor:", "backgroundColor", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(cornerRadius, "lua_setCornerRadius:","lua_cornerRadius", MLNUIView)
LUA_EXPORT_VIEW_METHOD(refresh, "lua_setNeedsDisplay", MLNUIView)
LUA_EXPORT_VIEW_METHOD(setCornerRadiusWithDirection, "lua_setCornerRadius:byRoundingCorners:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(getCornerRadiusWithDirection, "lua_getCornerRadiusWithDirection:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(clipToChildren, "lua_setClipsToChildren:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(clipToBounds, "lua_setClipsToBounds:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(notClip, "lua_setNotClip:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(addCornerMask, "lua_addCornerMaskWithRadius:maskColor:corners:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(setGradientColor, "lua_setGradientColor:endColor:vertical:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setGradientColorWithDirection, "lua_setGradientColor:endColor:direction:",MLNUIView)
// user interaction
LUA_EXPORT_VIEW_PROPERTY(enabled, "setLua_enable:","lua_enable", MLNUIView)
LUA_EXPORT_VIEW_METHOD(onClick, "lua_addClick:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(onLongPress, "lua_addLongPress:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(onTouch, "lua_addTouch:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(hasFocus, "isFirstResponder",MLNUIView)
LUA_EXPORT_VIEW_METHOD(canFocus, "canBecomeFirstResponder",MLNUIView)
LUA_EXPORT_VIEW_METHOD(requestFocus, "lua_requestFocus",MLNUIView)
LUA_EXPORT_VIEW_METHOD(cancelFocus, "resignFirstResponder",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchBegin, "lua_setTouchesBeganCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchMove, "lua_setTouchesMovedCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchEnd, "lua_setTouchesEndedCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchCancel, "lua_setTouchesCancelledCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchBeginExtension, "lua_setTouchesBeganExtensionCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchMoveExtension, "lua_setTouchesMovedExtensionCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchEndExtension, "lua_setTouchesEndedExtensionCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchCancelExtension, "lua_setTouchesCancelledExtensionCallback:",MLNUIView)
// keyboard
LUA_EXPORT_VIEW_METHOD(setPositionAdjustForKeyboard, "lua_setPositionAdjustForKeyboard:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setPositionAdjustForKeyboardAndOffset, "lua_setPositionAdjustForKeyboard:offsetY:",MLNUIView)
// transform
LUA_EXPORT_VIEW_METHOD(anchorPoint, "lua_anchorPoint:y:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(transform, "lua_transform:adding:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(rotation, "lua_rotation:notNeedAdding:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(scale, "lua_scale:sy:notNeedAdding:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(translation, "lua_translation:ty:notNeedAdding:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(transformIdentity, "lua_transformIdentity", MLNUIView)
// animation
LUA_EXPORT_VIEW_METHOD(removeAllAnimation, "lua_removeAllAnimation",MLNUIView)
LUA_EXPORT_VIEW_METHOD(startAnimation, "lua_startAnimation:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(clearAnimation, "lua_clearAnimation",MLNUIView)
// screen capture
LUA_EXPORT_VIEW_METHOD(snapshot, "lua_snapshotWithFileName:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(addBlurEffect, "lua_addBlurEffect", MLNUIView)
LUA_EXPORT_VIEW_METHOD(removeBlurEffect, "lua_removeBlurEffect", MLNUIView)
LUA_EXPORT_VIEW_METHOD(openRipple, "lua_openRipple:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(canEndEditing, "lua_endEditing:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(keyboardDismiss, "lua_keyboardDismiss:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(bringSubviewToFront, "lua_bringSubviewToFront:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(sendSubviewToBack, "lua_sendSubviewToBack:", MLNUIView)
//view的背景图片
LUA_EXPORT_VIEW_METHOD(bgImage, "lua_setBgImage:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(addShadow, "lua_addShadow:shadowOffset:shadowRadius:shadowOpacity:isOval:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(setShadow, "lua_setShadowWithShadowOffset:shadowRadius:shadowOpacity:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(onDetachedView, "lua_onDetachedFromWindowCallback:", MLNUIView)
LUA_EXPORT_VIEW_END(MLNUIView, View, NO, NULL, NULL)

@end
