//
//  MLNUIAnimationConst.h
//  CocoaLumberjack
//
//  Created by MoMo on 2018/8/16.
//

#import <UIKit/UIKit.h>
#import "MLNUIGlobalVarExportProtocol.h"

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
