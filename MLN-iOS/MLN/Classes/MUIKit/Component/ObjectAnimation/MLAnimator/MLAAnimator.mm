//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#import "MLAAnimator.h"
#import "MLAAnimator+Private.h"
#import "MLAAnimation.h"
#import "MLAAnimationPrivate.h"
#import "NSObject+Hash.h"

#import <QuartzCore/QuartzCore.h>

#include "AnimatorEngine.h"

using namespace ANIMATOR_NAMESPACE;

@interface MLAAnimator ()
{
    AnimatorEngine *animatorEngine;
}
// 以对象存储每个对象的动画列表
@property(nonatomic, strong) NSMapTable<NSString*, MLAAnimation*> *animations;

// 每个对象关联的动画
@property(nonatomic, strong) NSMapTable<id, NSMutableSet*> *objectaAimationKeys;

// 线程安全
@property(nonatomic, strong) dispatch_semaphore_t semaphore;

// transaction 当前开启状态
@property(nonatomic, assign) BOOL transactionEnableState;

@end

static MLAAnimator* shareInstance;
@implementation MLAAnimator

+ (instancetype)shareAnimator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [MLAAnimator new];
    });
    return shareInstance;
}
    
- (instancetype)init
{
    self = [super init];
    if (self) {
        _semaphore = dispatch_semaphore_create(1);
        _animations = [NSMapTable strongToStrongObjectsMapTable];
        _objectaAimationKeys = [NSMapTable weakToStrongObjectsMapTable];
        
        [self setupAnimatorEngine];
    }
    return self;
}

- (void)setupAnimatorEngine
{
    animatorEngine = AnimatorEngine::ShareAnimator();
    
    animatorEngine->animatorEngineLoopStart = [self](AMTTimeInterval currentTime) {
        [self onLoopStartCallback:currentTime];
    };
    
    animatorEngine->animatorEngineLoopEnd = [self](AMTTimeInterval currentTime) {
        [self onLoopEndCallback:currentTime];
    };
    
    animatorEngine->updateAnimation = [self](Animation* animation) {
        [self onUpdateAnimation:animation];
    };
    
    animatorEngine->animationStart = [self](Animation* animation) {
        [self onAnimationStart:animation];
    };
    
    animatorEngine->animationPause = [self](Animation* animation, AMTBool paused) {
        [self onAnimationPause:animation pause:paused];
    };
    
    animatorEngine->animationRepeat = [self](Animation *caller, Animation *executingAnimation, AMTInt count) {
        [self onAnimationRepeat:caller executingAnimation:executingAnimation count:count];
    };
    
    
    animatorEngine->animationFinish = [self](Animation* animation, AMTBool finish) {
        [self onAnimationFinsih:animation finish:finish];
    };
}

- (void)onLoopStartCallback:(AMTTimeInterval)currentTime
{
    // 开启CATransaction
    self.transactionEnableState = [CATransaction disableActions];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
}

- (void)onUpdateAnimation:(Animation *)animation
{
    // 获取动画名
    NSString *animationKey = [NSString stringWithUTF8String:animation->GetName().c_str()];
    // 取动画
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    MLAAnimation<MLAAnimationPrivate> *mlaAnimation = (id)[self.animations objectForKey:animationKey];
    dispatch_semaphore_signal(_semaphore);
    
    // 如果动画Target被释放,则直接异常底层插值动画
    if (!mlaAnimation.target) {
        animatorEngine->RemoveAnimation(animation);
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        [self.animations removeObjectForKey:animationKey];
        dispatch_semaphore_signal(_semaphore);
    } else {
        // 正常动画更新流程
        [mlaAnimation updateAnimation:animation];
    }
}

- (void)onAnimationStart:(Animation*)animation
{
    // 获取动画名
    NSString *animationKey = [NSString stringWithUTF8String:animation->GetName().c_str()];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    MLAAnimation<MLAAnimationPrivate> *mlaAnimation = (id)[self.animations objectForKey:animationKey];
    dispatch_semaphore_signal(_semaphore);
    
    if (mlaAnimation) {
        [mlaAnimation startAnimation];
    }
}

- (void)onAnimationPause:(Animation*)animation pause:(BOOL)paused
{
    // 获取动画名
    NSString *animationKey = [NSString stringWithUTF8String:animation->GetName().c_str()];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    MLAAnimation<MLAAnimationPrivate> *mlaAnimation = (id)[self.animations objectForKey:animationKey];
    dispatch_semaphore_signal(_semaphore);
    
    if (mlaAnimation) {
        [mlaAnimation pauseAnimation:paused];
    }
}

- (void)onAnimationRepeat:(Animation *)caller executingAnimation:(Animation *)executingAnimation count:(NSUInteger)count
{
    // 获取动画名
    NSString *animationKey = [NSString stringWithUTF8String:caller->GetName().c_str()];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    MLAAnimation<MLAAnimationPrivate> *mlaAnimation = (id)[self.animations objectForKey:animationKey];
    dispatch_semaphore_signal(_semaphore);
    
    MLAAnimation *doingAnimation = mlaAnimation;
    if ([mlaAnimation isKindOfClass:[MLAMultiAnimation class]]) {
        NSArray<MLAAnimation *> *array = [(MLAMultiAnimation *)mlaAnimation animations];
        for (MLAAnimation *anim in array) {
            if (anim.animationPtr == executingAnimation) {
                doingAnimation = anim;
                break;
            }
        }
    }
    if (mlaAnimation) {
        [mlaAnimation repeatAnimation:doingAnimation count:count];
    }
}

- (void)onAnimationFinsih:(Animation*)animation finish:(BOOL)finish
{
    // 获取动画名
    NSString *animationKey = [NSString stringWithUTF8String:animation->GetName().c_str()];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    MLAAnimation<MLAAnimationPrivate> *mlaAnimation = (id)[self.animations objectForKey:animationKey];
    dispatch_semaphore_signal(_semaphore);
    
    if (mlaAnimation) {
        [mlaAnimation finishAnimation:finish];
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        [self.animations removeObjectForKey:animationKey];
        NSMutableSet *animationKeys = [self.objectaAimationKeys objectForKey:mlaAnimation.target];
        if (animationKeys.count) {
            [animationKeys removeObject:animationKey];
        }
        dispatch_semaphore_signal(_semaphore);
    }
}

- (void)onLoopEndCallback:(AMTTimeInterval)currentTime
{
    [CATransaction commit];
    // 还原CATransaction原始状态
    [CATransaction setDisableActions:self.transactionEnableState];
}

- (void)addAnimation:(MLAAnimation *)animation forObject:(id)obj andKey:(NSString *)key
{
    if (!obj || !animation || !key || !key.length) {
        return;
    }
    NSString *animationKey = [NSString stringWithFormat:@"%@_%@",@([obj mla_hash]), key];
    
    // 取缓存
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    if ([self.animations objectForKey:animationKey]) {
        dispatch_semaphore_signal(_semaphore);
        NSLog(@"MLAAnimator addAnimation:forObject:andKey animation key [%@] is exist for object [%@] !!!",key, obj);
        return;
    } else {
        [self.animations setObject:animation forKey:animationKey];
        NSMutableSet *animationKeys = [self.objectaAimationKeys objectForKey:obj];
        if (!animationKeys) {
            animationKeys = [NSMutableSet set];
            [self.objectaAimationKeys setObject:animationKeys forKey:obj];
        }
        [animationKeys addObject:animationKey];
        dispatch_semaphore_signal(_semaphore);
    }
    
    // make c++ animation
    if ([animation isKindOfClass:[MLAObjectAnimation class]] || [animation isKindOfClass:[MLASpringAnimation class]]
        || [animation isKindOfClass:[MLACustomAnimation class]] || [animation isKindOfClass:[MLAMultiAnimation class]]) {
        id<MLAAnimationPrivate> animationPrivate = (id)animation;
        [animationPrivate makeAnimation:animationKey forObject:obj];
        Animation* cAnimation = (Animation *)[animationPrivate cplusplusAnimation];
        if (cAnimation) {
            animatorEngine->AddAnimation(cAnimation, animationKey.UTF8String);
        }
    }

}

- (void)removeAnimation:(id)obj
{
    if (!obj) {
        return;
    }
    
    NSSet *removeAnimationKeys;
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSMutableSet *animationKeys = [self.objectaAimationKeys objectForKey:obj];
    if (animationKeys.count) {
        [self.objectaAimationKeys removeObjectForKey:obj];
        removeAnimationKeys = [NSSet setWithSet:animationKeys];
    }
    dispatch_semaphore_signal(_semaphore);
    
    for (NSString *animationKey in removeAnimationKeys) {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        MLAAnimation *animation = [self.animations objectForKey:animationKey];
        dispatch_semaphore_signal(_semaphore);
        if (animation) {
            id<MLAAnimationPrivate> animationPrivate = (id)animation;
            animatorEngine->RemoveAnimation((Animation *)[animationPrivate cplusplusAnimation]);
        }
    }
}

- (void)removeAnimation:(id)obj forKey:(NSString *)key
{
    if (!obj || !key || !key.length) {
        return;
    }
    
    NSString *animationKey = [NSString stringWithFormat:@"%@_%@",@([obj mla_hash]), key];
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSMutableSet *animationKeys = [self.objectaAimationKeys objectForKey:obj];
    if (![animationKeys containsObject:animationKey]) {
        dispatch_semaphore_signal(_semaphore);
        return;
    }
    
    MLAAnimation *animation = [self.animations objectForKey:animationKey];
    dispatch_semaphore_signal(_semaphore);
    if (animation) {
        id<MLAAnimationPrivate> animationPrivate = (id)animation;
        animatorEngine->RemoveAnimation((Animation *)[animationPrivate cplusplusAnimation]);
    }
    
}

@end
