/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.constants;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by wang.yang on 2020/6/8.
 */
@ConstantClass
public interface Timing {
    @Constant
    int Default = 1;
    @Constant
    int Linear = 2;
    @Constant
    int EaseIn = 3;
    @Constant
    int EaseOut = 4;
    @Constant
    int EaseInEaseOut = 5;
    @Constant
    int Spring = 6;
}