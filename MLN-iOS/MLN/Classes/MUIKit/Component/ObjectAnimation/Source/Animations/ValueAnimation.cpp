//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include "ValueAnimation.h"

ANIMATOR_NAMESPACE_BEGIN

const char* ValueAnimation::ANIMATION_TYPENAME = "ValueAnimation";

ValueAnimation::ValueAnimation(const AMTString &strName)
: Animation(strName),
  valueCount(0),
  threshold(1.0),
  progress(0.0),
  callbackValue(nullptr) {

}

ValueAnimation::~ValueAnimation() {

}

ValueAnimation &ValueAnimation::FromToValues(AMTFloat* fromValues, AMTFloat* toValues, AMTInt count) {
    valueCount = count;
    if (valueCount) {
        fromValue.clear();
        toValue.clear();
        for (int i = 0; i < valueCount; i++) {
            fromValue.push_back(fromValues[i]);
            toValue.push_back(toValues[i]);
        }
    }
    return *this;
}

ValueAnimation &ValueAnimation::OnStepValue(ValueAnimationCallbackValue animationCallbackValue) {
    callbackValue = animationCallbackValue;
    return *this;
}

void ValueAnimation::Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) {
    Animation::Tick(time, timeInterval, timeProcess);

    // 统一的数值计算，让扩展类实现的数据插值方式
    // printf("ValueAnimation::Tick %p Type: %s value :%f \n", this, GetAnimationType(), currentValue[0]);
}

void ValueAnimation::Reset() {
    // 重置时间状态
    Animation::Reset();
    // 重置currentValue
    currentValue = fromValue;
}

void ValueAnimation::Start(AMTTimeInterval time) {
    Animation::Start(time);
}

void ValueAnimation::Repeat() {
    
    if (Animation::GetAutoreverses()) {
        auto preFromValue = fromValue;
        fromValue = toValue;
        toValue = preFromValue;
    }
    currentValue = fromValue;
    
    Animation::Repeat();
}

void ValueAnimation::Stop() {
    Animation::Stop();
}

ANIMATOR_NAMESPACE_END


