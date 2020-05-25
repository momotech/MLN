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

@interface MLNAnimationConst : NSObject <MLNGlobalVarExportProtocol>

+ (CAMediaTimingFunction *)buildTimingFunction:(MLNAnimationInterpolatorType)interpolator;

@end
