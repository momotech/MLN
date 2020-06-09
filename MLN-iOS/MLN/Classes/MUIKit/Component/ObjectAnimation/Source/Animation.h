//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#ifndef ANIMATION_ANIMATION_H
#define ANIMATION_ANIMATION_H

#include <functional>
#include "Defines.h"
#include "AnimationTracer.h"


ANIMATOR_NAMESPACE_BEGIN

class Animation {

    typedef std::function<void (Animation*)> AnimationStartCallback;
    typedef std::function<void (Animation*, AMTBool paused)> AnimationPauseCallback;
    typedef std::function<void (Animation*, AMTInt  repeat)> AnimationRepeatCallback;
    typedef std::function<void (Animation*, AMTBool finish)> AnimationStopCallback;

public:
    explicit Animation(const AMTString &strName);

    virtual ~Animation();

    /**
     * 获取动画标识
     */
    ANIMATOR_INLINE AMTString GetName() const {
        return name;
    }

    // 动画自动反转
    void SetAutoreverses(AMTBool bAutoReverses = false);

    // 暂停动画
    void Pause(AMTBool pause);

public:
    // 动画开始时间，相对动画添加的时间间隔，动画开始后设置不生效
    AMTTimeInterval beginTime;

    // 动画重复次数
    AMTInt repeatCount;

    // 动画永久重复
    AMTBool repeatForever;
    
    /**
     * 动画开始回调，给Engine层使用
     */
    AnimationStartCallback OnAnimationStartCallback;

    /**
     * 动画被暂停或恢复回调，给Engine层使用
     */
    AnimationPauseCallback OnAnimationPauseCallback;

    /**
     * 动画重复执行回调
     */
    AnimationRepeatCallback OnAnimationRepeatCallback;
    
    /**
     * 动画结束回调，给Engine层使用
     */
    AnimationStopCallback OnAnimationStopCallback;

    /**
     * 动画追踪器
     */
    const AnimationTracer& GetTracer();

    virtual	const char* & GetAnimationType() const { return ANIMATION_TYPENAME; }

    // 动画类型
    static const char *ANIMATION_TYPENAME;

protected:
    /**
     * 重置动画状态
     */
    virtual void Reset();
    
    virtual void InnerReset();

    /**
     * 动画开始
     */
    virtual void Start();

    /**
     * 动画重复
     */
    virtual void Repeat();

    /**
     * 动画结束
     */
    virtual void Stop();

    /**
     * 每帧动画Tick
     * @param time 当前时间
     * @param timeInterval 和上次loop的时间间隔
     * @param timeProcess 和动画开始的时间间隔
     */
    virtual void Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess);

private:

    /**
     * 检查动画是否可以开始，可以则开始动画
     * @param time 当前时间
     */
    void StartAnimationIfNeed(AMTTimeInterval time);

    /**
     * 计算时间间隔和进度，真被Tick动画
     * @param time 当前时间
     */
    void TickTime(AMTTimeInterval time);

    /**
     * 如果动画完成，则结束动画
     */
    void StopAnimationIfFinish();
    
private:
    // 动画行为追踪
    AnimationTracer *tracer;
    
    // 动画标识
    AMTString name;

    // 动画自动反转
    AMTBool autoreverses;
    
    // 动画重复次数
    AMTInt realRepeatCount;

    // 动画是否激活
    AMTBool active;

    // 暂停动画
    AMTBool paused;

    // 动画是否完成
    AMTBool finished;
    
    // 动画即将重复执行
    AMTBool willrepeat;

    // 动画开始时间
    AMTTimeInterval startTime;

    // 上一次动画时间
    AMTTimeInterval lastTime;

    // 真正的开始时间
    AMTTimeInterval absoluteBeginTime;
    
    // 暂停时间长度
    AMTTimeInterval pauseBeginTime;

    friend class AnimatorEngine;
    friend class ValueAnimation;
    friend class ObjectAnimation;
    friend class SpringAnimation;
    friend class CustomAnimation;
    friend class MultiAnimation;
};

#define ANIMATION_TYPE_DEF(T) virtual const char* & GetAnimationType() const override {return T;}

ANIMATOR_NAMESPACE_END


#endif //ANIMATION_ANIMATION_H
