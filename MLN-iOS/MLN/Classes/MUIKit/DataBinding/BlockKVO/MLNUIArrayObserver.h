//
//  MLNUIArrayObserver.h
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/30.
//

#import "MLNUIObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIArrayObserver : MLNUIObserver

- (instancetype)initWithTarget:(NSMutableArray *)target keyPath:(NSString *)keyPath owner:(id)owner;

@end

NS_ASSUME_NONNULL_END
