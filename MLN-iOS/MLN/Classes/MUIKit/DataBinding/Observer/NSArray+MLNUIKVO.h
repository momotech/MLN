//
//  NSArray+MLNUIKVO.h
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class ArgoObservableArray;
typedef void (^MLNUIItemKVOBlock)(NSObject *item,NSString *keyPath, NSObject * _Nullable oldValue, NSObject * _Nullable newValue);

@interface NSArray (MLNUIKVO)

// 是否二维数组
- (BOOL)mlnui_is2D;

- (void)mlnui_startKVOIfMutable;
- (void)mlnui_stopKVOIfMutable;

// 监听lua层对Cell ViewModel的改动，支持监听二维数组.
//@property (nonatomic, copy, readonly)NSArray * (^mlnui_subscribeItem)(MLNUIItemKVOBlock);
//@property (nonatomic, strong, readonly) NSMutableArray *mlnui_itemKVOBlocks;

- (NSArray *)mlnui_convertToLuaTableAvailable;
- (NSMutableArray *)mlnui_convertToMArray;

- (ArgoObservableArray *)argo_mutableCopy;

@end

NS_ASSUME_NONNULL_END
