/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim;

import android.animation.ValueAnimator;
import androidx.annotation.IntDef;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by XiongFangyu on 2018/8/10.
 */
@ConstantClass
public interface RepeatType {
    @Constant
    int NONE = 0;
    @Constant
    int FROM_START = ValueAnimator.RESTART;
    @Constant
    int REVERSE = ValueAnimator.REVERSE;

    @Constant
    int Normal = FROM_START;

    @Constant
    int Reverse = REVERSE;

    @IntDef({FROM_START, REVERSE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface RepeatMode {}
}