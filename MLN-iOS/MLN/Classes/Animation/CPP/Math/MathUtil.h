//
// Created by momo783 on 2020/5/19.
// Copyright (c) 2020 Boztrail. All rights reserved.
//

#ifndef MLANIMATOR_MATHUTIL_H
#define MLANIMATOR_MATHUTIL_H

#include "Defines.h"
#include <math.h>

#define MIX(a, b, f) ((a) + (f) * ((b) - (a)))

#define SOLVE_EPS(dur) (1. / (1000. * (dur)))

#if AMTFLOAT_IS_DOUBLE
#define sqrtr(f) sqrt(f);
#else
#define sqrtr(f) sqrtf(f);
#endif

ANIMATOR_NAMESPACE_BEGIN

struct BezierControlPoints {
    AMTFloat x1, y1;
    AMTFloat x2, y2;
};

class MathUtil {

public:
    /**
     * 根据时间间隔
     * @param count 数值个数
     * @param dst 目标数值
     * @param from 开始值
     * @param to 结束值
     * @param f 当前进度
     */
    static void InterpolateVector(AMTInt count, AMTFloat *dst, const AMTFloat *from, const AMTFloat *to, AMTFloat f);

    /**
     * 时间曲线函数
     * @param controlPoints 贝塞尔的两个控制点
     * @param t 当前时间
     * @param eps 精度控制
     * @return 时间结果
     */
    static double TimingFunctionSolve(const BezierControlPoints controlPoints, double t, double eps);

    // quadratic mapping of t [0, 1] to [start, end]
    static double QuadraticOutInterpolation(double t, double start, double end);

    // normalize value to [0, 1] based on its range [startValue, endValue]
    static double Normalize(double value, double startValue, double endValue);

    // project a normalized value [0, 1] to a given range [start, end]
    static double ProjectNormal(double n, double start, double end);

    // solve a quadratic equation of the form a * x^2 + b * x + c = 0
    static void QuadraticSolve(AMTFloat a, AMTFloat b, AMTFloat c, AMTFloat &x1, AMTFloat &x2);

    // for a given tension return the bouncy 3 friction that produces no bounce
    static double Bouncy3NoBounce(double tension);
};

ANIMATOR_NAMESPACE_END


#endif //MLANIMATOR_MATHUTIL_H
