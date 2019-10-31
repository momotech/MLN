//
//  MLNCanvasAnimation.m
//  AFNetworking
//
//  Created by MoMo on 2019/5/13.
//

#import "MLNCanvasAnimation.h"
#import "MLNKitHeader.h"
#import "MLNEntityExporterMacro.h"
#import "MLNCanvasAnimationDelegate.h"
#import "MLNBeforeWaitingTask.h"
#import "UIView+MLNKit.h"
#import "UIView+MLNLayout.h"
#import "MLNLayoutNode.h"
#import "MLNAnimationSet.h"
#import "MLNAnimationHandler.h"
#import "NSDictionary+MLNSafety.h"
#import "MLNKeyframeAnimationBuilder.h"

#define kAnimationStart @"MLNCanvasAnimation.Start"
#define kAnimationEnd @"MLNCanvasAnimation.End"
#define kAnimationRepeat @"MLNCanvasAnimation.Repeat"

#define kCanvasAnimationCapcity 2

@interface MLNCanvasAnimation()<CAAnimationDelegate, MLNAnimationHandlerCallbackProtocol>
{
    CAAnimationGroup *_animationGroup;
    NSUInteger _repeatCounting;
}

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *animationCallbacks;
@property (nonatomic, strong) MLNBeforeWaitingTask *lazyTask;
@property (nonatomic, weak) MLNCanvasAnimationDelegate *animationDelegate;

@end

@implementation MLNCanvasAnimation

@synthesize pivotX = _pivotX;
@synthesize pivotY = _pivotY;

- (instancetype)init
{
    if (self = [super init]) {
        _pivotX = 0.5;
        _pivotXType = MLNAnimationValueTypeRelativeToSelf;
        _pivotY = 0.5;
        _pivotYType = MLNAnimationValueTypeRelativeToSelf;
    }
    return self;
}

#pragma mark - Action
- (void)startWithView:(UIView *)targetView
{
    switch (self.status) {
        case MLNCanvasAnimationStatusPause:
        case MLNCanvasAnimationStatusRunning:
        case MLNCanvasAnimationStatusStop:
        {
            targetView.layer.speed = 1.0;
            targetView.layer.timeOffset = .0f;
            targetView.layer.beginTime = .0f;
            [targetView.layer removeAnimationForKey:self.animationKey];
            CAAnimation *animation = nil;
            [self animationDidStop:animation finished:NO];
            _animationDelegate.ignoreAnimationCallback = YES;
        }
            break;
        default:
            break;
    }
    _targetView = targetView;
    _status = MLNCanvasAnimationStatusReadyToPlay;
    [MLN_KIT_INSTANCE(self.mln_luaCore) pushLazyTask:self.lazyTask];
}

- (void)cancel
{
    [_targetView.layer removeAnimationForKey:self.animationKey];
    [[MLNAnimationHandler sharedHandler] removeCallback:self];
    self.status = MLNCanvasAnimationStatusNone;
}

- (void)lua_pause
{
    switch (self.status) {
        case MLNCanvasAnimationStatusReadyToPlay:
        case MLNCanvasAnimationStatusPause:
            self.status = MLNCanvasAnimationStatusPause;
            break;
        case MLNCanvasAnimationStatusRunning:
        {
            self.status = MLNCanvasAnimationStatusPause;
            CFTimeInterval pausedTime = [self.targetView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
            self.targetView.layer.speed = 0.f;
            self.targetView.layer.timeOffset = pausedTime;
            break;
        }
        default:
            break;
    }
}

- (void)lua_stop
{
    switch (self.status) {
        case MLNCanvasAnimationStatusStop:
            return;
        default:
            self.status = MLNCanvasAnimationStatusStop;
            [MLN_KIT_INSTANCE(self.mln_luaCore) popLazyTask:self.lazyTask];
            [self.targetView.layer removeAnimationForKey:self.animationKey];
            [[MLNAnimationHandler sharedHandler] removeCallback:self];
            return;
    }
}

- (void)lua_resumeAnimations
{
    switch (self.status) {
        case MLNCanvasAnimationStatusPause:
        {
            self.status = MLNCanvasAnimationStatusReadyToResume;
            [MLN_KIT_INSTANCE(self.mln_luaCore) pushLazyTask:self.lazyTask];
        }
        default:
            break;
    }
}

- (void)setStartCallback:(MLNBlock *)callback
{
    
}

- (void)setEndCallback:(MLNBlock *)callback
{
    
}

- (void)setRepeatCallback:(MLNBlock *)callback
{
    
}

- (instancetype)lua_clone
{
    return [self copy];
}

- (void)doAnimation
{
    switch (_status) {
        case MLNCanvasAnimationStatusReadyToPlay:{
            self.animationGroup.animations = [self animationValues];
            for (CABasicAnimation *anim in self.animationGroup.animations) {
                anim.removedOnCompletion =  _autoBack;
                if (!_autoBack) {
                    anim.fillMode = kCAFillModeForwards;
                }
            }
            self.animationGroup.removedOnCompletion = _autoBack;
            if (!_autoBack) {
                self.animationGroup.fillMode = kCAFillModeForwards;
            }
            self.status = MLNCanvasAnimationStatusRunning;
            [self animationRealStart];
            if (self.repeatCount) {
                [[MLNAnimationHandler sharedHandler] addCallback:self];
            }
            [self setupAnchorPointWithTargetView:_targetView];
            [_targetView.layer addAnimation:self.animationGroup forKey:self.animationKey];
        }
            break;
        case MLNCanvasAnimationStatusReadyToResume:{
            CFTimeInterval pauseTime = [self.targetView.layer timeOffset];
            self.targetView.layer.speed = 1.0;
            self.targetView.layer.timeOffset = 0.0;
            self.targetView.layer.beginTime = 0.0;
            CFTimeInterval timeSincePause = [self.targetView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
            self.targetView.layer.beginTime = timeSincePause;
            self.status = MLNCanvasAnimationStatusRunning;
        }
            break;
        default:
            break;
    }
    
}

- (void)tick
{
    if ([self remainingDelay] > FLT_EPSILON) {
        return;
    }
    CGFloat percent = (CACurrentMediaTime() - self.startTime - self.delay) / (self.duration * (_repeatType == MLNAnimationRepeatTypeReverse?2:1));
   
    NSInteger repeatCount = (NSUInteger)percent;
    percent = percent - repeatCount;
    if (repeatCount != _repeatCounting && repeatCount < self.repeatCount) {
        _repeatCounting = repeatCount;
        [self animationRepeatCallback:_repeatCounting];
    }
    if (self.repeatCount > 0 && self.repeatCount <= repeatCount) {
        [[MLNAnimationHandler sharedHandler] removeCallback:self];
        self.status = MLNCanvasAnimationStatusNone;
    }
}

- (void)animationRealStart
{
    self.startTime = CACurrentMediaTime();
    _repeatCounting = 0;
    [self animationStartCallback];
}

- (NSTimeInterval)remainingDelay
{
    return MAX(0.0, self.delay - (CACurrentMediaTime() - self.startTime));
}

- (void)animationRepeatCallback:(NSUInteger)repeatCount
{
    // callback
    MLNBlock *callback = [self.animationCallbacks objectForKey:kAnimationRepeat];
    if (callback) {
        [callback addUIntegerArgument:repeatCount];
        [callback callIfCan];
    }
}

- (void)animationStartCallback
{
    // callback
    MLNBlock *callback = [self.animationCallbacks objectForKey:kAnimationStart];
    if (callback) {
        [callback callIfCan];
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    // callback
//    MLNBlock *callback = [self.animationCallbacks objectForKey:kAnimationStart];
//    if (callback) {
//        [callback callIfCan];
//    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // callback
    MLNBlock *callback = [self.animationCallbacks objectForKey:kAnimationEnd];
    if (callback) {
        [callback addBOOLArgument:flag];
        [callback callIfCan];
    }
    [[MLNAnimationHandler sharedHandler] removeCallback:self];
}

#pragma mark - MLNAnimationHandlerCallbackProtocol
- (void)doAnimationFrame:(NSTimeInterval)frameTime {
    [self tick];
}


#pragma setup anchor point
- (void)setupAnchorPointWithTargetView:(UIView *)targetView
{
    CGFloat anchorX = 0.5;
    CGFloat anchorY = 0.5;
    switch (_pivotXType) {
        case MLNAnimationValueTypeAbsolute:
            anchorX = _targetView.frame.size.width * _pivotX;
            break;
        case MLNAnimationValueTypeRelativeToSelf:
            anchorX = _pivotX;
            break;
        default:
            break;
    }
    switch (_pivotYType) {
        case MLNAnimationValueTypeAbsolute:
            anchorY = _pivotY / _targetView.frame.size.height;
            break;
        case MLNAnimationValueTypeRelativeToSelf:
            anchorY = _pivotY;
            break;
        default:
            break;
    }
    [targetView mln_setAnchorPoint:CGPointMake(anchorX, anchorY)];
}

#pragma mark - copy
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    MLNCanvasAnimation *copy = [[self class] allocWithZone:zone];
    copy.pivotX = _pivotX;
    copy.pivotXType = _pivotXType;
    copy.pivotY = _pivotY;
    copy.pivotYType = _pivotYType;
    copy.autoBack = _autoBack;
    copy.duration = _duration;
    copy.delay = _delay;
    copy.interpolator = _interpolator;
    copy.repeatType = _repeatType;
    copy.startTime = _startTime;
    copy.repeatCount = _repeatCount;
    copy.executeCount = _executeCount;
    return copy;
}


#pragma mark - getter & setter

- (NSString *)animationKey
{
    return kDefaultGroupAnimation;
}

- (CABasicAnimation *)animationForKey:(NSString *)key
{
    CABasicAnimation *animation = [self.animations objectForKey:key];
    if (!animation) {
        animation = [CABasicAnimation animationWithKeyPath:key];
        [self.animations mln_setObject:animation forKey:key];
    }
    return animation;
}

- (void)setInterpolator:(MLNAnimationInterpolatorType)interpolator
{
    if (_interpolator != interpolator) {
        _interpolator = interpolator;
        self.animationGroup.timingFunction = [MLNAnimationConst buildTimingFunction:interpolator];
        [self resetAnimations];
    }
}

- (CABasicAnimation *)baseAnimationWithKeyPath:(NSString *)key interpolatorType:(MLNAnimationInterpolatorType)interpolatorType
{
    switch (interpolatorType) {
        case MLNAnimationInterpolatorTypeBounce:
        case MLNAnimationInterpolatorTypeOvershoot: {
            return (CABasicAnimation *)[MLNKeyframeAnimationBuilder buildAnimationWithKeyPath:key interpolatorType:MLNAnimationInterpolatorTypeBounce];
        }
        case MLNAnimationInterpolatorTypeLinear:
        case MLNAnimationInterpolatorTypeAccelerate:
        case MLNAnimationInterpolatorTypeDecelerate:
        case MLNAnimationInterpolatorTypeAccelerateDecelerate:
        default:
            return [CABasicAnimation animationWithKeyPath:key];
            break;
    }
}

- (void)resetAnimations
{
    NSMutableDictionary *newAnimations = [[NSMutableDictionary alloc] initWithCapacity:kCanvasAnimationCapcity];
    [self.animations enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CABasicAnimation * _Nonnull animation, BOOL * _Nonnull stop) {
        CABasicAnimation *newAnimation = [self baseAnimationWithKeyPath:key interpolatorType:self.interpolator];
        newAnimation.fromValue = animation.fromValue;
        newAnimation.toValue = animation.toValue;
        [newAnimations mln_setObject:newAnimation forKey:key];
    }];
    _animations = newAnimations;
}


- (NSArray<CABasicAnimation *> *)animationValues
{
    if (_delay) {
        for (CABasicAnimation *animation in self.animations.allValues) {
            animation.beginTime = _delay;
        }
    }
    return self.animations.allValues;
}

- (NSMutableDictionary<NSString *,CABasicAnimation *> *)animations
{
    if (!_animations) {
        _animations = [NSMutableDictionary dictionaryWithCapacity:kCanvasAnimationCapcity];
    }
    return _animations;
}

- (CAAnimationGroup *)animationGroup
{
    if (!_animationGroup) {
        _animationGroup = [CAAnimationGroup animation];
        MLNCanvasAnimationDelegate *delegate = [[MLNCanvasAnimationDelegate alloc] initWithAnimation:self];
        _animationGroup.delegate = delegate;
        _animationDelegate = delegate;
    }
    return _animationGroup;
}

- (NSMutableDictionary<NSString *,MLNBlock *> *)animationCallbacks
{
    if (!_animationCallbacks) {
        _animationCallbacks = [NSMutableDictionary dictionaryWithCapacity:kCanvasAnimationCapcity];
    }
    return _animationCallbacks;
}

- (void)setPivotXType:(MLNAnimationValueType)pivotXType
{
    _pivotXType = pivotXType;
}

- (void)setPivotX:(CGFloat)pivotX
{
    _pivotX = pivotX;
}

- (void)setPivotYType:(MLNAnimationValueType)pivotYType
{
    _pivotYType = pivotYType;
}

- (void)setPivotY:(CGFloat)pivotY
{
    _pivotY = pivotY;
}

- (CGFloat)pivotX
{
    if (!_targetView) {
        return _pivotX;
    }
    switch (_pivotXType) {
        case MLNAnimationValueTypeAbsolute:
            return (_pivotX / _targetView.lua_node.width);
            break;
        case MLNAnimationValueTypeRelativeToSelf:
            return _pivotX;
            break;
        default:
            return _pivotX;
            break;
    }
}

- (CGFloat)pivotY
{
    if (!_targetView) {
        return _pivotY;
    }
    switch (_pivotXType) {
        case MLNAnimationValueTypeAbsolute:
            return (_pivotY / _targetView.lua_node.height);
            break;
        case MLNAnimationValueTypeRelativeToSelf:
            return _pivotY;
            break;
        default:
            return _pivotY;
            break;
    }
}

- (CGFloat)lua_pivotX
{
    return _pivotX;
}

- (CGFloat)lua_pivotY
{
    return _pivotY;
}
- (void)setDuration:(CGFloat)duration
{
    _duration = duration;
    self.animationGroup.duration = duration;
}

- (void)setDelay:(CGFloat)delay
{
    _delay = delay;
//    self.animationGroup.beginTime = delay;
}

- (void)setRepeatCount:(NSInteger)repeatCount
{
    _repeatCount = repeatCount;
    self.animationGroup.repeatCount = repeatCount;
}

- (void)setRepeatType:(MLNAnimationRepeatType)repeatType
{
    _repeatType = repeatType;
    self.animationGroup.autoreverses = repeatType == MLNAnimationRepeatTypeReverse;
}

- (MLNBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            [sself doAnimation];
        }];
    }
    return _lazyTask;
}

#pragma mark - Export Method
- (void)lua_startWithView:(UIView *)targetView
{
    MLNCheckTypeAndNilValue(targetView, @"View", [UIView class])
    [self startWithView:targetView];
}

- (void)lua_setStartCallback:(MLNBlock *)callback
{
    if (!callback) {
        MLNKitLuaError(@"callback must not be nil!");
        return;
    }
    [self.animationCallbacks setObject:callback forKey:kAnimationStart];
}

- (void)lua_setEndCallback:(MLNBlock *)callback
{
    if (!callback) {
        MLNKitLuaError(@"callback must not be nil!");
        return;
    }
    [self.animationCallbacks setObject:callback forKey:kAnimationEnd];
}

- (void)lua_setRepeatCallback:(MLNBlock *)callback
{
    if (!callback) {
        MLNKitLuaError(@"callback must not be nil!");
        return;
    }
    [self.animationCallbacks setObject:callback forKey:kAnimationRepeat];
}

#pragma mark - Export Method
- (void)lua_setRepeat:(MLNAnimationRepeatType)type count:(float)count
{
    if (count == -1) {
        count = MAX_INT;
    }
    self.repeatType = type;
    self.repeatCount = count;
    switch (type) {
        case MLNAnimationRepeatTypeBeginToEnd:
            self.animationGroup.repeatCount = count;
            self.animationGroup.autoreverses = NO;
            break;
        case MLNAnimationRepeatTypeReverse:
            self.animationGroup.repeatCount = count;
            self.animationGroup.autoreverses = YES;
            break;
        default:
            self.animationGroup.repeatCount = 0;
            self.animationGroup.autoreverses = NO;
            break;
    }
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNCanvasAnimation)
LUA_EXPORT_PROPERTY(setPivotXType, "setPivotXType:", "pivotXType", MLNCanvasAnimation)
LUA_EXPORT_PROPERTY(setPivotX, "setPivotX:", "lua_pivotX", MLNCanvasAnimation)
LUA_EXPORT_PROPERTY(setPivotYType, "setPivotYType:", "pivotYType", MLNCanvasAnimation)
LUA_EXPORT_PROPERTY(setPivotY, "setPivotY:", "lua_pivotY", MLNCanvasAnimation)
LUA_EXPORT_PROPERTY(setDuration, "setDuration:", "duration", MLNCanvasAnimation)
LUA_EXPORT_PROPERTY(setDelay, "setDelay:", "delay", MLNCanvasAnimation)
LUA_EXPORT_PROPERTY(setInterpolator, "setInterpolator:", "interpolator", MLNCanvasAnimation)
LUA_EXPORT_METHOD(setRepeat, "lua_setRepeat:count:",  MLNCanvasAnimation)
LUA_EXPORT_METHOD(startWithView, "lua_startWithView:", MLNCanvasAnimation)
LUA_EXPORT_METHOD(cancel, "cancel", MLNCanvasAnimation)
LUA_EXPORT_METHOD(pause, "lua_pause", MLNCanvasAnimation)
LUA_EXPORT_METHOD(resume, "lua_resumeAnimations", MLNCanvasAnimation)
LUA_EXPORT_METHOD(stop, "lua_stop", MLNCanvasAnimation)
LUA_EXPORT_METHOD(setStartCallback, "lua_setStartCallback:", MLNCanvasAnimation)
LUA_EXPORT_METHOD(setEndCallback, "lua_setEndCallback:", MLNCanvasAnimation)
LUA_EXPORT_METHOD(setRepeatCallback, "lua_setRepeatCallback:", MLNCanvasAnimation)
LUA_EXPORT_METHOD(clone, "lua_clone", MLNCanvasAnimation)
LUA_EXPORT_END(MLNCanvasAnimation, CanvasAnimation, NO, NULL, NULL)

@end
