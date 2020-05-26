//
//  MLNUIBlockObserver.h
// MLNUI
//
//  Created by Dai Dongpeng on 2020/3/3.
//

#import "MLNUIKVOObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIBlockObserver : MLNUIKVOObserver

@property (nonatomic, strong, readonly) MLNUIBlock *block;

+ (instancetype)observerWithBlock:(MLNUIBlock *)block keyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
