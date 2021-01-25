/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.constants;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;
import com.facebook.yoga.YogaWrap;

/**
 * Created by zhang.ke
 * on 2020-06-01
 */
@ConstantClass
public interface Wrap {
    @Constant
    int NO_WRAP = YogaWrap.NO_WRAP.intValue();
    @Constant
    int WRAP = YogaWrap.WRAP.intValue();
    @Constant
    int WRAP_REVERSE = YogaWrap.WRAP_REVERSE.intValue();
}