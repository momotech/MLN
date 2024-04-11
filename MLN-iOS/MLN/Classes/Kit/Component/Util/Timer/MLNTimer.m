//
//  MLNTimer.m
//  MMDebugTools-DebugManager
//
//  Created by MoMo on 2018/7/4.
//

#import "MLNTimer.h"
#import "MLNLuaCore.h"
#import "MLNBlock.h"
#import "MLNKitHeader.h"

typedef enum : NSUInteger {
    MLNTimerStatusIdle = 0,
    MLNTimerStatusRunning,
    MLNTimerStatusPause,
} MLNTimerStatus;

@interface MLNTimer()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, assign) NSUInteger repeatCount;
@property (nonatomic, assign) NSUInteger timeOfTriggers;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) MLNTimerStatus status;
@property (nonatomic, strong) MLNBlock *triggerHandler;

@end

@implementation MLNTimer

- (void)mln_user_data_dealloc
{
    [self stop];
    [super mln_user_data_dealloc];
}

- (void)startWithCallback:(MLNBlock *)callback
{
    MLNCheckTypeAndNilValue(callback, @"function", MLNBlock);
    if (!self.isIdle) {
        return;
    }
    self.triggerHandler = callback;
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    self.status = MLNTimerStatusRunning;
}

- (void)stop
{
    [self.timer invalidate];
    self.timer = nil;
    self.timeOfTriggers = 0;
    self.status = MLNTimerStatusIdle;
}

- (void)pause
{
    if (!self.isRunning) {
        return;
    }
    [self.timer setFireDate:[NSDate distantFuture]];
    self.status = MLNTimerStatusPause;
}

- (void)resume
{
    if (!self.isPause) {
        return;
    }
    [self.timer setFireDate:[NSDate date]];
    self.status = MLNTimerStatusRunning;
}

- (void)resumeDelay
{
    if (!self.isPause) {
        return;
    }
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.interval]];
    self.status = MLNTimerStatusRunning;
}

- (void)setRepeatCount:(NSUInteger)repeatCount
{
    _repeatCount = repeatCount < 0 ? 0 : repeatCount;
}

- (BOOL)isIdle
{
    return self.status == MLNTimerStatusIdle;
}

- (BOOL)isRunning
{
    return self.status == MLNTimerStatusRunning;
}

- (BOOL)isPause
{
    return self.status == MLNTimerStatusPause;
}

- (BOOL)isCompleted
{
    return self.timeOfTriggers == self.repeatCount;
}

#pragma mark - Fire
- (void)_internal_triggerCallback
{
    self.timeOfTriggers++;
    [self triggerLuaCallback];
    [self checkTimeOfTriggers];
}

- (void)checkTimeOfTriggers
{
    if (self.isCompleted) {
        [self stop];
    }
}

- (void)triggerLuaCallback
{
    if (self.triggerHandler) {
        [self.triggerHandler addBOOLArgument:self.isCompleted];
        [self.triggerHandler callIfCan];
    }
}

#pragma mark - Getter
- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:self.interval target:self selector:@selector(_internal_triggerCallback) userInfo:nil repeats:YES];
    }
    return _timer;
}

#pragma mark - Export For Lua
LUA_EXPORT_BEGIN(MLNTimer)
LUA_EXPORT_PROPERTY(interval, "setInterval:", "interval", MLNTimer)
LUA_EXPORT_PROPERTY(repeatCount, "setRepeatCount:", "repeatCount", MLNTimer)
LUA_EXPORT_METHOD(start, "startWithCallback:", MLNTimer)
LUA_EXPORT_METHOD(pause, "pause", MLNTimer)
LUA_EXPORT_METHOD(resume, "resume", MLNTimer)
LUA_EXPORT_METHOD(resumeDelay, "resumeDelay", MLNTimer)
LUA_EXPORT_METHOD(stop, "stop", MLNTimer)
LUA_EXPORT_END(MLNTimer, Timer, NO, NULL, NULL)

@end
