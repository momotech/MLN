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
typedef void(^MLNDeallocatorCallback)(id receiver);

@interface NSObject (MLNKVO)

@property (nonatomic, copy, readonly) NSObject *(^mln_watch)(NSString *keyPath, MLNBlockChange block);

//- (void)mln_observeProperty:(NSString *)keyPath withBlock:(MLNBlockChange)observationBlock;
- (void)mln_observeObject:(id)object property:(NSString *)keyPath withBlock:(MLNBlockChange)observationBlock;

@end

@interface NSObject (MLNDeprecated)
//@property (nonatomic, copy, readonly) NSObject *(^mln_subscribe)(NSString *keyPath, MLNKVOBlock block);
@end

NS_ASSUME_NONNULL_END
