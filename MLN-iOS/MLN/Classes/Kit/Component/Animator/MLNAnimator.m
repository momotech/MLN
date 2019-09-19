//
//  Animator.m
//  MLN
//
//  Created by MoMo on 2019/5/21.
//

#import "MLNAnimator.h"
#import "MLNLuaCore.h"
#import "MLNAnimationHandler.h"
#import "MLNBlock.h"
#import "MLNAnimationConst.h"
#import "MLNKitHeader.h"

@interface MLNAnimator ()

@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign) MLNAnimationRepeatType repeatMode;
@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, strong) MLNBlock *startCallback;
@property (nonatomic, strong) MLNBlock *cancelCallback;
@property (nonatomic, strong) MLNBlock *endCallback;
@property (nonatomic, strong) MLNBlock *repeatCallback;
@property (nonatomic, strong) MLNBlock *onUpdateFrameCallback;

/**
 当前重复执行了多少个周期
 */
@property (nonatomic, assign) NSInteger doCount;

/**
 开始时间
 */
@property (nonatomic, assign) NSTimeInterval startTime;

/**
 上次执行的时间，用来校准doCount，避免主线程长时间阻塞，导致的doCount不准确
 */
@property (nonatomic, assign) NSTimeInterval lastTime;

@end
@implementation MLNAnimator

- (void)start
{
    if (self.isRunning) {
        MLNLuaError(self.mln_luaCore, @"The animtor is running!");
        return;
    }
    self.running = YES;
    [[self animationHandler] resume];
    [self setup];
    [[self animationHandler] addCallback:self];
    if (self.startCallback) {
        [self.startCallback callIfCan];
    }
}

- (void)setup
{
    self.startTime = CACurrentMediaTime();
    self.doCount = self.repeatCount;
}

- (void)cancel
{
    if (!self.isRunning) {
        if (self.startCallback) {
            [self.startCallback callIfCan];
        }
    }
    [[self animationHandler] removeCallback:self];
    self.running = NO;
    if (self.cancelCallback) {
        [self.cancelCallback callIfCan];
    }
    if (self.endCallback) {
        [self.endCallback callIfCan];
    }
}

- (void)end
{
    if (!self.isRunning) {
        if (self.startCallback) {
            [self.startCallback callIfCan];
        }
    }
    [[self animationHandler] removeCallback:self];
    [self percentageWithCurrentDuration:1.f];
    self.running = NO;
    if (self.endCallback) {
        [self.endCallback callIfCan];
    }
}

- (void)setRepeat:(MLNAnimationRepeatType)repeatMode count:(NSInteger)count
{
    self.repeatMode = repeatMode;
    self.repeatCount = count;
    self.doCount = count;
}

- (MLNAnimationHandler *)animationHandler
{
    return [MLNAnimationHandler sharedHandler];
}

#pragma mark - MLNAnimationHandlerCallbackProtocol
- (void)doAnimationFrame:(NSTimeInterval)frameTime
{
    NSTimeInterval durationTime = frameTime - self.startTime - self.delay;
    // 矫正当前重复次数，避免阻塞时间过长导致的次数记录错误问题
    if (frameTime - self.lastTime >= self.duration) {
        self.doCount = (NSInteger)(durationTime *1000) / (NSInteger)(self.duration *1000);
    }
    self.lastTime = frameTime;
    NSTimeInterval d = durationTime - self.doCount * self.duration;
    float p = [self percentageWithCurrentDuration:d];
    if (d >= self.duration) {
        // 完成一次动画周期
        [self doUpdateFrameWithPercentage:p];
        // -1 为无限循环
        if (self.repeatCount <= -1) {
            [self doAnimationRepeat];
            return;
        }
        // 剩余次数大于零，则表示还未结束，重复动画
        NSInteger remainCount = self.repeatCount - self.doCount;
        if (remainCount > 0) {
            [self doAnimationRepeat];
            return;
        }
        // 剩余次数不大于零，则表示动画应该结束
        [self doAnimationEnd];
    } else {
        [self doUpdateFrameWithPercentage: p];
    }
}

- (void)doUpdateFrameWithPercentage:(float)percentage
{
    if (self.onUpdateFrameCallback) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.onUpdateFrameCallback addFloatArgument:percentage];
        [self.onUpdateFrameCallback callIfCan];
        // 重新布局当前界面，以支持动画
        [MLN_KIT_INSTANCE(self.onUpdateFrameCallback.luaCore) requestLayout];
        [CATransaction commit];
    }
}

- (void)doAnimationEnd
{
    self.running = NO;
    [[self animationHandler] removeCallback:self];
    if (self.endCallback) {
        [self.endCallback callIfCan];
    }
}

- (void)doAnimationRepeat
{
    self.doCount++;
    if (self.repeatCallback) {
        [self.repeatCallback callIfCan];
    }
}

- (float)percentageWithCurrentDuration:(NSTimeInterval)duration
{
    if (self.repeatMode == MLNAnimationRepeatTypeREVERSE &&
        self.doCount % 2 == 1) {
        if (duration >= self.duration) {
            return 0.f;
        } else {
            return 1.f - (float)(duration / self.duration);
        }
    }
    if (duration >= self.duration) {
        return 1.f;
    }
    return duration / self.duration;
}

#pragma mark - Lifecycle
- (id)copyWithZone:(NSZone *)zone
{
    MLNAnimator *copyAnimator = [[[self class] allocWithZone:zone] init];
    copyAnimator.repeatMode = self.repeatMode;
    copyAnimator.repeatCount = self.repeatCount;
    copyAnimator.duration = self.duration;
    copyAnimator.delay = self.delay;
    return copyAnimator;
}

- (void)dealloc4Lua
{
    [self cancel];
}

#pragma mark - Export To Lua
LUA_EXPORT_BEGIN(MLNAnimator)
LUA_EXPORT_METHOD(setRepeat, "setRepeat:count:", MLNAnimator)
LUA_EXPORT_METHOD(setDuration, "setDuration:", MLNAnimator)
LUA_EXPORT_METHOD(setDelay, "setDelay:", MLNAnimator)
LUA_EXPORT_METHOD(start, "start", MLNAnimator)
LUA_EXPORT_METHOD(stop, "end", MLNAnimator)
LUA_EXPORT_METHOD(cancel, "cancel", MLNAnimator)
LUA_EXPORT_METHOD(isRunning, "isRunning", MLNAnimator)
LUA_EXPORT_METHOD(setStartCallback, "setStartCallback:", MLNAnimator)
LUA_EXPORT_METHOD(setStopCallback, "setEndCallback:", MLNAnimator)
LUA_EXPORT_METHOD(setRepeatCallback, "setRepeatCallback:", MLNAnimator)
LUA_EXPORT_METHOD(setCancelCallback, "setCancelCallback:", MLNAnimator)
LUA_EXPORT_METHOD(setOnAnimationUpdateCallback, "setOnUpdateFrameCallback:", MLNAnimator)
LUA_EXPORT_METHOD(clone, "copy", MLNAnimator)
LUA_EXPORT_END(MLNAnimator, Animator, NO, NULL, NULL)

@end
