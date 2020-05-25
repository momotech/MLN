//
//  NSObject+MLNUIKVO.h
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/29.
//
#import <Foundation/Foundation.h>
#import "MLNUIObserver.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MLNUIKVOBlock)(id oldValue, id newValue, id observedObject);

@interface NSObject (MLNUIKVO)

@property (nonatomic, copy, readonly) NSObject *(^mlnui_watch)(NSString *keyPath, MLNUIKVOBlock block);

- (void)mlnui_observeObject:(id)object property:(NSString *)keyPath withBlock:(MLNUIBlockChange)observationBlock;
- (void)mlnui_observeObject:(id)object properties:(NSArray <NSString *> *)keyPaths withBlock:(MLNUIBlockChangeMany)observationBlock;

- (void)mlnui_removeObervationsForOwner:(id)owner keyPath:(NSString *)keyPath;
- (void)mlnui_removeAllObservations;

@end

@interface NSObject (MLNUIArrayKVO)

- (void)mlnui_observeArray:(NSMutableArray *)array withBlock:(MLNUIBlockChange)observationBlock;
- (void)mlnui_removeArrayObervationsForOwner:(id)owner;
@end

@interface NSObject (MLNUIDeprecated)
@property (nonatomic, copy, readonly) NSObject *(^mlnui_subscribe)(NSString *keyPath, MLNUIKVOBlock block);
@end

NS_ASSUME_NONNULL_END
