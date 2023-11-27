/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.constants;

import androidx.annotation.IntDef;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by XiongFangyu on 2018/8/21.
 */
@ConstantClass
public interface GradientType {

    @Constant
    int LEFT_TO_RIGHT = 1;

    @Constant
    int RIGHT_TO_LEFT = 2;

    @Constant
    int TOP_TO_BOTTOM = 3;

    @Constant
    int BOTTOM_TO_TOP = 4;

    @IntDef({LEFT_TO_RIGHT, RIGHT_TO_LEFT, TOP_TO_BOTTOM, BOTTOM_TO_TOP})
    @Retention(RetentionPolicy.SOURCE)
    @interface Type {}
}