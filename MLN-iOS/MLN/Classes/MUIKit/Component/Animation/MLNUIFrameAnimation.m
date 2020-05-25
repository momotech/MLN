//
//  MLNUIFrameAnimation.m
//
//
//  Created by MoMo on 2018/11/14.
//

#import "MLNUIFrameAnimation.h"
#import "MLNUIKitHeader.h"
#import "MLNUIEntityExporterMacro.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutNode.h"
#import "MLNUIAnimationConst.h"
#import "MLNUIBlock.h"

@interface MLNUIFrameAnimation ()

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, assign) NSInteger lua_repeatCount;
@end

@implementation MLNUIFrameAnimation

- (instancetype)init
{
    if (self = [super init]) {
        _translationStartX = MLNUIValueTypeCurrent;
        _translationStartY = MLNUIValueTypeCurrent;
        _translationEndX = MLNUIValueTypeCurrent;
        _translationEndY = MLNUIValueTypeCurrent;
        _scaleStartWidth = MLNUIValueTypeCurrent;
        _scaleStartHeight = MLNUIValueTypeCurrent;
        _scaleEndWidth = MLNUIValueTypeCurrent;
        _scaleEndHeight = MLNUIValueTypeCurrent;
        _startAlpha = MLNUIValueTypeCurrent;
        _endAlpha = MLNUIValueTypeCurrent;
        _options = UIViewAnimationOptionLayoutSubviews;
    }
    return self;
}

- (void)lua_setTranslateXTo:(CGFloat)toValue
{
    [self lua_setTranslateX:MLNUIValueTypeCurrent to:toValue];
}

- (void)lua_setTranslateX:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.translationStartX = fromeValue;
    self.translationEndX = toValue;
}

- (void)lua_setTranslateYTo:(CGFloat)toValue
{
    [self lua_setTranslateY:MLNUIValueTypeCurrent to:toValue];
}

- (void)lua_setTranslateY:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.translationStartY = fromeValue;
    self.translationEndY = toValue;
}

- (void)lua_setScaleWidthTo:(CGFloat)toValue
{
    [self lua_setScaleWidth:MLNUIValueTypeCurrent to:toValue];
}

- (void)lua_setScaleWidth:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.scaleStartWidth = fromeValue;
    self.scaleEndWidth = toValue;
}

- (void)lua_setScaleHeightTo:(CGFloat)toValue
{
    [self lua_setScaleHeight:MLNUIValueTypeCurrent to:toValue];
}

- (void)lua_setScaleHeight:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.scaleStartHeight = fromeValue;
    self.scaleEndHeight = toValue;
}

- (void)lua_setAlphaTo:(CGFloat)toValue
{
    [self lua_setAlpha:MLNUIValueTypeCurrent to:toValue];
}

- (void)lua_setAlpha:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.startAlpha = fromeValue;
    self.endAlpha = toValue;
}

- (void)lua_setBgColorTo:(UIColor *)toValue
{
    MLNUICheckTypeAndNilValue(toValue, @"Color", [UIColor class])
    self.endBgColor = toValue;
}

- (void)lua_setBgColor:(UIColor *)fromeValue to:(UIColor *)toValue
{
    MLNUICheckTypeAndNilValue(fromeValue, @"Color", [UIColor class])
    MLNUICheckTypeAndNilValue(toValue, @"Color", [UIColor class])
    self.startBgColor = fromeValue;
    self.endBgColor = toValue;
}

- (void)lua_needRepeat
{
    self.options = self.options & ~UIViewAnimationOptionAutoreverse;
    self.options = self.options | UIViewAnimationOptionRepeat;
}

- (void)lua_needAutoreverseRepeat
{
    self.options = self.options | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse;
}

- (void)lua_setInterpolator:(MLNUIAnimationInterpolatorType)type
{
    switch (type) {
        case MLNUIAnimationInterpolatorTypeAccelerateDecelerate:
            self.options = self.options | UIViewAnimationOptionCurveEaseInOut;
            break;
        case MLNUIAnimationInterpolatorTypeAccelerate:
            self.options = self.options | UIViewAnimationOptionCurveEaseIn;
            break;
        case MLNUIAnimationInterpolatorTypeDecelerate:
            self.options = self.options | UIViewAnimationOptionCurveEaseOut;
            break;
        default:
            //@note: MLNUIAnimationInterpolatorTypeBounce
            //       MLNUIAnimationInterpolatorTypeOvershoot
            //       MLNUIAnimationInterpolatorTypeLinear
            self.options = self.options | UIViewAnimationOptionCurveLinear;
            break;
    }
}

- (void)lua_repeatCount:(NSInteger)repeatCount
{
    self.lua_repeatCount = repeatCount;
    self.options = self.options & ~UIViewAnimationOptionRepeat;
}

- (void)lua_startWithView:(UIView *)view
{
    MLNUICheckTypeAndNilValue(view, @"View", [UIView class])
    self.targetView = view;
    [MLNUI_KIT_INSTANCE(self.mln_luaCore) pushAnimation:self];
}

#pragma mark - MLNUIAnimateProtocol
- (void)doTask
{
    UIView *view = self.targetView;
    // startFrame
    CGRect startFrame = view.frame;
    startFrame.origin.x = self.translationStartX != MLNUIValueTypeCurrent ? self.translationStartX : startFrame.origin.x;
    startFrame.origin.y = self.translationStartY != MLNUIValueTypeCurrent  ? self.translationStartY : startFrame.origin.y;
    startFrame.size.width = self.scaleStartWidth != MLNUIValueTypeCurrent ? self.scaleStartWidth : startFrame.size.width;
    startFrame.size.height = self.scaleStartHeight != MLNUIValueTypeCurrent ? self.scaleStartHeight : startFrame.size.height;
    // endFrame
    CGRect endFrame = view.frame;
    endFrame.origin.x = self.translationEndX != MLNUIValueTypeCurrent ? self.translationEndX : endFrame.origin.x;
    endFrame.origin.y = self.translationEndY != MLNUIValueTypeCurrent ? self.translationEndY : endFrame.origin.y;
    endFrame.size.width = self.scaleEndWidth != MLNUIValueTypeCurrent? self.scaleEndWidth : endFrame.size.width;
    endFrame.size.height = self.scaleEndHeight != MLNUIValueTypeCurrent ? self.scaleEndHeight : endFrame.size.height;
    // offset
    __unsafe_unretained MLNUILayoutNode *node = view.lua_node;
    node.offsetX = endFrame.origin.x - view.frame.origin.x + node.offsetX;
    node.offsetY = endFrame.origin.y - view.frame.origin.y + node.offsetY;
    node.offsetWidth = endFrame.size.width - view.frame.size.width + node.offsetWidth;
    node.offsetHeight = endFrame.size.height - view.frame.size.height + node.offsetHeight;
    view.frame = startFrame;
    // alpha
    CGFloat startAlpha = self.startAlpha != MLNUIValueTypeCurrent ? self.startAlpha : view.alpha;
    CGFloat endAlpha= self.endAlpha != MLNUIValueTypeCurrent ? self.endAlpha : view.alpha;
    view.alpha = startAlpha;
    // Color
    UIColor *startColor = self.startBgColor ? self.startBgColor : view.backgroundColor;
    UIColor *endColor = self.endBgColor ? self.endBgColor : view.backgroundColor;
    view.backgroundColor = startColor;

    // do
    [UIView animateWithDuration:self.duration delay:self.delay options:self.options animations:^{
        BOOL repeatIndefinitely = self.options & UIViewAnimationOptionRepeat;
        if (repeatIndefinitely || self.lua_repeatCount) {
            [UIView setAnimationRepeatCount:(self.lua_repeatCount == -1 || repeatIndefinitely ? MAX_INT:self.lua_repeatCount)];
        }
        view.frame = endFrame;
        view.alpha = endAlpha;
        view.backgroundColor = endColor;
        [view lua_needLayoutAndSpread];
        [view lua_changedLayout];
    } completion:^(BOOL finished) {
        BOOL repeatIndefinitely = self.options & UIViewAnimationOptionRepeat;
        if (CGRectEqualToRect(startFrame, endFrame) && startAlpha == endAlpha && CGColorEqualToColor(startColor.CGColor, endColor.CGColor) && !repeatIndefinitely) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.delay + self.duration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.completionCallback) {
                    [self.completionCallback addBOOLArgument:finished];
                    [self.completionCallback callIfCan];
                }
            });
        } else {
            if (self.completionCallback) {
                [self.completionCallback addBOOLArgument:finished];
                [self.completionCallback callIfCan];
            }
        }
    }];
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setTranslateXTo, "lua_setTranslateXTo:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setTranslateX, "lua_setTranslateX:to:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setTranslateYTo, "lua_setTranslateYTo:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setTranslateY, "lua_setTranslateY:to:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setScaleWidthTo, "lua_setScaleWidthTo:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setScaleWidth, "lua_setScaleWidth:to:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setScaleHeightTo, "lua_setScaleHeightTo:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setScaleHeight, "lua_setScaleHeight:to:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setAlphaTo, "lua_setAlphaTo:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setAlpha, "lua_setAlpha:to:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setBgColorTo, "lua_setBgColorTo:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setBgColor, "lua_setBgColor:to:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setDuration, "setDuration:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setDelay, "setDelay:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(repeatCount, "lua_repeatCount:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(needRepeat, "lua_needRepeat", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(needAutoreverseRepeat, "lua_needAutoreverseRepeat", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setInterpolator, "lua_setInterpolator:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(start, "lua_startWithView:", MLNUIFrameAnimation)
LUA_EXPORT_METHOD(setEndCallback, "setCompletionCallback:", MLNUIFrameAnimation)
LUA_EXPORT_END(MLNUIFrameAnimation, FrameAnimation, NO, NULL, NULL)

@end
