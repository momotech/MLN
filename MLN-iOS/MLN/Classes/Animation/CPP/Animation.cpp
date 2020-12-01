//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include "Animation.h"
#include "RunLoop.h"
#include "MultiAnimation.h"

ANIMATOR_NAMESPACE_BEGIN

const char* Animation::ANIMATION_TYPENAME = "Animation";

Animation::Animation(const AMTString &strName)
: name(strName),
  paused(false),
  active(false),
  finished(false),
  willrepeat(false),
  repeatCount(0),
  didRepeatedCount(0),
  executeCount(1),
  repeatForever(false),
  autoreverses(false),
  beginTime(0.f),
  startTime(0.f),
  lastTime(0.f),
  absoluteBeginTime(0.f),
  pauseBeginTime(0.f),
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

void Animation::SetAutoreverses(AMTBool bAutoReverses) {
    Animation::autoreverses = bAutoReverses;
    Animation::updateAnimationExecuteCount(repeatCount, autoreverses);
}

void Animation::SetRepeatCount(AMTInt count) {
    Animation::repeatCount = count;
    Animation::updateAnimationExecuteCount(repeatCount, autoreverses);
}

void Animation::updateAnimationExecuteCount(AMTInt repeatCount, AMTBool autoreverse) {
    executeCount = 1;
    executeCount += (repeatCount > 0) ? repeatCount : 0;
    executeCount *= autoreverse ? 2 : 1;
}

void Animation::SetBeginTime(AMTTimeInterval beginTime) {
    Animation::beginTime = beginTime;
}

void Animation::SetRepeatForever(AMTBool forever) {
    Animation::repeatForever = forever;
}

void Animation::Pause(AMTBool pause) {
    if (pause == this->paused) {
        return;
    }
    
    paused = pause;
    if (paused) {
        pauseBeginTime = RunLoop::ShareLoop()->CurrentTime();
    } else {
        AMTTimeInterval pasedTime = RunLoop::ShareLoop()->CurrentTime() - pauseBeginTime;
        startTime += pasedTime;
        lastTime += pasedTime;
        absoluteBeginTime += pasedTime;
        pauseBeginTime = 0.f;
    }
    
    if (OnAnimationPauseCallback) {
        OnAnimationPauseCallback(this, pause);
    }
}

void Animation::Reset() {
    active = false;
    startTime = lastTime = 0.f;
    finished = false;
    willrepeat = false;
    didRepeatedCount = 0;
    absoluteBeginTime = RunLoop::ShareLoop()->CurrentTime();
}

void Animation::Start(AMTTimeInterval time) {
    CallAnimationStartCallbackIfNeeded();
}

void Animation::Repeat() {
    if (willrepeat) {
        if (finished && repeatForever) {
            RepeatReset();
        } else if (finished && executeCount > 1) {
            executeCount --;
            RepeatReset();
        }
        willrepeat = false;
        CallAnimationRepeatCallbackIfNeeded(this);
    }
}

void Animation::CallAnimationStartCallbackIfNeeded() {
    if (OnAnimationStartCallback == nullptr) {
        return;
    }
    if (didRepeatedCount == 0) { // 重复执行的动画不应多次回调startBlock
        OnAnimationStartCallback(this);
    }
}

void Animation::CallAnimationRepeatCallbackIfNeeded(Animation *executingAnimation) {
    if (OnAnimationRepeatCallback == nullptr || executingAnimation == nullptr) {
        return;
    }
    executingAnimation->didRepeatedCount++;
    if (executingAnimation->GetAutoreverses()) {
        if (executingAnimation->didRepeatedCount % 2 == 0) {
            OnAnimationRepeatCallback(this, executingAnimation, executingAnimation->didRepeatedCount / 2);
        }
    } else {
        OnAnimationRepeatCallback(this, executingAnimation, executingAnimation->didRepeatedCount);
    }
}

void Animation::Stop() {
    active = false;
    
    if (OnAnimationStopCallback) {
        OnAnimationStopCallback(this, finished);
    }
}

void Animation::StartAnimationIfNeed(AMTTimeInterval time) {
    if (paused || active) {
        return;
    }
    AMTBool start = false;
    
    if (time >= (absoluteBeginTime + beginTime)) {
        active = true;
        startTime = lastTime = (absoluteBeginTime + beginTime);
        start = true;
    }

    if (start) {
        Start(time);
    }
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

void Animation::SetFinish(AMTBool bFinish) {
    finished = bFinish;
}

void Animation::StopAnimationIfFinish() {
    if (!finished) return;
    if (executeCount > 1 || repeatForever) {
        willrepeat = true;
    }
}

void Animation::RepeatReset() {
     paused = false;
     active = false;
     startTime = lastTime = 0.f;
     finished = false;
     absoluteBeginTime = RunLoop::ShareLoop()->CurrentTime();
}

ANIMATOR_NAMESPACE_END
