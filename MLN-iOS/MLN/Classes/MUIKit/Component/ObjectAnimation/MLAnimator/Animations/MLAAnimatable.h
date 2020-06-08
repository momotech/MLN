//
// Created by momo783 on 2020/5/19.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MLAValueReadBlock)(id obj, CGFloat values[_Nonnull]);
typedef void (^MLAValueWriteBlock)(id obj, const CGFloat values[_Nonnull]);

@interface MLAAnimatable : NSObject

/**
 * 可插值的数据类型
 */
@property(nonatomic, strong) NSString *name;

/**
 * 数据读取函数
 */
@property(nonatomic, strong) MLAValueReadBlock readBlock;

/**
 * 数值更新函数
 */
@property(nonatomic, strong) MLAValueWriteBlock writeBlock;

/**
 * 预留值，精度控制
 */
@property(nonatomic, assign) CGFloat threshold;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)animatableWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
