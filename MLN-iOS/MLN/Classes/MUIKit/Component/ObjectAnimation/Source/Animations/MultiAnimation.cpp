//
// Created by momo783 on 2020/5/22.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#include "MultiAnimation.h"
#include "RunLoop.h"

ANIMATOR_NAMESPACE_BEGIN

const char* MultiAnimation::ANIMATION_TYPENAME = "MultiAnimation";

MultiAnimation::MultiAnimation(const AMTString &strName)
:
Animation(strName),
runningType(Together),
didSetAutoReverse(false),
didSetRepeatCount(false),
didSetRepeatForever(false) {

}

MultiAnimation::~MultiAnimation() {
    if (animationList.size()) {
        animationList.clear();
    }
}

void MultiAnimation::RunTogether(MultiAnimationList list) {
    animationList = list;
    runningType = Together;
}

void MultiAnimation::RunSequentially(MultiAnimationList list) {
    animationList = list;
    runningType = Sequentially;
}

void MultiAnimation::Reset() {
    Animation::Reset();
    ClearSubAnimationSettingsIfNeeded();
    
    ResetSubAnimation();
}

void MultiAnimation::RepeatReset() {
    Animation::RepeatReset();
    
    StartAddRunningAnimation(RunLoop::ShareLoop()->CurrentTime());
}

void MultiAnimation::ResetSubAnimation() {
    for (int i = 0; i < animationList.size(); i++) {
        Animation* animation = animationList[i];
        animation->Reset();
    }
}

void MultiAnimation::StartAddRunningAnimation(AMTTimeInterval time) {
    runningAnimationList.clear();
    finishAnimationList.clear();
    
    for (int i = 0; i < animationList.size(); i++) {
        Animation* animation = animationList[i];
        
        animation->OnAnimationStopCallback = [this] (Animation* animation1, AMTBool finish) {
            this->finishAnimationList.push_back(animation1);
        };
        if (runningType == Together) {
            runningAnimationList.push_back(animation);
        } else {
            if (i == 0) {
                runningAnimationList.push_back(animation);
            }
        }
    }
}

void MultiAnimation::Pause(AMTBool pause) {
    if (animationList.size()) {
        for (int i = 0; i < animationList.size(); i++) {
            Animation* animation = animationList[i];
            animation->Pause(pause);
        }
    }
    Animation::Pause(pause);
}

void MultiAnimation::Start(AMTTimeInterval time) {
    Animation::Start(time);
    StartAddRunningAnimation(time);
}

void MultiAnimation::Repeat() {
    Animation::Repeat();
}

void MultiAnimation::Stop() {
    Animation::Stop();
}

void MultiAnimation::Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) {
    Animation::Tick(time, timeInterval, timeProcess);

    if (animationList.size() == 0) {
        Animation::SetFinish(true);
    }

    if (runningType == Together) {
        for (auto animation : animationList) {
            if (animation->finished) {
                MultiAnimationList::iterator i = runningAnimationList.begin();
                for (; i != runningAnimationList.end(); i++) {
                    auto running = *i;
                    if (running == animation) {
                        runningAnimationList.erase(i);
                        break;
                    }
                }
                continue;
            }
            animation->StartAnimationIfNeed(time);
            if (animation->active && !animation->paused) {
                animation->TickTime(time);
                animation->StopAnimationIfFinish();
                if (animation->finished) {
                    if (animation->willrepeat) {
                        animation->Repeat();
                        CallAnimationRepeatCallbackIfNeeded(animation);
                    } else {
                        animation->Stop();
                    }
                }
            }
        }
    } else {
        Animation *animation = animationList[finishAnimationList.size()];
        if (animation) {
            if (runningAnimationList.size() == 0 || runningAnimationList[0] != animation) {
                runningAnimationList.clear();
                runningAnimationList.push_back(animation);
            }
            animation->StartAnimationIfNeed(time);
            if (animation->active && !animation->paused) {
                animation->TickTime(time);
                animation->StopAnimationIfFinish();
                
                if (animation->finished) {
                    if (animation->willrepeat) {
                        animation->Repeat();
                        CallAnimationRepeatCallbackIfNeeded(animation);
                    } else {
                        animation->Stop();
                        if (finishAnimationList.size() < animationList.size()) {
                            auto animation01 = animationList[finishAnimationList.size()];
                            animation01->Reset();
                        }
                    }
                }
            }
        }
    }
    
    if (finishAnimationList.size() && finishAnimationList.size() == animationList.size()) {
        Animation::SetFinish(true);
    }
}

void MultiAnimation::SetRepeatForever(AMTBool forever) {
    repeatForever = forever;
    didSetRepeatForever = true;
}

void MultiAnimation::SetRepeatCount(AMTInt count) {
    repeatCount = count;
    didSetRepeatCount = true;
}

void MultiAnimation::SetAutoreverses(AMTBool reverse) {
    autoreverses = reverse;
    didSetAutoReverse = true;
}

void MultiAnimation::SetBeginTime(AMTTimeInterval time) {
    beginTime = time;
    didSetBeginTime = true;
}

void MultiAnimation::ClearSubAnimationSettingsIfNeeded() {
    for (int i = 0; i < animationList.size(); i++) {
        Animation* animation = animationList[i];
        if (didSetRepeatCount) {
            animation->SetRepeatCount(repeatCount);
        }
        if (didSetRepeatForever) {
            animation->SetRepeatForever(repeatForever);
        }
        if (didSetAutoReverse) {
            animation->SetAutoreverses(autoreverses);
        }
        if (didSetBeginTime) {
            animation->SetBeginTime(beginTime);
        }
    }
}

ANIMATOR_NAMESPACE_END
