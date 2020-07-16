//
//  MLNUIBeforeWaitingTaskEngine.m
//  MMLNUIua
//
//  Created by MoMo on 2019/3/19.
//

#import "MLNUIBeforeWaitingTaskEngine.h"
#import "MLNUIMainRunLoopObserver.h"
#import "MLNUIBeforeWaitingTaskProtocol.h"

@interface MLNUIBeforeWaitingTaskEngine ()

@property (nonatomic, strong) NSMutableArray *taskQueue;
@property (nonatomic, strong) MLNUIMainRunLoopObserver *mainLoopObserver;
@property (nonatomic, assign) CFIndex order;

@end
@implementation MLNUIBeforeWaitingTaskEngine

- (instancetype)initWithLuaInstance:(MLNUIKitInstance *)luaInstance order:(CFIndex)order
{
    if (self = [super init]) {
        _luaInstance = luaInstance;
        _order = order;
    }
    return self;
}

- (void)start
{
    if (!self.mainLoopObserver) {
        self.mainLoopObserver = [[MLNUIMainRunLoopObserver alloc] init];
        [self.mainLoopObserver beginForBeforeWaiting:self.order repeats:YES callback:^{
            [self doTasks];
        }];
    }
}

- (void)end
{
    [self clearAll];
    [self.mainLoopObserver end];
}

- (void)pushTask:(id<MLNUIBeforeWaitingTaskProtocol>)task
{
    if (![self.taskQueue containsObject:task]) {
        [self.taskQueue addObject:task];
    }
}

- (void)forcePushTask:(id<MLNUIBeforeWaitingTaskProtocol>)task {
    NSUInteger index = [self.taskQueue indexOfObject:task];
    if (index == NSNotFound) {
        [self.taskQueue addObject:task];
    } else {
        [self.taskQueue replaceObjectAtIndex:index withObject:task];
    }
}

- (void)popTask:(id<MLNUIBeforeWaitingTaskProtocol>)task
{
    [_taskQueue removeObject:task];
}

- (void)clearAll
{
    [_taskQueue removeAllObjects];
}

#pragma mark - Do Animations
- (void)doTasks
{
    if (!_taskQueue || _taskQueue.count <= 0) {
        return;
    }
    NSArray<id<MLNUIBeforeWaitingTaskProtocol>> *taskQueueTmp = [_taskQueue copy];
    [self clearAll];
    for (id<MLNUIBeforeWaitingTaskProtocol> animation in taskQueueTmp) {
        [animation doTask];
    }
}

#pragma mark - Getter
- (NSMutableArray *)taskQueue
{
    if (!_taskQueue) {
        _taskQueue = [NSMutableArray array];
    }
    return _taskQueue;
}

@end
