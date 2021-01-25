/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim;

import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.BounceInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.Interpolator;
import android.view.animation.LinearInterpolator;
import android.view.animation.OvershootInterpolator;

import com.immomo.mls.fun.ud.anim.interpolator.SpringInterpolator;

/**
 * Created by XiongFangyu on 2018/8/10.
 */
public class Utils {
    public final static Interpolator linear = new LinearInterpolator();
    static Interpolator Accelerate;
    static Interpolator Decelerate;
    static Interpolator AccelerateDecelerate;
    static Interpolator Overshoot;
    static Interpolator Bounce;
    static Interpolator Spring;
    public static Interpolator parse(@InterpolatorType.Interpolators int type) {
        switch (type) {
            case InterpolatorType.EaseIn:
            case InterpolatorType.Accelerate:
                if (Accelerate == null)
                    Accelerate = new AccelerateInterpolator();
                return Accelerate;
            case InterpolatorType.EaseOut:
            case InterpolatorType.Decelerate:
                if (Decelerate == null)
                    Decelerate = new DecelerateInterpolator();
                return Decelerate;
            case InterpolatorType.EaseInOut:
            case InterpolatorType.AccelerateDecelerate:
                if (AccelerateDecelerate == null)
                    AccelerateDecelerate = new AccelerateDecelerateInterpolator();
                return AccelerateDecelerate;
            case InterpolatorType.Overshoot:
                if (Overshoot == null)
                    Overshoot = new OvershootInterpolator();
                return Overshoot;
            case InterpolatorType.Bounce:
                if (Bounce == null)
                    Bounce = new BounceInterpolator();
                return Bounce;

            case InterpolatorType.Spring:
                if (Spring == null)
                    Spring = new SpringInterpolator();
                return Spring;
        }
        return linear;
    }

    public static Interpolator parse(@InterpolatorType.Interpolators int type, long duration) {
        switch (type) {
//            case InterpolatorType.EaseIn:
//                return new EaseInInterpolator(duration);
//            case InterpolatorType.EaseOut:
//                return new EaseOutInterpolator(duration);
//            case InterpolatorType.EaseInOut:
//                return new EaseInEaseOutInterpolator(duration);
            default:
                return parse(type);
        }
    }
}