/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.constants;

import android.view.Gravity;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

@ConstantClass(alias = "Gravity")
public interface GravityConstants {
    @Constant
    int LEFT = Gravity.LEFT;
    @Constant
    int TOP = Gravity.TOP;
    @Constant
    int RIGHT = Gravity.RIGHT;
    @Constant
    int BOTTOM = Gravity.BOTTOM;
    @Constant
    int CENTER_HORIZONTAL = Gravity.CENTER_HORIZONTAL;
    @Constant
    int CENTER_VERTICAL = Gravity.CENTER_VERTICAL;
    @Constant
    int CENTER = Gravity.CENTER;
}