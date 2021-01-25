//
// Created by momo783 on 2020/5/19.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#include "MathUtil.h"
#include "UnitBezier.h"

ANIMATOR_NAMESPACE_BEGIN

static double linear_interpolation(double t, double start, double end)
{
    return t * end + (1.f - t) * start;
}

static double b3_friction1(double x)
{
    return (0.0007 * pow(x, 3)) - (0.031 * pow(x, 2)) + 0.64 * x + 1.28;
}

static double b3_friction2(double x)
{
    return (0.000044 * pow(x, 3)) - (0.006 * pow(x, 2)) + 0.36 * x + 2.;
}

static double b3_friction3(double x)
{
    return (0.00000045 * pow(x, 3)) - (0.000332 * pow(x, 2)) + 0.1078 * x + 5.84;
}

double MathUtil::TimingFunctionSolve(const BezierControlPoints controlPoints, double t, double eps)
{
    UnitBezier bezier(controlPoints.x1, controlPoints.y1, controlPoints.x2, controlPoints.y2);
    return bezier.solve(t, eps);
}

void MathUtil::InterpolateVector(AMTInt count, AMTFloat *dst, const AMTFloat *from, const AMTFloat *to, AMTFloat f)
{
    for (AMTInt idx = 0; idx < count; idx++) {
        dst[idx] = MIX(from[idx], to[idx], f);
    }
}

double MathUtil::QuadraticOutInterpolation(double t, double start, double end) {
    return linear_interpolation(2*t - t*t, start, end);
}

double MathUtil::Normalize(double value, double startValue, double endValue) {
    return (value - startValue) / (endValue - startValue);
}

double MathUtil::ProjectNormal(double n, double start, double end) {
    return start + (n * (end - start));
}

void MathUtil::QuadraticSolve(AMTFloat a, AMTFloat b, AMTFloat c, AMTFloat &x1, AMTFloat &x2) {
    AMTFloat discriminant = sqrt(b * b - 4 * a * c);
    x1 = (-b + discriminant) / (2 * a);
    x2 = (-b - discriminant) / (2 * a);
}

double MathUtil::Bouncy3NoBounce(double tension) {
    double friction = 0;
    if (tension <= 18.) {
        friction = b3_friction1(tension);
    } else if (tension > 18 && tension <= 44) {
        friction = b3_friction2(tension);
    } else if (tension > 44) {
        friction = b3_friction3(tension);
    } else {
        assert(false);
    }
    return friction;
}

ANIMATOR_NAMESPACE_END