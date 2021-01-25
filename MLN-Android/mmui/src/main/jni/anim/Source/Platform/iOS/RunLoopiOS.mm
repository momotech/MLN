//
// Created by momo783 on 2020/5/15.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#include "RunLoop.h"

#ifdef ANIMATOR_PLATFORM_IOS

#if TARGET_IPHONE_SIMULATOR
#include <UIKit/UIKit.h>

static CFTimeInterval kSlowMotionAccumulator;
static CFTimeInterval kSlowMotionStartTime;
static CFTimeInterval kSlowMotionLastTime;

UIKIT_EXTERN float UIAnimationDragCoefficient(); // UIKit private drag coefficient, use judiciously

#endif
static CADisplayLink* loopDisplayLink;

@interface AnimatorRunLoop : NSObject

+ (void)startDislpayLink;

+ (void)pauseDisplayLink;

+ (void)stopDisplayLink;

@end

@implementation AnimatorRunLoop

+ (void)startDislpayLink
{
    dispatch_block_t block = ^() {
        if (!loopDisplayLink) {
            loopDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
            [loopDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
        if (loopDisplayLink.paused) {
            loopDisplayLink.paused = NO;
        }
    };
    if ([NSThread currentThread].isMainThread) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

+ (void)pauseDisplayLink
{
    if (loopDisplayLink) {
        loopDisplayLink.paused = YES;
    }
}

+ (void)stopDisplayLink
{
    [self pauseDisplayLink];
    loopDisplayLink = NULL;
}

+ (void)render {
    ANIMATOR_NAMESPACE::RunLoop *loop = ANIMATOR_NAMESPACE::RunLoop::ShareLoop();
    if (loop->LoopCallback && loop->IsRunning()) {
        loop->LoopCallback([self currentTime]);
    }
}

+ (CFTimeInterval)currentTime {
    CFTimeInterval time = CACurrentMediaTime();
#if TARGET_IPHONE_SIMULATOR
    // support slow-motion animations
    time += kSlowMotionAccumulator;
    float f = UIAnimationDragCoefficient();

    if (f > 1.0) {
        if (!kSlowMotionStartTime) {
            kSlowMotionStartTime = time;
        } else {
            time = (time - kSlowMotionStartTime) / f + kSlowMotionStartTime;
            kSlowMotionLastTime = time;
        }
    } else if (kSlowMotionStartTime) {
        CFTimeInterval dt = (kSlowMotionLastTime - time);
        time += dt;
        kSlowMotionAccumulator += dt;
        kSlowMotionStartTime = 0;
    }
#endif
    return time;
}

@end

ANIMATOR_NAMESPACE_BEGIN

AMTTimeInterval RunLoop::CurrentTime() {
    return [AnimatorRunLoop currentTime];
}

void RunLoop::StartLoop() {
    [AnimatorRunLoop startDislpayLink];
    running = true;
}

void RunLoop::StopLoop() {
    [AnimatorRunLoop pauseDisplayLink];
    running = false;
}

void RunLoop::DestoryShareLoop() {
    [AnimatorRunLoop stopDisplayLink];
}

ANIMATOR_NAMESPACE_END

#endif
