//
//  MLNAnchorPointTask.m
//  MMLNua
//
//  Created by MoMo on 2019/3/19.
//

#import "MLNBeforeWaitingTask.h"
#import "MLNLayoutNode.h"

@implementation MLNBeforeWaitingTask

+ (instancetype)taskWithCallback:(void (^)(void))callabck
{
    MLNBeforeWaitingTask *task = [[MLNBeforeWaitingTask alloc] init];
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
