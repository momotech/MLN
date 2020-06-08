//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include "Animation.h"
#include "RunLoop.h"

ANIMATOR_NAMESPACE_BEGIN

const char* Animation::ANIMATION_TYPENAME = "Animation";

Animation::Animation(const AMTString &name)
: name(name),
  paused(true),
  active(false),
  finished(false),
  repeatCount(1),
  realRepeatCount(1),
  repeatForever(false),
  autoreverses(false),
  beginTime(0.f),
  startTime(0.f),
  lastTime(0.f),
  absoluteBeginTime(0.f),
  tracer(nullptr),
  OnAnimationStartCallback(nullptr),
  OnAnimationStopCallback(nullptr),
  OnAnimationRepeatCallback(nullptr),
  OnAnimationPauseCallback(nullptr) {

}

Animation::~Animation() {
    ANIMATOR_SAFE_DELETE(tracer);
}

const AnimationTracer &Animation::GetTracer() {
    if (tracer == nullptr) {
        tracer = new AnimationTracer();
    }
    return reinterpret_cast<const AnimationTracer &>(tracer);
}

void Animation::SetAutoreverses(AMTBool autoreverses) {
    Animation::autoreverses = autoreverses;
    if (autoreverses) {
        realRepeatCount = 2 * repeatCount;
    } else {
        realRepeatCount = repeatCount;
    }
}

void Animation::Pause(AMTBool pause) {
    paused = pause;
    if (OnAnimationPauseCallback) {
        OnAnimationPauseCallback(this, pause);
    }
}

void Animation::Reset() {
     paused = true;
     active = false;
     startTime = lastTime = 0.f;
     finished = false;
     if (autoreverses) {
         realRepeatCount = 2 * repeatCount;
     } else {
         realRepeatCount = repeatCount;
     }
     absoluteBeginTime = RunLoop::ShareLoop()->CurrentTime();
}

void Animation::Start() {
    if (OnAnimationStartCallback) {
        OnAnimationStartCallback(this);
    }
}

void Animation::Repeat() {
    if (OnAnimationRepeatCallback) {
        OnAnimationRepeatCallback(this, realRepeatCount);
    }
}

void Animation::Stop() {
    if (OnAnimationStopCallback) {
        OnAnimationStopCallback(this, finished);
    }
    active = false;
}

void Animation::StartAnimationIfNeed(AMTTimeInterval time) {
    AMTBool start = false;

    if (startTime == 0.f && time >= (absoluteBeginTime + beginTime)) {
        active = true;
        paused = false;
        startTime = lastTime = (absoluteBeginTime + beginTime);
        start = true;
    }

    if (start) Start();
}

void Animation::TickTime(AMTTimeInterval time) {
    // 1、开始动画时间间隔计算
    AMTTimeInterval interval = time - lastTime;
    AMTTimeInterval processInterval = time - startTime;
    // 2、Tick Time
    Tick(time, interval, processInterval);
    // 3、update lastTime
    Animation::lastTime = time;
}

void Animation::Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) {
    // 更新相关数据，扩展类实现自己的数值计算算法
}

void Animation::StopAnimationIfFinish() {

    if (finished && realRepeatCount == 1 && !repeatForever) {
        //Stop();
    } else {
        if (finished && realRepeatCount > 1) {
            realRepeatCount --;
            Repeat(); // 扩展类实现自己的重复逻辑
            InnerReset();
        } else if (finished && repeatForever) {
            Repeat(); // 扩展类实现自己的重复逻辑
            InnerReset();
        }
    }
    
}

void Animation::InnerReset() {
     paused = true;
     active = false;
     startTime = lastTime = 0.f;
     finished = false;
     absoluteBeginTime = RunLoop::ShareLoop()->CurrentTime();
}

ANIMATOR_NAMESPACE_END
