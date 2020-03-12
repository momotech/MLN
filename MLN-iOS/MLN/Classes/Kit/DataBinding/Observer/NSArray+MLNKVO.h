//
//  NSArray+MLNKVO.h
// MLN
//
//  Created by Dai Dongpeng on 2020/3/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (MLNKVO)

@property (nonatomic, copy)NSString *(^mln_resueIdBlock)(NSArray *items, NSUInteger section, NSUInteger row);

// AutoFitAdaper 会自动计算行高，所以不需要.
@property (nonatomic, copy, nullable)NSUInteger(^mln_heightBlock)(NSArray *items, NSUInteger section, NSUInteger row);

// 是否二维数组
- (BOOL)mln_is2D;
@end

NS_ASSUME_NONNULL_END
