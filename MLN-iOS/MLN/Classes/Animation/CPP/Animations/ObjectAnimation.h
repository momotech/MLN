//
// Created by momo783 on 2020/5/16.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#ifndef NIMATION_TWEENANIMATION_H
#define NIMATION_TWEENANIMATION_H

#include "Defines.h"
#include "ValueAnimation.h"
#include "MathUtil.h"

ANIMATOR_NAMESPACE_BEGIN


class ObjectAnimation : public ValueAnimation {

public:
    explicit ObjectAnimation(const AMTString &strName);

    ~ObjectAnimation();

    /**
     * 属性动画动画时间
     * @param timeInterval 时间间隔
     */
    ObjectAnimation& Duration(AMTTimeInterval timeInterval);

    /**
     * 动画时间函数
     * @param function 时间插值函数
     */
    ObjectAnimation& ViaTimingFunction(TimingFunction function);

    static const char* ANIMATION_TYPENAME;ANIMATION_TYPE_DEF(ANIMATION_TYPENAME)

protected:
    /**
     * 覆写父类方法，实现属性动画的Tick
     * @param time 当前时间
     * @param timeInterval 和上次loop的时间间隔
     */
    void Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) override;
    
private:
    // Tween动画执行插值时间间隔
    AMTTimeInterval duration;

    // 差值计算函数
    TimingFunction timingFunction;

    // 贝塞尔默认控制点
    BezierControlPoints controlPoints;
};

ANIMATOR_NAMESPACE_END


#endif //NIMATION_TWEENANIMATION_H
