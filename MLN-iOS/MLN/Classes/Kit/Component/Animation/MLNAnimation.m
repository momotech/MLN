//
//  MLNAnimation.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/9.
//

#import "MLNAnimation.h"
#import "MLNEntityExporterMacro.h"
#import "MLNAnimationConst.h"
#import "MLNBlock.h"
#import "MLNAnimationDelegate.h"
#import "NSDictionary+MLNSafety.h"
#import "MLNKitHeader.h"
#import "MLNKeyframeAnimationBuilder.h"


#define kStartCallback @"MLNAnimation.Start"
#define kEndCallback @"MLNAnimation.End"

#define kAnimationKeysCount 10

typedef enum : NSUInteger {
    MLNAnimationStatusIdle,
    MLNAnimationStatusReadyToPlay,
    MLNAnimationStatusRunning,
    MLNAnimationStatusPuase,
    MLNAnimationStatusReadyToResume,
    MLNAnimationStatusStop,
} MLNAnimationStatus;

@interface MLNAnimation ()
{
    CAAnimationGroup *_animationGroup;
    BOOL _autoBack;
    BOOL _ignoreAnimationCallback;
}

@property (nonatomic, strong, readonly) CAAnimationGroup *animationGroup;
@property (nonatomic, strong) NSMutableDictionary<NSString *, CABasicAnimation *> *animations;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MLNBlock *> *animationCallbacks;
@property(nonatomic, assign) float delay;
@property(nonatomic, weak) UIView *targetView;
@property (nonatomic, assign) MLNAnimationStatus status;
@property (nonatomic, assign) MLNAnimationRepeatType repeateType;
@property (nonatomic, assign) MLNAnimationInterpolatorType interpolatorType;
@property (nonatomic, assign) CATransform3D scale;

@end
@implementation MLNAnimation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _status = MLNAnimationStatusIdle;
        _autoBack = NO;
    }
    return self;
}

- (CABasicAnimation *)animationForKey:(NSString *)key
{
    CABasicAnimation *animation = [self.animations objectForKey:key];
    if (!animation) {
        animation = [self baseAnimationWithKeyPath:key interpolatorType:self.interpolatorType];
        [self.animations mln_setObject:animation forKey:key];
    }
    return animation;
}

- (CABasicAnimation *)baseAnimationWithKeyPath:(NSString *)key interpolatorType:(MLNAnimationInterpolatorType)interpolatorType
{
    switch (interpolatorType) {
        case MLNAnimationInterpolatorTypeBounce:
        case MLNAnimationInterpolatorTypeOvershoot: {
            return (CABasicAnimation *)[MLNKeyframeAnimationBuilder buildAnimationWithKeyPath:key interpolatorType:interpolatorType];
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
    NSMutableDictionary *newAnimations = [[NSMutableDictionary alloc] initWithCapacity:11];
    [self.animations enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CABasicAnimation * _Nonnull animation, BOOL * _Nonnull stop) {
        CABasicAnimation *newAnimation = [self baseAnimationWithKeyPath:key interpolatorType:self.interpolatorType];
        newAnimation.fromValue = animation.fromValue;
        newAnimation.toValue = animation.toValue;
        [newAnimations mln_setObject:newAnimation forKey:key];
    }];
    _animations = newAnimations;
}

- (NSMutableDictionary<NSString *,CABasicAnimation *> *)animations
{
    if (!_animations) {
        _animations = [NSMutableDictionary dictionaryWithCapacity:kAnimationKeysCount];
    }
    return _animations;
}

- (CAAnimationGroup *)animationGroup
{
    if (!_animationGroup) {
        _animationGroup = [CAAnimationGroup animation];
        MLNAnimationDelegate *delegate = [[MLNAnimationDelegate alloc] initWithAnimation:self];
        _animationGroup.delegate = delegate;
    }
    return _animationGroup;
}

- (NSMutableDictionary<NSString *,MLNBlock *> *)animationCallbacks
{
    if (!_animationCallbacks) {
        _animationCallbacks = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return _animationCallbacks;
}


#pragma mark - MLNAnimateProtocol
- (void)doTask
{
    switch (self.status) {
        case MLNAnimationStatusReadyToPlay:
        {
            NSArray<CAAnimation *> *animations = self.animations.allValues;
            UIView *view = self.targetView;
            if (!_autoBack) {//动画结束后停滞
                for (CAAnimation* animation in animations) {
                    animation.removedOnCompletion = _autoBack;
                    if (!_autoBack) {
                        animation.fillMode = kCAFillModeForwards;
                    }
                }
                self.animationGroup.removedOnCompletion = _autoBack;
                self.animationGroup.fillMode = kCAFillModeForwards;
            }
            for (CABasicAnimation *animation in animations) {
                animation.duration = self.animationGroup.duration;
            }
            if (view && animations.count >0) {
                if (_scale.m34 != 0) {
                    view.layer.transform = _scale;
                }
                if (self.delay >0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.status = MLNAnimationStatusRunning;
                        self.animationGroup.animations = animations;
                        [self.targetView.layer addAnimation:self.animationGroup forKey:kDefaultGroupAnimation];
                    });
                } else {
                    self.status = MLNAnimationStatusRunning;
                    self.animationGroup.animations = animations;
                    [self.targetView.layer addAnimation:self.animationGroup forKey:kDefaultGroupAnimation];
                }
            }
            break;
        }
        case MLNAnimationStatusReadyToResume:
        {
            CFTimeInterval pausedTime = [self.targetView.layer timeOffset];
            self.targetView.layer.speed = 1.0;
            self.targetView.layer.timeOffset = 0.0;
            self.targetView.layer.beginTime = 0.0;
            CFTimeInterval timeSincePause = [self.targetView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
            self.targetView.layer.beginTime = timeSincePause;
            self.status = MLNAnimationStatusRunning;
            break;
        }
        default:
            break;
    }
}

#pragma mark - CAAnimationDelegate
- (void)callAnimationDidStart
{
    // callback
    MLNBlock *callback = [self.animationCallbacks objectForKey:kStartCallback];
    if (callback && !_ignoreAnimationCallback) {
        [callback callIfCan];
    }
}

- (void)callAnimationDidStopWith:(BOOL)flag
{
    // callback
    MLNBlock *callback = [self.animationCallbacks objectForKey:kEndCallback];
    if (callback && !_ignoreAnimationCallback) {
        self.status = MLNAnimationStatusIdle;
        [callback addBOOLArgument:flag];
        [callback callIfCan];
    }
    _ignoreAnimationCallback = NO;
}


#pragma mark - Export Mothed
- (void)lua_setTranslateX:(CGFloat)fromeValue to:(CGFloat)toValue
{
    CABasicAnimation *animation = [self animationForKey:kTranslationX];
    animation.fromValue = @(fromeValue);
    animation.toValue = @(toValue);
}

- (void)lua_setTranslateY:(CGFloat)fromeValue to:(CGFloat)toValue
{
    CABasicAnimation *animation = [self animationForKey:kTranslationY];
    animation.fromValue = @(fromeValue);
    animation.toValue = @(toValue);
}

- (void)lua_setScaleX:(CGFloat)fromeValue to:(CGFloat)toValue
{
    CABasicAnimation *animation = [self animationForKey:kScaleX];
    animation.fromValue = @(fromeValue);
    animation.toValue = @(toValue);
}

- (void)lua_setRotationY:(CGFloat)fromValue to:(CGFloat)toValue
{
    CABasicAnimation *animation = [self animationForKey:kRotaionY];
    animation.fromValue = @(fromValue/180.f*M_PI);
    animation.toValue = @(toValue/180.f*M_PI);
    [self lua_setScaleValue:1500];
}

- (void)lua_setRotationX:(CGFloat)fromValue to:(CGFloat)toValue
{
    CABasicAnimation *animation = [self animationForKey:kRotaionX];
    animation.fromValue = @(fromValue/180.f*M_PI);
    animation.toValue = @(toValue/180.f*M_PI);
    [self lua_setScaleValue:1500];
}

- (void)lua_setScaleValue:(CGFloat)value
{
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/value;
    self.scale = scale;
}

- (void)lua_setRotationZ:(CGFloat)fromeValue to:(CGFloat)toValue
{
    CABasicAnimation *animation = [self animationForKey:kRotaionZ];
    animation.fromValue = @(fromeValue/180.f*M_PI);
    animation.toValue = @(toValue/180.f*M_PI);
}

- (void)lua_setScaleY:(CGFloat)fromeValue to:(CGFloat)toValue
{
    CABasicAnimation *animation = [self animationForKey:kScaleY];
    animation.fromValue = @(fromeValue);
    animation.toValue = @(toValue);
}

- (void)lua_setAutoBack:(BOOL)autoBack
{
    self.animationGroup.removedOnCompletion = autoBack;
    _autoBack = autoBack;
}

- (void)lua_setRepeat:(MLNAnimationRepeatType)type count:(float)count
{
    if (count == -1) {
        count = MAX_INT;
    }
    self.repeateType = type;
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

- (void)lua_repeatCount:(NSInteger)repeatCount
{
    if (repeatCount == -1) {
        repeatCount = MAX_INT;
    }
    self.animationGroup.repeatCount = repeatCount;
}

- (void)lua_setDuration:(CGFloat)duration
{
    self.animationGroup.duration =duration;
}

- (void)lua_setDelay:(CGFloat)delay
{
    self.delay = delay;
}

- (void)lua_setInterpolator:(MLNAnimationInterpolatorType)type
{
    if (type != _interpolatorType) {
        _interpolatorType = type;
        self.animationGroup.timingFunction = [MLNAnimationConst buildTimingFunction:type];
        [self resetAnimations];
    }
}

- (void)lua_setAlpha:(CGFloat)fromeValue to:(CGFloat)toValue
{
    CABasicAnimation *animation = [self animationForKey:kOpacity];
    animation.fromValue = @(fromeValue);
    animation.toValue = @(toValue);
}

#pragma mark - Callbacks
- (void)lua_setStartCallback:(MLNBlock *)block
{
    [self.animationCallbacks mln_setObject:block forKey:kStartCallback];
}

- (void)lua_setEndCallback:(MLNBlock *)block
{
    [self.animationCallbacks mln_setObject:block forKey:kEndCallback];
}

#pragma mark - Contol
- (void)lua_startWithView:(UIView *)view
{
    MLNCheckTypeAndNilValue(view, @"View", [UIView class]);
    switch (self.status) {
        case MLNAnimationStatusRunning:
        case MLNAnimationStatusPuase:
            view.layer.speed = 1.0;
            view.layer.timeOffset = .0f;
            view.layer.beginTime = .0f;
            [view.layer removeAnimationForKey:kDefaultGroupAnimation];
            [self callAnimationDidStopWith:NO];
            _ignoreAnimationCallback = YES;
            break;
        default:
            break;
    }
    self.targetView = view;
    self.status = MLNAnimationStatusReadyToPlay;
    [MLN_KIT_INSTANCE(self.mln_luaCore) pushAnimation:self];
}

- (void)lua_stop
{
    switch (self.status) {
        case MLNAnimationStatusStop:
            return;
        default:
            self.status = MLNAnimationStatusStop;
            [MLN_KIT_INSTANCE(self.mln_luaCore) popAnimation:self];
            [self.targetView.layer removeAnimationForKey:kDefaultGroupAnimation];
            return;
    }
}

- (void)lua_pause
{
    switch (self.status) {
        case MLNAnimationStatusReadyToPlay:
        case MLNAnimationStatusReadyToResume:
            self.status = MLNAnimationStatusPuase;
            break;
        case MLNAnimationStatusRunning:
        {
            self.status = MLNAnimationStatusPuase;
            CFTimeInterval pausedTime = [self.targetView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
            self.targetView.layer.speed = 0.f;
            self.targetView.layer.timeOffset = pausedTime;
            break;
        }
        default:
            break;
    }
}

- (void)lua_resumeAnimations
{
    switch (self.status) {
        case MLNAnimationStatusPuase:
        {
            self.status = MLNAnimationStatusReadyToResume;
            [MLN_KIT_INSTANCE(self.mln_luaCore) pushAnimation:self];
        }
        default:
            break;
    }
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNAnimation)
LUA_EXPORT_METHOD(setTranslateX, "lua_setTranslateX:to:", MLNAnimation)
LUA_EXPORT_METHOD(setTranslateY, "lua_setTranslateY:to:", MLNAnimation)
LUA_EXPORT_METHOD(setRotate, "lua_setRotationZ:to:", MLNAnimation)
LUA_EXPORT_METHOD(setRotateY, "lua_setRotationY:to:", MLNAnimation)
LUA_EXPORT_METHOD(setRotateX, "lua_setRotationX:to:", MLNAnimation)
LUA_EXPORT_METHOD(setScaleX, "lua_setScaleX:to:", MLNAnimation)
LUA_EXPORT_METHOD(setScaleY, "lua_setScaleY:to:", MLNAnimation)
LUA_EXPORT_METHOD(setAlpha, "lua_setAlpha:to:", MLNAnimation)
LUA_EXPORT_METHOD(repeatCount, "lua_repeatCount:", MLNAnimation)
LUA_EXPORT_METHOD(setRepeat, "lua_setRepeat:count:", MLNAnimation)
LUA_EXPORT_METHOD(setAutoBack, "lua_setAutoBack:", MLNAnimation)
LUA_EXPORT_METHOD(setDuration, "lua_setDuration:", MLNAnimation)
LUA_EXPORT_METHOD(setDelay, "lua_setDelay:", MLNAnimation)
LUA_EXPORT_METHOD(setInterpolator, "lua_setInterpolator:", MLNAnimation)
LUA_EXPORT_METHOD(start, "lua_startWithView:", MLNAnimation)
LUA_EXPORT_METHOD(pause, "lua_pause", MLNAnimation)
LUA_EXPORT_METHOD(resume, "lua_resumeAnimations", MLNAnimation)
LUA_EXPORT_METHOD(stop, "lua_stop", MLNAnimation)
LUA_EXPORT_METHOD(setStartCallback, "lua_setStartCallback:", MLNAnimation)
LUA_EXPORT_METHOD(setEndCallback, "lua_setEndCallback:", MLNAnimation)
LUA_EXPORT_END(MLNAnimation, Animation, NO, NULL, NULL)

@end

