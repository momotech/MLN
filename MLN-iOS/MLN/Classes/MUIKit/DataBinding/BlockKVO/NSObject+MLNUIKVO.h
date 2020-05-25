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

@property (nonatomic, copy, readonly) NSObject *(^mln_watch)(NSString *keyPath, MLNUIKVOBlock block);

- (void)mln_observeObject:(id)object property:(NSString *)keyPath withBlock:(MLNUIBlockChange)observationBlock;
- (void)mln_observeObject:(id)object properties:(NSArray <NSString *> *)keyPaths withBlock:(MLNUIBlockChangeMany)observationBlock;

- (void)mln_removeObervationsForOwner:(id)owner keyPath:(NSString *)keyPath;
- (void)mln_removeAllObservations;

@end

@interface NSObject (MLNUIArrayKVO)

- (void)mln_observeArray:(NSMutableArray *)array withBlock:(MLNUIBlockChange)observationBlock;
- (void)mln_removeArrayObervationsForOwner:(id)owner;
@end

@interface NSObject (MLNUIDeprecated)
@property (nonatomic, copy, readonly) NSObject *(^mln_subscribe)(NSString *keyPath, MLNUIKVOBlock block);
@end

NS_ASSUME_NONNULL_END
