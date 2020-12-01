//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include "AnimatorEngine.h"
#include "CustomAnimation.h"
#include "ValueAnimation.h"
#include <vector>

ANIMATOR_NAMESPACE_BEGIN

static AnimatorEngine *shareEngine = nullptr;

AnimatorEngine::AnimatorEngine() :
lastLoopTime(0.f),
startTime(0.f) {
    animationList.clear();
    pthread_mutex_init(&lock, NULL);
}

AnimatorEngine::~AnimatorEngine() {
    if (RunLoop::ShareLoop()->LoopCallback) {
        RunLoop::ShareLoop()->LoopCallback = nullptr;
    }
    RunLoop::DestoryShareLoop();

    RemoveAllAnimations();
}

AnimatorEngine *AnimatorEngine::ShareAnimator() {
    if (shareEngine == nullptr) {
        shareEngine = new AnimatorEngine();
    }
    return shareEngine;
}

void AnimatorEngine::AddAnimation(Animation *animation) {
    AddAnimation(animation, animation->name);
}

void AnimatorEngine::AddAnimation(Animation *animation, const AMTString &animationKey) {
    if (!animation || !animationKey.size()) {
        return;
    }

    pthread_mutex_lock(&lock);
    AMTBool success = FindAnimationInList(animation, animationKey);
    if (success) {
        pthread_mutex_unlock(&lock);
        return;
    }

    AnimationItemRef item(new AnimationItem(animationKey, animation));
    animationList.push_back(item);

    animation->OnAnimationStartCallback = [this](Animation* animation1) {
        if (this->animationStart) {
            this->animationStart(animation1);
        }
    };

    animation->OnAnimationPauseCallback = [this](Animation* animation1, AMTBool paused) {
        if (this->animationPause) {
            this->animationPause(animation1, paused);
        }
    };
    
    animation->OnAnimationRepeatCallback = [this](Animation *caller, Animation *executingAnimation, AMTInt count) {
        if (this->animationRepeat) {
            this->animationRepeat(caller, executingAnimation, count);
        }
    };

    animation->OnAnimationStopCallback = [this](Animation* animation1, AMTBool finish) {
        if (this->animationFinish) {
            this->animationFinish(animation1, finish);
        }
    };

    animation->Reset();
    pthread_mutex_unlock(&lock);
    
    UpdateLoopState();
}

void AnimatorEngine::RemoveAnimation(Animation *animation) {
    if (!animation || !animation->name.size()) {
        return;
    }

    pthread_mutex_lock(&lock);

    AnimationItemRef item;
    auto iterator = animationList.begin();
    for (; iterator != animationList.end() ; iterator++) {
        item = *iterator;
        if (item->animation == animation) {
            break;
        }
    }
    if (iterator != animationList.end()) {
        animationList.erase(iterator);
    } else {
        item = nullptr;
    }
    pthread_mutex_unlock(&lock);

    if (item && item->animation) {
        item->animation->Stop();
    }
}

void AnimatorEngine::RemoveAnimation(const AMTString &animationKey) {
    if (!animationKey.size()) {
        return;
    }
    pthread_mutex_lock(&lock);

    AnimationItemRef item;
    auto iterator = animationList.begin();
    for (auto iterator = animationList.begin(); iterator != animationList.end() ; iterator++) {
        item = *iterator;
        if (item->key == animationKey) {
            break;
        }
    }
    if (iterator != animationList.end()) {
        animationList.erase(iterator);
    } else {
        item = nullptr;
    }
    pthread_mutex_unlock(&lock);

    if (item && item->animation) {
        item->animation->Stop();
    }
}

void AnimatorEngine::RemoveAllAnimations() {
    pthread_mutex_lock(&lock);

    std::vector<AnimationItemRef> removeList {animationList.begin(), animationList.end()};
    animationList.clear();

    pthread_mutex_unlock(&lock);

    if (removeList.size()) {
        for (AnimationItemRef item : removeList) {
            if (item && item->animation) {
                item->animation->Stop();
            }
        }
        removeList.clear();
    }
}

void AnimatorEngine::UpdateLoopState() {
    pthread_mutex_lock(&lock);
    size_t size = animationList.size();
    size_t finishSize = willRemoveAnimationList.size();
    pthread_mutex_unlock(&lock);

    if (size == 0 && finishSize == 0) {
        if (RunLoop::ShareLoop()->IsRunning()) {
            RunLoop::ShareLoop()->StopLoop();
        }
        return;
    } else {
        if (RunLoop::ShareLoop()->IsRunning()) {
            return;
        }
    }

    RunLoop::ShareLoop()->StartLoop();
    lastLoopTime = RunLoop::ShareLoop()->CurrentTime();

    // printf("AnimatorEngine Start Loop !!!\n");
    RunLoop::ShareLoop()->LoopCallback = [this](AMTTimeInterval currentTime ) -> void {
        this->LoopTick(currentTime);
    };
}

void AnimatorEngine::LoopTick(AMTTimeInterval currentTime) {
    if (currentTime < lastLoopTime) {
        lastLoopTime = currentTime;
        return;
    }
    // 1、计算时间片间隔
    AMTTimeInterval timeInterval = currentTime - lastLoopTime;
    lastLoopTime = currentTime;

    // 2、开始Loop执行回调
    if (animatorEngineLoopStart != nullptr) {
        animatorEngineLoopStart(currentTime);
    }

    // 3、开始执行所有动画的插值计算
    TickAnimation(currentTime, timeInterval);

    // 4、执行Loop结束的回调
    if (animatorEngineLoopEnd != nullptr) {
        animatorEngineLoopEnd(currentTime);
    }
 }

void AnimatorEngine::TickAnimation(AMTTimeInterval currentTime, AMTTimeInterval timeInterval) {
    pthread_mutex_lock(&lock);

    // 1、拷贝动画列表
    size_t size = animationList.size();
    if (size == 0) {
        pthread_mutex_unlock(&lock);
    } else {
        std::vector<AnimationItemRef> vector{ animationList.begin(), animationList.end() };
        pthread_mutex_unlock(&lock);
        // 2、动画计算过程
        for (auto item : vector) {
            TickAnimation(item->animation, currentTime, timeInterval);
        }
    }

    // 3、开始批量执行动画数值回调，finish的统一放到will remove队列
    pthread_mutex_lock(&lock);

    // 3/1、回调有进度但未完成的动画数值
    std::vector<AnimationItemRef> callbackList;
    std::vector<AnimationItemRef> repeatCallbackList;
    
    AnimationItemRef item;
    for (auto iterator = animationList.begin(); iterator != animationList.end() ; iterator++) {
        item = *iterator;
        if (item->animation->finished) {
            if (item->animation->willrepeat) {
                repeatCallbackList.push_back(item);
            } else {
                willRemoveAnimationList.push_back(item);
            }
        }
        callbackList.push_back(item);
    }
    pthread_mutex_unlock(&lock);

    if (callbackList.size()) {
        for (auto item : callbackList) {
            Animation* animation = item->animation;
            if (animation && updateAnimation) {
                updateAnimation(animation);
            }
        }
        callbackList.clear();
    }
    
    if (repeatCallbackList.size()) {
        for (auto item : repeatCallbackList) {
            Animation* animation = item->animation;
            if (animation) {
                animation->Repeat();
            }
        }
        repeatCallbackList.clear();
    }

    // 3/2、移除完成的动画对象
    pthread_mutex_lock(&lock);
    std::vector<AnimationItemRef> removeList {willRemoveAnimationList.begin(), willRemoveAnimationList.end()};
    willRemoveAnimationList.clear();
    if (removeList.size()) {
        for (auto item : removeList) {
            AnimationListIterator iter = find(animationList.begin(), animationList.end(), item);
            if (iter != animationList.end()) {
                animationList.erase(iter);
            }
        }
    }
    pthread_mutex_unlock(&lock);

    if (removeList.size()) {
        for (AnimationItemRef item : removeList) {
            if (item && item->animation) {
                item->animation->Stop();
            }
        }
        removeList.clear();
    }

    // 4、刷新Loop状态
    UpdateLoopState();
}

void AnimatorEngine::TickAnimation(Animation *animation, AMTTimeInterval time, AMTTimeInterval timeInterval) {
    if (!animation) {
        return;
    }
    // 1、检查如果需要开始就开始动画
    animation->StartAnimationIfNeed(time);

    // 2、Tick 动画时间
    if (animation->active && !animation->paused) {
        animation->TickTime(time);
        // 如果动画执行完成
        animation->StopAnimationIfFinish();
    }
}

AMTBool AnimatorEngine::FindAnimationInList(Animation *animation, const AMTString &key) {
    AMTBool findSuccess = false;
    AnimationItemRef item;
    auto iterator = animationList.begin();
    for (; iterator != animationList.end() ; iterator++) {
        item = *iterator;
        if (item->animation == animation) {
            findSuccess = true;
            break;
        }
    }
    return findSuccess;
}

ANIMATOR_NAMESPACE_END
