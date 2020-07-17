//
//  MLNAnimationConst.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/16.
//

#import <UIKit/UIKit.h>
#import "MLNGlobalVarExportProtocol.h"

FOUNDATION_EXPORT NSString * const kDefaultGroupAnimation;
FOUNDATION_EXPORT NSString * const kDefaultScaleAnimation;
FOUNDATION_EXPORT NSString * const kDefaultTranslationAnimation;
FOUNDATION_EXPORT NSString * const kDefaultRotationAnimation;
FOUNDATION_EXPORT NSString * const kDefaultOpacityAnimation;
FOUNDATION_EXPORT NSString * const kTranslationX;
FOUNDATION_EXPORT NSString * const kTranslationY;
FOUNDATION_EXPORT NSString * const kTranslationZ;
FOUNDATION_EXPORT NSString * const kScaleX;
FOUNDATION_EXPORT NSString * const kScaleY;
FOUNDATION_EXPORT NSString * const kScaleZ;
FOUNDATION_EXPORT NSString * const kRotaionX;
FOUNDATION_EXPORT NSString * const kRotaionY;
FOUNDATION_EXPORT NSString * const kRotaionZ;
FOUNDATION_EXPORT NSString * const kOpacity;
FOUNDATION_EXPORT NSString * const kTransform;

FOUNDATION_EXPORT NSString * const kTimingConfigDuration;
FOUNDATION_EXPORT NSString * const kTimingConfigVelocity;
FOUNDATION_EXPORT NSString * const kTimingConfigBounciness;
FOUNDATION_EXPORT NSString * const kTimingConfigSpeed;
FOUNDATION_EXPORT NSString * const kTimingConfigTension;
FOUNDATION_EXPORT NSString * const kTimingConfigFriction;
FOUNDATION_EXPORT NSString * const kTimingConfigMass;

FOUNDATION_EXPORT NSString * const kAnimPropertyAlpha;
FOUNDATION_EXPORT NSString * const kAnimPropertyColor;
FOUNDATION_EXPORT NSString * const kAnimPropertyOrigin;
FOUNDATION_EXPORT NSString * const kAnimPropertyOriginX;
FOUNDATION_EXPORT NSString * const kAnimPropertyOriginY;
FOUNDATION_EXPORT NSString * const kAnimPropertyCenter;
FOUNDATION_EXPORT NSString * const kAnimPropertyCenterX;
FOUNDATION_EXPORT NSString * const kAnimPropertyCenterY;
FOUNDATION_EXPORT NSString * const kAnimPropertySize;
FOUNDATION_EXPORT NSString * const kAnimPropertyFrame;
FOUNDATION_EXPORT NSString * const kAnimPropertyScale;
FOUNDATION_EXPORT NSString * const kAnimPropertyScaleX;
FOUNDATION_EXPORT NSString * const kAnimPropertyScaleY;
FOUNDATION_EXPORT NSString * const kAnimPropertyRotation;
FOUNDATION_EXPORT NSString * const kAnimPropertyRotationX;
FOUNDATION_EXPORT NSString * const kAnimPropertyRotationY;


typedef enum : NSUInteger {
    MLNAnimationRepeatTypeNone,
    MLNAnimationRepeatTypeBeginToEnd,
    MLNAnimationRepeatTypeReverse,
} MLNAnimationRepeatType;

typedef enum : NSUInteger {
    MLNAnimationInterpolatorTypeLinear = 0,
    MLNAnimationInterpolatorTypeAccelerate,
    MLNAnimationInterpolatorTypeDecelerate,
    MLNAnimationInterpolatorTypeAccelerateDecelerate,
    MLNAnimationInterpolatorTypeOvershoot,
    MLNAnimationInterpolatorTypeBounce,
} MLNAnimationInterpolatorType;

typedef enum : NSUInteger {
    MLNAnimationAnimTypeDefault = 0,
    MLNAnimationAnimTypeNone,
    MLNAnimationAnimTypeLeftToRight,
    MLNAnimationAnimTypeRightToLeft,
    MLNAnimationAnimTypeTopToBottom,
    MLNAnimationAnimTypeBottomToTop,
    MLNAnimationAnimTypeScale,
    MLNAnimationAnimTypeFade,
} MLNAnimationAnimType;

typedef enum : NSInteger {
    MLNAnimationValueTypeAbsolute = 0,
    MLNAnimationValueTypeRelativeToSelf,
    MLNAnimationValueTypeRelativeToParent
}MLNAnimationValueType;

typedef enum : NSInteger {
    MLNAnimationTimingFunctionDefault,
    MLNAnimationTimingFunctionLinear,
    MLNAnimationTimingFunctionEaseIn,
    MLNAnimationTimingFunctionEaseOut,
    MLNAnimationTimingFunctionEaseInEaseOut,
    MLNAnimationTimingFunctionSpring,
} MLNAnimationTimingFunction;

@interface MLNAnimationConst : NSObject <MLNGlobalVarExportProtocol>

+ (CAMediaTimingFunction *)buildTimingFunction:(MLNAnimationInterpolatorType)interpolator;

@end
