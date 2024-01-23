//
//  MLNAnimationConst.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/16.
//

#import "MLNAnimationConst.h"
#import "MLNGlobalVarExporterMacro.h"

NSString * const kDefaultGroupAnimation = @"com.milua.group.animation";
NSString * const kDefaultScaleAnimation = @"com.milua.scale.animation";
NSString * const kDefaultTranslationAnimation = @"com.milua.translation.animation";
NSString * const kDefaultRotationAnimation = @"com.milua.rotation.animation";
NSString * const kDefaultOpacityAnimation = @"com.milua.opacity.animation";
NSString * const kTranslationX = @"transform.translation.x";
NSString * const kTranslationY = @"transform.translation.y";
NSString * const kTranslationZ = @"transform.translation.z";
NSString * const kScaleX = @"transform.scale.x";
NSString * const kScaleY = @"transform.scale.y";
NSString * const kScaleZ = @"transform.scale.z";
NSString * const kRotaionX = @"transform.rotation.x";
NSString * const kRotaionY = @"transform.rotation.y";
NSString * const kRotaionZ = @"transform.rotation.z";
NSString * const kOpacity = @"opacity";
NSString * const kTransform = @"transform";

@implementation MLNAnimationConst

+ (CAMediaTimingFunction *)buildTimingFunction:(MLNAnimationInterpolatorType)interpolator
{
    switch (interpolator) {
        case MLNAnimationInterpolatorTypeBounce:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        case MLNAnimationInterpolatorTypeOvershoot:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        case MLNAnimationInterpolatorTypeAccelerateDecelerate:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        case MLNAnimationInterpolatorTypeAccelerate:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        case MLNAnimationInterpolatorTypeDecelerate:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        case MLNAnimationInterpolatorTypeLinear:
        default:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
}

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(RepeatType, (@{@"NONE": @(MLNAnimationRepeatTypeNone),
                                     @"FROM_START": @(MLNAnimationRepeatTypeBeginToEnd),
                                     @"REVERSE": @(MLNAnimationRepeatTypeReverse)}))
LUA_EXPORT_GLOBAL_VAR(InterpolatorType, (@{@"Linear": @(MLNAnimationInterpolatorTypeLinear),
                                           @"Accelerate": @(MLNAnimationInterpolatorTypeAccelerate),
                                           @"Decelerate": @(MLNAnimationInterpolatorTypeDecelerate),
                                           @"AccelerateDecelerate": @(MLNAnimationInterpolatorTypeAccelerateDecelerate),
                                           @"Overshoot": @(MLNAnimationInterpolatorTypeOvershoot),
                                           @"Bounce": @(MLNAnimationInterpolatorTypeBounce)}))
LUA_EXPORT_GLOBAL_VAR(AnimType, (@{
                                   @"Default": @(MLNAnimationAnimTypeDefault),
                                   @"None": @(MLNAnimationAnimTypeNone),
                                   @"LeftToRight": @(MLNAnimationAnimTypeLeftToRight),
                                   @"RightToLeft": @(MLNAnimationAnimTypeRightToLeft),
                                   @"TopToBottom": @(MLNAnimationAnimTypeTopToBottom),
                                   @"BottomToTop": @(MLNAnimationAnimTypeBottomToTop),
                                   @"Scale": @(MLNAnimationAnimTypeScale),
                                   @"Fade": @(MLNAnimationAnimTypeFade),
                                   }))
LUA_EXPORT_GLOBAL_VAR(AnimationValueType, (@{
                                   @"ABSOLUTE": @(MLNAnimationValueTypeAbsolute),
                                   @"RELATIVE_TO_SELF": @(MLNAnimationValueTypeRelativeToSelf),
                                   @"RELATIVE_TO_PARENT": @(MLNAnimationValueTypeRelativeToParent),
                                   }))
LUA_EXPORT_GLOBAL_VAR_END(MLNAnimationConst)


@end
