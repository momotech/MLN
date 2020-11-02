/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
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

    @Constant
    int Normal = Linear;
    @Constant
    int Spring = 6;
    @Constant
    int EaseIn = 7;
    @Constant
    int EaseOut = 8;
    @Constant
    int EaseInOut = 9;

    @IntDef({Linear, Accelerate, Decelerate, AccelerateDecelerate, Overshoot, Bounce,
            Spring, EaseIn, EaseOut, EaseInOut})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Interpolators {}
}