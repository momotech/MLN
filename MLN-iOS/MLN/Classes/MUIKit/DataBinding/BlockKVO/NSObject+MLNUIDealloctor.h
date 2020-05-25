//
//  NSObject+MLNUIDealloctor.h
//  MLNUI
//
//  Created by Dai Dongpeng on 2020/4/30.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MLNUIDeallocatorCallback)(id receiver);

@interface NSObject (MLNUIDealloctor)
- (void)mlnui_addDeallocationCallback:(MLNUIDeallocatorCallback)block;
@end

NS_ASSUME_NONNULL_END
