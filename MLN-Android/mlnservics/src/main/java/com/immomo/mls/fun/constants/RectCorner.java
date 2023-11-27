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
public interface RectCorner {
    @Constant
    int TOP_LEFT = 1;
    @Constant
    int TOP_RIGHT = 2;
    @Constant
    int BOTTOM_LEFT = 4;
    @Constant
    int BOTTOM_RIGHT = 8;
    @Constant
    int ALL_CORNERS = 15;


    @IntDef({TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, ALL_CORNERS})
    @Retention(RetentionPolicy.SOURCE)
    @interface Direction {}
}