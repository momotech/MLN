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
LUAUI_EXPORT_VIEW_BEGIN(MLNUIView)
// layout
LUAUI_EXPORT_VIEW_PROPERTY(x, "setLuaui_x:","luaui_x", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(y, "setLuaui_y:","luaui_y", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(width, "setLuaui_width:","luaui_width", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(height, "setLuaui_height:","luaui_height", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(right, "setLuaui_right:","luaui_right", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(bottom, "setLuaui_bottom:","luaui_bottom", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(centerX, "luaui_setCenterX:","luaui_centerX", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(centerY, "luaui_setCenterY:","luaui_centerY", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(frame, "setLuaui_frame:","luaui_frame", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(size, "luaui_setSize:","luaui_size", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(point, "luaui_setOrigin:","luaui_origin", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(marginTop, "setLuaui_marginTop:","luaui_marginTop", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(marginLeft, "setLuaui_marginLeft:","luaui_marginLeft", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(marginBottom, "setLuaui_marginBottom:","luaui_marginBottom", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(marginRight, "setLuaui_marginRight:","luaui_marginRight", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(priority, "setLuaui_priority:","luaui_priority", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(weight, "setLuaui_weight:","luaui_weight", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(padding, "luaui_setPaddingWithTop:right:bottom:left:", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setMaxWidth, "setLuaui_maxWidth:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setMinWidth, "setLuaui_minWidth:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setMaxHeight, "setLuaui_maxHieght:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setMinHeight, "setLuaui_minHeight:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(getCenterX, "luaui_centerX", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(getCenterY, "luaui_centerY", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(sizeToFit, "luaui_sizeToFit",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(superview, "luaui_superview",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(addView, "luaui_addSubview:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(insertView, "luaui_insertSubview:atIndex:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(removeFromSuper, "luaui_removeFromSuperview",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(removeAllSubviews, "luaui_removeAllSubViews",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(layoutIfNeeded, "luaui_layoutIfNeed",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(convertPointTo, "luaui_convertToView:point:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(convertPointFrom, "luaui_convertFromView:point:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setGravity, "setLuaui_gravity:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(requestLayout, "luaui_requestLayout", MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(convertRelativePointTo, "luaui_convertRelativePointToView:point:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(overlay, "luaui_overlay:", MLNUIView)
// render
LUAUI_EXPORT_VIEW_PROPERTY(alpha, "setAlpha:","alpha", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(hidden, "setHidden:","isHidden", MLNUIView)
LUAUI_EXPORT_VIEW_PROPERTY(gone, "setLuaui_gone:","luaui_gone", MLNUIView)
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
// keyboard
LUAUI_EXPORT_VIEW_METHOD(setPositionAdjustForKeyboard, "luaui_setPositionAdjustForKeyboard:",MLNUIView)
LUAUI_EXPORT_VIEW_METHOD(setPositionAdjustForKeyboardAndOffset, "luaui_setPositionAdjustForKeyboard:offsetY:",MLNUIView)
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
LUAUI_EXPORT_VIEW_END(MLNUIView, View, NO, NULL, NULL)

@end
