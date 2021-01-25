//
// Created by momo783 on 2020/5/18.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#import "MLAAnimation.h"
#import "MLAAnimationPrivate.h"
#import "MLADefines.h"
#import "MLAAnimator+Private.h"
//#import "MLAAnimatable.h"
#import "MLAAnimationRuntime.h"
#import "NSObject+Animator.h"
#import "NSObject+Hash.h"

#include "ObjectAnimation.h"
#include "SpringAnimation.h"
#include "MultiAnimation.h"
#include "CustomAnimation.h"
#include "MLAActionEnabler.h"
#import "MLAValueAnimation+Interactive.h" //不可删除
//#import "MLNUIObjectAnimation.h"

using namespace ANIMATOR_NAMESPACE;

@interface MLAAnimation () <MLAAnimationPrivate>

@property(readwrite, weak) id target;

@property (nonatomic, assign) Animation *animation;
@property (nonatomic, assign) BOOL animationPaused;

@property (nonatomic, strong) NSString *innerKey;

@end

#pragma mark - MLAAnimation Implementation

@implementation MLAAnimation

- (instancetype)initDefault {
    if (self = [super init]) {
        _innerKey = [NSString stringWithFormat:@"animationKey_%@",@([self hash])];
    }
    return self;
}

- (void)dealloc {
    if (self.animation) {
        ANIMATOR_SAFE_DELETE(self.animation);
    }
}

- (void *)animationPtr {
    return _animation;
}

- (void)setBeginTime:(NSNumber *)beginTime {
    _beginTime = beginTime;
    if (self.animation) {
        self.animation->SetBeginTime(beginTime.floatValue);
    }
}

- (void)setRepeatCount:(NSNumber *)repeatCount {
    _repeatCount = repeatCount;
    if (self.animation) {
        self.animation->SetRepeatCount((AMTInt)repeatCount.integerValue);
    }
}

- (void)setRepeatForever:(NSNumber *)repeatForever {
    _repeatForever = repeatForever;
    if (self.animation) {
        self.animation->SetRepeatForever(repeatForever.boolValue);
    }
}

- (void)setAutoReverses:(NSNumber *)autoReverses {
    _autoReverses = autoReverses;
    if (self.animation) {
        self.animation->SetAutoreverses(autoReverses.boolValue);
    }
}

- (void)start {
    if (self.target) {
        [[MLAAnimator shareAnimator] addAnimation:self forObject:self.target andKey:self.innerKey];
    }
}

- (void)start:(MLAAnimationFinishBlock)finishBlock {
    _finishBlock = finishBlock;
    [self start];
}

- (void)pause {
    self.animationPaused = YES;
    if (self.animation) {
        self.animation->Pause(true);
    }
}

- (void)resume {
    self.animationPaused = NO;
    if (self.animation) {
        self.animation->Pause(false);
    }
}

- (void)finish {
    if (self.target) {
        [[MLAAnimator shareAnimator] removeAnimation:self.target forKey:self.innerKey];
    } else {
        // Target 释放情况下，Loop会主动移除动画
    }
}

- (void)reset {
    // 重置为初始状态
}

#pragma mark - MLAAniamtionPrivate
- (void)makeAnimation:(NSString *)key forObject:(id)obj {
    [self setTarget:obj];
    
    if (self.animation) {
        if (self.beginTime) {
            self.animation->SetBeginTime(self.beginTime.floatValue);
        }
        if (self.repeatCount) {
            self.animation->SetRepeatCount((AMTInt)self.repeatCount.integerValue);
        }
        if (self.autoReverses) {
            self.animation->SetAutoreverses(self.autoReverses.boolValue);
        }
        if (self.repeatForever) {
            self.animation->SetRepeatForever(self.repeatForever.boolValue);
        }
        if (self.animationPaused) {
            self.animation->Pause(true);
        }
    }
}

- (animator::Animation *)cplusplusAnimation {
    return self.animation;
}

- (void)updateAnimation:(animator::Animation *)animation {
    
}

- (void)startAnimation {
    if (self.startBlock) {
        ActionEnabler enabler;
        self.startBlock(self);
    }
}

- (void)pauseAnimation:(BOOL)paused {
    if (paused && self.pauseBlock) {
        ActionEnabler enabler;
        self.pauseBlock(self);
    } else if (!paused && self.resumeBlock) {
        ActionEnabler enabler;
        self.resumeBlock(self);
    }
}

- (void)repeatAnimation:(MLAAnimation *)executingAnimation count:(NSUInteger)count {
    [self reset];
    if (self.repeatBlock) {
        ActionEnabler enabler;
        self.repeatBlock(executingAnimation, count);
    }
}

- (void)finishAnimation:(BOOL)finish {
    if (self.finishBlock) {
        ActionEnabler enabler;
        self.finishBlock(self, finish);
    }
    if (self.resetOnFinish) {
        [self resetAnimationToOriginalState];
    }
}

- (void)resetAnimationToOriginalState {
    // subclass should override
}

@end

#pragma mark - MLAValueAnimation Implementation

@interface MLAValueAnimation ()

@property(readwrite, strong) NSString *valueName;
@property(nonatomic, strong) MLAAnimatable *animatable;

@end


@implementation MLAValueAnimation
@synthesize target;

- (instancetype)initWithValueName:(NSString *)valueName tartget:(id)target {
    if (self = [super initDefault]) {
        [self setTarget:target];
        _valueName = valueName;
        _animatable = [MLAAnimatable animatableWithName:valueName];
    }
    return self;
}

- (instancetype)initWithValueName:(NSString *)valueName tartget:(id)target
      mutableAnimatableInitialize:(MLAMutableAnimatableInitializeHandler)initializeHandler {
    if (!initializeHandler) {
        return nil;
    }
    if (self = [super initDefault]) {
        [self setTarget:target];
        _valueName = valueName;
        MLAMutableAnimatable *mutableAnimatable = [MLAMutableAnimatable animatableWithName:valueName];
        initializeHandler(mutableAnimatable);
        _animatable = mutableAnimatable;
    }
    return self;
}

- (void)makeValueAnimation:(ValueAnimation*)animation {
    if (animation) {
        VectorRef fromVec = nullptr, toVec = nullptr;
        NSUInteger valueCount = self.animatable.valueCount;
        if (self.fromValue) {
            NSUInteger fromValueCount = 0;
            MLAValueType valueType = kMLAValueUnknown;
            fromVec = MLAUnbox(self.fromValue, valueType, fromValueCount, false);
            if (valueCount != fromValueCount) {
                fromVec = nullptr;
            }
        }
        if (self.toValue) {
            NSUInteger toValueCount = 0;
            MLAValueType valueType = kMLAValueUnknown;
            toVec = MLAUnbox(self.toValue, valueType, toValueCount, false);
            if (valueCount != toValueCount) {
                toVec = nullptr;
            }
        }
        
        if (!fromVec) {
            Vector4r vec = read_values(self.animatable.readBlock, self.target, valueCount);
            fromVec = VectorRef(Vector::new_vector(valueCount, vec));
        }
        if (!toVec) {
            Vector4r vec = read_values(self.animatable.readBlock, self.target, valueCount);
            toVec = VectorRef(Vector::new_vector(valueCount, vec));
        }
        
        animation->FromToValues(fromVec->data(), toVec->data(), (AMTInt)valueCount);
    }
}

- (void)updateAnimation:(animator::Animation *)animation {
    if (self.animatable && self.target && self.animation == animation) {
        ValueAnimation *valueAnimation = (ValueAnimation*)animation;
        self.animatable.writeBlock(self.target, valueAnimation->GetCurrentValue().data());
    }
}

- (void)reset {
    if (self.animatable && self.target && self.animation) {
        ValueAnimation *valueAnimation = (ValueAnimation*)self.animation;
        self.animatable.writeBlock(self.target, valueAnimation->GetCurrentValue().data());
    }
}

- (void)updateWithProgress:(CGFloat)progress {
    [self updateWithFactor:progress isBegan:NO];
}

- (void)resetAnimationToOriginalState {
    if (self.animatable && self.target && self.animation) {
        ValueAnimation *valueAnimation = (ValueAnimation*)self.animation;
        self.animatable.writeBlock(self.target, valueAnimation->GetFromValue().data());
    }
}

@end

#pragma mark - MLAObjectAnimation Implementation

@interface MLAObjectAnimation ()

@end

@implementation MLAObjectAnimation

- (instancetype)initWithValueName:(NSString *)valueName tartget:(id)target {
    if (self = [super initWithValueName:valueName tartget:target]) {
        _timingFunction = MLATimingFunctionDefault;
    }
    return self;
}

- (TimingFunction)timingFunctionWith:(MLATimingFunction)function
{
    switch (function) {
        case MLATimingFunctionDefault:
            return TimingFunction::Default;
            break;
        case MLATimingFunctionLinear:
        return TimingFunction::Linear;
            break;
        case MLATimingFunctionEaseIn:
            return TimingFunction::EaseIn;
            break;
        case MLATimingFunctionEaseOut:
        return TimingFunction::EaseOut;
        break;
        case MLATimingFunctionEaseInEaseOut:
            return TimingFunction::EaseInOut;
            break;
        default:
            return TimingFunction::Default;
            break;
    }
}

- (void)setDuration:(CGFloat)duration {
    _duration = duration;
    if (self.animation) {
        ObjectAnimation *_animation = (ObjectAnimation *)self.animation;
        _animation->Duration(duration);
    }
}

- (void)setTimingFunction:(MLATimingFunction)timingFunction {
    _timingFunction = timingFunction;
    if (self.animation) {
        ObjectAnimation *_animation = (ObjectAnimation *)self.animation;
        _animation->ViaTimingFunction([self timingFunctionWith:self.timingFunction]);
    }
}


- (void)makeAnimation:(NSString *)key forObject:(id)obj {
    if (!self.animation) {
        self.animation = new ObjectAnimation(key.UTF8String);
    }
    [super makeAnimation:key forObject:obj];
    
    ObjectAnimation *animation = (ObjectAnimation *)self.animation;
    [self makeValueAnimation:animation];
    
    animation->Duration(self.duration);
    animation->ViaTimingFunction([self timingFunctionWith:self.timingFunction]);
    animation->threshold = self.animatable.threshold;
}

@end

#pragma mark - MLASpringAnimation Implementation

@interface MLASpringAnimation ()

@end

@implementation MLASpringAnimation

- (instancetype)initWithValueName:(NSString *)valueName tartget:(id)target {
    if (self = [super initWithValueName:valueName tartget:target]) {
        _springSpeed = 12.;
        _springBounciness = 4.0;
    }
    return self;
}

- (void)makeAnimation:(NSString *)key forObject:(id)obj {
    
    if (!self.animation) {
        self.animation = new SpringAnimation(key.UTF8String);
    }
    [super makeAnimation:key forObject:obj];
    
    SpringAnimation *animation = (SpringAnimation*)self.animation;
    [self makeValueAnimation:animation];
    
    animation->SetSpringSpeed(self.springSpeed);
    animation->SetSpringBounciness(self.springBounciness);
    
    NSUInteger valueCount = 0;
    MLAValueType valueType = kMLAValueUnknown;
    VectorRef vec = MLAUnbox(self.velocity, valueType, valueCount, false);
    if (!vec || valueCount != self.animatable.valueCount) {
        Vector4r vec4r = read_values(self.animatable.readBlock, self.target, self.animatable.valueCount);
        vec = VectorRef(Vector::new_vector(self.animatable.valueCount, vec4r));
    }
    animation->SetVelocity(vec->data());
    
    if (self.dynamicsTension) {
        animation->SetDynamicsTension(self.dynamicsTension);
    }
    if (self.dynamicsFriction) {
        animation->SetDynamicsFriction(self.dynamicsFriction);
    }
    if (self.dynamicsMass) {
        animation->SetDynamicsMass(self.dynamicsMass);
    }
    
    animation->threshold = self.animatable.threshold;
}

- (void)setSpringSpeed:(CGFloat)springSpeed {
    _springSpeed = springSpeed;
    if (self.animation) {
        SpringAnimation *_animation = (SpringAnimation*)self.animation;
        _animation->SetSpringSpeed(springSpeed);
    }
}

- (void)setSpringBounciness:(CGFloat)springBounciness {
    _springBounciness = springBounciness;
    if (self.animation) {
        SpringAnimation *_animation = (SpringAnimation*)self.animation;
        _animation->SetSpringBounciness(springBounciness);
    }
}

- (void)setDynamicsTension:(CGFloat)dynamicsTension {
    _dynamicsTension = dynamicsTension;
    if (self.animation) {
        SpringAnimation *_animation = (SpringAnimation*)self.animation;
        _animation->SetDynamicsTension(dynamicsTension);
    }
}

- (void)setDynamicsFriction:(CGFloat)dynamicsFriction {
    _dynamicsFriction = dynamicsFriction;
    if (self.animation) {
        SpringAnimation *_animation = (SpringAnimation*)self.animation;
        _animation->SetDynamicsFriction(dynamicsFriction);
    }
}

- (void)setDynamicsMass:(CGFloat)dynamicsMass {
    _dynamicsMass = dynamicsMass;
    if (self.animation) {
        SpringAnimation *_animation = (SpringAnimation*)self.animation;
        _animation->SetDynamicsMass(dynamicsMass);
    }
}


@end

#pragma mark - MLAM Implementation
typedef NS_ENUM(NSInteger) {
    RunningTypeTogether,
    RunningTypeSequentially,
    
} RunningType;

@interface MLAMultiAnimation ()

@property(readwrite, strong) NSArray<MLAAnimation*> *animations;

@property(nonatomic, assign) RunningType runningType;

@property(nonatomic, strong) NSMutableArray<MLAAnimation*> *finishAniamtions;

@property(nonatomic, assign) BOOL startCallbacked;

@end

@implementation MLAMultiAnimation

- (instancetype)init {
    if (self = [super initDefault]) {
        _runningType = RunningTypeTogether;
        _finishAniamtions = [NSMutableArray array];
    }
    return self;
}

- (void)runTogether:(NSArray<MLAAnimation *> *)animations {
    _runningType = RunningTypeTogether;
    _animations = animations;
}

- (void)runSequentially:(NSArray<MLAAnimation *> *)animations {
    _runningType = RunningTypeSequentially;
    _animations = animations;
}

- (void)start {
    [self setTarget:self];
    [super start];
}

- (void)updateAnimation:(animator::Animation *)animation {
    [super updateAnimation:animation];
    //
    MultiAnimation *multiAnimation = dynamic_cast<MultiAnimation*>(animation);
    if (multiAnimation) {
        const MultiAnimationList animations = multiAnimation->GetRunningAnimationList();
        for (auto subAnimation : animations) {
            for (MLAAnimation *objcAnimation in self.animations) {
                if (objcAnimation.animation == subAnimation) {
                    [objcAnimation updateAnimation:subAnimation];
                    break;
                }
            }
        }
    }
}

- (void)makeAnimation:(NSString *)key forObject:(id)obj {
    if (!self.animation) {
        self.animation = new MultiAnimation(key.UTF8String);
    }
    
    MultiAnimation *animation = (MultiAnimation*)self.animation;
    std::vector<Animation *> animations;
    for (MLAAnimation *objcAnimation in self.animations) {
        [objcAnimation makeAnimation:objcAnimation.innerKey forObject:objcAnimation.target];
        animations.push_back(objcAnimation.cplusplusAnimation);
    }
    if (self.runningType == RunningTypeTogether) {
        animation->RunTogether(animations);
    } else {
        animation->RunSequentially(animations);
    }
    
    [super makeAnimation:key forObject:obj];
}

- (void)reset {
    for (MLAAnimation *objcAnimation in self.animations) {
        [objcAnimation reset];
    }
}

- (void)resetAnimationToOriginalState {
    for (MLAAnimation *objcAnimation in self.animations) {
        [objcAnimation resetAnimationToOriginalState];
    }
}

static inline CGFloat MIN_MAX(CGFloat value, CGFloat min, CGFloat max) {
    if (value < min) value = min;
    if (value > max) value = max;
    return value;
}

- (void)updateWithProgress:(CGFloat)progress {
    switch (_runningType) {
        case RunningTypeTogether: {
            for (MLAValueAnimation *anim in self.animations) {
                [anim updateWithProgress:progress];
            }
            break;
        }
            
        case RunningTypeSequentially: {
            static NSInteger index = 0;
            if (self.animations.count > 1 && index == 0 && progress >= 1.0) {
                return; // 过滤极端情况 (具有多个动画，但当第一个动画执行时，progress就>=1.0，不合理)
            }
            CGFloat section = 1.0 / self.animations.count;  // 所有动画平分progress
            CGFloat progressOfEachAnimation = progress - index * section;
            CGFloat validProgress = MIN_MAX(progressOfEachAnimation * self.animations.count, 0, 1);
            
            MLAValueAnimation *anim = (MLAValueAnimation *)self.animations[MIN(index, self.animations.count-1)];
            [anim updateWithProgress:validProgress];
            
            if (progressOfEachAnimation >= section) { // 当前动画的进度超过其所分配的范围，则表示当前动画执行完毕，需执行下一个动画
                index++;
            }
            if (progressOfEachAnimation <= 0) { // 当前动画的进度为负数，则表示当前动画执行完毕，需执行上一个动画
                index--;
            }
            if (progress >= 1.0) { // 所有动画执行完则index复位
                index = 0;
            }
            break;
        }
            
        default:
            break;
    }
}

@end

#pragma mark - MLACustomAnimation Implementation

@interface MLACustomAnimation ()
<MLAAnimationPrivate> {
    CustomAnimation *_animation;
}
@property(nonatomic, strong) MLACustomAnimationBlock animationBlock;

@end

@implementation MLACustomAnimation
@synthesize target;

- (instancetype)initWithBlock:(MLACustomAnimationBlock)animationBlock {
    if (self = [super initDefault]) {
        _animationBlock = animationBlock;
    }
    return self;
}

- (void)makeAnimation:(NSString *)key forObject:(id)obj {
    [self setTarget:obj];
    if (!self.animation) {
        self.animation = new CustomAnimation(key.UTF8String);
    }
    [super makeAnimation:key forObject:obj];
}

- (animator::Animation *)cplusplusAnimation {
    return _animation;
}

- (void)updateAnimation:(animator::Animation *)animation {
    
}

- (void)finishAnimation:(BOOL)finish {
    
}

@end
