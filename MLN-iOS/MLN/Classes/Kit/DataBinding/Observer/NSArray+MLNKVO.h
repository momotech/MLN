//
//  NSArray+MLNKVO.h
// MLN
//
//  Created by Dai Dongpeng on 2020/3/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MLNItemKVOBlock)(NSObject *item,NSString *keyPath, NSObject * _Nullable oldValue, NSObject * _Nullable newValue);

@interface NSArray (MLNKVO)

// 是否二维数组
- (BOOL)mln_is2D;

- (void)mln_startKVOIfMutable;
- (void)mln_stopKVOIfMutable;

// 监听lua层对Cell ViewModel的改动，支持监听二维数组.
@property (nonatomic, copy, readonly)NSArray * (^mln_subscribeItem)(MLNItemKVOBlock);
@property (nonatomic, strong, readonly) NSMutableArray *mln_itemKVOBlocks;

- (instancetype)mln_convertToLuaTableAvailable;

@end

NS_ASSUME_NONNULL_END
