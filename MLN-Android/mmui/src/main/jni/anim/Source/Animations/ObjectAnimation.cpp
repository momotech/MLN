//
// Created by momo783 on 2020/5/16.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include "ObjectAnimation.h"
#include <math.h>

ANIMATOR_NAMESPACE_BEGIN

static BezierControlPoints staticControls[] = {
        {0.25, 0.10, 0.25, 1.0}, // Default
        {0.0,  0.0,  1.0,  1.0}, // Linear
        {0.42, 0.0,  1.0,  1.0}, // EaseIn
        {0.0,  0.0,  0.58, 1.0}, // EaseOut
        {0.42, 0.0,  0.58, 1.0}  // EaseInOut
};

const char* ObjectAnimation::ANIMATION_TYPENAME = "ObjectAnimation";

ObjectAnimation::ObjectAnimation(const AMTString &strName)
: ValueAnimation(strName),
  duration(0.f) {
    timingFunction = TimingFunction::Default;
    controlPoints = staticControls[0];
}

ObjectAnimation::~ObjectAnimation() {

}

ObjectAnimation &ObjectAnimation::Duration(AMTTimeInterval timeInterval) {
    duration = timeInterval;
    return *this;
}

ObjectAnimation &ObjectAnimation::ViaTimingFunction(TimingFunction function) {
    timingFunction = function;
    if (function < ANIMATOR_ARRAY_COUNT(staticControls)) {
        controlPoints = staticControls[timingFunction];
    }
    return *this;
}

void ObjectAnimation::Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) {
    ValueAnimation::Tick(time, timeInterval, timeProcess);

    // 1、Cap tick 时间到 Duration
    //AMTFloat localDuration = fmin(timeInterval, duration) / duration
    progress = fmin(timeProcess / duration, 1.0);

    AMTFloat t = MathUtil::TimingFunctionSolve(controlPoints, progress, SOLVE_EPS(duration));

    MathUtil::InterpolateVector(valueCount, currentValue.data(), fromValue.data(), toValue.data(), t);
    
    if (progress >= 1.0) {
        Animation::SetFinish(true);
        currentValue = toValue;
    }

    if (callbackValue) {
        callbackValue(currentValue.data());
    }
}

ANIMATOR_NAMESPACE_END
