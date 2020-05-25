//
//  MLNUIAnimationConst.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/16.
//

#import "MLNUIAnimationConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

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

@implementation MLNUIAnimationConst

+ (CAMediaTimingFunction *)buildTimingFunction:(MLNUIAnimationInterpolatorType)interpolator
{
    switch (interpolator) {
        case MLNUIAnimationInterpolatorTypeBounce:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        case MLNUIAnimationInterpolatorTypeOvershoot:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        case MLNUIAnimationInterpolatorTypeAccelerateDecelerate:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        case MLNUIAnimationInterpolatorTypeAccelerate:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        case MLNUIAnimationInterpolatorTypeDecelerate:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        case MLNUIAnimationInterpolatorTypeLinear:
        default:
            return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
}

#pragma mark - Setup For Lua
LUA_EXPORT_GLOBAL_VAR_BEGIN()
LUA_EXPORT_GLOBAL_VAR(RepeatType, (@{@"NONE": @(MLNUIAnimationRepeatTypeNone),
                                     @"FROM_START": @(MLNUIAnimationRepeatTypeBeginToEnd),
                                     @"REVERSE": @(MLNUIAnimationRepeatTypeReverse)}))
LUA_EXPORT_GLOBAL_VAR(InterpolatorType, (@{@"Linear": @(MLNUIAnimationInterpolatorTypeLinear),
                                           @"Accelerate": @(MLNUIAnimationInterpolatorTypeAccelerate),
                                           @"Decelerate": @(MLNUIAnimationInterpolatorTypeDecelerate),
                                           @"AccelerateDecelerate": @(MLNUIAnimationInterpolatorTypeAccelerateDecelerate),
                                           @"Overshoot": @(MLNUIAnimationInterpolatorTypeOvershoot),
                                           @"Bounce": @(MLNUIAnimationInterpolatorTypeBounce)}))
LUA_EXPORT_GLOBAL_VAR(AnimType, (@{
                                   @"Default": @(MLNUIAnimationAnimTypeDefault),
                                   @"None": @(MLNUIAnimationAnimTypeNone),
                                   @"LeftToRight": @(MLNUIAnimationAnimTypeLeftToRight),
                                   @"RightToLeft": @(MLNUIAnimationAnimTypeRightToLeft),
                                   @"TopToBottom": @(MLNUIAnimationAnimTypeTopToBottom),
                                   @"BottomToTop": @(MLNUIAnimationAnimTypeBottomToTop),
                                   @"Scale": @(MLNUIAnimationAnimTypeScale),
                                   @"Fade": @(MLNUIAnimationAnimTypeFade),
                                   }))
LUA_EXPORT_GLOBAL_VAR(AnimationValueType, (@{
                                   @"ABSOLUTE": @(MLNUIAnimationValueTypeAbsolute),
                                   @"RELATIVE_TO_SELF": @(MLNUIAnimationValueTypeRelativeToSelf),
                                   @"RELATIVE_TO_PARENT": @(MLNUIAnimationValueTypeRelativeToParent),
                                   }))
LUA_EXPORT_GLOBAL_VAR_END()


@end
