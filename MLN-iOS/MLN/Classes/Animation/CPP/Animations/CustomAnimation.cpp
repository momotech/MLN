//
// Created by momo783 on 2020/5/14.
// Copyright (c) 2020 boztrail. All rights reserved.
//

#include "CustomAnimation.h"

ANIMATOR_NAMESPACE_BEGIN

const char* CustomAnimation::ANIMATION_TYPENAME = "CustomAnimation";

CustomAnimation::CustomAnimation(const AMTString &strName)
: Animation(strName),
tickCallback(nullptr),
currentTime(0.f),
elapsedTime(0.f),
userData(nullptr) {

}

CustomAnimation::CustomAnimation(const AMTString &strName, void *data)
: Animation(strName),
tickCallback(nullptr),
currentTime(0.f),
elapsedTime(0.f),
userData(data) {

}

const CustomAnimation &CustomAnimation::OnSetp(CustomAnimationTickCallback callback) {
    tickCallback = callback;
    return *this;
}

void CustomAnimation::SetUserData(void *data) {
    userData = data;
}

void CustomAnimation::Tick(AMTTimeInterval time, AMTTimeInterval timeInterval, AMTTimeInterval timeProcess) {
    Animation::Tick(time, timeInterval, timeProcess);

    // 当前时间和间隔时间计算
    currentTime = time;
    elapsedTime = timeInterval;

    if (tickCallback) {
        AMTBool bFinish = tickCallback(GetName(), *this);
        Animation::SetFinish(bFinish);
    }
}

ANIMATOR_NAMESPACE_END
