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

extern NSString * const kMLAViewPosition;     // 位置
extern NSString * const kMLAViewPositionX;    // 位置X
extern NSString * const kMLAViewPositionY;    // 位置Y

extern NSString * const kMLAViewScale;      // XY缩放
extern NSString * const kMLAViewScaleX;     // X缩放
extern NSString * const kMLAViewScaleY;     // Y缩放

extern NSString * const kMLAViewRotation;       // Z旋转
extern NSString * const kMLAViewRotationX;      // X旋转
extern NSString * const kMLAViewRotationY;      // Y旋转

extern NSString *const kMLAViewContentOffset; // UIScrollView及其子类contentOffset
extern NSString *const kMLAViewTextColor; // MLNUILabel的文字颜色

typedef NS_ENUM(NSInteger) {
    MLATimingFunctionDefault,
    MLATimingFunctionLinear,
    MLATimingFunctionEaseIn,
    MLATimingFunctionEaseOut,
    MLATimingFunctionEaseInEaseOut
} MLATimingFunction;

NS_ASSUME_NONNULL_END
