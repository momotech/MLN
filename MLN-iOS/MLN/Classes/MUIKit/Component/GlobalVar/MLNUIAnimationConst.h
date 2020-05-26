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

@interface MLNUIAnimationConst : NSObject <MLNUIGlobalVarExportProtocol>

+ (CAMediaTimingFunction *)buildTimingFunction:(MLNUIAnimationInterpolatorType)interpolator;

@end
