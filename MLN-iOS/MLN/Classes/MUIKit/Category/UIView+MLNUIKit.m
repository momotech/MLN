//
//  UIView+MLNUICore.m
//  MLNUICore
//
//  Created by MoMo on 2019/7/23.
//

#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUIKitHeader.h"
#import <objc/runtime.h>
#import "MLNUIViewConst.h"
#import "MLNUIRenderContext.h"
#import "MLNUIBlock.h"
#import "MLNUILayoutNode.h"
#import "MLNUIKeyboardViewHandler.h"
#import "MLNUITransformTask.h"
#import "MLNUISnapshotManager.h"
#import "MLNUICanvasAnimation.h"
#import "MLNUIKitInstanceHandlersManager.h"

#define kMLNUIDefaultRippleColor [UIColor colorWithRed:247/255.0 green:246/255.0 blue:244/255.0 alpha:1.0]

static IMP __mln_in_UIView_Origin_TouchesBegan_Method_Imp;
static IMP __mln_in_UIView_Origin_TouchesMoved_Method_Imp;
static IMP __mln_in_UIView_Origin_TouchesEnded_Method_Imp;
static IMP __mln_in_UIView_Origin_TouchesCancelled_Method_Imp;

static const void *kLuaGradientLayer = &kLuaGradientLayer;
static const void *kLuaKeyboardViewHandlerKey = &kLuaKeyboardViewHandlerKey;
static const void *kLuaBlurEffectView = &kLuaBlurEffectView;
static const void *kLuaOpenRipple = &kLuaOpenRipple;
static const void *kLuaOldColor = &kLuaOldColor;
static const void *kDidSetLuaOldColor = &kDidSetLuaOldColor;
static const void *kLuaNeedEndEditing = &kLuaNeedEndEditing;
static const void *kLuaKeyboardDismiss = &kLuaKeyboardDismiss;

@implementation UIView (MLNUIKit)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method origMethod1 = class_getInstanceMethod([self class], @selector(touchesBegan:withEvent:));
        Method swizzledMethod1 = class_getInstanceMethod([self class], @selector(mln_in_touchesBegan:withEvent:));
        __mln_in_UIView_Origin_TouchesBegan_Method_Imp = method_getImplementation(origMethod1);
        method_exchangeImplementations(origMethod1, swizzledMethod1);
        
        Method origMethod2 = class_getInstanceMethod([self class], @selector(touchesMoved:withEvent:));
        Method swizzledMethod2 = class_getInstanceMethod([self class], @selector(mln_in_touchesMoved:withEvent:));
        
        __mln_in_UIView_Origin_TouchesMoved_Method_Imp = method_getImplementation(origMethod2);
        method_exchangeImplementations(origMethod2, swizzledMethod2);
        
        Method origMethod3 = class_getInstanceMethod([self class], @selector(touchesEnded:withEvent:));
        Method swizzledMethod3 = class_getInstanceMethod([self class], @selector(mln_in_touchesEnded:withEvent:));
        
        __mln_in_UIView_Origin_TouchesEnded_Method_Imp = method_getImplementation(origMethod3);
        method_exchangeImplementations(origMethod3, swizzledMethod3);
        
        Method origMethod4 = class_getInstanceMethod([self class], @selector(touchesCancelled:withEvent:));
        Method swizzledMethod4 = class_getInstanceMethod([self class], @selector(mln_in_touchesCancelled:withEvent:));
        
        __mln_in_UIView_Origin_TouchesCancelled_Method_Imp = method_getImplementation(origMethod4);
        method_exchangeImplementations(origMethod4, swizzledMethod4);
        
        Method origMethod5 = class_getInstanceMethod([self class], @selector(removeFromSuperview));
        Method swizzledMethod5 = class_getInstanceMethod([self class], @selector(mln_in_removeFromSuperview));
        method_exchangeImplementations(origMethod5, swizzledMethod5);
    });
}

- (void)mln_in_removeFromSuperview
{
    if ([self mln_isConvertible]) {
        [self mln_in_traverseAllSubviewsCallbackDetached];
    }
    [self mln_in_removeFromSuperview];
}

- (void)mln_in_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void (*)(id, SEL, NSSet<UITouch *> *, UIEvent *))__mln_in_UIView_Origin_TouchesBegan_Method_Imp;
    functionPointer(self, _cmd, touches, event);
    if (![self isKindOfClass:[UIView class]]) {
        return;
    }
    
    if([self isOpenRipple]) {
        if (![self oldColor] && ![self lua_didSetOldColor]) {
            [self setOldColor:self.backgroundColor];
            [self lua_setDidSetOldColor:YES];
        }
        self.backgroundColor = kMLNUIDefaultRippleColor;
    }
    
    if ([self lua_needEndEditing]) {
        [self endEditing:YES];
    }
    
    if ([self lua_needDismissKeyboard]) {
        [self.window endEditing:YES];
    }
    
    if (self.mln_touchesBeganCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self.mln_touchesBeganCallback addFloatArgument:point.x];
        [self.mln_touchesBeganCallback addFloatArgument:point.y];
        [self.mln_touchesBeganCallback callIfCan];
    }
    
    if (self.mln_touchesBeganExtensionCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint screenLocation = [touch locationInView:self.window];
        CGPoint pageLocation = [touch locationInView:self];
        NSDictionary *touchDict = [self touchResultWithScreenLocation:screenLocation pageLocation:pageLocation target:self];
        [self.mln_touchesBeganExtensionCallback addObjArgument:[NSMutableDictionary dictionaryWithDictionary:touchDict]];
        [self.mln_touchesBeganExtensionCallback callIfCan];
    }
}

- (void)mln_in_touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void (*)(id, SEL, NSSet<UITouch *> *, UIEvent *))__mln_in_UIView_Origin_TouchesMoved_Method_Imp;
    functionPointer(self, _cmd, touches, event);
    if (![self isKindOfClass:[UIView class]]) {
        return;
    }
    
    if (self.mln_touchesMovedCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self.mln_touchesMovedCallback addFloatArgument:point.x];
        [self.mln_touchesMovedCallback addFloatArgument:point.y];
        [self.mln_touchesMovedCallback callIfCan];
    }
    
    if (self.mln_touchesMovedExtensionCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint screenLocation = [touch locationInView:self.window];
        CGPoint pageLocation = [touch locationInView:self];
        NSDictionary *touchDict = [self touchResultWithScreenLocation:screenLocation pageLocation:pageLocation target:self];
        [self.mln_touchesMovedExtensionCallback addObjArgument:touchDict.mutableCopy];
        [self.mln_touchesMovedExtensionCallback callIfCan];
    }
}

- (void)mln_in_touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void (*)(id, SEL, NSSet<UITouch *> *, UIEvent *))__mln_in_UIView_Origin_TouchesEnded_Method_Imp;
    functionPointer(self, _cmd, touches, event);
    
    if (![self isKindOfClass:[UIView class]]) {
        return;
    }
    if([self isOpenRipple]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.backgroundColor = [self oldColor];
            [self lua_setDidSetOldColor:NO];
        });
    }
    
    if (self.mln_touchesEndedCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self.mln_touchesEndedCallback addFloatArgument:point.x];
        [self.mln_touchesEndedCallback addFloatArgument:point.y];
        [self.mln_touchesEndedCallback callIfCan];
    }
    
    if (self.mln_touchesEndedExtensionCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint screenLocation = [touch locationInView:self.window];
        CGPoint pageLocation = [touch locationInView:self];
        NSDictionary *touchDict = [self touchResultWithScreenLocation:screenLocation pageLocation:pageLocation target:self];
        [self.mln_touchesEndedExtensionCallback addObjArgument:touchDict.mutableCopy];
        [self.mln_touchesEndedExtensionCallback callIfCan];
    }
}

- (void)mln_in_touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void (*)(id, SEL, NSSet<UITouch *> *, UIEvent *))__mln_in_UIView_Origin_TouchesCancelled_Method_Imp;
    functionPointer(self, _cmd, touches, event);
    if (![self isKindOfClass:[UIView class]]) {
        return;
    }
    if([self isOpenRipple]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.backgroundColor = [self oldColor];
            [self lua_setDidSetOldColor:NO];
        });
    }
    
    if (self.mln_touchesCancelledCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self.mln_touchesCancelledCallback addFloatArgument:point.x];
        [self.mln_touchesCancelledCallback addFloatArgument:point.y];
        [self.mln_touchesCancelledCallback callIfCan];
    }
    
    if (self.mln_touchesCancelledExtensionCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint screenLocation = [touch locationInView:self.window];
        CGPoint pageLocation = [touch locationInView:self];
        NSDictionary *touchDict = [self touchResultWithScreenLocation:screenLocation pageLocation:pageLocation target:self];
        [self.mln_touchesCancelledExtensionCallback addObjArgument:touchDict.mutableCopy];
        [self.mln_touchesCancelledExtensionCallback callIfCan];
    }
}

#pragma mark - Geometry
- (void)setLua_x:(CGFloat)lua_x
{
    MLNUIKitLuaAssert(NO, @"The setter of 'x' method is deprecated!");
    [self.lua_node changeX:lua_x];
}

- (CGFloat)lua_x
{
    MLNUIKitLuaAssert(NO, @"The getter of 'x' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    switch (node.layoutStrategy) {
        case MLNUILayoutStrategyNativeFrame:
            return node.x;
        default:
            return 0.f;
    }
}

- (void)setLua_y:(CGFloat)lua_y
{
    MLNUIKitLuaAssert(NO, @"The setter of 'y' method is deprecated!");
    [self.lua_node changeY:lua_y];
}

- (CGFloat)lua_y
{
    MLNUIKitLuaAssert(NO, @"The getter of 'y' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    switch (node.layoutStrategy) {
        case MLNUILayoutStrategyNativeFrame:
            return node.y;
        default:
            return 0.f;
    }
}

- (void)setLua_width:(CGFloat)lua_width
{
    MLNUICheckWidth(lua_width);
    [self.lua_node changeWidth:lua_width];
}

- (CGFloat)lua_width
{
    MLNUILayoutNode *node = self.lua_node;
    switch (node.widthType) {
        case MLNUILayoutMeasurementTypeIdle:
            return node.width;
        default:
            return node.measuredWidth;
    }
}

- (void)setLua_height:(CGFloat)lua_Height
{
    MLNUICheckWidth(lua_Height);
    [self.lua_node changeHeight:lua_Height];
}

- (CGFloat)lua_height
{
    MLNUILayoutNode *node = self.lua_node;
    switch (node.heightType) {
        case MLNUILayoutMeasurementTypeIdle:
            return node.height;
        default:
            return node.measuredHeight;
    }
}

- (void)setLua_right:(CGFloat)lua_right
{
    MLNUIKitLuaAssert(NO, @"The setter of 'right' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    CGFloat x = lua_right - [self lua_width];
    [node changeX:x];
}

- (CGFloat)lua_right
{
    MLNUIKitLuaAssert(NO, @"The getter of 'right' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    switch (node.layoutStrategy) {
        case MLNUILayoutStrategyNativeFrame:
            return node.x + [self lua_width];
        default:
            return [self lua_width];
    }
}

- (void)setLua_bottom:(CGFloat)lua_bottom
{
    MLNUIKitLuaAssert(NO, @"The setter of 'bottom' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    CGFloat y = lua_bottom - [self lua_height];
    [node changeY:y];
}

- (CGFloat)lua_bottom
{
    MLNUIKitLuaAssert(NO, @"The getter of 'bottom' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    switch (node.layoutStrategy) {
        case MLNUILayoutStrategyNativeFrame:
            return node.y + [self lua_height];
        default:
            return [self lua_height];
    }
}

- (void)lua_setSize:(CGSize)size
{
    MLNUIKitLuaAssert(NO, @"The setter of 'size' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    [node changeWidth:size.width];
    [node changeHeight:size.height];
}

- (CGSize )lua_size
{
    MLNUIKitLuaAssert(NO, @"The getter of 'size' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    CGFloat width = 0.f;
    switch (node.widthType) {
        case MLNUILayoutMeasurementTypeIdle:
            width = node.width;
            break;
        default:
            width = node.measuredWidth;
            break;
    }
    CGFloat height = 0.f;
    switch (node.heightType) {
        case MLNUILayoutMeasurementTypeIdle:
            height = node.height;
            break;
        default:
            height = node.measuredHeight;
            break;
    }
    return CGSizeMake(width, height);
}

- (void)lua_setOrigin:(CGPoint)point
{
    MLNUIKitLuaAssert(NO, @"The setter of 'point' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    [node changeX:point.x];
    [node changeY:point.y];
}

- (CGPoint)lua_origin
{
    MLNUIKitLuaAssert(NO, @"The getter of 'point' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    switch (node.layoutStrategy) {
        case MLNUILayoutStrategyNativeFrame:
            x = node.x;
            y = node.y;
            break;
        default:
            x = node.measuredX;
            y = node.measuredY;
            break;
    }
    return CGPointMake(x, y);
}

- (CGFloat)lua_centerX
{
    MLNUIKitLuaAssert(NO, @"The getter of 'centerX' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    switch (node.layoutStrategy) {
        case MLNUILayoutStrategyNativeFrame:
            return node.x + [self lua_width] *.5f;
        default:
            return node.measuredX + [self lua_width] *.5f;
    }
}

- (CGFloat)lua_centerY
{
    MLNUIKitLuaAssert(NO, @"The getter of 'centerY' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    switch (node.layoutStrategy) {
        case MLNUILayoutStrategyNativeFrame:
            return node.y + [self lua_height] *.5f;
        default:
            return node.measuredY + [self lua_height] *.5f;
    }
}

- (void)lua_setCenterX:(CGFloat)centerX
{
    MLNUIKitLuaAssert(NO, @"The setter of 'centerX' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    CGFloat x = centerX - [self lua_width] * .5f;
    [node changeX:x];
}

- (void)lua_setCenterY:(CGFloat)centerY
{
    MLNUIKitLuaAssert(NO, @"The setter of 'centerY' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    CGFloat y = centerY - [self lua_height] * .5f;
    [node changeY:y];
}

- (void)lua_setBackgroundColor:(UIColor *)color
{
    MLNUICheckTypeAndNilValue(color, @"Color", UIColor);
    [self setOldColor:color];
    self.backgroundColor = color;
    [self.mln_in_renderContext  cleanGradientColorIfNeed];
    [self.mln_in_renderContext cleanLayerContentsIfNeed];
}

- (void)lua_layoutIfNeed
{
    MLNUIKitLuaAssert(NO, @"View:layoutIfNeeded method is deprecated!");
    [self layoutIfNeeded];
    self.lua_node.enable = NO;
}

- (void)lua_setNeedsDisplay
{
    MLNUIKitLuaAssert(NO, @"View:refresh method is deprecated!");
    [self setNeedsDisplay];
}

- (void)lua_sizeToFit
{
    [self sizeToFit];
    self.lua_node.enable = NO;
}

- (void)setLua_frame:(CGRect)lua_frame
{
    MLNUIKitLuaAssert(NO, @"The setter of 'frame' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    [node changeX:lua_frame.origin.x];
    [node changeY:lua_frame.origin.y];
    [node changeWidth:lua_frame.size.width];
    [node changeHeight:lua_frame.size.height];
}

- (CGRect)lua_frame
{
    MLNUIKitLuaAssert(NO, @"The getter of 'frame' method is deprecated!");
    MLNUILayoutNode *node = self.lua_node;
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    switch (node.layoutStrategy) {
        case MLNUILayoutStrategyNativeFrame:
            x = node.x;
            y = node.y;
            break;
        default:
            x = node.measuredX;
            y = node.measuredY;
            break;
    }
    CGFloat width = 0.f;
    switch (node.widthType) {
        case MLNUILayoutMeasurementTypeIdle:
            width = node.width;
            break;
        default:
            width = node.measuredWidth;
            break;
    }
    CGFloat height = 0.f;
    switch (node.heightType) {
        case MLNUILayoutMeasurementTypeIdle:
            height = node.height;
            break;
        default:
            height = node.measuredHeight;
            break;
    }
    return CGRectMake(x, y, width, height);
}

- (CGPoint)lua_convertToView:(UIView *)view point:(CGPoint)point
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    return [self convertPoint:point toView:view];
}

- (CGPoint)lua_convertRelativePointToView:(UIView *)view point:(CGPoint)point
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    CGPoint retPoint = [self convertPoint:point toView:view];
#if defined(__LP64__) && __LP64__
    CGFloat x = fmod(retPoint.x, view.frame.size.width);
    CGFloat y = fmod(retPoint.y, view.frame.size.height);
#else
    CGFloat x = fmodf(retPoint.x, view.frame.size.width);
    CGFloat y = fmodf(retPoint.y, view.frame.size.height);
#endif
    return CGPointMake(x, y);
}

- (CGPoint)lua_convertFromView:(UIView *)view point:(CGPoint)point
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    return [self convertPoint:point fromView:view];
}

- (void)lua_setAnchorPoint:(CGPoint)point
{
    self.layer.anchorPoint = point;
}

- (CGPoint)lua_anchorPoint
{
    return self.layer.anchorPoint;
}

#pragma mark - Render
static const void *kLuaBoarderColor = &kLuaBoarderColor;
- (void)lua_setBorderColor:(UIColor *)color
{
    MLNUICheckTypeAndNilValue(color, @"Color", UIColor);
    objc_setAssociatedObject(self, kLuaBoarderColor, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.mln_in_renderContext resetBorderWithBorderWidth:[self lua_borderWidth] borderColor:[self lua_borderColor]];
}

- (UIColor *)lua_borderColor
{
    return objc_getAssociatedObject(self, kLuaBoarderColor);
}

static const void *kLuaBoarderWidth = &kLuaBoarderWidth;
- (void)lua_setBorderWidth:(CGFloat)borderWidth
{
    objc_setAssociatedObject(self, kLuaBoarderWidth, @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.mln_in_renderContext resetBorderWithBorderWidth:borderWidth borderColor:[self lua_borderColor]];
}

- (CGFloat)lua_borderWidth
{
    return CGFloatValueFromNumber(objc_getAssociatedObject(self, kLuaBoarderWidth));
}

- (void)lua_showShadowPath
{
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)lua_setShadowOffset:(CGFloat)x y:(CGFloat)y
{
    [self.layer setShadowOffset:CGSizeMake(x, y)];
}

- (void)lua_setShadowRadius:(CGFloat)radius
{
    [self.layer setShadowRadius:radius];
}

- (void)lua_setShadowOpacity:(BOOL)opacity
{
    [self.layer setShadowOpacity:opacity];
}

- (void)lua_setNotClip:(BOOL)not
{
    // Just for android.
}

- (void)lua_setClipsToBounds:(BOOL)clipsToBounds
{
    self.clipsToBounds = clipsToBounds;
    MLNUIRenderContext *renderContext = [self mln_in_renderContext];
    renderContext.clipToBounds = clipsToBounds;
    renderContext.didSetClipToBounds = YES;
}

- (void)lua_setClipsToChildren:(BOOL)clipsToChildren
{
    MLNUIRenderContext *renderContext = [self mln_in_renderContext];
    renderContext.clipToChildren = clipsToChildren;
    renderContext.didSetClipToChildren = YES;
}

#pragma mark - Corner Radius
- (void)lua_setCornerRadius:(CGFloat)cornerRadius
{
    [self.mln_in_renderContext resetCornerRadius:cornerRadius];
}

- (CGFloat)lua_cornerRadius
{
    return [self.mln_in_renderContext cornerRadius];
}

- (CGFloat)lua_getCornerRadiusWithDirection:(MLNUIRectCorner)corner
{
    return [self.mln_in_renderContext cornerRadiusWithDirection:corner];
}

- (void)lua_setCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(MLNUIRectCorner)corners
{
    if (corners == MLNUIRectCornerNone) {
        corners = MLNUIRectCornerAllCorners;
    }
    [self.mln_in_renderContext resetCornerRadius:cornerRadius byRoundingCorners:corners];
}

- (void)lua_addCornerMaskWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(MLNUIRectCorner)corners
{
    MLNUICheckTypeAndNilValue(maskColor, @"Color", UIColor);
    if (corners == MLNUIRectCornerNone) {
        corners = MLNUIRectCornerAllCorners;
    }
    [self.mln_in_renderContext resetCornerMaskViewWithRadius:cornerRadius maskColor:maskColor corners:(UIRectCorner)corners];
}

- (void)mln_updateCornersIfNeed
{
    [self.mln_in_renderContext updateIfNeed];
}

#pragma mark - gradientLayer
- (void)lua_setGradientColor:(UIColor *)startColor endColor:(UIColor *)endColor vertical:(BOOL)isVertical
{
    MLNUIKitLuaAssert(startColor && [startColor isKindOfClass:[UIColor class]], @"startColor must be type of UIColor");
    MLNUIKitLuaAssert(endColor && [endColor isKindOfClass:[UIColor class]], @"endColor must be type of UIColor");
    if (![startColor isKindOfClass:[UIColor class]] || ![endColor isKindOfClass:[UIColor class]]) return;
    MLNUIGradientType type = isVertical ? MLNUIGradientTypeTopToBottom : MLNUIGradientTypeLeftToRight;
    [self.mln_in_renderContext resetGradientColor:startColor endColor:endColor direction:type];
}

- (void)lua_setGradientColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(MLNUIGradientType)direction
{
    MLNUIKitLuaAssert(startColor && [startColor isKindOfClass:[UIColor class]], @"startColor must be type of UIColor");
    MLNUIKitLuaAssert(endColor && [endColor isKindOfClass:[UIColor class]], @"endColor must be type of UIColor");
    [self.mln_in_renderContext resetGradientColor:startColor endColor:endColor direction:direction];
}

- (void)mln_updateGradientLayerIfNeed
{
    [self.mln_in_renderContext updateIfNeed];
}

#pragma mark - shadowLayer
- (void)lua_addShadow:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowRadius:(CGFloat)radius shadowOpacity:(CGFloat)opacity isOval:(BOOL)isOval
{
    MLNUIKitLuaAssert(NO, @"The 'addShadow' method is deprected, use 'setShadow' method instead!");
    MLNUIKitLuaAssert(shadowColor && [shadowColor isKindOfClass:[UIColor class]], @"shadowColor must be type of UIColor");
    MLNUIKitLuaAssert(![self isKindOfClass:[UIImageView class]], @"ImageView does not support addShadow");
    if (![shadowColor isKindOfClass:[UIColor class]]) return;
    [self.mln_in_renderContext resetShadow:shadowColor shadowOffset:offset shadowRadius:radius shadowOpacity:opacity isOval:isOval];
}

- (void)lua_setShadowWithShadowOffset:(CGSize)offset shadowRadius:(CGFloat)radius shadowOpacity:(CGFloat)opacity
{
    if ([self isKindOfClass:[UIImageView class]]) return;
    UIColor *defaultShadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.215];
    [self.mln_in_renderContext resetShadow:defaultShadowColor shadowOffset:offset shadowRadius:radius shadowOpacity:opacity isOval:false];
}

static const void *kLuaRenderContext = &kLuaRenderContext;
- (MLNUIRenderContext *)mln_in_renderContext
{
    MLNUIRenderContext *cxt = objc_getAssociatedObject(self, kLuaRenderContext);
    if (!cxt) {
        cxt = [[MLNUIRenderContext alloc] initWithTargetView:self];
        objc_setAssociatedObject(self, kLuaRenderContext, cxt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cxt;
}

- (MLNUIRenderContext *)mln_renderContext
{
    return [self mln_in_renderContext];
}

#pragma mark - blurEffect
- (void)lua_addBlurEffect
{
    CGRect rect = self.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    UIView* view = [self mln_in_getBlurView];
    view.frame = rect;
    if ([self respondsToSelector: @selector(setBackgroundView:)]) {
        [self performSelector:@selector(setBackgroundView:) withObject:view afterDelay:0];
    } else {
        [self insertSubview:view atIndex:0];
    }
}

- (void)lua_removeBlurEffect
{
    UIView* view = [self mln_in_getBlurView];
    [view removeFromSuperview];
}

- (void)mln_in_setBlurEffectView:(UIView*)blurView
{
    objc_setAssociatedObject(self, kLuaBlurEffectView, blurView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)mln_in_getBlurView
{
    UIView* view = objc_getAssociatedObject(self, kLuaBlurEffectView);
    if (!view) {
        UIView *blurView = [[UIView alloc]init];
        UIToolbar *toolBar = [[UIToolbar alloc]init];
        toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        toolBar.barStyle = UIBarStyleDefault;
        [blurView addSubview:toolBar];
        UIView *topView = [[UIView alloc] initWithFrame:toolBar.bounds];
        topView.backgroundColor = [UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:0.7];
        topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [blurView addSubview:topView];
        [self mln_in_setBlurEffectView:blurView];
        view = blurView;
    }
    return view;
}

#pragma mark - Focus
- (void)lua_requestFocus
{
    if (self.userInteractionEnabled) {
        [self becomeFirstResponder];
    }
}

#pragma mark - TouchEvent
- (void)lua_setTouchesBeganCallback:(MLNUIBlock *)callback
{
    self.mln_touchesBeganCallback = callback;
}

- (void)lua_setTouchesMovedCallback:(MLNUIBlock *)callback
{
    self.mln_touchesMovedCallback = callback;
}

- (void)lua_setTouchesEndedCallback:(MLNUIBlock *)callback
{
    self.mln_touchesEndedCallback = callback;
}

- (void)lua_setTouchesCancelledCallback:(MLNUIBlock *)callback
{
    self.mln_touchesCancelledCallback = callback;
}

- (void)lua_setTouchesBeganExtensionCallback:(MLNUIBlock *)callback
{
    self.mln_touchesBeganExtensionCallback = callback;
}

- (void)lua_setTouchesMovedExtensionCallback:(MLNUIBlock *)callback
{
    self.mln_touchesMovedExtensionCallback = callback;
}

- (void)lua_setTouchesEndedExtensionCallback:(MLNUIBlock *)callback
{
    self.mln_touchesEndedExtensionCallback = callback;
}

- (void)lua_setTouchesCancelledExtensionCallback:(MLNUIBlock *)callback
{
    self.mln_touchesCancelledExtensionCallback = callback;
}

#pragma mark - Gesture
- (BOOL)lua_enable
{
    return self.userInteractionEnabled;
}

- (void)setLua_enable:(BOOL)lua_enable
{
    self.userInteractionEnabled = lua_enable;
}

- (BOOL)lua_canClick
{
    return NO;
}

- (BOOL)lua_canLongPress
{
    return NO;
}

- (void)lua_addTouch:(MLNUIBlock *)touchCallBack
{
    MLNUIKitLuaAssert(NO, @"View:onTouch method is deprecated");
    [self mln_in_addTapGestureIfNeed];
    self.mln_touchClickBlock = touchCallBack;
}

- (void)lua_addClick:(MLNUIBlock *)clickCallback
{
    [self mln_in_addTapGestureIfNeed];
    self.mln_tapClickBlock = clickCallback;
}

- (void)mln_in_addTapGestureIfNeed
{
    if (!self.mln_tapClickBlock && [self lua_canClick]) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mln_in_tapClickAction:)];
        [self addGestureRecognizer:gesture];
    }
}

- (void)mln_in_tapClickAction:(UIGestureRecognizer *)gesture
{
    if (!self.lua_enable) {
        return;
    }
    if (self.mln_tapClickBlock) {
        [self.mln_tapClickBlock callIfCan];
    }
    if (self.mln_touchClickBlock) {
        CGPoint point = [gesture locationInView:self];
        [self.mln_touchClickBlock addFloatArgument:point.x];
        [self.mln_touchClickBlock addFloatArgument:point.y];
        [self.mln_touchClickBlock callIfCan];
    }
}

- (void)lua_addLongPress:(MLNUIBlock *)longPressCallback
{
    [self mln_in_addLongPressGestureIfNeed];
    self.mln_longPressBlock = longPressCallback;
}

- (void)mln_in_addLongPressGestureIfNeed
{
    if (!self.mln_longPressBlock && [self lua_canLongPress]) {
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mln_in_longPressAction:)];
        [self addGestureRecognizer:gesture];
    }
}

- (void)mln_in_longPressAction:(UIGestureRecognizer *)gesture
{
    if (!self.lua_enable) {
        return;
    }
    if (!self.mln_longPressBlock) return;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self];
        [self.mln_longPressBlock addFloatArgument:point.x];
        [self.mln_longPressBlock addFloatArgument:point.y];
        [self.mln_longPressBlock callIfCan];
    }
}

static const void *kLuaTapGesture = &kLuaTapGesture;
- (void)setMln_tapClickBlock:(MLNUIBlock *)tapClickBlock
{
    MLNUICheckTypeAndNilValue(tapClickBlock, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTapGesture, tapClickBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_tapClickBlock
{
    return objc_getAssociatedObject(self, kLuaTapGesture);
}

static const void *kLuaTouchGesture = &kLuaTouchGesture;
- (void)setMln_touchClickBlock:(MLNUIBlock *)mln_touchClickBlock {
    MLNUICheckTypeAndNilValue(mln_touchClickBlock, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchGesture, mln_touchClickBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_touchClickBlock {
    return objc_getAssociatedObject(self, kLuaTouchGesture);
}

static const void *kLuaLongPressGesture = &kLuaLongPressGesture;
- (void)setMln_longPressBlock:(MLNUIBlock *)longPressBlock
{
    MLNUICheckTypeAndNilValue(longPressBlock, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaLongPressGesture, longPressBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_longPressBlock
{
    return objc_getAssociatedObject(self, kLuaLongPressGesture);
}

static const void *kLuaTouchesBeganEvent = &kLuaTouchesBeganEvent;
- (void)setMln_touchesBeganCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesBeganEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_touchesBeganCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesBeganEvent);
}

static const void *kLuaTouchesMovedEvent = &kLuaTouchesMovedEvent;
- (void)setMln_touchesMovedCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesMovedEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_touchesMovedCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesMovedEvent);
}

static const void *kLuaTouchesEndedEvent = &kLuaTouchesEndedEvent;
- (void)setMln_touchesEndedCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesEndedEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_touchesEndedCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesEndedEvent);
}

static const void *kLuaTouchesCancelledEvent = &kLuaTouchesCancelledEvent;
- (void)setMln_touchesCancelledCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesCancelledEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_touchesCancelledCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesCancelledEvent);
}

static const void *kLuaTouchesBeganExtensionEvent = &kLuaTouchesBeganExtensionEvent;
- (void)setMln_touchesBeganExtensionCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesBeganExtensionEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_touchesBeganExtensionCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesBeganExtensionEvent);
}

static const void *kLuaTouchesMovedExtensionEvent = &kLuaTouchesMovedExtensionEvent;
- (void)setMln_touchesMovedExtensionCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesMovedExtensionEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_touchesMovedExtensionCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesMovedExtensionEvent);
}

static const void *kLuaTouchesEndedExtensionEvent = &kLuaTouchesEndedExtensionEvent;
- (void)setMln_touchesEndedExtensionCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesEndedExtensionEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_touchesEndedExtensionCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesEndedExtensionEvent);
}

static const void *kLuaTouchesCancelledExtensionEvent = &kLuaTouchesCancelledExtensionEvent;
- (void)setMln_touchesCancelledExtensionCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesCancelledExtensionEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_touchesCancelledExtensionCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesCancelledExtensionEvent);
}

static const void *kLuaOnDetachedFromWindowCallback = &kLuaOnDetachedFromWindowCallback;
- (void)setMln_onDetachedFromWindowCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"callback", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaOnDetachedFromWindowCallback, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mln_onDetachedFromWindowCallback
{
    return objc_getAssociatedObject(self, kLuaOnDetachedFromWindowCallback);
}

#pragma mark - Utils
- (NSDictionary *)touchResultWithScreenLocation:(CGPoint)screenLocation pageLocation:(CGPoint)pageLocation target:(UIView *)targetView
{
    NSMutableDictionary *resultTouch = [[NSMutableDictionary alloc] initWithCapacity:5];
    resultTouch[@"screenX"] = @(screenLocation.x);
    resultTouch[@"screenY"] = @(screenLocation.y);
    resultTouch[@"pageX"] = @(pageLocation.x);
    resultTouch[@"pageY"] = @(pageLocation.y);
    resultTouch[@"timeStamp"] = @([NSDate date].timeIntervalSince1970);
    resultTouch[@"target"] = targetView;
    return resultTouch;
}

#pragma mark - Keyboard

- (void)mln_in_setPositionAdjustForKeyboard:(BOOL)bAdjust offsetY:(CGFloat)offsetY
{
    if (!self.lua_keyboardViewHandler) {
        MLNUIKeyboardViewHandler *keyboardViewHandler = [[MLNUIKeyboardViewHandler alloc] initWithView:self];
        self.lua_keyboardViewHandler = keyboardViewHandler;
    }
    self.lua_keyboardViewHandler.alwaysAdjustPositionKeyboardCoverView = NO;
    
    self.lua_keyboardViewHandler.positionAdjust = bAdjust;
    self.lua_keyboardViewHandler.positionAdjustOffsetY = bAdjust? offsetY : 0.0;
}

- (void)lua_setPositionAdjustForKeyboard:(BOOL)bAdjust
{
    [self lua_setPositionAdjustForKeyboard:bAdjust offsetY:0.0];
}

- (void)lua_setPositionAdjustForKeyboard:(BOOL)bAdjust offsetY:(CGFloat)offsetY
{
    if (offsetY != 0.0) {
        MLNUIKitLuaAssert(NO, @"View:setPositionAdjustForKeyboardOffsetY method is deprecated!");
    } else {
        MLNUIKitLuaAssert(NO, @"View:setPositionAdjustForKeyboard method is deprecated!");
    }
    [self mln_in_setPositionAdjustForKeyboard:bAdjust offsetY:offsetY];
}

- (void)setLua_keyboardViewHandler:(MLNUIKeyboardViewHandler *)keyboardViewHandler
{
    objc_setAssociatedObject(self, kLuaKeyboardViewHandlerKey, keyboardViewHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIKeyboardViewHandler *)lua_keyboardViewHandler
{
    return objc_getAssociatedObject(self, kLuaKeyboardViewHandlerKey);
}

#pragma mark - Open Ripple
- (UIColor*)oldColor
{
    return objc_getAssociatedObject(self, kLuaOldColor);
}

- (void)setOldColor:(UIColor*)oldColor
{
    if (oldColor) {
        objc_setAssociatedObject(self, kLuaOldColor, oldColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)lua_didSetOldColor
{
    NSNumber* number = objc_getAssociatedObject(self, kDidSetLuaOldColor);
    if (number) {
        return [number boolValue];
    }
    return NO;
}

- (void)lua_setDidSetOldColor:(BOOL)set
{
    objc_setAssociatedObject(self, kDidSetLuaOldColor, @(set), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isOpenRipple
{
    NSNumber* number = objc_getAssociatedObject(self, kLuaOpenRipple);
    if (number) {
        return [number boolValue];
    }
    return NO;
}

- (void)openRipple:(BOOL)isopen
{
    objc_setAssociatedObject(self, kLuaOpenRipple, @(isopen), OBJC_ASSOCIATION_ASSIGN);
}

- (void)lua_endEditing:(BOOL)needEnd
{
    objc_setAssociatedObject(self,kLuaNeedEndEditing,@(needEnd),OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)lua_needEndEditing
{
    NSNumber* number = objc_getAssociatedObject(self, kLuaNeedEndEditing);
    if (number) {
        return [number boolValue];
    }
    return NO;
}

- (void)lua_keyboardDismiss:(BOOL)autodismiss
{
    objc_setAssociatedObject(self,kLuaKeyboardDismiss,@(autodismiss),OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)lua_needDismissKeyboard
{
    NSNumber* number = objc_getAssociatedObject(self, kLuaKeyboardDismiss);
    if (number) {
        return [number boolValue];
    }
    return NO;
}

//开启高亮
- (void)lua_openRipple:(BOOL)open
{
    if (!self.userInteractionEnabled && open) {
        self.userInteractionEnabled = YES;
    }
    [self openRipple:open];
}

- (void)lua_bringSubviewToFront:(UIView*)view
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    [self bringSubviewToFront:view];
}

- (void)lua_sendSubviewToBack:(UIView*)view
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView)
    [self sendSubviewToBack:view];
}

#pragma mark - Life Cycle
- (void)lua_onDetachedFromWindowCallback:(MLNUIBlock *)callback
{
    [self setMln_onDetachedFromWindowCallback:callback];
}

#pragma mark - Detached
- (void)mln_in_traverseAllSubviewsCallbackDetached
{
    if (![self mln_isConvertible] || !self.superview) {
        return;
    }
    for (UIView *subView in self.subviews) {
        [subView mln_in_traverseAllSubviewsCallbackDetached];
    }
    [self.mln_onDetachedFromWindowCallback callIfCan];
}

#pragma mark - Transform
- (void)lua_resetTransformIfNeed
{
    MLNUITransformTask *myTransform = [self mln_in_getTransform];
    if (!CGAffineTransformEqualToTransform(myTransform.transform, CGAffineTransformIdentity)) {
        [self mln_pushAnimation:myTransform];
    }
}

- (void)lua_anchorPoint:(CGFloat)x y:(CGFloat)y
{
    MLNUIKitLuaAssert(x >= 0.0f && x <= 1.0f, @"param x should bigger or equal than 0.0 and smaller or equal than 1.0!");
    MLNUIKitLuaAssert(y >= 0.0f && y <= 1.0f, @"param y should bigger or equal than 0.0 and smaller or equal than 1.0!");
    [self.lua_node changeAnchorPoint:CGPointMake(x, y)];
}

- (void)lua_transform:(CGFloat)angle adding:(NSNumber *)add
{
    BOOL needAdd = YES;
    if ([add isKindOfClass:[NSNumber class]]) {
        needAdd = [add boolValue];
    }
    MLNUIKitLuaAssert(NO, @"View:transform method is deprecated , please use View:rotation method to achieve the same effect");
    MLNUITransformTask *myTransform = [self mln_in_getTransform];
    angle = angle / 360.0 * M_PI * 2;
    if (!needAdd) {
        myTransform.transform = CGAffineTransformMakeRotation(angle);
    } else   {
        myTransform.transform = CGAffineTransformRotate(myTransform.transform, angle);
    }
}

- (void)lua_rotation:(CGFloat)angle notNeedAdding:(NSNumber *)notNeedAdding
{
    BOOL needAdd = YES;
    if ([notNeedAdding isKindOfClass:[NSNumber class]]) {
        needAdd = ![notNeedAdding boolValue];
    }
    MLNUITransformTask *myTransform = [self mln_in_getTransform];
    angle = angle / 360.0 * M_PI * 2;
    if (!needAdd) {
        myTransform.transform = CGAffineTransformMakeRotation(angle);
    } else   {
        myTransform.transform = CGAffineTransformRotate(myTransform.transform, angle);
    }
}

- (void)lua_scale:(CGFloat)sx sy:(CGFloat)sy notNeedAdding:(NSNumber *)notNeedAdding
{
    BOOL needAdd = YES;
    if ([notNeedAdding isKindOfClass:[NSNumber class]]) {
        needAdd = ![notNeedAdding boolValue];
    }
    MLNUITransformTask *myTransform = [self mln_in_getTransform];
    if (!needAdd) {
        myTransform.transform = CGAffineTransformMakeScale(sx, sy);
    } else   {
        myTransform.transform = CGAffineTransformScale(myTransform.transform, sx, sy);
    }
}

- (void)lua_translation:(CGFloat)tx ty:(CGFloat)ty notNeedAdding:(NSNumber *)notNeedAdding
{
    BOOL needAdd = YES;
    if ([notNeedAdding isKindOfClass:[NSNumber class]]) {
        needAdd = ![notNeedAdding boolValue];
    }
    MLNUITransformTask *myTransform = [self mln_in_getTransform];
    if (!needAdd) {
        myTransform.transform = CGAffineTransformMakeTranslation(tx, ty);
    } else   {
        myTransform.transform = CGAffineTransformTranslate(myTransform.transform, tx, ty);
    }
}

- (void)lua_transformIdentity
{
    [self mln_in_getTransform].transform = CGAffineTransformIdentity;
    [self mln_pushAnimation:[self mln_in_getTransform]];
}

static const void *kViewTransform = &kViewTransform;
- (MLNUITransformTask *)mln_in_getTransform
{
    MLNUITransformTask *transform = objc_getAssociatedObject(self, kViewTransform);
    if (!transform) {
        transform = [[MLNUITransformTask alloc] initWithTargetView:self];
        objc_setAssociatedObject(self, kViewTransform, transform, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return transform;
}

#pragma mark - animtion
- (void)lua_removeAllAnimation
{
    [self.layer removeAllAnimations];
}

- (void)lua_startAnimation:(MLNUICanvasAnimation *)animation
{
    MLNUIKitLuaAssert([animation isKindOfClass:[MLNUICanvasAnimation class]], @"animation must be type CanvasAnimation!");
    if ([animation isKindOfClass:[MLNUICanvasAnimation class]]) {
        [animation startWithView:self];
    }
}

- (NSString *)lua_snapshotWithFileName:(NSString *)fileName
{
    MLNUICheckStringTypeAndNilValue(fileName);
    UIImage *image = nil;
    if ([self isKindOfClass:[UIScrollView class]]) {
        image = [MLNUISnapshotManager mln_captureScrollView:(UIScrollView *)self];
    } else if ([self isKindOfClass:[UIView class]]) {
        image = [MLNUISnapshotManager mln_captureNormalView:self];
    }
    
    return [MLNUISnapshotManager mln_image:image saveWithFileName:fileName];
}

- (void)lua_setBgImage:(NSString *)imageName
{
    if (!stringNotEmpty(imageName)) {
        self.layer.contents = nil;
        return;
    }
    if ([self mln_isConvertible]) {
        UIView<MLNUIEntityExportProtocol> *obj = (UIView<MLNUIEntityExportProtocol> *)self;
        id<MLNUIImageLoaderProtocol> imageLoader = MLNUI_KIT_INSTANCE(obj.mln_luaCore).instanceHandlersManager.imageLoader;
        [imageLoader view:obj loadImageWithPath:imageName completed:^(UIImage * _Nullable image, NSError * _Nullable error, NSString * _Nullable imagePath) {
            if (image) {
                self.layer.contentsScale = [UIScreen mainScreen].scale;
                self.layer.contents = (__bridge id)image.CGImage;
            } else {
                self.layer.contents = nil;
            }
        }];
    }
}

@end

@implementation UIView (Layout)

- (BOOL)lua_isContainer
{
    return NO;
}

@end

@implementation UIView (LazyTask)

- (void)mln_pushLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask;
{
    if ([self mln_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mln_luaCore]);
        [instance pushLazyTask:lazyTask];
    }
}

- (void)mln_popLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask
{
    if ([self mln_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mln_luaCore]);
        [instance popLazyTask:lazyTask];
    }
}

- (void)mln_pushAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation
{
    if ([self mln_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mln_luaCore]);
        [instance pushAnimation:animation];
    }
}

- (void)mln_popAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation
{
    if ([self mln_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mln_luaCore]);
        [instance popAnimation:animation];
    }
}

- (void)mln_pushRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask
{
    if ([self mln_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mln_luaCore]);
        [instance pushRenderTask:renderTask];
    }
}

- (void)mln_popRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask
{
    if ([self mln_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mln_luaCore]);
        [instance popRenderTask:renderTask];
    }
}

@end
