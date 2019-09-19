/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.constants;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

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

}