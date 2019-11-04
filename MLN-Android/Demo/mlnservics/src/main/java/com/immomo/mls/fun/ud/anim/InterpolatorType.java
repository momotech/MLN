package com.immomo.mls.fun.ud.anim;

import androidx.annotation.IntDef;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by XiongFangyu on 2018/8/10.
 */
@ConstantClass
public interface InterpolatorType {
    @Constant
    int Linear = 0;
    @Constant
    int Accelerate = 1;
    @Constant
    int Decelerate = 2;
    @Constant
    int AccelerateDecelerate = 3;
    @Constant
    int Overshoot = 4;
    @Constant
    int Bounce = 5;

    @IntDef({Linear, Accelerate, Decelerate, AccelerateDecelerate, Overshoot, Bounce})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Interpolators {}
}
