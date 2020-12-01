//
// Created by momo783 on 2020/5/16.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include "SpringAnimation.h"
#include "AnimatorExtras.h"
#include "MathUtil.h"
#include <stdlib.h>

ANIMATOR_NAMESPACE_BEGIN

template<class T>
struct ComputeProgressFunctor {
    AMTFloat operator()(const T &value, const T &start, const T &end) const {
        return 0;
    }
};

template<>
struct ComputeProgressFunctor<Vector4r> {
    AMTFloat operator()(const Vector4r &value, const Vector4r &start, const Vector4r &end) const {
        AMTFloat s = (value - start).squaredNorm(); // distance from start
        AMTFloat e = (value - end).squaredNorm();   // distance from end
        AMTFloat d = (end - start).squaredNorm();   // distance from start to end

        if (0 == d) {
            return 1;
        } else if (s > e) {
            // s -------- p ---- e   OR   s ------- e ---- p
            return sqrtr(s/d);
        } else {
            // s --- p --------- e   OR   p ---- s ------- e
            return 1 - sqrtr(e/d);
        }
    }
};

const char* SpringAnimation::ANIMATION_TYPENAME = "SpringAnimation";

SpringAnimation::SpringAnimation(const AMTString &strName)
: ValueAnimation(strName),
  velocity(0.f),
  springBounciness(12.f),
  springSpeed(4.f),
  dynamicsFriction(0.f),
  dynamicsTension(0.f),
  dynamicsMass(0.f),
  velocityVec(nullptr),
  toValueVec(nullptr),
  currentVec(nullptr),
  previousVec(nullptr),
  previous2Vec(nullptr),
  userSpecifiedDynamics(false) {
    springSolver4R = new SpringSolver4r(1, 1, 1);
    dynamicsThreshold = this->threshold;
    SpringAnimationUtil::ConvertBouncinessAndSpeedToTensionFrictionMass(springBounciness, springSpeed, &dynamicsTension, &dynamicsFriction, &dynamicsMass);
    UpdateDynamics();
}

SpringAnimation::~SpringAnimation() {

}

void SpringAnimation::UpdateDynamics() {
    userSpecifiedDynamics = true;
    springSolver4R->setConstants(dynamicsTension, dynamicsFriction, dynamicsMass);
}

void SpringAnimation::UpdateDynamicsBySpeedOrBounciness() {
    userSpecifiedDynamics = false;
    SpringAnimationUtil::ConvertBouncinessAndSpeedToTensionFrictionMass(springBounciness, springSpeed, &dynamicsTension, &dynamicsFriction, &dynamicsMass);
    UpdateDynamics();
}

void SpringAnimation::SetVelocity(const AMTFloat* values) {
    if (valueCount) {
        velocity.clear();
        for (int i = 0; i < valueCount; i ++) {
            velocity.push_back(values[i]);
        }
    }
}

void SpringAnimation::SetSpringSpeed(AMTFloat speed) {
    if (userSpecifiedDynamics || speed != springSpeed) {
        SpringAnimation::springSpeed = speed;
        SpringAnimation::UpdateDynamicsBySpeedOrBounciness();
    }
}

void SpringAnimation::SetSpringBounciness(AMTFloat bounciness) {
    if (userSpecifiedDynamics || bounciness != springBounciness) {
        SpringAnimation::springBounciness = bounciness;
        SpringAnimation::UpdateDynamicsBySpeedOrBounciness();
    }
}


void SpringAnimation::SetDynamicsTension(AMTFloat dynamicsTension) {
    SpringAnimation::dynamicsTension = dynamicsTension;
    SpringAnimation::UpdateDynamics();
}


void SpringAnimation::SetDynamicsFriction(AMTFloat dynamicsFriction) {
    SpringAnimation::dynamicsFriction = dynamicsFriction;
    SpringAnimation::UpdateDynamics();
}

void SpringAnimation::SetDynamicsMass(AMTFloat dynamicsMass) {
    SpringAnimation::dynamicsMass = dynamicsMass;
    SpringAnimation::UpdateDynamics();
}

void SpringAnimation::Reset() {
    ValueAnimation::Reset();
    ResetSpringValue();
}

void SpringAnimation::RepeatReset() {
    Animation::RepeatReset();
    ResetSpringValue();
}

void SpringAnimation::ResetSpringValue() {
    previousVec = previous2Vec = nullptr;
    currentVec = toValueVec = velocityVec = nullptr;
    dynamicsThreshold = this->threshold;
}

void SpringAnimation::Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) {
    ValueAnimation::Tick(time, timeInterval, timeProcess);

    // 1、开始计算Spring动画

    if (currentValue.size() == 0) {
        return;
    }

    AMTFloat localTime = timeProcess;

    if (!currentVec || !toValueVec || !velocityVec) {
        currentVec = VectorRef(Vector::new_vector(valueCount, currentValue.data()));
        toValueVec = VectorRef(Vector::new_vector(valueCount, toValue.data()));
        velocityVec = VectorRef(Vector::new_vector(valueCount, velocity.data()));
    }

    Vector4r value = currentVec->vector4r();
    Vector4r tValue = toValueVec->vector4r();
    Vector4r velocityValue = velocityVec->vector4r();

    SSState4r state;
    state.p = tValue - value;

    // the solver assumes a spring of size zero
    // flip the velocity from user perspective to solver perspective
    state.v = velocityVec->vector4r() * -1;

    springSolver4R->advance(state, localTime, timeInterval);
    value = tValue - state.p;

    // flip velocity back to user perspective
    velocityValue = state.v * -1;

    *currentVec = value;

    if (velocityVec) {
        *velocityVec = velocityValue;
    }
    currentValue.clear();
    velocity.clear();
    for (int i = 0; i < valueCount; i++) {
        currentValue.push_back(currentVec->data()[i]);
        velocity.push_back(velocityVec->data()[i]);
    }

    // 计算动画进度
    if (valueCount) {
        static ComputeProgressFunctor<Vector4r> func;
        Vector4r v = currentVec->vector4r();
        Vector4r f = Vector::new_vector(valueCount, fromValue.data())->vector4r();
        Vector4r t = toValueVec->vector4r();;
        progress = func(v, f, t);
    }

    if (springSolver4R->started() && (HasConverged() && springSolver4R->hasConverged())) {
        Animation::SetFinish(true);
        currentValue = toValue;
    }

    if (callbackValue) {
        callbackValue(currentValue.data());
    }
}

AMTBool SpringAnimation::HasConverged() {
    if (!previousVec || !previous2Vec) {
        if (!previous2Vec && previousVec) {
            previous2Vec = previousVec;
        }
        previousVec = currentVec;
        return false;
    }
    
    AMTInt count = valueCount;
    AMTFloat t  = dynamicsThreshold / 5;

    const AMTFloat *toValues = toValueVec->data();
    const AMTFloat *previousValues = previousVec->data();
    const AMTFloat *previous2Values = previous2Vec->data();

    for (AMTInt idx = 0; idx < count; idx++) {
        if ((abs(toValues[idx] - previousValues[idx]) >= t) ||
            (abs(previous2Values[idx] - previousValues[idx]) >= t)) {
            return false;
        }
    }
    return true;
}

ANIMATOR_NAMESPACE_END
