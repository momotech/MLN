//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
# define MLA_EXTERN_C_BEGIN extern "C" {
# define MLA_EXTERN_C_END   }
#else
# define MLA_EXTERN_C_BEGIN
# define MLA_EXTERN_C_END
#endif

#define MLA_ARRAY_COUNT(x) sizeof(x) / sizeof(x[0])

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kMLAViewAlpha;  // 透明度
extern NSString * const kMLAViewColor;  // 背景色

extern NSString * const kMLAViewOrigin;     // 原点位置
extern NSString * const kMLAViewOriginX;    // 原点X
extern NSString * const kMLAViewOriginY;    // 原点Y

extern NSString * const kMLAViewCenter;     // 中心点
extern NSString * const kMLAViewCenterX;    // 中心点X
extern NSString * const kMLAViewCenterY;    // 中心点Y

extern NSString * const kMLAViewSize;       // 尺寸
extern NSString * const kMLAViewFrame;      // 原点 + 尺寸

extern NSString * const kMLAViewScale;      // XY缩放
extern NSString * const kMLAViewScaleX;     // X缩放
extern NSString * const kMLAViewScaleY;     // Y缩放

extern NSString * const kMLAViewRotation;       // Z旋转
extern NSString * const kMLAViewRotationX;      // X旋转
extern NSString * const kMLAViewRotationY;      // Y旋转

typedef NS_ENUM(NSInteger) {
    MLATimingFunctionDefault,
    MLATimingFunctionLinear,
    MLATimingFunctionEaseIn,
    MLATimingFunctionEaseOut,
    MLATimingFunctionEaseInEaseOut
} MLATimingFunction;

NS_ASSUME_NONNULL_END
