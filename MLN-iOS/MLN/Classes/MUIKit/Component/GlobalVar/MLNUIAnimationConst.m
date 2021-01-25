//
//  MLNUIAnimationConst.m
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/16.
//

#import "MLNUIAnimationConst.h"
#import "MLNUIGlobalVarExporterMacro.h"

NSString * const kMUIDefaultGroupAnimation = @"com.milua.group.animation";
NSString * const kMUIDefaultScaleAnimation = @"com.milua.scale.animation";
NSString * const kMUIDefaultTranslationAnimation = @"com.milua.translation.animation";
NSString * const kMUIDefaultRotationAnimation = @"com.milua.rotation.animation";
NSString * const kMUIDefaultOpacityAnimation = @"com.milua.opacity.animation";
NSString * const kMUITranslationX = @"transform.translation.x";
NSString * const kMUITranslationY = @"transform.translation.y";
NSString * const kMUITranslationZ = @"transform.translation.z";
NSString * const kMUIScaleX = @"transform.scale.x";
NSString * const kMUIScaleY = @"transform.scale.y";
NSString * const kMUIScaleZ = @"transform.scale.z";
NSString * const kMUIRotaionX = @"transform.rotation.x";
NSString * const kMUIRotaionY = @"transform.rotation.y";
NSString * const kMUIRotaionZ = @"transform.rotation.z";
NSString * const kMUIOpacity = @"opacity";
NSString * const kMUITransform = @"transform";

NSString * const kMUITimingConfigDuration = @"Duration";
NSString * const kMUITimingConfigVelocity = @"Velocity";
NSString * const kMUITimingConfigBounciness = @"Bounciness";
NSString * const kMUITimingConfigSpeed = @"Speed";
NSString * const kMUITimingConfigTension = @"Tension";
NSString * const kMUITimingConfigFriction = @"Friction";
NSString * const kMUITimingConfigMass = @"Mass";

NSString * const kMUIAnimPropertyAlpha = @"view.alpha";
NSString * const kMUIAnimPropertyColor = @"view.backgroundColor";
NSString * const kMUIAnimPropertyOrigin = @"view.origin";
NSString * const kMUIAnimPropertyOriginX = @"view.originX";
NSString * const kMUIAnimPropertyOriginY = @"view.originY";
NSString * const kMUIAnimPropertyCenter = @"view.center";
NSString * const kMUIAnimPropertyCenterX = @"view.centerX";
NSString * const kMUIAnimPropertyCenterY = @"view.centerY";
NSString * const kMUIAnimPropertyScale = @"view.scale";
NSString * const kMUIAnimPropertyScaleX = @"view.scaleX";
NSString * const kMUIAnimPropertyScaleY = @"view.scaleY";
NSString * const kMUIAnimPropertyRotation = @"view.rotation";
NSString * const kMUIAnimPropertyRotationX = @"view.rotationX";
NSString * const kMUIAnimPropertyRotationY = @"view.rotationY";

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
LUAUI_EXPORT_GLOBAL_VAR_BEGIN()
LUAUI_EXPORT_GLOBAL_VAR(RepeatType, (@{@"NONE": @(MLNUIAnimationRepeatTypeNone),
                                     @"FROM_START": @(MLNUIAnimationRepeatTypeBeginToEnd),
                                     @"REVERSE": @(MLNUIAnimationRepeatTypeReverse)}))
LUAUI_EXPORT_GLOBAL_VAR(InterpolatorType, (@{@"Linear": @(MLNUIAnimationInterpolatorTypeLinear),
                                           @"Accelerate": @(MLNUIAnimationInterpolatorTypeAccelerate),
                                           @"Decelerate": @(MLNUIAnimationInterpolatorTypeDecelerate),
                                           @"AccelerateDecelerate": @(MLNUIAnimationInterpolatorTypeAccelerateDecelerate),
                                           @"Overshoot": @(MLNUIAnimationInterpolatorTypeOvershoot),
                                           @"Bounce": @(MLNUIAnimationInterpolatorTypeBounce)}))
LUAUI_EXPORT_GLOBAL_VAR(AnimType, (@{
                                   @"Default": @(MLNUIAnimationAnimTypeDefault),
                                   @"None": @(MLNUIAnimationAnimTypeNone),
                                   @"LeftToRight": @(MLNUIAnimationAnimTypeLeftToRight),
                                   @"RightToLeft": @(MLNUIAnimationAnimTypeRightToLeft),
                                   @"TopToBottom": @(MLNUIAnimationAnimTypeTopToBottom),
                                   @"BottomToTop": @(MLNUIAnimationAnimTypeBottomToTop),
                                   @"Scale": @(MLNUIAnimationAnimTypeScale),
                                   @"Fade": @(MLNUIAnimationAnimTypeFade),
                                   }))
LUAUI_EXPORT_GLOBAL_VAR(AnimationValueType, (@{
                                   @"ABSOLUTE": @(MLNUIAnimationValueTypeAbsolute),
                                   @"RELATIVE_TO_SELF": @(MLNUIAnimationValueTypeRelativeToSelf),
                                   @"RELATIVE_TO_PARENT": @(MLNUIAnimationValueTypeRelativeToParent),
                                   }))
LUAUI_EXPORT_GLOBAL_VAR(Timing, (@{
                            @"Default": @(MLNUIAnimationTimingFunctionDefault),
                            @"Linear": @(MLNUIAnimationTimingFunctionLinear),
                            @"EaseIn": @(MLNUIAnimationTimingFunctionEaseIn),
                            @"EaseOut": @(MLNUIAnimationTimingFunctionEaseOut),
                            @"EaseInEaseOut": @(MLNUIAnimationTimingFunctionEaseInEaseOut),
                            @"Spring": @(MLNUIAnimationTimingFunctionSpring),
                            }))
LUAUI_EXPORT_GLOBAL_VAR(AnimProperty, (@{
                            @"Alpha": @(MLNUIAnimationPropertyTypeAlpha),
                            @"Color": @(MLNUIAnimationPropertyTypeColor),
                            @"Position": @(MLNUIAnimationPropertyTypePosition),
                            @"PositionX": @(MLNUIAnimationPropertyTypePositionX),
                            @"PositionY": @(MLNUIAnimationPropertyTypePositionY),
                            @"Scale": @(MLNUIAnimationPropertyTypeScale),
                            @"ScaleX": @(MLNUIAnimationPropertyTypeScaleX),
                            @"ScaleY": @(MLNUIAnimationPropertyTypeScaleY),
                            @"Rotation": @(MLNUIAnimationPropertyTypeRotation),
                            @"RotationX": @(MLNUIAnimationPropertyTypeRotationX),
                            @"RotationY": @(MLNUIAnimationPropertyTypeRotationY),
                            @"ContentOffset":@(MLNUIAnimationPropertyTypeContentOffset),
                            @"TextColor":@(MLNUIAnimationPropertyTypeTextColor)
                            }))
LUAUI_EXPORT_GLOBAL_VAR_END()


@end
