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
#import "MLNUITransformTask.h"
#import "MLNUISnapshotManager.h"
#import "MLNUICanvasAnimation.h"
#import "MLNUIKitInstanceHandlersManager.h"

#define kMLNUIDefaultRippleColor [UIColor colorWithRed:247/255.0 green:246/255.0 blue:244/255.0 alpha:1.0]

#define MLNUIMarkViewNeedRender  self.mlnui_needRender = YES;

static IMP __mlnui_in_UIView_Origin_TouchesBegan_Method_Imp;
static IMP __mlnui_in_UIView_Origin_TouchesMoved_Method_Imp;
static IMP __mlnui_in_UIView_Origin_TouchesEnded_Method_Imp;
static IMP __mlnui_in_UIView_Origin_TouchesCancelled_Method_Imp;

static const void *kLuaGradientLayer = &kLuaGradientLayer;
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
        Method swizzledMethod1 = class_getInstanceMethod([self class], @selector(mlnui_in_touchesBegan:withEvent:));
        __mlnui_in_UIView_Origin_TouchesBegan_Method_Imp = method_getImplementation(origMethod1);
        method_exchangeImplementations(origMethod1, swizzledMethod1);
        
        Method origMethod2 = class_getInstanceMethod([self class], @selector(touchesMoved:withEvent:));
        Method swizzledMethod2 = class_getInstanceMethod([self class], @selector(mlnui_in_touchesMoved:withEvent:));
        
        __mlnui_in_UIView_Origin_TouchesMoved_Method_Imp = method_getImplementation(origMethod2);
        method_exchangeImplementations(origMethod2, swizzledMethod2);
        
        Method origMethod3 = class_getInstanceMethod([self class], @selector(touchesEnded:withEvent:));
        Method swizzledMethod3 = class_getInstanceMethod([self class], @selector(mlnui_in_touchesEnded:withEvent:));
        
        __mlnui_in_UIView_Origin_TouchesEnded_Method_Imp = method_getImplementation(origMethod3);
        method_exchangeImplementations(origMethod3, swizzledMethod3);
        
        Method origMethod4 = class_getInstanceMethod([self class], @selector(touchesCancelled:withEvent:));
        Method swizzledMethod4 = class_getInstanceMethod([self class], @selector(mlnui_in_touchesCancelled:withEvent:));
        
        __mlnui_in_UIView_Origin_TouchesCancelled_Method_Imp = method_getImplementation(origMethod4);
        method_exchangeImplementations(origMethod4, swizzledMethod4);
        
        Method origMethod5 = class_getInstanceMethod([self class], @selector(removeFromSuperview));
        Method swizzledMethod5 = class_getInstanceMethod([self class], @selector(mlnui_in_removeFromSuperview));
        method_exchangeImplementations(origMethod5, swizzledMethod5);
    });
}

- (void)mlnui_in_removeFromSuperview
{
    if ([self mlnui_isConvertible]) {
        [self mlnui_in_traverseAllSubviewsCallbackDetached];
    }
    [self mlnui_in_removeFromSuperview];
}

- (void)mlnui_in_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void (*)(id, SEL, NSSet<UITouch *> *, UIEvent *))__mlnui_in_UIView_Origin_TouchesBegan_Method_Imp;
    functionPointer(self, _cmd, touches, event);
    if (![self isKindOfClass:[UIView class]]) {
        return;
    }
    [self mlnui_touchType:MLNUITouchType_Begin touch:touches.anyObject event:event];
    
    if([self isOpenRipple]) {
        if (![self oldColor] && ![self luaui_didSetOldColor]) {
            [self setOldColor:self.backgroundColor];
            [self luaui_setDidSetOldColor:YES];
        }
        self.backgroundColor = kMLNUIDefaultRippleColor;
    }
    
    if ([self luaui_needEndEditing]) {
        [self endEditing:YES];
    }
    
    if (self.mlnui_touchesBeganCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self.mlnui_touchesBeganCallback addFloatArgument:point.x];
        [self.mlnui_touchesBeganCallback addFloatArgument:point.y];
        [self.mlnui_touchesBeganCallback callIfCan];
    }
    
    if (self.mlnui_touchesBeganExtensionCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint screenLocation = [touch locationInView:self.window];
        CGPoint pageLocation = [touch locationInView:self];
        NSDictionary *touchDict = [self touchResultWithScreenLocation:screenLocation pageLocation:pageLocation target:self];
        [self.mlnui_touchesBeganExtensionCallback addObjArgument:[NSMutableDictionary dictionaryWithDictionary:touchDict]];
        [self.mlnui_touchesBeganExtensionCallback callIfCan];
    }
}

- (void)mlnui_in_touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void (*)(id, SEL, NSSet<UITouch *> *, UIEvent *))__mlnui_in_UIView_Origin_TouchesMoved_Method_Imp;
    functionPointer(self, _cmd, touches, event);
    if (![self isKindOfClass:[UIView class]]) {
        return;
    }
    [self mlnui_touchType:MLNUITouchType_Move touch:touches.anyObject event:event];

    if (self.mlnui_touchesMovedCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self.mlnui_touchesMovedCallback addFloatArgument:point.x];
        [self.mlnui_touchesMovedCallback addFloatArgument:point.y];
        [self.mlnui_touchesMovedCallback callIfCan];
    }
    
    if (self.mlnui_touchesMovedExtensionCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint screenLocation = [touch locationInView:self.window];
        CGPoint pageLocation = [touch locationInView:self];
        NSDictionary *touchDict = [self touchResultWithScreenLocation:screenLocation pageLocation:pageLocation target:self];
        [self.mlnui_touchesMovedExtensionCallback addObjArgument:touchDict.mutableCopy];
        [self.mlnui_touchesMovedExtensionCallback callIfCan];
    }
}

- (void)mlnui_in_touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void (*)(id, SEL, NSSet<UITouch *> *, UIEvent *))__mlnui_in_UIView_Origin_TouchesEnded_Method_Imp;
    functionPointer(self, _cmd, touches, event);
    
    if (![self isKindOfClass:[UIView class]]) {
        return;
    }
    [self mlnui_touchType:MLNUITouchType_End touch:touches.anyObject event:event];

    if([self isOpenRipple]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.backgroundColor = [self oldColor];
            [self luaui_setDidSetOldColor:NO];
        });
    }
    
    if (self.mlnui_touchesEndedCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self.mlnui_touchesEndedCallback addFloatArgument:point.x];
        [self.mlnui_touchesEndedCallback addFloatArgument:point.y];
        [self.mlnui_touchesEndedCallback callIfCan];
    }
    
    if (self.mlnui_touchesEndedExtensionCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint screenLocation = [touch locationInView:self.window];
        CGPoint pageLocation = [touch locationInView:self];
        NSDictionary *touchDict = [self touchResultWithScreenLocation:screenLocation pageLocation:pageLocation target:self];
        [self.mlnui_touchesEndedExtensionCallback addObjArgument:touchDict.mutableCopy];
        [self.mlnui_touchesEndedExtensionCallback callIfCan];
    }
}

- (void)mlnui_in_touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void (*)(id, SEL, NSSet<UITouch *> *, UIEvent *))__mlnui_in_UIView_Origin_TouchesCancelled_Method_Imp;
    functionPointer(self, _cmd, touches, event);
    if (![self isKindOfClass:[UIView class]]) {
        return;
    }
    [self mlnui_touchType:MLNUITouchType_End touch:touches.anyObject event:event];

    if([self isOpenRipple]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.backgroundColor = [self oldColor];
            [self luaui_setDidSetOldColor:NO];
        });
    }
    
    if (self.mlnui_touchesCancelledCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        [self.mlnui_touchesCancelledCallback addFloatArgument:point.x];
        [self.mlnui_touchesCancelledCallback addFloatArgument:point.y];
        [self.mlnui_touchesCancelledCallback callIfCan];
    }
    
    if (self.mlnui_touchesCancelledExtensionCallback) {
        UITouch *touch = [touches anyObject];
        CGPoint screenLocation = [touch locationInView:self.window];
        CGPoint pageLocation = [touch locationInView:self];
        NSDictionary *touchDict = [self touchResultWithScreenLocation:screenLocation pageLocation:pageLocation target:self];
        [self.mlnui_touchesCancelledExtensionCallback addObjArgument:touchDict.mutableCopy];
        [self.mlnui_touchesCancelledExtensionCallback callIfCan];
    }
}

static void *kMLNUITouchCallbacksKey = &kMLNUITouchCallbacksKey;
- (void)mlnui_addTouchBlock:(MLNUITouchCallback)block {
    if (block) {
        NSMutableArray *touchCallbacks = [self mlnui_touchBlocksCreateIfNeeded:YES];
        if (![touchCallbacks containsObject:block]) {
            [touchCallbacks addObject:block];
        }
    }
}

- (void)mlnui_removeTouchBlock:(MLNUITouchCallback)block {
    if (block) {
        NSMutableArray *touchCallbacks = [self mlnui_touchBlocksCreateIfNeeded:NO];
        [touchCallbacks removeObject:block];
    }
}

- (NSMutableArray *)mlnui_touchBlocksCreateIfNeeded:(BOOL)create {
    NSMutableArray *arr = objc_getAssociatedObject(self, kMLNUITouchCallbacksKey);
    if (!arr && create) {
        arr = [NSMutableArray array];
        objc_setAssociatedObject(self, kMLNUITouchCallbacksKey, arr, OBJC_ASSOCIATION_RETAIN);
    }
    return arr;
}

- (void)mlnui_touchType:(MLNUITouchType)type touch:(UITouch *)touch event:(UIEvent *)event {
    NSMutableArray<MLNUITouchCallback> *callbacks = [self mlnui_touchBlocksCreateIfNeeded:NO];
    for (MLNUITouchCallback block in callbacks) {
        block(type, touch, event);
    }
}

#pragma mark -

- (void)luaui_setBackgroundColor:(UIColor *)color
{
    MLNUICheckTypeAndNilValue(color, @"Color", UIColor);
    MLNUIMarkViewNeedRender;
    [self setOldColor:color];
    self.backgroundColor = color;
    [self.mlnui_in_renderContext  cleanGradientColorIfNeed];
    [self.mlnui_in_renderContext cleanLayerContentsIfNeed];
}

- (void)luaui_setNeedsDisplay
{
    MLNUIKitLuaAssert(NO, @"View:refresh method is deprecated!");
    [self setNeedsDisplay];
}

- (CGPoint)luaui_convertToView:(UIView *)view point:(CGPoint)point
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    return [self convertPoint:point toView:view];
}

- (CGPoint)luaui_convertRelativePointToView:(UIView *)view point:(CGPoint)point
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

- (CGPoint)luaui_convertFromView:(UIView *)view point:(CGPoint)point
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    return [self convertPoint:point fromView:view];
}

#pragma mark - Render

- (void)setMlnui_needRender:(BOOL)needRender {
    objc_setAssociatedObject(self, @selector(mlnui_needRender), @(needRender), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)mlnui_needRender {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

static const void *kLuaBoarderColor = &kLuaBoarderColor;
- (void)luaui_setBorderColor:(UIColor *)color
{
    MLNUICheckTypeAndNilValue(color, @"Color", UIColor);
    MLNUIMarkViewNeedRender;
    objc_setAssociatedObject(self, kLuaBoarderColor, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.mlnui_in_renderContext resetBorderWithBorderWidth:[self luaui_borderWidth] borderColor:[self luaui_borderColor]];
}

- (UIColor *)luaui_borderColor
{
    return objc_getAssociatedObject(self, kLuaBoarderColor);
}

static const void *kLuaBoarderWidth = &kLuaBoarderWidth;
- (void)luaui_setBorderWidth:(CGFloat)borderWidth
{
    MLNUIMarkViewNeedRender;
    objc_setAssociatedObject(self, kLuaBoarderWidth, @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.mlnui_in_renderContext resetBorderWithBorderWidth:borderWidth borderColor:[self luaui_borderColor]];
}

- (CGFloat)luaui_borderWidth
{
    return CGFloatValueFromNumber(objc_getAssociatedObject(self, kLuaBoarderWidth));
}

- (void)luaui_showShadowPath
{
    MLNUIMarkViewNeedRender;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)luaui_setShadowOffset:(CGFloat)x y:(CGFloat)y
{
    MLNUIMarkViewNeedRender;
    [self.layer setShadowOffset:CGSizeMake(x, y)];
}

- (void)luaui_setShadowRadius:(CGFloat)radius
{
    MLNUIMarkViewNeedRender;
    [self.layer setShadowRadius:radius];
}

- (void)luaui_setShadowOpacity:(BOOL)opacity
{
    MLNUIMarkViewNeedRender;
    [self.layer setShadowOpacity:opacity];
}

- (void)luaui_setNotClip:(BOOL)not
{
    // Just for android.
}

- (void)luaui_setClipsToBounds:(BOOL)clipsToBounds
{
    MLNUIMarkViewNeedRender;
    self.clipsToBounds = clipsToBounds;
    MLNUIRenderContext *renderContext = [self mlnui_in_renderContext];
    renderContext.clipToBounds = clipsToBounds;
    renderContext.didSetClipToBounds = YES;
}

- (void)luaui_setClipsToChildren:(BOOL)clipsToChildren
{
    MLNUIMarkViewNeedRender;
    MLNUIRenderContext *renderContext = [self mlnui_in_renderContext];
    renderContext.clipToChildren = clipsToChildren;
    renderContext.didSetClipToChildren = YES;
}

#pragma mark - Corner Radius
- (void)luaui_setCornerRadius:(CGFloat)cornerRadius
{
    MLNUIMarkViewNeedRender;
    [self.mlnui_in_renderContext resetCornerRadius:cornerRadius];
}

- (CGFloat)luaui_cornerRadius
{
    return [self.mlnui_in_renderContext cornerRadius];
}

- (CGFloat)luaui_getCornerRadiusWithDirection:(MLNUIRectCorner)corner
{
    return [self.mlnui_in_renderContext cornerRadiusWithDirection:corner];
}

- (void)luaui_setCornerRadius:(CGFloat)cornerRadius byRoundingCorners:(MLNUIRectCorner)corners
{
    MLNUIMarkViewNeedRender;
    if (corners == MLNUIRectCornerNone) {
        corners = MLNUIRectCornerAllCorners;
    }
    [self.mlnui_in_renderContext resetCornerRadius:cornerRadius byRoundingCorners:corners];
}

- (void)luaui_addCornerMaskWithRadius:(CGFloat)cornerRadius maskColor:(UIColor *)maskColor corners:(MLNUIRectCorner)corners
{
    MLNUICheckTypeAndNilValue(maskColor, @"Color", UIColor);
    MLNUIMarkViewNeedRender;
    if (corners == MLNUIRectCornerNone) {
        corners = MLNUIRectCornerAllCorners;
    }
    [self.mlnui_in_renderContext resetCornerMaskViewWithRadius:cornerRadius maskColor:maskColor corners:(UIRectCorner)corners];
}

- (void)mlnui_updateCornersIfNeed
{
    [self.mlnui_in_renderContext updateIfNeed];
}

#pragma mark - gradientLayer
- (void)luaui_setGradientColor:(UIColor *)startColor endColor:(UIColor *)endColor vertical:(BOOL)isVertical
{
    MLNUIKitLuaAssert(startColor && [startColor isKindOfClass:[UIColor class]], @"startColor must be type of UIColor");
    MLNUIKitLuaAssert(endColor && [endColor isKindOfClass:[UIColor class]], @"endColor must be type of UIColor");
    if (![startColor isKindOfClass:[UIColor class]] || ![endColor isKindOfClass:[UIColor class]]) return;
    MLNUIMarkViewNeedRender;
    MLNUIGradientType type = isVertical ? MLNUIGradientTypeTopToBottom : MLNUIGradientTypeLeftToRight;
    [self.mlnui_in_renderContext resetGradientColor:startColor endColor:endColor direction:type];
}

- (void)luaui_setGradientColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(MLNUIGradientType)direction
{
    MLNUIKitLuaAssert(startColor && [startColor isKindOfClass:[UIColor class]], @"startColor must be type of UIColor");
    MLNUIKitLuaAssert(endColor && [endColor isKindOfClass:[UIColor class]], @"endColor must be type of UIColor");
    MLNUIMarkViewNeedRender;
    [self.mlnui_in_renderContext resetGradientColor:startColor endColor:endColor direction:direction];
}

- (void)mlnui_updateGradientLayerIfNeed
{
    [self.mlnui_in_renderContext updateIfNeed];
}

#pragma mark - shadowLayer
- (void)luaui_addShadow:(UIColor *)shadowColor shadowOffset:(CGSize)offset shadowRadius:(CGFloat)radius shadowOpacity:(CGFloat)opacity isOval:(BOOL)isOval
{
    MLNUIKitLuaAssert(NO, @"The 'addShadow' method is deprected, use 'setShadow' method instead!");
    MLNUIKitLuaAssert(shadowColor && [shadowColor isKindOfClass:[UIColor class]], @"shadowColor must be type of UIColor");
    MLNUIKitLuaAssert(![self isKindOfClass:[UIImageView class]], @"ImageView does not support addShadow");
    if (![shadowColor isKindOfClass:[UIColor class]]) return;
    MLNUIMarkViewNeedRender;
    [self.mlnui_in_renderContext resetShadow:shadowColor shadowOffset:offset shadowRadius:radius shadowOpacity:opacity isOval:isOval];
}

- (void)luaui_setShadowWithShadowOffset:(CGSize)offset shadowRadius:(CGFloat)radius shadowOpacity:(CGFloat)opacity
{
    if ([self isKindOfClass:[UIImageView class]]) return;
    MLNUIMarkViewNeedRender;
    UIColor *defaultShadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.215];
    [self.mlnui_in_renderContext resetShadow:defaultShadowColor shadowOffset:offset shadowRadius:radius shadowOpacity:opacity isOval:false];
}

static const void *kLuaRenderContext = &kLuaRenderContext;
- (MLNUIRenderContext *)mlnui_in_renderContext
{
    MLNUIRenderContext *cxt = objc_getAssociatedObject(self, kLuaRenderContext);
    if (!cxt) {
        cxt = [[MLNUIRenderContext alloc] initWithTargetView:self];
        objc_setAssociatedObject(self, kLuaRenderContext, cxt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cxt;
}

- (MLNUIRenderContext *)mlnui_renderContext
{
    return [self mlnui_in_renderContext];
}

#pragma mark - blurEffect
- (void)luaui_addBlurEffect
{
    MLNUIMarkViewNeedRender;
    CGRect rect = self.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    UIView* view = [self mlnui_in_getBlurView];
    view.frame = rect;
    if ([self respondsToSelector: @selector(setBackgroundView:)]) {
        [self performSelector:@selector(setBackgroundView:) withObject:view afterDelay:0];
    } else {
        [self insertSubview:view atIndex:0];
    }
}

- (void)luaui_removeBlurEffect
{
    UIView* view = [self mlnui_in_getBlurView];
    [view removeFromSuperview];
}

- (void)mlnui_in_setBlurEffectView:(UIView*)blurView
{
    objc_setAssociatedObject(self, kLuaBlurEffectView, blurView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)mlnui_in_getBlurView
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
        [self mlnui_in_setBlurEffectView:blurView];
        view = blurView;
    }
    return view;
}

#pragma mark - Focus
- (void)luaui_requestFocus
{
    if (self.userInteractionEnabled) {
        [self becomeFirstResponder];
    }
}

#pragma mark - TouchEvent
- (void)luaui_setTouchesBeganCallback:(MLNUIBlock *)callback
{
    MLNUIMarkViewNeedRender;
    self.mlnui_touchesBeganCallback = callback;
}

- (void)luaui_setTouchesMovedCallback:(MLNUIBlock *)callback
{
    MLNUIMarkViewNeedRender;
    self.mlnui_touchesMovedCallback = callback;
}

- (void)luaui_setTouchesEndedCallback:(MLNUIBlock *)callback
{
    MLNUIMarkViewNeedRender;
    self.mlnui_touchesEndedCallback = callback;
}

- (void)luaui_setTouchesCancelledCallback:(MLNUIBlock *)callback
{
    MLNUIMarkViewNeedRender;
    self.mlnui_touchesCancelledCallback = callback;
}

- (void)luaui_setTouchesBeganExtensionCallback:(MLNUIBlock *)callback
{
    MLNUIMarkViewNeedRender;
    self.mlnui_touchesBeganExtensionCallback = callback;
}

- (void)luaui_setTouchesMovedExtensionCallback:(MLNUIBlock *)callback
{
    MLNUIMarkViewNeedRender;
    self.mlnui_touchesMovedExtensionCallback = callback;
}

- (void)luaui_setTouchesEndedExtensionCallback:(MLNUIBlock *)callback
{
    MLNUIMarkViewNeedRender;
    self.mlnui_touchesEndedExtensionCallback = callback;
}

- (void)luaui_setTouchesCancelledExtensionCallback:(MLNUIBlock *)callback
{
    MLNUIMarkViewNeedRender;
    self.mlnui_touchesCancelledExtensionCallback = callback;
}

#pragma mark - Gesture
- (BOOL)luaui_enable
{
    return self.userInteractionEnabled;
}

- (void)setLuaui_enable:(BOOL)luaui_enable
{
    self.userInteractionEnabled = luaui_enable;
}

- (BOOL)luaui_canClick
{
    return NO;
}

- (BOOL)luaui_canLongPress
{
    return NO;
}

- (void)luaui_addTouch:(MLNUIBlock *)touchCallBack
{
    MLNUIKitLuaAssert(NO, @"View:onTouch method is deprecated");
    MLNUIMarkViewNeedRender;
    [self mlnui_in_addTapGestureIfNeed];
    self.mlnui_touchClickBlock = touchCallBack;
}

- (void)luaui_addClick:(MLNUIBlock *)clickCallback
{
    MLNUIMarkViewNeedRender;
    [self mlnui_in_addTapGestureIfNeed];
    self.mlnui_tapClickBlock = clickCallback;
}

- (void)mlnui_in_addTapGestureIfNeed
{
    UITapGestureRecognizer *gesture = [self mlnui_in_getClickGesture];
    if (!gesture && [self luaui_canClick]) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mlnui_in_tapClickAction:)];
        [self addGestureRecognizer:gesture];
        [self mlnui_in_setClickGesture:gesture];
    }
}

- (void)mlnui_in_removeTapGestureIfNeed
{
    if (self.mlnui_touchClickBlock != nil || self.mlnui_tapClickBlock != nil || [self luaui_needDismissKeyboard]) {
        return;
    }
    
    UITapGestureRecognizer *gesture = [self mlnui_in_getClickGesture];
    if (gesture) {
        [self removeGestureRecognizer:gesture];
        [self mlnui_in_setClickGesture:nil];
    }
}

- (void)mlnui_in_tapClickAction:(UIGestureRecognizer *)gesture
{
    if (!self.luaui_enable) {
        return;
    }
    if (self.mlnui_tapClickBlock) {
        [self.mlnui_tapClickBlock callIfCan];
    }
    if ([self luaui_needDismissKeyboard]) {
        [self.window endEditing:YES];
    }
    if (self.mlnui_touchClickBlock) {
        CGPoint point = [gesture locationInView:self];
        [self.mlnui_touchClickBlock addFloatArgument:point.x];
        [self.mlnui_touchClickBlock addFloatArgument:point.y];
        [self.mlnui_touchClickBlock callIfCan];
    }
}

- (void)luaui_addLongPress:(MLNUIBlock *)longPressCallback
{
    MLNUIMarkViewNeedRender;
    [self mlnui_in_addLongPressGestureIfNeed];
    self.mlnui_longPressBlock = longPressCallback;
}

- (void)mlnui_in_addLongPressGestureIfNeed
{
    if (!self.mlnui_longPressBlock && [self luaui_canLongPress]) {
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mlnui_in_longPressAction:)];
        [self addGestureRecognizer:gesture];
    }
}

- (void)mlnui_in_longPressAction:(UIGestureRecognizer *)gesture
{
    if (!self.luaui_enable) {
        return;
    }
    if (!self.mlnui_longPressBlock) return;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self];
        [self.mlnui_longPressBlock addFloatArgument:point.x];
        [self.mlnui_longPressBlock addFloatArgument:point.y];
        [self.mlnui_longPressBlock callIfCan];
    }
}

static const void *kLuaClickGesture = &kLuaClickGesture;
- (void)mlnui_in_setClickGesture:(UITapGestureRecognizer *)gesture
{
    objc_setAssociatedObject(self, kLuaClickGesture, gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITapGestureRecognizer *)mlnui_in_getClickGesture
{
    return objc_getAssociatedObject(self, kLuaClickGesture);
}

static const void *kLuaTapGesture = &kLuaTapGesture;
- (void)setMlnui_tapClickBlock:(MLNUIBlock *)tapClickBlock
{
    MLNUICheckTypeAndNilValue(tapClickBlock, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTapGesture, tapClickBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_tapClickBlock
{
    return objc_getAssociatedObject(self, kLuaTapGesture);
}

static const void *kLuaTouchGesture = &kLuaTouchGesture;
- (void)setMlnui_touchClickBlock:(MLNUIBlock *)mlnui_touchClickBlock {
    MLNUICheckTypeAndNilValue(mlnui_touchClickBlock, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchGesture, mlnui_touchClickBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_touchClickBlock {
    return objc_getAssociatedObject(self, kLuaTouchGesture);
}

static const void *kLuaLongPressGesture = &kLuaLongPressGesture;
- (void)setMlnui_longPressBlock:(MLNUIBlock *)longPressBlock
{
    MLNUICheckTypeAndNilValue(longPressBlock, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaLongPressGesture, longPressBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_longPressBlock
{
    return objc_getAssociatedObject(self, kLuaLongPressGesture);
}

static const void *kLuaTouchesBeganEvent = &kLuaTouchesBeganEvent;
- (void)setMlnui_touchesBeganCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesBeganEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_touchesBeganCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesBeganEvent);
}

static const void *kLuaTouchesMovedEvent = &kLuaTouchesMovedEvent;
- (void)setMlnui_touchesMovedCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesMovedEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_touchesMovedCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesMovedEvent);
}

static const void *kLuaTouchesEndedEvent = &kLuaTouchesEndedEvent;
- (void)setMlnui_touchesEndedCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesEndedEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_touchesEndedCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesEndedEvent);
}

static const void *kLuaTouchesCancelledEvent = &kLuaTouchesCancelledEvent;
- (void)setMlnui_touchesCancelledCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesCancelledEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_touchesCancelledCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesCancelledEvent);
}

static const void *kLuaTouchesBeganExtensionEvent = &kLuaTouchesBeganExtensionEvent;
- (void)setMlnui_touchesBeganExtensionCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesBeganExtensionEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_touchesBeganExtensionCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesBeganExtensionEvent);
}

static const void *kLuaTouchesMovedExtensionEvent = &kLuaTouchesMovedExtensionEvent;
- (void)setMlnui_touchesMovedExtensionCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesMovedExtensionEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_touchesMovedExtensionCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesMovedExtensionEvent);
}

static const void *kLuaTouchesEndedExtensionEvent = &kLuaTouchesEndedExtensionEvent;
- (void)setMlnui_touchesEndedExtensionCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesEndedExtensionEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_touchesEndedExtensionCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesEndedExtensionEvent);
}

static const void *kLuaTouchesCancelledExtensionEvent = &kLuaTouchesCancelledExtensionEvent;
- (void)setMlnui_touchesCancelledExtensionCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaTouchesCancelledExtensionEvent, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_touchesCancelledExtensionCallback
{
    return objc_getAssociatedObject(self, kLuaTouchesCancelledExtensionEvent);
}

static const void *kLuaOnDetachedFromWindowCallback = &kLuaOnDetachedFromWindowCallback;
- (void)setMlnui_onDetachedFromWindowCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"callback", MLNUIBlock);
    objc_setAssociatedObject(self, kLuaOnDetachedFromWindowCallback, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MLNUIBlock *)mlnui_onDetachedFromWindowCallback
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

- (BOOL)luaui_didSetOldColor
{
    NSNumber* number = objc_getAssociatedObject(self, kDidSetLuaOldColor);
    if (number) {
        return [number boolValue];
    }
    return NO;
}

- (void)luaui_setDidSetOldColor:(BOOL)set
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

- (void)luaui_endEditing:(BOOL)needEnd
{
    objc_setAssociatedObject(self,kLuaNeedEndEditing,@(needEnd),OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)luaui_needEndEditing
{
    NSNumber* number = objc_getAssociatedObject(self, kLuaNeedEndEditing);
    if (number) {
        return [number boolValue];
    }
    return NO;
}

- (void)luaui_keyboardDismiss:(BOOL)autodismiss
{
    objc_setAssociatedObject(self,kLuaKeyboardDismiss,@(autodismiss),OBJC_ASSOCIATION_ASSIGN);
    //当添加点击取消键盘事件后，检查是否添加了点击手势，否则检查是否应该删除点击手势
    if (autodismiss) {
        [self mlnui_in_addTapGestureIfNeed];
    } else {
        [self mlnui_in_removeTapGestureIfNeed];
    }
}

- (BOOL)luaui_needDismissKeyboard
{
    NSNumber* number = objc_getAssociatedObject(self, kLuaKeyboardDismiss);
    if (number) {
        return [number boolValue];
    }
    return NO;
}

//开启高亮
- (void)luaui_openRipple:(BOOL)open
{
    if (!self.userInteractionEnabled && open) {
        self.userInteractionEnabled = YES;
    }
    [self openRipple:open];
}

- (void)luaui_bringSubviewToFront:(UIView*)view
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView);
    [self bringSubviewToFront:view];
}

- (void)luaui_sendSubviewToBack:(UIView*)view
{
    MLNUICheckTypeAndNilValue(view, @"View", UIView)
    [self sendSubviewToBack:view];
}

#pragma mark - Life Cycle
- (void)luaui_onDetachedFromWindowCallback:(MLNUIBlock *)callback
{
    [self setMlnui_onDetachedFromWindowCallback:callback];
}

#pragma mark - Detached
- (void)mlnui_in_traverseAllSubviewsCallbackDetached
{
    if (![self mlnui_isConvertible] || !self.superview) {
        return;
    }
    for (UIView *subView in self.subviews) {
        [subView mlnui_in_traverseAllSubviewsCallbackDetached];
    }
    [self.mlnui_onDetachedFromWindowCallback callIfCan];
}

#pragma mark - Transform

- (void)luaui_resetTransformIfNeed
{
    MLNUITransformTask *myTransform = [self mlnui_in_getTransform];
    if (!CGAffineTransformEqualToTransform(myTransform.transform, CGAffineTransformIdentity)) {
        [self mlnui_pushAnimation:myTransform];
    }
}

- (void)luaui_anchorPoint:(CGFloat)x y:(CGFloat)y
{
    MLNUIKitLuaAssert(x >= 0.0f && x <= 1.0f, @"param x should bigger or equal than 0.0 and smaller or equal than 1.0!");
    MLNUIKitLuaAssert(y >= 0.0f && y <= 1.0f, @"param y should bigger or equal than 0.0 and smaller or equal than 1.0!");
    self.layer.anchorPoint = CGPointMake(x, y);
}

- (void)luaui_transform:(CGFloat)angle adding:(NSNumber *)add
{
    BOOL needAdd = YES;
    if ([add isKindOfClass:[NSNumber class]]) {
        needAdd = [add boolValue];
    }
    MLNUIKitLuaAssert(NO, @"View:transform method is deprecated , please use View:rotation method to achieve the same effect");
    MLNUITransformTask *myTransform = [self mlnui_in_getTransform];
    angle = angle / 360.0 * M_PI * 2;
    if (!needAdd) {
        myTransform.transform = CGAffineTransformMakeRotation(angle);
    } else   {
        myTransform.transform = CGAffineTransformRotate(myTransform.transform, angle);
    }
}

- (void)luaui_rotation:(CGFloat)angle notNeedAdding:(NSNumber *)notNeedAdding
{
    BOOL needAdd = YES;
    if ([notNeedAdding isKindOfClass:[NSNumber class]]) {
        needAdd = ![notNeedAdding boolValue];
    }
    MLNUITransformTask *myTransform = [self mlnui_in_getTransform];
    angle = angle / 360.0 * M_PI * 2;
    if (!needAdd) {
        myTransform.transform = CGAffineTransformMakeRotation(angle);
    } else   {
        myTransform.transform = CGAffineTransformRotate(myTransform.transform, angle);
    }
}

- (void)luaui_scale:(CGFloat)sx sy:(CGFloat)sy notNeedAdding:(NSNumber *)notNeedAdding
{
    BOOL needAdd = YES;
    if ([notNeedAdding isKindOfClass:[NSNumber class]]) {
        needAdd = ![notNeedAdding boolValue];
    }
    MLNUITransformTask *myTransform = [self mlnui_in_getTransform];
    if (!needAdd) {
        myTransform.transform = CGAffineTransformMakeScale(sx, sy);
    } else   {
        myTransform.transform = CGAffineTransformScale(myTransform.transform, sx, sy);
    }
}

- (void)luaui_translation:(CGFloat)tx ty:(CGFloat)ty notNeedAdding:(NSNumber *)notNeedAdding
{
    BOOL needAdd = YES;
    if ([notNeedAdding isKindOfClass:[NSNumber class]]) {
        needAdd = ![notNeedAdding boolValue];
    }
    MLNUITransformTask *myTransform = [self mlnui_in_getTransform];
    if (!needAdd) {
        myTransform.transform = CGAffineTransformMakeTranslation(tx, ty);
    } else   {
        myTransform.transform = CGAffineTransformTranslate(myTransform.transform, tx, ty);
    }
}

- (void)luaui_transformIdentity
{
    [self mlnui_in_getTransform].transform = CGAffineTransformIdentity;
    [self mlnui_pushAnimation:[self mlnui_in_getTransform]];
}

static const void *kViewTransform = &kViewTransform;
- (MLNUITransformTask *)mlnui_in_getTransform
{
    MLNUITransformTask *transform = objc_getAssociatedObject(self, kViewTransform);
    if (!transform) {
        transform = [[MLNUITransformTask alloc] initWithTargetView:self];
        objc_setAssociatedObject(self, kViewTransform, transform, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return transform;
}

#pragma mark - animtion
- (void)luaui_removeAllAnimation
{
    [self.layer removeAllAnimations];
}

- (void)luaui_startAnimation:(MLNUICanvasAnimation *)animation
{
    MLNUIKitLuaAssert([animation isKindOfClass:[MLNUICanvasAnimation class]], @"animation must be type CanvasAnimation!");
    if ([animation isKindOfClass:[MLNUICanvasAnimation class]]) {
        [animation startWithView:self];
    }
}

- (NSString *)luaui_snapshotWithFileName:(NSString *)fileName
{
    MLNUICheckStringTypeAndNilValue(fileName);
    UIImage *image = nil;
    if ([self isKindOfClass:[UIScrollView class]]) {
        image = [MLNUISnapshotManager mlnui_captureScrollView:(UIScrollView *)self];
    } else if ([self isKindOfClass:[UIView class]]) {
        image = [MLNUISnapshotManager mlnui_captureNormalView:self];
    }
    
    return [MLNUISnapshotManager mlnui_image:image saveWithFileName:fileName];
}

- (void)luaui_setBgImage:(NSString *)imageName
{
    MLNUIMarkViewNeedRender;
    if (!stringNotEmpty(imageName)) {
        self.layer.contents = nil;
        return;
    }
    if ([self mlnui_isConvertible]) {
        UIView<MLNUIEntityExportProtocol> *obj = (UIView<MLNUIEntityExportProtocol> *)self;
        id<MLNUIImageLoaderProtocol> imageLoader = MLNUI_KIT_INSTANCE(obj.mlnui_luaCore).instanceHandlersManager.imageLoader;
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

- (BOOL)luaui_isContainer
{
    return NO;
}

@end

@implementation UIView (LazyTask)

- (void)mlnui_pushLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask;
{
    if ([self mlnui_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mlnui_luaCore]);
        [instance pushLazyTask:lazyTask];
    }
}

- (void)mlnui_popLazyTask:(id<MLNUIBeforeWaitingTaskProtocol>)lazyTask
{
    if ([self mlnui_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mlnui_luaCore]);
        [instance popLazyTask:lazyTask];
    }
}

- (void)mlnui_pushAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation
{
    if ([self mlnui_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mlnui_luaCore]);
        [instance pushAnimation:animation];
    }
}

- (void)mlnui_popAnimation:(id<MLNUIBeforeWaitingTaskProtocol>)animation
{
    if ([self mlnui_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mlnui_luaCore]);
        [instance popAnimation:animation];
    }
}

- (void)mlnui_pushRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask
{
    if ([self mlnui_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mlnui_luaCore]);
        [instance pushRenderTask:renderTask];
    }
}

- (void)mlnui_popRenderTask:(id<MLNUIBeforeWaitingTaskProtocol>)renderTask
{
    if ([self mlnui_isConvertible]) {
        MLNUIKitInstance *instance = MLNUI_KIT_INSTANCE([(UIView<MLNUIEntityExportProtocol> *)self mlnui_luaCore]);
        [instance popRenderTask:renderTask];
    }
}

@end
