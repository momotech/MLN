//
//  MLNArrayObserver.h
//  MLN
//
//  Created by Dai Dongpeng on 2020/4/30.
//

#import "MLNObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNArrayObserver : MLNObserver

- (instancetype)initWithTarget:(NSMutableArray *)target keyPath:(NSString *)keyPath owner:(id)owner;

@end

NS_ASSUME_NONNULL_END
