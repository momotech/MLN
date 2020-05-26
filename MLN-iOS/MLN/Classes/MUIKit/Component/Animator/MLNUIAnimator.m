//
//  Animator.m
//  MLNUI
//
//  Created by MoMo on 2019/5/21.
//

#import "MLNUIAnimator.h"
#import "MLNUILuaCore.h"
#import "MLNUIAnimationHandler.h"
#import "MLNUIBlock.h"
#import "MLNUIAnimationConst.h"
#import "MLNUIKitHeader.h"

@interface MLNUIAnimator ()

@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isStarted) BOOL started;
@property (nonatomic, assign) MLNUIAnimationRepeatType repeatMode;
@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, strong) MLNUIBlock *startCallback;
@property (nonatomic, strong) MLNUIBlock *cancelCallback;
@property (nonatomic, strong) MLNUIBlock *endCallback;
@property (nonatomic, strong) MLNUIBlock *repeatCallback;
@property (nonatomic, strong) MLNUIBlock *onUpdateFrameCallback;

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
@implementation MLNUIAnimator

- (void)start
{
    if (self.isRunning) {
        return;
    }
    self.running = YES;
    [[self animationHandler] resume];
    [self setup];
    [[self animationHandler] addCallback:self];
}

- (void)setup
{
    self.startTime = CACurrentMediaTime();
    self.doCount = self.repeatCount;
}

- (void)cancel
{
    if (!self.isRunning) {
        return;
    }
    if (self.cancelCallback) {
        [self.cancelCallback callIfCan];
    }
    [self doAnimationEnd];
}

- (void)end
{
    if (!self.isRunning) {
        return;
    }
    CGFloat percentage = (self.repeatMode == MLNUIAnimationRepeatTypeReverse && self.repeatCount >= 0) ? ((self.repeatCount + 1) % 2): 1.f;
    [self doUpdateFrameWithPercentage:percentage];
    [self doAnimationEnd];
}

- (void)setRepeat:(MLNUIAnimationRepeatType)repeatMode count:(NSInteger)count
{
    self.repeatMode = repeatMode;
    self.repeatCount = count;
    self.doCount = count;
}

- (MLNUIAnimationHandler *)animationHandler
{
    return [MLNUIAnimationHandler sharedHandler];
}

#pragma mark - MLNUIAnimationHandlerCallbackProtocol
- (void)doAnimationFrame:(NSTimeInterval)frameTime
{
    NSTimeInterval durationTime = frameTime - self.startTime - self.delay;
    // 处理延时
    if (durationTime <0) {
        return;
    }
    // 开始动画
    if (!self.isStarted && self.startCallback) {
        self.started = YES;
        [self.startCallback callIfCan];
    }
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
        if (self.repeatCount - self.doCount > 0) {
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
        [MLNUI_KIT_INSTANCE(self.onUpdateFrameCallback.luaCore) requestLayout];
        [CATransaction commit];
    }
}

- (void)doAnimationEnd
{
    self.running = NO;
    self.started = NO;
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
    if (self.repeatMode == MLNUIAnimationRepeatTypeReverse &&
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
    MLNUIAnimator *copyAnimator = [[[self class] allocWithZone:zone] init];
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
LUAUI_EXPORT_BEGIN(MLNUIAnimator)
LUAUI_EXPORT_METHOD(setRepeat, "setRepeat:count:", MLNUIAnimator)
LUAUI_EXPORT_METHOD(setDuration, "setDuration:", MLNUIAnimator)
LUAUI_EXPORT_METHOD(setDelay, "setDelay:", MLNUIAnimator)
LUAUI_EXPORT_METHOD(start, "start", MLNUIAnimator)
LUAUI_EXPORT_METHOD(stop, "end", MLNUIAnimator)
LUAUI_EXPORT_METHOD(cancel, "cancel", MLNUIAnimator)
LUAUI_EXPORT_METHOD(isRunning, "isRunning", MLNUIAnimator)
LUAUI_EXPORT_METHOD(setStartCallback, "setStartCallback:", MLNUIAnimator)
LUAUI_EXPORT_METHOD(setStopCallback, "setEndCallback:", MLNUIAnimator)
LUAUI_EXPORT_METHOD(setRepeatCallback, "setRepeatCallback:", MLNUIAnimator)
LUAUI_EXPORT_METHOD(setCancelCallback, "setCancelCallback:", MLNUIAnimator)
LUAUI_EXPORT_METHOD(setOnAnimationUpdateCallback, "setOnUpdateFrameCallback:", MLNUIAnimator)
LUAUI_EXPORT_METHOD(clone, "copy", MLNUIAnimator)
LUAUI_EXPORT_END(MLNUIAnimator, Animator, NO, NULL, NULL)

@end
