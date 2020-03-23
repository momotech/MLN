//
//  NSArray+MLNKVO.h
// MLN
//
//  Created by Dai Dongpeng on 2020/3/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (MLNKVO)

// 是否二维数组
- (BOOL)mln_is2D;

- (void)mln_startKVOIfMutableble;

@end

NS_ASSUME_NONNULL_END
