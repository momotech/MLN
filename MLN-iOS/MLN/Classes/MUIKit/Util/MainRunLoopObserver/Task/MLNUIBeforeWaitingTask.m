//
//  MLNUIAnchorPointTask.m
//  MMLNUIua
//
//  Created by MoMo on 2019/3/19.
//

#import "MLNUIBeforeWaitingTask.h"

@implementation MLNUIBeforeWaitingTask

+ (instancetype)taskWithCallback:(void (^)(void))callabck
{
    MLNUIBeforeWaitingTask *task = [[self alloc] init];
    task.taskCallback = callabck;
    return task;
}

- (void)doTask
{
    if (self.taskCallback) {
        self.taskCallback();
    }
}

@end
