package com.immomo.mls.fun.ud.anim;

import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.BounceInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.Interpolator;
import android.view.animation.LinearInterpolator;
import android.view.animation.OvershootInterpolator;

/**
 * Created by XiongFangyu on 2018/8/10.
 */
public class Utils {
    final static Interpolator linear = new LinearInterpolator();
    static Interpolator Accelerate;
    static Interpolator Decelerate;
    static Interpolator AccelerateDecelerate;
    static Interpolator Overshoot;
    static Interpolator Bounce;
    public static Interpolator parse(@InterpolatorType.Interpolators int type) {
        switch (type) {
            case InterpolatorType.Accelerate:
                if (Accelerate == null)
                    Accelerate = new AccelerateInterpolator();
                return Accelerate;
            case InterpolatorType.Decelerate:
                if (Decelerate == null)
                    Decelerate = new DecelerateInterpolator();
                return Decelerate;
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
        }
        return linear;
    }
}
