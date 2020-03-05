//
//  MLNBlockObserver.h
//  AFNetworking
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNKVOObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNBlockObserver : MLNKVOObserver

@property (nonatomic, strong, readonly) MLNBlock *block;

+ (instancetype)observerWithBlock:(MLNBlock *)block keyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
