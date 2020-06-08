//
//  MLNUIAnimationConst.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/16.
//

#import <UIKit/UIKit.h>
#import "MLNUIGlobalVarExportProtocol.h"

FOUNDATION_EXPORT NSString * const kMUIDefaultGroupAnimation;
FOUNDATION_EXPORT NSString * const kMUIDefaultScaleAnimation;
FOUNDATION_EXPORT NSString * const kMUIDefaultTranslationAnimation;
FOUNDATION_EXPORT NSString * const kMUIDefaultRotationAnimation;
FOUNDATION_EXPORT NSString * const kMUIDefaultOpacityAnimation;
FOUNDATION_EXPORT NSString * const kMUITranslationX;
FOUNDATION_EXPORT NSString * const kMUITranslationY;
FOUNDATION_EXPORT NSString * const kMUITranslationZ;
FOUNDATION_EXPORT NSString * const kMUIScaleX;
FOUNDATION_EXPORT NSString * const kMUIScaleY;
FOUNDATION_EXPORT NSString * const kMUIScaleZ;
FOUNDATION_EXPORT NSString * const kMUIRotaionX;
FOUNDATION_EXPORT NSString * const kMUIRotaionY;
FOUNDATION_EXPORT NSString * const kMUIRotaionZ;
FOUNDATION_EXPORT NSString * const kMUIOpacity;
FOUNDATION_EXPORT NSString * const kMUITransform;

FOUNDATION_EXPORT NSString * const kMUITimingConfigDuration;
FOUNDATION_EXPORT NSString * const kMUITimingConfigVelocity;
FOUNDATION_EXPORT NSString * const kMUITimingConfigBounciness;
FOUNDATION_EXPORT NSString * const kMUITimingConfigSpeed;
FOUNDATION_EXPORT NSString * const kMUITimingConfigTension;
FOUNDATION_EXPORT NSString * const kMUITimingConfigFriction;
FOUNDATION_EXPORT NSString * const kMUITimingConfigMass;

FOUNDATION_EXPORT NSString * const kMUIAnimPropertyAlpha;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyColor;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyOrigin;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyOriginX;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyOriginY;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyCenter;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyCenterX;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyCenterY;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertySize;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyFrame;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyScale;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyScaleX;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyScaleY;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyRotation;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyRotationX;
FOUNDATION_EXPORT NSString * const kMUIAnimPropertyRotationY;



typedef enum : NSUInteger {
    MLNUIAnimationRepeatTypeNone,
    MLNUIAnimationRepeatTypeBeginToEnd,
    MLNUIAnimationRepeatTypeReverse,
} MLNUIAnimationRepeatType;

typedef enum : NSUInteger {
    MLNUIAnimationInterpolatorTypeLinear = 0,
    MLNUIAnimationInterpolatorTypeAccelerate,
    MLNUIAnimationInterpolatorTypeDecelerate,
    MLNUIAnimationInterpolatorTypeAccelerateDecelerate,
    MLNUIAnimationInterpolatorTypeOvershoot,
    MLNUIAnimationInterpolatorTypeBounce,
} MLNUIAnimationInterpolatorType;

typedef enum : NSUInteger {
    MLNUIAnimationAnimTypeDefault = 0,
    MLNUIAnimationAnimTypeNone,
    MLNUIAnimationAnimTypeLeftToRight,
    MLNUIAnimationAnimTypeRightToLeft,
    MLNUIAnimationAnimTypeTopToBottom,
    MLNUIAnimationAnimTypeBottomToTop,
    MLNUIAnimationAnimTypeScale,
    MLNUIAnimationAnimTypeFade,
} MLNUIAnimationAnimType;

typedef enum : NSInteger {
    MLNUIAnimationValueTypeAbsolute = 0,
    MLNUIAnimationValueTypeRelativeToSelf,
    MLNUIAnimationValueTypeRelativeToParent
}MLNUIAnimationValueType;

typedef enum : NSInteger {
    MLNUIAnimationTimingFunctionDefault,
    MLNUIAnimationTimingFunctionLinear,
    MLNUIAnimationTimingFunctionEaseIn,
    MLNUIAnimationTimingFunctionEaseOut,
    MLNUIAnimationTimingFunctionEaseInEaseOut,
    MLNUIAnimationTimingFunctionSpring,
} MLNUIAnimationTimingFunction;


@interface MLNUIAnimationConst : NSObject <MLNUIGlobalVarExportProtocol>

+ (CAMediaTimingFunction *)buildTimingFunction:(MLNUIAnimationInterpolatorType)interpolator;

@end
