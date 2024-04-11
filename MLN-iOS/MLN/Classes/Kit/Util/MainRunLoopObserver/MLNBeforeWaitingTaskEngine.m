//
//  MLNBeforeWaitingTaskEngine.m
//  MMLNua
//
//  Created by MoMo on 2019/3/19.
//

#import "MLNBeforeWaitingTaskEngine.h"
#import "MLNMainRunLoopObserver.h"
#import "MLNBeforeWaitingTaskProtocol.h"

@interface MLNBeforeWaitingTaskEngine ()

@property (nonatomic, strong) NSMutableArray *taskQueue;
@property (nonatomic, strong) MLNMainRunLoopObserver *mainLoopObserver;
@property (nonatomic, assign) CFIndex order;

@end
@implementation MLNBeforeWaitingTaskEngine

- (instancetype)initWithLuaInstance:(MLNKitInstance *)luaInstance order:(CFIndex)order
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
        self.mainLoopObserver = [[MLNMainRunLoopObserver alloc] init];
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

- (void)pushTask:(id<MLNBeforeWaitingTaskProtocol>)task
{
    if (![self.taskQueue containsObject:task]) {
        [self.taskQueue addObject:task];
    }
}

- (void)popTask:(id<MLNBeforeWaitingTaskProtocol>)task
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
    NSArray<id<MLNBeforeWaitingTaskProtocol>> *taskQueueTmp = [_taskQueue copy];
    [self clearAll];
    for (id<MLNBeforeWaitingTaskProtocol> animation in taskQueueTmp) {
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
