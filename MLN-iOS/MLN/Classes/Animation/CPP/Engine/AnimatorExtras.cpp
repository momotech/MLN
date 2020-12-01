//
// Created by momo783 on 2020/5/20.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#include "AnimatorExtras.h"
#include "MathUtil.h"

#define ANIMATION_FRICTION_FOR_QC_FRICTION(qcFriction) (25.0 + (((qcFriction - 8.0) / 2.0) * (25.0 - 19.0)))
#define ANIMATION_TENSION_FOR_QC_TENSION(qcTension) (194.0 + (((qcTension - 30.0) / 50.0) * (375.0 - 194.0)))

#define QC_FRICTION_FOR_ANIMATION_FRICTION(fbFriction) (8.0 + 2.0 * ((fbFriction - 25.0)/(25.0 - 19.0)))
#define QC_TENSION_FOR_ANIMATION_TENSION(fbTension) (30.0 + 50.0 * ((fbTension - 194.0)/(375.0 - 194.0)))

static const AMTFloat Bouncy3NormalizationRange = 20.0;
static const AMTFloat Bouncy3NormalizationScale = 1.7;
static const AMTFloat Bouncy3BouncinessNormalizedMin = 0.0;
static const AMTFloat Bouncy3BouncinessNormalizedMax = 0.8;
static const AMTFloat Bouncy3SpeedNormalizedMin = 0.5;
static const AMTFloat Bouncy3SpeedNormalizedMax = 200;
static const AMTFloat Bouncy3FrictionInterpolationMax = 0.01;

ANIMATOR_NAMESPACE_BEGIN

void SpringAnimationUtil::ConvertBouncinessAndSpeedToTensionFrictionMass
(AMTFloat bounciness, AMTFloat speed, AMTFloat *outTension, AMTFloat *outFriction, AMTFloat *outMass)
{
    double b = MathUtil::Normalize(bounciness / Bouncy3NormalizationScale, 0, Bouncy3NormalizationRange);
    b = MathUtil::ProjectNormal(b, Bouncy3BouncinessNormalizedMin, Bouncy3BouncinessNormalizedMax);

    double s = MathUtil::Normalize(speed / Bouncy3NormalizationScale, 0, Bouncy3NormalizationRange);

    AMTFloat tension = MathUtil::ProjectNormal(s, Bouncy3SpeedNormalizedMin, Bouncy3SpeedNormalizedMax);
    AMTFloat friction = MathUtil::QuadraticOutInterpolation(b, MathUtil::Bouncy3NoBounce(tension), Bouncy3FrictionInterpolationMax);

    tension = ANIMATION_TENSION_FOR_QC_TENSION(tension);
    friction = ANIMATION_FRICTION_FOR_QC_FRICTION(friction);

    if (outTension) {
        *outTension = tension;
    }

    if (outFriction) {
        *outFriction = friction;
    }

    if (outMass) {
        *outMass = 1.0;
    }
}

void SpringAnimationUtil::ConvertTensionAndFrictionToBouncinessAndSpeed
(AMTFloat tension, AMTFloat friction, AMTFloat *outBounciness, AMTFloat *outSpeed)
{
    // Convert to QC values, in which our calculations are done.
    AMTFloat qcFriction = QC_FRICTION_FOR_ANIMATION_FRICTION(friction);
    AMTFloat qcTension = QC_TENSION_FOR_ANIMATION_TENSION(tension);

    // Friction is a function of bounciness and tension, according to the following:
    // friction = QuadraticOutInterpolation(b, Bouncy3NoBounce(tension), Bouncy3FrictionInterpolationMax);
    // Solve for bounciness, given a tension and friction.

    AMTFloat nobounceTension = MathUtil::Bouncy3NoBounce(qcTension);
    AMTFloat bounciness1, bounciness2;

    MathUtil::QuadraticSolve((nobounceTension - Bouncy3FrictionInterpolationMax),      // a
            2 * (Bouncy3FrictionInterpolationMax - nobounceTension),  // b
            (nobounceTension - qcFriction),                             // c
            bounciness1,                                                // x1
            bounciness2);                                               // x2


    // Choose the quadratic solution within the normalized bounciness range
    AMTFloat projectedNormalizedBounciness = (bounciness2 < Bouncy3BouncinessNormalizedMax) ? bounciness2 : bounciness1;
    AMTFloat projectedNormalizedSpeed = qcTension;

    // Reverse projection + normalization
    AMTFloat bounciness = ((Bouncy3NormalizationRange * Bouncy3NormalizationScale) / (Bouncy3BouncinessNormalizedMax - Bouncy3BouncinessNormalizedMin)) * (projectedNormalizedBounciness - Bouncy3BouncinessNormalizedMin);
    AMTFloat speed = ((Bouncy3NormalizationRange * Bouncy3NormalizationScale) / (Bouncy3SpeedNormalizedMax - Bouncy3SpeedNormalizedMin)) * (projectedNormalizedSpeed - Bouncy3SpeedNormalizedMin);

    // Write back results
    if (outBounciness) {
        *outBounciness = bounciness;
    }

    if (outSpeed) {
        *outSpeed = speed;
    }
}

ANIMATOR_NAMESPACE_END
