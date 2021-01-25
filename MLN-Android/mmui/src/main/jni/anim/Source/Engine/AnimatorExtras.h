//
// Created by momo783 on 2020/5/20.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#ifndef MLANIMATOR_ANIMATOREXTRAS_H
#define MLANIMATOR_ANIMATOREXTRAS_H

#include "Defines.h"

ANIMATOR_NAMESPACE_BEGIN

class SpringAnimationUtil {
public:

    /**
     * 转弹力和速度参数到 Tension 、 friction、mass
     * @param bounciness 弹力
     * @param speed 速度
     * @param outTension 输出 Tension
     * @param outFriction 输出 friction
     * @param outMass 输出 mass
     */
    static void ConvertBouncinessAndSpeedToTensionFrictionMass(AMTFloat bounciness, AMTFloat speed, AMTFloat* outTension, AMTFloat* outFriction, AMTFloat* outMass);


    /**
     * 转换Tension 、 friction到弹力和速度
     * @param tension 入参
     * @param friction 入参
     * @param outBounciness 返回值
     * @param outSpeed 返回值
     */
    static void ConvertTensionAndFrictionToBouncinessAndSpeed(AMTFloat tension, AMTFloat friction, AMTFloat *outBounciness, AMTFloat* outSpeed);

};


ANIMATOR_NAMESPACE_END

#endif //MLANIMATOR_ANIMATOREXTRAS_H
