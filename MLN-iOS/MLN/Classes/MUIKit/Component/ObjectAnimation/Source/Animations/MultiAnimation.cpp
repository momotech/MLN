//
// Created by momo783 on 2020/5/22.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#include "MultiAnimation.h"

ANIMATOR_NAMESPACE_BEGIN

const char* MultiAnimation::ANIMATION_TYPENAME = "MultiAnimation";

MultiAnimation::MultiAnimation(const AMTString &strName)
: Animation(strName), runningType(Together) {

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
    
    ResetSubAnimation();
}

void MultiAnimation::RepeatReset() {
    Animation::RepeatReset();
    
    ResetSubAnimation();
    StartAddRunningAnimation();
}

void MultiAnimation::ResetSubAnimation() {
    for (int i = 0; i < animationList.size(); i++) {
        Animation* animation = animationList[i];
        animation->Reset();
    }
    finishAnimationList.clear();
}

void MultiAnimation::StartAddRunningAnimation() {
    runningAnimationList.clear();
    
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
    if (runningAnimationList.size()) {
        for (int i = 0; i < runningAnimationList.size(); i++) {
            Animation* animation = runningAnimationList[i];
            animation->Pause(pause);
        }
    }
    Animation::Pause(pause);
}

void MultiAnimation::Start() {
    Animation::Start();

    StartAddRunningAnimation();
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
            animation->TickTime(time);
            animation->StopAnimationIfFinish();
            if (animation->finished) {
                animation->Stop();
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
            animation->TickTime(time);
            animation->StopAnimationIfFinish();
            if (animation->finished) {
                animation->Stop();
                if (finishAnimationList.size() < animationList.size()) {
                    auto animation = animationList[finishAnimationList.size()];
                    animation->Reset();
                }
            }
        }
    }

    if (finishAnimationList.size() && finishAnimationList.size() == animationList.size()) {
        Animation::SetFinish(true);
    }
}

ANIMATOR_NAMESPACE_END
