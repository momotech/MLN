//
//  NSObject+MLNDealloctor.h
//  MLN
//
//  Created by Dai Dongpeng on 2020/4/30.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MLNDeallocatorCallback)(id receiver);

@interface NSObject (MLNDealloctor)
- (void)mln_addDeallocationCallback:(MLNDeallocatorCallback)block;
@end

NS_ASSUME_NONNULL_END
