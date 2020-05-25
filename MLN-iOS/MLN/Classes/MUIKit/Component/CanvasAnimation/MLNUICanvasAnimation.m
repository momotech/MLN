//
//  MLNUICanvasAnimation.m
//  MLNUI
//
//  Created by MoMo on 2019/5/13.
//

#import "MLNUICanvasAnimation.h"
#import "MLNUIKitHeader.h"
#import "MLNUIEntityExporterMacro.h"
#import "MLNUICanvasAnimationDelegate.h"
#import "MLNUIBeforeWaitingTask.h"
#import "UIView+MLNUIKit.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutNode.h"
#import "MLNUIAnimationSet.h"
#import "MLNUIAnimationHandler.h"
#import "NSDictionary+MLNUISafety.h"
#import "MLNUIKeyframeAnimationBuilder.h"

#define kAnimationStart @"MLNUICanvasAnimation.Start"
#define kAnimationEnd @"MLNUICanvasAnimation.End"
#define kAnimationRepeat @"MLNUICanvasAnimation.Repeat"

#define kCanvasAnimationCapcity 2

@interface MLNUICanvasAnimation()<CAAnimationDelegate, MLNUIAnimationHandlerCallbackProtocol>
{
    CAAnimationGroup *_animationGroup;
    NSUInteger _repeatCounting;
}

@property (nonatomic, weak, readwrite) UIView *targetView;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNUIBlock *> *animationCallbacks;
@property (nonatomic, strong) MLNUIBeforeWaitingTask *lazyTask;
@property (nonatomic, weak) MLNUICanvasAnimationDelegate *animationDelegate;

@end

@implementation MLNUICanvasAnimation

@synthesize pivotX = _pivotX;
@synthesize pivotY = _pivotY;

- (instancetype)init
{
    if (self = [super init]) {
        _pivotX = 0.5;
        _pivotXType = MLNUIAnimationValueTypeRelativeToSelf;
        _pivotY = 0.5;
        _pivotYType = MLNUIAnimationValueTypeRelativeToSelf;
    }
    return self;
}

#pragma mark - Action
- (void)startWithView:(UIView *)targetView
{
    switch (self.status) {
        case MLNUICanvasAnimationStatusPause:
        case MLNUICanvasAnimationStatusRunning:
        case MLNUICanvasAnimationStatusStop:
        {
            targetView.layer.speed = 1.0;
            targetView.layer.timeOffset = .0f;
            targetView.layer.beginTime = .0f;
            [targetView.layer removeAnimationForKey:self.animationKey];
//            CAAnimation *animation = nil;
//            [self animationDidStop:animation finished:NO];
//            _animationDelegate.ignoreAnimationCallback = YES;
        }
            break;
        default:
            break;
    }
    _targetView = targetView;
    _status = MLNUICanvasAnimationStatusReadyToPlay;
    [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) pushLazyTask:self.lazyTask];
}

- (void)cancel
{
    [_targetView.layer removeAnimationForKey:self.animationKey];
    [[MLNUIAnimationHandler sharedHandler] removeCallback:self];
    self.status = MLNUICanvasAnimationStatusNone;
}

- (void)luaui_pause
{
    switch (self.status) {
        case MLNUICanvasAnimationStatusReadyToPlay:
        case MLNUICanvasAnimationStatusPause:
            self.status = MLNUICanvasAnimationStatusPause;
            break;
        case MLNUICanvasAnimationStatusRunning:
        {
            self.status = MLNUICanvasAnimationStatusPause;
            CFTimeInterval pausedTime = [self.targetView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
            self.targetView.layer.speed = 0.f;
            self.targetView.layer.timeOffset = pausedTime;
            break;
        }
        default:
            break;
    }
}

- (void)luaui_stop
{
    switch (self.status) {
        case MLNUICanvasAnimationStatusStop:
            return;
        default:
            self.status = MLNUICanvasAnimationStatusStop;
            [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) popLazyTask:self.lazyTask];
            [self.targetView.layer removeAnimationForKey:self.animationKey];
            [[MLNUIAnimationHandler sharedHandler] removeCallback:self];
            return;
    }
}

- (void)luaui_resumeAnimations
{
    switch (self.status) {
        case MLNUICanvasAnimationStatusPause:
        {
            self.status = MLNUICanvasAnimationStatusReadyToResume;
            [MLNUI_KIT_INSTANCE(self.mlnui_luaCore) pushLazyTask:self.lazyTask];
        }
        default:
            break;
    }
}

- (void)setStartCallback:(MLNUIBlock *)callback
{
    
}

- (void)setEndCallback:(MLNUIBlock *)callback
{
    
}

- (void)setRepeatCallback:(MLNUIBlock *)callback
{
    
}

- (instancetype)luaui_clone
{
    return [self copy];
}

- (void)doAnimation
{
    switch (_status) {
        case MLNUICanvasAnimationStatusReadyToPlay:{
            self.animationGroup.animations = [self animationValues];
            self.animationGroup.beginTime = CACurrentMediaTime() + _delay;
            for (CABasicAnimation *anim in self.animationGroup.animations) {
                anim.removedOnCompletion =  _autoBack;
                anim.fillMode = _autoBack ? kCAFillModeBackwards : kCAFillModeBoth;
            }
            self.animationGroup.removedOnCompletion = _autoBack;
            self.animationGroup.fillMode = _autoBack ? kCAFillModeBackwards : kCAFillModeBoth;
            
            self.status = MLNUICanvasAnimationStatusRunning;
            [self animationRealStart];
            if (self.repeatCount) {
                [[MLNUIAnimationHandler sharedHandler] addCallback:self];
            }
            [self setupAnchorPointWithTargetView:_targetView];
            [_targetView.layer addAnimation:self.animationGroup forKey:self.animationKey];
        }
            break;
        case MLNUICanvasAnimationStatusReadyToResume:{
            CFTimeInterval pauseTime = [self.targetView.layer timeOffset];
            self.targetView.layer.speed = 1.0;
            self.targetView.layer.timeOffset = 0.0;
            self.targetView.layer.beginTime = 0.0;
            CFTimeInterval timeSincePause = [self.targetView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
            self.targetView.layer.beginTime = timeSincePause;
            self.status = MLNUICanvasAnimationStatusRunning;
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
    CGFloat percent = (CACurrentMediaTime() - self.startTime - self.delay) / (self.duration * 1);
   
    NSInteger repeatCount = (NSUInteger)percent;
    percent = percent - repeatCount;
    if (repeatCount != _repeatCounting && repeatCount < self.repeatCount) {
        _repeatCounting = repeatCount;
        [self animationRepeatCallback:_repeatCounting];
    }
    if (self.repeatCount > 0 && self.repeatCount <= repeatCount) {
        [[MLNUIAnimationHandler sharedHandler] removeCallback:self];
        self.status = MLNUICanvasAnimationStatusNone;
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
    MLNUIBlock *callback = [self.animationCallbacks objectForKey:kAnimationRepeat];
    if (callback) {
        [callback addUIntegerArgument:repeatCount];
        [callback callIfCan];
    }
}

- (void)animationStartCallback
{
    // callback
    MLNUIBlock *callback = [self.animationCallbacks objectForKey:kAnimationStart];
    if (callback) {
        [callback callIfCan];
    }
}

- (void)animationStopCallback:(BOOL)finishedFlag
{
    MLNUIBlock *callback = [self.animationCallbacks objectForKey:kAnimationEnd];
    if (callback) {
        [callback addBOOLArgument:finishedFlag];
        [callback callIfCan];
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    // callback
//    MLNUIBlock *callback = [self.animationCallbacks objectForKey:kAnimationStart];
//    if (callback) {
//        [callback callIfCan];
//    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // callback
    [self animationStopCallback:flag];
    [[MLNUIAnimationHandler sharedHandler] removeCallback:self];
}

#pragma mark - MLNUIAnimationHandlerCallbackProtocol
- (void)doAnimationFrame:(NSTimeInterval)frameTime {
    [self tick];
}


#pragma setup anchor point
- (void)setupAnchorPointWithTargetView:(UIView *)targetView
{
    CGFloat anchorX = 0.5;
    CGFloat anchorY = 0.5;
    switch (_pivotXType) {
        case MLNUIAnimationValueTypeAbsolute:{
            anchorX = _pivotX / _targetView.frame.size.width ;
        }
            break;
        case MLNUIAnimationValueTypeRelativeToSelf:
            anchorX = _pivotX;
            break;
        default:
            break;
    }
    switch (_pivotYType) {
        case MLNUIAnimationValueTypeAbsolute:
            anchorY = _pivotY / _targetView.frame.size.height;
            break;
        case MLNUIAnimationValueTypeRelativeToSelf:
            anchorY = _pivotY;
            break;
        default:
            break;
    }
    [self setAnchorPoint:CGPointMake(anchorX, anchorY) targetView:targetView];
}

- (void)setAnchorPoint:(CGPoint)point targetView:(UIView *)targetView
{
    CGPoint newPoint = CGPointMake(targetView.bounds.size.width * point.x, targetView.bounds.size.height * point.y);
    CGPoint oldPoint = CGPointMake(targetView.bounds.size.width * targetView.layer.anchorPoint.x, targetView.bounds.size.height * targetView.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, targetView.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, targetView.transform);
    
    CGPoint position = targetView.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    targetView.layer.position = position;
    targetView.layer.anchorPoint = point;
}

#pragma mark - copy
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    MLNUICanvasAnimation *copy = [[self class] allocWithZone:zone];
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
    return kMUIDefaultGroupAnimation;
}

- (CABasicAnimation *)animationForKey:(NSString *)key
{
    CABasicAnimation *animation = [self.animations objectForKey:key];
    if (!animation) {
        animation = [CABasicAnimation animationWithKeyPath:key];
        [self.animations mlnui_setObject:animation forKey:key];
    }
    return animation;
}

- (void)setInterpolator:(MLNUIAnimationInterpolatorType)interpolator
{
    if (_interpolator != interpolator) {
        _interpolator = interpolator;
        self.animationGroup.timingFunction = [MLNUIAnimationConst buildTimingFunction:interpolator];
        [self resetAnimations];
    }
}

- (CABasicAnimation *)baseAnimationWithKeyPath:(NSString *)key interpolatorType:(MLNUIAnimationInterpolatorType)interpolatorType
{
    switch (interpolatorType) {
        case MLNUIAnimationInterpolatorTypeBounce:
        case MLNUIAnimationInterpolatorTypeOvershoot: {
            return (CABasicAnimation *)[MLNUIKeyframeAnimationBuilder buildAnimationWithKeyPath:key interpolatorType:MLNUIAnimationInterpolatorTypeBounce];
        }
        case MLNUIAnimationInterpolatorTypeLinear:
        case MLNUIAnimationInterpolatorTypeAccelerate:
        case MLNUIAnimationInterpolatorTypeDecelerate:
        case MLNUIAnimationInterpolatorTypeAccelerateDecelerate:
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
        [newAnimations mlnui_setObject:newAnimation forKey:key];
    }];
    _animations = newAnimations;
}


- (NSArray<CABasicAnimation *> *)animationValues
{
    if (_delay) {
        for (CABasicAnimation *animation in self.animations.allValues) {
            animation.duration = _duration;
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
        MLNUICanvasAnimationDelegate *delegate = [[MLNUICanvasAnimationDelegate alloc] initWithAnimation:self];
        _animationGroup.delegate = delegate;
        _animationDelegate = delegate;
    }
    return _animationGroup;
}

- (NSMutableDictionary<NSString *,MLNUIBlock *> *)animationCallbacks
{
    if (!_animationCallbacks) {
        _animationCallbacks = [NSMutableDictionary dictionaryWithCapacity:kCanvasAnimationCapcity];
    }
    return _animationCallbacks;
}

- (void)setPivotXType:(MLNUIAnimationValueType)pivotXType
{
    _pivotXType = pivotXType;
}

- (void)setPivotX:(CGFloat)pivotX
{
    _pivotX = pivotX;
}

- (void)setPivotYType:(MLNUIAnimationValueType)pivotYType
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
        case MLNUIAnimationValueTypeAbsolute:
            return (_pivotX / _targetView.luaui_node.width);
            break;
        case MLNUIAnimationValueTypeRelativeToSelf:
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
        case MLNUIAnimationValueTypeAbsolute:
            return (_pivotY / _targetView.luaui_node.height);
            break;
        case MLNUIAnimationValueTypeRelativeToSelf:
            return _pivotY;
            break;
        default:
            return _pivotY;
            break;
    }
}

- (CGFloat)luaui_pivotX
{
    return _pivotX;
}

- (CGFloat)luaui_pivotY
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
}

- (void)setRepeatCount:(NSInteger)repeatCount
{
    _repeatCount = repeatCount;
    self.animationGroup.repeatCount = repeatCount;
}

- (void)setRepeatType:(MLNUIAnimationRepeatType)repeatType
{
    _repeatType = repeatType;
    self.animationGroup.autoreverses = repeatType == MLNUIAnimationRepeatTypeReverse;
}

- (MLNUIBeforeWaitingTask *)lazyTask
{
    if (!_lazyTask) {
        __weak typeof(self) wself = self;
        _lazyTask = [MLNUIBeforeWaitingTask taskWithCallback:^{
            __strong typeof(wself) sself = wself;
            [sself doAnimation];
        }];
    }
    return _lazyTask;
}

#pragma mark - Export Method
- (void)luaui_startWithView:(UIView *)targetView
{
    MLNUICheckTypeAndNilValue(targetView, @"View", [UIView class])
    [self startWithView:targetView];
}

- (void)luaui_setStartCallback:(MLNUIBlock *)callback
{
    if (!callback) {
        MLNUIKitLuaError(@"callback must not be nil!");
        return;
    }
    [self.animationCallbacks setObject:callback forKey:kAnimationStart];
}

- (void)luaui_setEndCallback:(MLNUIBlock *)callback
{
    if (!callback) {
        MLNUIKitLuaError(@"callback must not be nil!");
        return;
    }
    [self.animationCallbacks setObject:callback forKey:kAnimationEnd];
}

- (void)luaui_setRepeatCallback:(MLNUIBlock *)callback
{
    if (!callback) {
        MLNUIKitLuaError(@"callback must not be nil!");
        return;
    }
    [self.animationCallbacks setObject:callback forKey:kAnimationRepeat];
}

#pragma mark - Export Method
- (void)luaui_setRepeat:(MLNUIAnimationRepeatType)type count:(float)count
{
    if (count < 0) {
        count = MAX_INT;
    }else {
        count ++;
    }
    
    self.repeatType = type;
    self.repeatCount = count;
    switch (type) {
        case MLNUIAnimationRepeatTypeBeginToEnd:
            self.animationGroup.repeatCount = count;
            self.animationGroup.autoreverses = NO;
            break;
        case MLNUIAnimationRepeatTypeReverse:
            self.animationGroup.repeatCount = count * 1.0 / 2;
            self.animationGroup.autoreverses = YES;
            break;
        default:
            self.animationGroup.repeatCount = 0;
            self.animationGroup.autoreverses = NO;
            break;
    }
}

- (void)luaui_setAutoBack:(BOOL)autoBack
{
    _autoBack = autoBack;
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNUICanvasAnimation)
LUA_EXPORT_PROPERTY(setPivotXType, "setPivotXType:", "pivotXType", MLNUICanvasAnimation)
LUA_EXPORT_PROPERTY(setPivotX, "setPivotX:", "luaui_pivotX", MLNUICanvasAnimation)
LUA_EXPORT_PROPERTY(setPivotYType, "setPivotYType:", "pivotYType", MLNUICanvasAnimation)
LUA_EXPORT_PROPERTY(setPivotY, "setPivotY:", "luaui_pivotY", MLNUICanvasAnimation)
LUA_EXPORT_PROPERTY(setDuration, "setDuration:", "duration", MLNUICanvasAnimation)
LUA_EXPORT_PROPERTY(setDelay, "setDelay:", "delay", MLNUICanvasAnimation)
LUA_EXPORT_PROPERTY(setInterpolator, "setInterpolator:", "interpolator", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(setRepeat, "luaui_setRepeat:count:",  MLNUICanvasAnimation)
LUA_EXPORT_METHOD(startWithView, "luaui_startWithView:", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(cancel, "cancel", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(pause, "luaui_pause", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(resume, "luaui_resumeAnimations", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(stop, "luaui_stop", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(setStartCallback, "luaui_setStartCallback:", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(setEndCallback, "luaui_setEndCallback:", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(setRepeatCallback, "luaui_setRepeatCallback:", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(clone, "luaui_clone", MLNUICanvasAnimation)
LUA_EXPORT_METHOD(setAutoBack, "luaui_setAutoBack:", MLNUICanvasAnimation)
LUA_EXPORT_END(MLNUICanvasAnimation, CanvasAnimation, NO, NULL, NULL)

@end
