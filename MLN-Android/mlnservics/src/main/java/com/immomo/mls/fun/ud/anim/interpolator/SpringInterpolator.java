/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.anim.interpolator;

import android.view.animation.Interpolator;

/**
 * Created by wang.yang on 2020-04-16
 */
public class SpringInterpolator implements Interpolator {
    private final float damping;
    private final float mass;
    private final float stiffness;

    public SpringInterpolator() {
        this(1, 100, 10);
    }

    public SpringInterpolator(float mass, float stiffness, float damping) {
        this.mass = mass;
        this.stiffness = stiffness;
        this.damping = damping;
    }

    @Override
    public float getInterpolation(float input) {
        float beta = damping / (2 * mass);
        float omega0 = (float) Math.sqrt(stiffness / mass);
        float omega1 = (float) Math.sqrt((omega0 * omega0) - (beta * beta));
        float omega2 = (float) Math.sqrt((beta * beta) - (omega0 * omega0));
        float x0 = -1;
        float v0 = 0;
        float envelope = (float) Math.exp(-beta * input);
        if (beta < omega0) {
            return -x0 + envelope * (x0 * ((float) Math.cos(omega1 * input)) + ((beta * x0 + v0) / omega1) * ((float) Math.sin(omega1 * input)));
        } else if (beta == omega0) {
            return -x0 + envelope * (x0 + (beta * x0 + v0) * input);
        } else {
            return -x0 + envelope * (x0 * ((float) Math.cos(omega2 * input)) + ((beta * x0 + v0) / omega2) * ((float) Math.sin(omega2 * input)));
        }
    }
}
