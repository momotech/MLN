//
//  NSObject+MLNKVO.h
//  MLN
//
//  Created by Dai Dongpeng on 2020/4/29.
//
#import <Foundation/Foundation.h>
#import "MLNObserver.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MLNKVOBlock)(id oldValue, id newValue);

@interface NSObject (MLNKVO)

@property (nonatomic, copy, readonly) NSObject *(^mln_watch)(NSString *keyPath, MLNKVOBlock block);

- (void)mln_observeObject:(id)object property:(NSString *)keyPath withBlock:(MLNBlockChange)observationBlock;
- (void)mln_observeObject:(id)object properties:(NSArray <NSString *> *)keyPaths withBlock:(MLNBlockChangeMany)observationBlock;

- (void)mln_removeObervationsForOwner:(id)owner keyPath:(NSString *)keyPath;
- (void)mln_removeAllObservations;

@end

@interface NSObject (MLNArrayKVO)

- (void)mln_observeArray:(NSMutableArray *)array withBlock:(MLNBlockChange)observationBlock;
- (void)mln_removeArrayObervationsForOwner:(id)owner;
@end

@interface NSObject (MLNDeprecated)
@property (nonatomic, copy, readonly) NSObject *(^mln_subscribe)(NSString *keyPath, MLNKVOBlock block);
@end

NS_ASSUME_NONNULL_END
