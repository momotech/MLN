//
//  MLNFrameAnimation.m
//
//
//  Created by MoMo on 2018/11/14.
//

#import "MLNFrameAnimation.h"
#import "MLNKitHeader.h"
#import "MLNEntityExporterMacro.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutNode.h"
#import "MLNAnimationConst.h"
#import "MLNBlock.h"

@interface MLNFrameAnimation ()

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, assign) NSInteger lua_repeatCount;
@end

@implementation MLNFrameAnimation

- (instancetype)init
{
    if (self = [super init]) {
        _translationStartX = MLNValueTypeCurrent;
        _translationStartY = MLNValueTypeCurrent;
        _translationEndX = MLNValueTypeCurrent;
        _translationEndY = MLNValueTypeCurrent;
        _scaleStartWidth = MLNValueTypeCurrent;
        _scaleStartHeight = MLNValueTypeCurrent;
        _scaleEndWidth = MLNValueTypeCurrent;
        _scaleEndHeight = MLNValueTypeCurrent;
        _startAlpha = MLNValueTypeCurrent;
        _endAlpha = MLNValueTypeCurrent;
        _options = UIViewAnimationOptionLayoutSubviews;
    }
    return self;
}

- (void)lua_setTranslateXTo:(CGFloat)toValue
{
    [self lua_setTranslateX:MLNValueTypeCurrent to:toValue];
}

- (void)lua_setTranslateX:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.translationStartX = fromeValue;
    self.translationEndX = toValue;
}

- (void)lua_setTranslateYTo:(CGFloat)toValue
{
    [self lua_setTranslateY:MLNValueTypeCurrent to:toValue];
}

- (void)lua_setTranslateY:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.translationStartY = fromeValue;
    self.translationEndY = toValue;
}

- (void)lua_setScaleWidthTo:(CGFloat)toValue
{
    [self lua_setScaleWidth:MLNValueTypeCurrent to:toValue];
}

- (void)lua_setScaleWidth:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.scaleStartWidth = fromeValue;
    self.scaleEndWidth = toValue;
}

- (void)lua_setScaleHeightTo:(CGFloat)toValue
{
    [self lua_setScaleHeight:MLNValueTypeCurrent to:toValue];
}

- (void)lua_setScaleHeight:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.scaleStartHeight = fromeValue;
    self.scaleEndHeight = toValue;
}

- (void)lua_setAlphaTo:(CGFloat)toValue
{
    [self lua_setAlpha:MLNValueTypeCurrent to:toValue];
}

- (void)lua_setAlpha:(CGFloat)fromeValue to:(CGFloat)toValue
{
    self.startAlpha = fromeValue;
    self.endAlpha = toValue;
}

- (void)lua_setBgColorTo:(UIColor *)toValue
{
    MLNCheckTypeAndNilValue(toValue, @"Color", [UIColor class])
    self.endBgColor = toValue;
}

- (void)lua_setBgColor:(UIColor *)fromeValue to:(UIColor *)toValue
{
    MLNCheckTypeAndNilValue(fromeValue, @"Color", [UIColor class])
    MLNCheckTypeAndNilValue(toValue, @"Color", [UIColor class])
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

- (void)lua_setInterpolator:(MLNAnimationInterpolatorType)type
{
    switch (type) {
        case MLNAnimationInterpolatorTypeAccelerateDecelerate:
            self.options = self.options | UIViewAnimationOptionCurveEaseInOut;
            break;
        case MLNAnimationInterpolatorTypeAccelerate:
            self.options = self.options | UIViewAnimationOptionCurveEaseIn;
            break;
        case MLNAnimationInterpolatorTypeDecelerate:
            self.options = self.options | UIViewAnimationOptionCurveEaseOut;
            break;
        default:
            //@note: MLNAnimationInterpolatorTypeBounce
            //       MLNAnimationInterpolatorTypeOvershoot
            //       MLNAnimationInterpolatorTypeLinear
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
    MLNCheckTypeAndNilValue(view, @"View", [UIView class])
    self.targetView = view;
    [MLN_KIT_INSTANCE(self.mln_luaCore) pushAnimation:self];
}

#pragma mark - MLNAnimateProtocol
- (void)doTask
{
    UIView *view = self.targetView;
    // startFrame
    CGRect startFrame = view.frame;
    startFrame.origin.x = self.translationStartX != MLNValueTypeCurrent ? self.translationStartX : startFrame.origin.x;
    startFrame.origin.y = self.translationStartY != MLNValueTypeCurrent  ? self.translationStartY : startFrame.origin.y;
    startFrame.size.width = self.scaleStartWidth != MLNValueTypeCurrent ? self.scaleStartWidth : startFrame.size.width;
    startFrame.size.height = self.scaleStartHeight != MLNValueTypeCurrent ? self.scaleStartHeight : startFrame.size.height;
    // endFrame
    CGRect endFrame = view.frame;
    endFrame.origin.x = self.translationEndX != MLNValueTypeCurrent ? self.translationEndX : endFrame.origin.x;
    endFrame.origin.y = self.translationEndY != MLNValueTypeCurrent ? self.translationEndY : endFrame.origin.y;
    endFrame.size.width = self.scaleEndWidth != MLNValueTypeCurrent? self.scaleEndWidth : endFrame.size.width;
    endFrame.size.height = self.scaleEndHeight != MLNValueTypeCurrent ? self.scaleEndHeight : endFrame.size.height;
    // offset
    __unsafe_unretained MLNLayoutNode *node = view.lua_node;
    node.offsetX = endFrame.origin.x - view.frame.origin.x + node.offsetX;
    node.offsetY = endFrame.origin.y - view.frame.origin.y + node.offsetY;
    node.offsetWidth = endFrame.size.width - view.frame.size.width + node.offsetWidth;
    node.offsetHeight = endFrame.size.height - view.frame.size.height + node.offsetHeight;
    view.frame = startFrame;
    // alpha
    CGFloat startAlpha = self.startAlpha != MLNValueTypeCurrent ? self.startAlpha : view.alpha;
    CGFloat endAlpha= self.endAlpha != MLNValueTypeCurrent ? self.endAlpha : view.alpha;
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
LUA_EXPORT_BEGIN(MLNFrameAnimation)
LUA_EXPORT_METHOD(setTranslateXTo, "lua_setTranslateXTo:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setTranslateX, "lua_setTranslateX:to:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setTranslateYTo, "lua_setTranslateYTo:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setTranslateY, "lua_setTranslateY:to:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setScaleWidthTo, "lua_setScaleWidthTo:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setScaleWidth, "lua_setScaleWidth:to:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setScaleHeightTo, "lua_setScaleHeightTo:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setScaleHeight, "lua_setScaleHeight:to:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setAlphaTo, "lua_setAlphaTo:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setAlpha, "lua_setAlpha:to:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setBgColorTo, "lua_setBgColorTo:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setBgColor, "lua_setBgColor:to:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setDuration, "setDuration:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setDelay, "setDelay:", MLNFrameAnimation)
LUA_EXPORT_METHOD(repeatCount, "lua_repeatCount:", MLNFrameAnimation)
LUA_EXPORT_METHOD(needRepeat, "lua_needRepeat", MLNFrameAnimation)
LUA_EXPORT_METHOD(needAutoreverseRepeat, "lua_needAutoreverseRepeat", MLNFrameAnimation)
LUA_EXPORT_METHOD(setInterpolator, "lua_setInterpolator:", MLNFrameAnimation)
LUA_EXPORT_METHOD(start, "lua_startWithView:", MLNFrameAnimation)
LUA_EXPORT_METHOD(setEndCallback, "setCompletionCallback:", MLNFrameAnimation)
LUA_EXPORT_END(MLNFrameAnimation, FrameAnimation, NO, NULL, NULL)

@end
