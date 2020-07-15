//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#ifndef ANIMATION_ANIMATORENGINE_H
#define ANIMATION_ANIMATORENGINE_H

#include "Defines.h"
#include <list>
#include "RunLoop.h"
#include "Animation.h"

#ifdef ANIMATOR_PLATFORM_IOS
#include <pthread/pthread.h>
#else
#include <pthread.h>
#endif

ANIMATOR_NAMESPACE_BEGIN

struct AnimationItem {
    AMTString key;
    Animation* animation;
    AnimationItem(const AMTString& string, Animation* animation1) : key(string),animation(animation1){}
};
typedef std::shared_ptr<AnimationItem> AnimationItemRef;

typedef std::list<AnimationItemRef> AnimationList;
typedef AnimationList::iterator AnimationListIterator;

typedef std::function<void(AMTTimeInterval currentTime)> AnimatorEngineLoopStart;
typedef std::function<void(AMTTimeInterval currentTime)> AnimatorEngineLoopEnd;

typedef std::function<void(Animation *)> AnimatorEngineAnimationStart;
typedef std::function<void(Animation *, AMTBool)> AnimatorEngineAnimationPause;
typedef std::function<void(Animation *, Animation *, AMTInt)> AnimatorEngineAnimationRepeat;
typedef std::function<void(Animation *, AMTBool)> AnimatorEngineAnimationFinish;

typedef std::function<void(Animation*)> AnimatorEngineUpdateAnimation;

class AnimatorEngine {
    AnimatorEngine();
    ~AnimatorEngine();
public:
    // AnimatorEngine 内存中只需要维持一个实例
    static AnimatorEngine * ShareAnimator();

    // 添加一个插值动画，默认使用name作为存储Key
    void AddAnimation(Animation* animation);

    // 添加一个插值动画，并指定存储Key
    void AddAnimation(Animation* animation, const AMTString& animationKey);

    // 移除插值动画，会回调业务移除操作
    void RemoveAnimation(Animation* animation);

    // 以动画存储Key移除插值动画，会回调业务移除操作
    void RemoveAnimation(const AMTString& animationKey);

    // 移除所有插值动画，会回调业务移除操作
    void RemoveAllAnimations();

    // Callback All Animation Tick Finish Values

    // 动画引擎Loop开始、iOS上Layer层动画事务的开启时机
    AnimatorEngineLoopStart animatorEngineLoopStart;

    // 动画引擎Loop结束、iOS上Layer层动画事务的关闭时机
    AnimatorEngineLoopEnd   animatorEngineLoopEnd;

    // 每个动画Tick结束，回调数值给业务刷新
    AnimatorEngineUpdateAnimation updateAnimation;

    // 动画开始的回调
    AnimatorEngineAnimationStart animationStart;

    // 动画暂停和恢复的回调
    AnimatorEngineAnimationPause animationPause;
    
    // 动画重复执行回调
    AnimatorEngineAnimationRepeat animationRepeat;

    // 动画结束的回调，在主动调用移除或Tick完后回调业务
    AnimatorEngineAnimationFinish animationFinish;

private:
    // 检测并启动RunLoop
    void UpdateLoopState();

    // 引擎每个Loop执行,计算刷新事件间隔
    void LoopTick(AMTTimeInterval currentTime);

    // 刷新动画队列的相关状态，并遍历List执行每个动画的刷新
    void TickAnimation(AMTTimeInterval currentTime, AMTTimeInterval timeInterval);

    // 单个动画的刷新
    void TickAnimation(Animation* animation,  AMTTimeInterval time, AMTTimeInterval timeInterval);

    // 查找某个动画是否在动画列表里
    AMTBool FindAnimationInList(Animation* animation, const AMTString& key);

private:
    // List的线程安全
    pthread_mutex_t lock;

    // 所有动画列表，以List的数据结构存储，保证插入删除效率
    AnimationList animationList;

    // 即将移除的动画列表、包括主动移除和被动移除
    AnimationList willRemoveAnimationList;

    // 引擎开始运行时间，用于测试使用
    AMTTimeInterval startTime;

    // 最近一次执行Loop的时间
    AMTTimeInterval lastLoopTime;

};

ANIMATOR_NAMESPACE_END

#endif //ANIMATION_ANIMATORENGINE_H
