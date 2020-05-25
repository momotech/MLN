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
- (BOOL)luaui_canClick
{
    return YES;
}

- (BOOL)luaui_canLongPress
{
    return YES;
}

- (BOOL)luaui_layoutEnable
{
    return YES;
}

- (BOOL)luaui_isContainer
{
    return YES;
}

#pragma mark - Export For Lua
LUA_EXPORT_VIEW_BEGIN(MLNUIView)
// layout
LUA_EXPORT_VIEW_PROPERTY(x, "setLuaui_x:","luaui_x", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(y, "setLuaui_y:","luaui_y", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(width, "setLuaui_width:","luaui_width", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(height, "setLuaui_height:","luaui_height", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(right, "setLuaui_right:","luaui_right", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(bottom, "setLuaui_bottom:","luaui_bottom", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(centerX, "luaui_setCenterX:","luaui_centerX", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(centerY, "luaui_setCenterY:","luaui_centerY", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(frame, "setLuaui_frame:","luaui_frame", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(size, "luaui_setSize:","luaui_size", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(point, "luaui_setOrigin:","luaui_origin", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(marginTop, "setLuaui_marginTop:","luaui_marginTop", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(marginLeft, "setLuaui_marginLeft:","luaui_marginLeft", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(marginBottom, "setLuaui_marginBottom:","luaui_marginBottom", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(marginRight, "setLuaui_marginRight:","luaui_marginRight", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(priority, "setLuaui_priority:","luaui_priority", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(weight, "setLuaui_weight:","luaui_weight", MLNUIView)
LUA_EXPORT_VIEW_METHOD(padding, "luaui_setPaddingWithTop:right:bottom:left:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(setMaxWidth, "setLuaui_maxWidth:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setMinWidth, "setLuaui_minWidth:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setMaxHeight, "setLuaui_maxHieght:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setMinHeight, "setLuaui_minHeight:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(getCenterX, "luaui_centerX", MLNUIView)
LUA_EXPORT_VIEW_METHOD(getCenterY, "luaui_centerY", MLNUIView)
LUA_EXPORT_VIEW_METHOD(sizeToFit, "luaui_sizeToFit",MLNUIView)
LUA_EXPORT_VIEW_METHOD(superview, "luaui_superview",MLNUIView)
LUA_EXPORT_VIEW_METHOD(addView, "luaui_addSubview:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(insertView, "luaui_insertSubview:atIndex:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(removeFromSuper, "luaui_removeFromSuperview",MLNUIView)
LUA_EXPORT_VIEW_METHOD(removeAllSubviews, "luaui_removeAllSubViews",MLNUIView)
LUA_EXPORT_VIEW_METHOD(layoutIfNeeded, "luaui_layoutIfNeed",MLNUIView)
LUA_EXPORT_VIEW_METHOD(convertPointTo, "luaui_convertToView:point:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(convertPointFrom, "luaui_convertFromView:point:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setGravity, "setLuaui_gravity:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(requestLayout, "luaui_requestLayout", MLNUIView)
LUA_EXPORT_VIEW_METHOD(convertRelativePointTo, "luaui_convertRelativePointToView:point:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(overlay, "luaui_overlay:", MLNUIView)
// render
LUA_EXPORT_VIEW_PROPERTY(alpha, "setAlpha:","alpha", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(hidden, "setHidden:","isHidden", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(gone, "setLuaui_gone:","luaui_gone", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(borderWidth, "luaui_setBorderWidth:","luaui_borderWidth", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(borderColor, "luaui_setBorderColor:","luaui_borderColor", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(bgColor, "luaui_setBackgroundColor:", "backgroundColor", MLNUIView)
LUA_EXPORT_VIEW_PROPERTY(cornerRadius, "luaui_setCornerRadius:","luaui_cornerRadius", MLNUIView)
LUA_EXPORT_VIEW_METHOD(refresh, "luaui_setNeedsDisplay", MLNUIView)
LUA_EXPORT_VIEW_METHOD(setCornerRadiusWithDirection, "luaui_setCornerRadius:byRoundingCorners:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(getCornerRadiusWithDirection, "luaui_getCornerRadiusWithDirection:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(clipToChildren, "luaui_setClipsToChildren:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(clipToBounds, "luaui_setClipsToBounds:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(notClip, "luaui_setNotClip:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(addCornerMask, "luaui_addCornerMaskWithRadius:maskColor:corners:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(setGradientColor, "luaui_setGradientColor:endColor:vertical:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setGradientColorWithDirection, "luaui_setGradientColor:endColor:direction:",MLNUIView)
// user interaction
LUA_EXPORT_VIEW_PROPERTY(enabled, "setLuaui_enable:","luaui_enable", MLNUIView)
LUA_EXPORT_VIEW_METHOD(onClick, "luaui_addClick:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(onLongPress, "luaui_addLongPress:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(onTouch, "luaui_addTouch:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(hasFocus, "isFirstResponder",MLNUIView)
LUA_EXPORT_VIEW_METHOD(canFocus, "canBecomeFirstResponder",MLNUIView)
LUA_EXPORT_VIEW_METHOD(requestFocus, "luaui_requestFocus",MLNUIView)
LUA_EXPORT_VIEW_METHOD(cancelFocus, "resignFirstResponder",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchBegin, "luaui_setTouchesBeganCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchMove, "luaui_setTouchesMovedCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchEnd, "luaui_setTouchesEndedCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchCancel, "luaui_setTouchesCancelledCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchBeginExtension, "luaui_setTouchesBeganExtensionCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchMoveExtension, "luaui_setTouchesMovedExtensionCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchEndExtension, "luaui_setTouchesEndedExtensionCallback:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(touchCancelExtension, "luaui_setTouchesCancelledExtensionCallback:",MLNUIView)
// keyboard
LUA_EXPORT_VIEW_METHOD(setPositionAdjustForKeyboard, "luaui_setPositionAdjustForKeyboard:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(setPositionAdjustForKeyboardAndOffset, "luaui_setPositionAdjustForKeyboard:offsetY:",MLNUIView)
// transform
LUA_EXPORT_VIEW_METHOD(anchorPoint, "luaui_anchorPoint:y:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(transform, "luaui_transform:adding:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(rotation, "luaui_rotation:notNeedAdding:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(scale, "luaui_scale:sy:notNeedAdding:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(translation, "luaui_translation:ty:notNeedAdding:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(transformIdentity, "luaui_transformIdentity", MLNUIView)
// animation
LUA_EXPORT_VIEW_METHOD(removeAllAnimation, "luaui_removeAllAnimation",MLNUIView)
LUA_EXPORT_VIEW_METHOD(startAnimation, "luaui_startAnimation:",MLNUIView)
LUA_EXPORT_VIEW_METHOD(clearAnimation, "luaui_clearAnimation",MLNUIView)
// screen capture
LUA_EXPORT_VIEW_METHOD(snapshot, "luaui_snapshotWithFileName:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(addBlurEffect, "luaui_addBlurEffect", MLNUIView)
LUA_EXPORT_VIEW_METHOD(removeBlurEffect, "luaui_removeBlurEffect", MLNUIView)
LUA_EXPORT_VIEW_METHOD(openRipple, "luaui_openRipple:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(canEndEditing, "luaui_endEditing:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(keyboardDismiss, "luaui_keyboardDismiss:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(bringSubviewToFront, "luaui_bringSubviewToFront:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(sendSubviewToBack, "luaui_sendSubviewToBack:", MLNUIView)
//view的背景图片
LUA_EXPORT_VIEW_METHOD(bgImage, "luaui_setBgImage:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(addShadow, "luaui_addShadow:shadowOffset:shadowRadius:shadowOpacity:isOval:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(setShadow, "luaui_setShadowWithShadowOffset:shadowRadius:shadowOpacity:", MLNUIView)
LUA_EXPORT_VIEW_METHOD(onDetachedView, "luaui_onDetachedFromWindowCallback:", MLNUIView)
LUA_EXPORT_VIEW_END(MLNUIView, View, NO, NULL, NULL)

@end
