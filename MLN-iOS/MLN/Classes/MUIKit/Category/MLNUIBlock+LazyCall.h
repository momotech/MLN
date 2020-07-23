//
//  MLNUIBlock+LazyCall.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/7/20.
//

#import "MLNUIBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUIBlock (LazyCall)

- (void)lazyCallIfCan:(void(^ __nullable)(id))completionBlock;

@end

NS_ASSUME_NONNULL_END
