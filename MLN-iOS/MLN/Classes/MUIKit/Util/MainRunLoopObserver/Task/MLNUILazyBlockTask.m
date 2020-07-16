//
//  MLNUILazyBlockTask.m
//  ArgoUI
//
//  Created by Dongpeng Dai on 2020/7/6.
//

#import "MLNUILazyBlockTask.h"

@interface MLNUILazyBlockTask ()
@property (nonatomic, strong) NSValue *taskID;
@end

@implementation MLNUILazyBlockTask

+ (instancetype)taskWithCallback:(void (^)(void))callabck taskID:(NSValue *)taskID {
    MLNUILazyBlockTask *task = [self taskWithCallback:callabck];
    task.taskID = taskID;
    return task;;
}

- (BOOL)isEqual:(MLNUILazyBlockTask *)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[MLNUILazyBlockTask class]]) {
        return NO;
    }
    if ([self.taskID isEqual:object.taskID]) {
        return YES;
    }
    return NO;
}
@end
