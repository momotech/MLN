//
//  MLNUITimer.m
//  MMDebugTools-DebugManager
//
//  Created by MoMo on 2018/7/4.
//

#import "MLNUITimer.h"
#import "MLNUILuaCore.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"

typedef enum : NSUInteger {
    MLNUITimerStatusIdle = 0,
    MLNUITimerStatusRunning,
    MLNUITimerStatusPause,
} MLNUITimerStatus;

@interface MLNUITimer()

@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, assign) NSUInteger repeatCount;
@property (nonatomic, assign) NSUInteger timeOfTriggers;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) MLNUITimerStatus status;
@property (nonatomic, strong) MLNUIBlock *triggerHandler;

@end

@implementation MLNUITimer

- (void)mln_user_data_dealloc
{
    [self stop];
    [super mln_user_data_dealloc];
}

- (void)startWithCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    if (!self.isIdle) {
        return;
    }
    self.triggerHandler = callback;
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    self.status = MLNUITimerStatusRunning;
}

- (void)stop
{
    [self.timer invalidate];
    self.timer = nil;
    self.timeOfTriggers = 0;
    self.status = MLNUITimerStatusIdle;
}

- (void)pause
{
    if (!self.isRunning) {
        return;
    }
    [self.timer setFireDate:[NSDate distantFuture]];
    self.status = MLNUITimerStatusPause;
}

- (void)resume
{
    if (!self.isPause) {
        return;
    }
    [self.timer setFireDate:[NSDate date]];
    self.status = MLNUITimerStatusRunning;
}

- (void)resumeDelay
{
    if (!self.isPause) {
        return;
    }
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.interval]];
    self.status = MLNUITimerStatusRunning;
}

- (void)setRepeatCount:(NSUInteger)repeatCount
{
    _repeatCount = repeatCount < 0 ? 0 : repeatCount;
}

- (BOOL)isIdle
{
    return self.status == MLNUITimerStatusIdle;
}

- (BOOL)isRunning
{
    return self.status == MLNUITimerStatusRunning;
}

- (BOOL)isPause
{
    return self.status == MLNUITimerStatusPause;
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
LUA_EXPORT_BEGIN(MLNUITimer)
LUA_EXPORT_PROPERTY(interval, "setInterval:", "interval", MLNUITimer)
LUA_EXPORT_PROPERTY(repeatCount, "setRepeatCount:", "repeatCount", MLNUITimer)
LUA_EXPORT_METHOD(start, "startWithCallback:", MLNUITimer)
LUA_EXPORT_METHOD(pause, "pause", MLNUITimer)
LUA_EXPORT_METHOD(resume, "resume", MLNUITimer)
LUA_EXPORT_METHOD(resumeDelay, "resumeDelay", MLNUITimer)
LUA_EXPORT_METHOD(stop, "stop", MLNUITimer)
LUA_EXPORT_END(MLNUITimer, Timer, NO, NULL, NULL)

@end
