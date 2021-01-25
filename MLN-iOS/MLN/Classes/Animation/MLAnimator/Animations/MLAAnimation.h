//
// Created by momo783 on 2020/5/18.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "MLADefines.h"
//#import "MLAValueAnimation+Interactive.h"
//#import "MLAAnimatable.h"

// 动画过程回调Block
@class MLAAnimation, MLNUIObjectAnimation, MLAMutableAnimatable;
typedef void(^MLAAnimationStartBlock)(MLAAnimation* animation);
typedef void(^MLAAnimationPauseBlock)(MLAAnimation* animation);
typedef void(^MLAAnimationResumeBlock)(MLAAnimation* animation);
typedef void(^MLAAnimationRepeatBlock)(MLAAnimation* animation, NSUInteger count);
typedef void(^MLAAnimationFinishBlock)(MLAAnimation* animation, BOOL finish);

typedef void(^MLAMutableAnimatableInitializeHandler)(MLAMutableAnimatable *animatable);

#pragma mark - MLAAnimation
/**
 * 动画基础类，设置时间相关参数，不会被单独实例化
 */

@interface MLAAnimation : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property(readonly, weak) id target;

/// animator::Animation*
@property (nonatomic, assign, readonly) void *animationPtr;

/// MLNUIObjectAnimation
@property (nonatomic, weak) MLNUIObjectAnimation *bridgeAnimation;

/**
 * 动画开始执行时间，相对动画被添加的时间间隔
 */
@property(nonatomic, strong) NSNumber *beginTime;

/**
 * 动画重读执行的次数
 */
@property(nonatomic, strong) NSNumber *repeatCount;

/**
 * 动画是否永远重复执行
 */
@property(nonatomic, strong) NSNumber *repeatForever;

/**
 * 动画是翻转
 */
@property(nonatomic, strong) NSNumber *autoReverses;

/// 重置动画结束后是否重置为初始状态, 默认为NO.
@property (nonatomic, assign) BOOL resetOnFinish;

/**
 * 动画开始回调
 */
@property(nonatomic, strong) MLAAnimationStartBlock startBlock;

/**
 * 动画暂停回调
 */
@property(nonatomic, strong) MLAAnimationPauseBlock pauseBlock;

/**
 * 动画恢复回调
 */
@property(nonatomic, strong) MLAAnimationResumeBlock resumeBlock;

/**
 * 动画重复回调
 */
@property(nonatomic, strong) MLAAnimationRepeatBlock repeatBlock;

/**
 * 动画完成回调
 */
@property(nonatomic, strong) MLAAnimationFinishBlock finishBlock;

/**
 * 开始动画
 */
- (void)start;

/**
 * 开始动画，带Finish回调
 * @param finishBlock 动画完成
 */

- (void)start:(MLAAnimationFinishBlock)finishBlock;

/**
 * 暂停动画
 */
- (void)pause;

/**
 * 恢复动画
 */
- (void)resume;

/**
 * 强制结束动画
 */
- (void)finish;

@end

#pragma mark - MLAValueAnimation

/**
 * 针对对象属性进行的动画，覆盖基本数据类型和属性，不可被实例化
 * 如：X、Y、Origin、Width、Height、Size、Bounds、ScaleX、SacleY、ScaleXY、RotateX、RotateY
 * BackgroundColor、CornerRadius、CornerRadius 等
 */

@interface MLAValueAnimation : MLAAnimation

/**
 * 动画起始值，一般类型为 NSNumber 或者 NAValue
 */
@property(nonatomic, strong) id fromValue;

/**
 * 动画目标值，一般类型为 NSNumber 或者 NAValue
 */
@property(nonatomic, strong) id toValue;

/**
 * 进行动画的属性类型
 */
@property(nonatomic, readonly) NSString *valueName;

/**
 * 构造函数，传如属性名构造，并指定动画对象
 * @param valueName 进行动画的属性类型
 */
- (instancetype)initWithValueName:(NSString *)valueName tartget:(id)target;

/**
 * 自定义数值刷新绑定
 */
- (instancetype)initWithValueName:(NSString *)valueName tartget:(id)target
      mutableAnimatableInitialize:(MLAMutableAnimatableInitializeHandler)initializeHandler;

- (void)updateWithProgress:(CGFloat)progress NS_SWIFT_NAME(update(progress:));

@end

#pragma mark - MLAObjectAnimation

/**
 * 针对对象属性进行的 EaseIn EaseOut 动画
 * 如：X、Y、Origin、Width、Height、Size、Bounds、ScaleX、SacleY、ScaleXY、RotateX、RotateY
 * BackgroundColor、CornerRadius、CornerRadius 等
 */

@interface MLAObjectAnimation : MLAValueAnimation

/**
 * 动画进行时间
 */
@property(nonatomic, assign) CGFloat duration;

/**
 * 动画效果时间函数, 默认是EaseIn函数
 */
@property(nonatomic, assign) MLATimingFunction timingFunction;

@end

#pragma mark - MLASpringAnimation

/**
 * Spring 弹簧效果动画
 */
@interface MLASpringAnimation : MLAValueAnimation

/**
 * 当前值，需要在动画开始前设置初始值
 */
@property(nonatomic, strong) id velocity;

/**
 * 反弹力，和springSpeed数值一起可以改变动画效果，数值越大，弹簧运动范围越大，振动和弹性越大
 * 参考 POP 动画库 定义为[0,20]范围内的值，默认为4
 */
@property(nonatomic, assign) CGFloat springBounciness;

/**
 * 弹簧速度，和springBounciness数值一起可以改变动画效果，更高的数值增加了弹簧的阻尼能力，导致更快的初始速度和更快速的反弹减速
 * 参考 POP 动画库 定义为[0,20]范围内的值。默认为12
 */
@property(nonatomic, assign) CGFloat springSpeed;

/**
 * 动态张力，可以在弹力和速度上使用，以更精细地调整动画效果
 */
@property(nonatomic, assign) CGFloat dynamicsTension;

/**
 * 动态摩擦，可以在弹力和速度上使用，以更精细地调整动画效果
 */
@property(nonatomic, assign) CGFloat dynamicsFriction;

/**
 * 动态质量，同上
 */
@property(nonatomic, assign) CGFloat dynamicsMass;

@end

#pragma mark - MLAMultiAnimation

@interface MLAMultiAnimation : MLAAnimation

@property(readonly, strong) NSArray<MLAAnimation*> *animations;

- (instancetype)init NS_AVAILABLE(10.10, 9.0);

- (void)runTogether:(NSArray<MLAAnimation *> *)animations;

- (void)runSequentially:(NSArray<MLAAnimation *> *)animations;

- (void)updateWithProgress:(CGFloat)progress NS_SWIFT_NAME(update(progress:));

@end

#pragma mark - MLACustomAnimation

/**
 * 自定义动画，回抛时间数据，用户自定义实现
 */
@class MLACustomAnimation;
typedef BOOL(^MLACustomAnimationBlock)(id target, MLACustomAnimation *animation);

@interface MLACustomAnimation : MLAAnimation
/**
 * 当前系统时间
 */
@property(nonatomic, assign) CGFloat currentTime;

/**
 * 上一次动画处理和到现在的间隔时间
 */
@property(nonatomic, assign) CGFloat elapsedTime;

/**
 * 唯一构造函数
 * @param animationBlock 回调Block，给用户动画逻辑实现
 */
- (instancetype)initWithBlock:(MLACustomAnimationBlock)animationBlock;

@end
