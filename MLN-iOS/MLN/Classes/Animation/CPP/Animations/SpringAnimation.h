//
// Created by momo783 on 2020/5/16.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#ifndef NIMATION_SPRINGANIMATION_H
#define NIMATION_SPRINGANIMATION_H

#include "Defines.h"
#include "ValueAnimation.h"
#if ANIMATOR_PLATFORM_IOS
#import "SpringSolver.h"
#else
#include "SpringSolver.h"
#endif

ANIMATOR_NAMESPACE_BEGIN

class SpringAnimation : public ValueAnimation {
public:
    explicit SpringAnimation(const AMTString &strName);

    ~SpringAnimation() override;

    /**
     * 设置初始值，动画开始前设置
     * @param values 类型和fromValue、toValue保持一致
     */
    void SetVelocity(const AMTFloat* values);

    /**
     * 设置速度值，默认是4.0【0-20】
     */
    void SetSpringSpeed(AMTFloat speed);

    /**
     * 设置弹力值，默认是12.0【0-20】
     */
    void SetSpringBounciness(AMTFloat bounciness);

    /**
     * 设置动态张力
     */
    void SetDynamicsTension(AMTFloat dynamicsTension);

    /**
     * 设置动态摩擦
     */
    void SetDynamicsFriction(AMTFloat dynamicsFriction);

    /**
     * 设置动态质量
     */
    void SetDynamicsMass(AMTFloat dynamicsMass);

    ANIMATOR_INLINE AnimationValue GetVelocity() const {
        return velocity;
    }

    ANIMATOR_INLINE AMTFloat GetSpringSpeed()  const {
        return springSpeed;
    }

    ANIMATOR_INLINE AMTFloat GetSpringBounciness() const {
        return springBounciness;
    }

    ANIMATOR_INLINE AMTFloat GetDynamicsTension() const {
        return dynamicsTension;
    }

    ANIMATOR_INLINE AMTFloat GetDynamicsFriction() const {
        return dynamicsFriction;
    }

    static const char* ANIMATION_TYPENAME;ANIMATION_TYPE_DEF(ANIMATION_TYPENAME)

protected:
    /**
    * 重制Spring属性动画数值
    */
    void Reset() override;
    
    /**
     * 重复重置
     */
    void RepeatReset() override;
    
    /**
     * 重置Spring数值
     */
    void ResetSpringValue();
    
    /**
     * 覆写父类方法，实现属性动画的Tick
     * @param time 当前时间
     * @param timeInterval 和上次loop的时间间隔
     */
    void Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) override;

private:
    /**
     * 更新Spring动态算法参数
     */
    void UpdateDynamics();

    /**
     * 通过Speed和Bounciness计算Spring动态算法参数
     */
    void UpdateDynamicsBySpeedOrBounciness();
    
    /**
     * 判断是否收敛
     */
    AMTBool HasConverged();

private:
    // 当前的速度值
    AnimationValue velocity;

    // 反弹力，和speed数值一起可以改变动画效果，
    // 数值越大，弹簧运动范围越大，振动和弹性越大
    AMTFloat springBounciness;

    // 弹簧速度
    AMTFloat springSpeed;

    // 动态张力参数
    AMTFloat dynamicsTension;

    // 动态摩擦参数
    AMTFloat dynamicsFriction;

    // 动态质量参数
    AMTFloat dynamicsMass;

    // Spring Solver
    SpringSolver4r *springSolver4R;

    // 动态精度
    AMTFloat dynamicsThreshold;

    // 更新过动态参数（Friction、Tension、Mass）
    AMTBool userSpecifiedDynamics;

    // Spring动画用到的Vector,避免临时创建
    VectorRef currentVec;

    VectorRef toValueVec;

    VectorRef velocityVec;
    
    // 最近两次插值缓存
    VectorRef previousVec;
    
    VectorRef previous2Vec;
    
};

ANIMATOR_NAMESPACE_END


#endif //NIMATION_SPRINGANIMATION_H
