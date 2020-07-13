//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#ifndef ANIMATION_PROPERTYANIMATION_H
#define ANIMATION_PROPERTYANIMATION_H

#include "Defines.h"
#include "Animation.h"
#include <vector>

ANIMATOR_NAMESPACE_BEGIN

class AnimatorEngine;

typedef std::vector<AMTFloat > AnimationValue;
typedef std::function<void (AMTFloat*)> ValueAnimationCallbackValue;

class ValueAnimation : public Animation {

public:
    explicit ValueAnimation(const AMTString& strName);

    ~ValueAnimation();

    /**
     * 属性动画插值最重要的数据
     * @param fromValues 动画起始数值，最大长度支持4
     * @param toValues   动画目标数值，最大长度4
     * @param count  数值格式
     */
    ValueAnimation& FromToValues(AMTFloat* fromValues, AMTFloat* toValues, AMTInt count);

    /**
     * 动画每帧Tick回调的数值
     * @param animationCallbackValue 插值刷新回调
     */
    ValueAnimation& OnStepValue(ValueAnimationCallbackValue animationCallbackValue);
    
    ANIMATOR_INLINE const AnimationValue& GetCurrentValue() const {
        return currentValue;
    }

    static const char* ANIMATION_TYPENAME;ANIMATION_TYPE_DEF(ANIMATION_TYPENAME)

    // 精度
    AMTFloat threshold;

protected:
    /**
     * 重制Value属性动画数值
     */
    virtual void Reset() override;

    /**
     * 动画开始
     */
    virtual void Start(AMTTimeInterval time) override;

    /**
     * 动画重复
     */
    virtual void Repeat() override;

    /**
     * 动画结束
     */
    virtual void Stop() override;

    /**
     * 覆写父类方法，实现属性动画的Tick
     * @param time 当前时间
     * @param timeInterval 和上次loop的时间间隔
     */
    virtual void Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) override;

private:
    // value数据的个数
    AMTInt valueCount;

    // 动画开始的一组数据
    AnimationValue fromValue;

    // 动画最终的一组数据
    AnimationValue toValue;

    // 当前时间点插值得到的数据
    AnimationValue currentValue;

    // 动画进度
    AMTFloat progress;

    // 每次Tick产值产生的数据结果
    ValueAnimationCallbackValue callbackValue;

    friend class AnimatorEngine;
    friend class ObjectAnimation;
    friend class SpringAnimation;
};

ANIMATOR_NAMESPACE_END


#endif //ANIMATION_PROPERTYANIMATION_H
