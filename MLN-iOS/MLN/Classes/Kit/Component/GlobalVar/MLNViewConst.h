//
//  MLNViewGlobalVar.h
//  MLN
//
//  Created by MoMo on 2019/8/3.
//

#import <Foundation/Foundation.h>
#import "MLNGlobalVarExportProtocol.h"
#import "llimits.h"

typedef NS_OPTIONS(NSUInteger, MLNRectCorner)  {
    MLNRectCornerNone = 0,
    MLNRectCornerTopLeft = 1<<0,
    MLNRectCornerTopRight = 1<<1,
    MLNRectCornerBottomLeft = 1<<2,
    MLNRectCornerBottomRight = 1<<3,
    MLNRectCornerAllCorners  = ~0UL
};

static const NSUInteger MLN_AXIS_SPECIFIED = 0x0001;
static const NSUInteger MLN_AXIS_PULL_BEFORE = 0x0002;
static const NSUInteger MLN_AXIS_PULL_AFTER = 0x0004;
static const NSUInteger MLN_AXIS_X_SHIFT = 0;
static const NSUInteger MLN_AXIS_Y_SHIFT = 4;
typedef NS_OPTIONS(NSUInteger, MLNGravity) {
    MLNGravityNone = 0,
    MLNGravityLeft = (MLN_AXIS_PULL_BEFORE|MLN_AXIS_SPECIFIED)<<MLN_AXIS_X_SHIFT,
    MLNGravityTop = (MLN_AXIS_PULL_BEFORE|MLN_AXIS_SPECIFIED)<<MLN_AXIS_Y_SHIFT,
    MLNGravityRight = (MLN_AXIS_PULL_AFTER|MLN_AXIS_SPECIFIED)<<MLN_AXIS_X_SHIFT,
    MLNGravityBottom = (MLN_AXIS_PULL_AFTER|MLN_AXIS_SPECIFIED)<<MLN_AXIS_Y_SHIFT,
    MLNGravityCenterHorizontal = MLN_AXIS_SPECIFIED<<MLN_AXIS_X_SHIFT,
    MLNGravityCenterVertical = MLN_AXIS_SPECIFIED<<MLN_AXIS_Y_SHIFT,
    MLNGravityCenter = MLNGravityCenterHorizontal|MLNGravityCenterVertical,
    MLNGravityHorizontalMask = (MLN_AXIS_SPECIFIED |
                                MLN_AXIS_PULL_BEFORE | MLN_AXIS_PULL_AFTER) << MLN_AXIS_X_SHIFT,
    MLNGravityVerticalMask = (MLN_AXIS_SPECIFIED |
                              MLN_AXIS_PULL_BEFORE | MLN_AXIS_PULL_AFTER) << MLN_AXIS_Y_SHIFT,
};

typedef NS_OPTIONS(NSUInteger, MLNValueType) {
    MLNValueTypeNone = 0,
    MLNValueTypeCurrent = MAX_INT,
};

typedef NS_OPTIONS(NSUInteger, MLNGradientType) {
    MLNGradientTypeNone = 0,
    MLNGradientTypeLeftToRight = 1<<0,
    MLNGradientTypeRightToLeft = 1<<1,
    MLNGradientTypeTopToBottom = 1<<2,
    MLNGradientTypeBottomToTop = 1<<3,
};

typedef NS_OPTIONS(NSUInteger, MLNLayoutDirection){
    MLNLayoutDirectionHorizontal = 1,
    MLNLayoutDirectionVertical = 2,
};

typedef enum : NSInteger {
    MLNLayoutMeasurementTypeIdle = 0,
    MLNLayoutMeasurementTypeMatchParent = -1,
    MLNLayoutMeasurementTypeWrapContent = -2,
} MLNLayoutMeasurementType;

typedef enum : NSUInteger {
    MLNStatusBarStyleDefault = 0,
    MLNStatusBarStyleLight,
}MLNStatusBarStyle;

typedef enum : NSUInteger {
    MLNTabSegmentAlignmentLeft = 0,
    MLNTabSegmentAlignmentCenter,
    MLNTabSegmentAlignmentRight,
}MLNTabSegmentAlignment;

typedef enum : NSUInteger {
    MLNLabelMaxModeNone = 0,
    MLNLabelMaxModeLines,
    MLNLabelMaxModeValue,
}MLNLabelMaxMode;

typedef struct {
    CGFloat topLeft;
    CGFloat topRight;
    CGFloat bottomLeft;
    CGFloat bottomRight;
} MLNCornerRadius;

typedef enum : NSUInteger {
    // 设置layer的ConerRadius
    MLNCornerModeNone = 0,
    // 设置layer的ConerRadius
    MLNCornerLayerMode,
    // 设置layer的mask layer
    MLNCornerMaskLayerMode,
    // 给View添加一个中间透明四周有圆角的ImageView子视图
    MLNCornerMaskImageViewMode,
} MLNCornerMode;

NS_ASSUME_NONNULL_BEGIN

@interface MLNViewConst : NSObject <MLNGlobalVarExportProtocol>

+ (UIRectCorner)convertToRectCorner:(MLNRectCorner)corners;

@end

NS_ASSUME_NONNULL_END
