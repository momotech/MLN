//
//  MLNUILazyBlockTask.h
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/7/6.
//

#import "MLNUIBeforeWaitingTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLNUILazyBlockTask : MLNUIBeforeWaitingTask

+ (instancetype)taskWithCallback:(void(^)(void))callabck taskID:(NSValue *)taskID;

@end

NS_ASSUME_NONNULL_END
