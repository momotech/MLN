//
//  MLNUIViewGlobalVar.h
//  MLNUI
//
//  Created by MoMo on 2019/8/3.
//

#import <Foundation/Foundation.h>
#import "MLNUIGlobalVarExportProtocol.h"
#import "MLNUISafeAreaViewProtocol.h"
#import "llimits.h"

typedef NS_OPTIONS(NSUInteger, MLNUIRectCorner)  {
    MLNUIRectCornerNone = 0,
    MLNUIRectCornerTopLeft = 1<<0,
    MLNUIRectCornerTopRight = 1<<1,
    MLNUIRectCornerBottomLeft = 1<<2,
    MLNUIRectCornerBottomRight = 1<<3,
    MLNUIRectCornerAllCorners  = ~0UL
};

typedef NS_OPTIONS(NSUInteger, MLNUIValueType) {
    MLNUIValueTypeNone = 0,
    MLNUIValueTypeCurrent = MAX_INT,
};

typedef NS_OPTIONS(NSUInteger, MLNUIGradientType) {
    MLNUIGradientTypeNone = 0,
    MLNUIGradientTypeLeftToRight = 1<<0,
    MLNUIGradientTypeRightToLeft = 1<<1,
    MLNUIGradientTypeTopToBottom = 1<<2,
    MLNUIGradientTypeBottomToTop = 1<<3,
};

typedef NS_ENUM(NSInteger, MLNUIStatusBarMode) {
    MLNUIStatusBarModeNoneFullScreen = 0,
    MLNUIStatusBarModeFullScreen,
    MLNUIStatusBarModeTransparency,
};

typedef enum : NSUInteger {
    MLNUIStatusBarStyleDefault = 0,
    MLNUIStatusBarStyleLight,
}MLNUIStatusBarStyle;

typedef enum : NSUInteger {
    MLNUITabSegmentAlignmentLeft = 0,
    MLNUITabSegmentAlignmentCenter,
    MLNUITabSegmentAlignmentRight,
}MLNUITabSegmentAlignment;

typedef enum : NSUInteger {
    MLNUILabelMaxModeNone = 0,
    MLNUILabelMaxModeLines,
    MLNUILabelMaxModeValue,
}MLNUILabelMaxMode;

typedef struct {
    CGFloat topLeft;
    CGFloat topRight;
    CGFloat bottomLeft;
    CGFloat bottomRight;
} MLNUICornerRadius;

typedef enum : NSUInteger {
    // 设置layer的ConerRadius
    MLNUICornerModeNone = 0,
    // 设置layer的ConerRadius
    MLNUICornerLayerMode,
    // 设置layer的mask layer
    MLNUICornerMaskLayerMode,
    // 给View添加一个中间透明四周有圆角的ImageView子视图
    MLNUICornerMaskImageViewMode,
} MLNUICornerMode;

typedef enum : NSUInteger {
    MLNUIImageViewModeNone = 0,
    //    点9图模式，需要忽略contentMode设置
    MLNUIImageViewModeNine,
} MLNUIImageViewMode;

typedef NS_ENUM(NSUInteger, MLNUITouchType) {
    MLNUITouchType_Begin,
    MLNUITouchType_Move,
    MLNUITouchType_End
//    MLNUITouchType_Cancel
};

typedef void(^MLNUITouchCallback)(MLNUITouchType type, UITouch * _Nonnull touch, UIEvent * _Nonnull event);

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIViewConst : NSObject <MLNUIGlobalVarExportProtocol>

+ (UIRectCorner)convertToRectCorner:(MLNUIRectCorner)corners;

@end

NS_ASSUME_NONNULL_END
