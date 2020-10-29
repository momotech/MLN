/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.constants;

import com.facebook.yoga.YogaPositionType;
import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by zhang.ke
 * on 2020-06-04
 */
@ConstantClass
public interface PositionType {
    @Constant
    int RELATIVE = YogaPositionType.RELATIVE.ordinal();
    @Constant
    int ABSOLUTE = YogaPositionType.ABSOLUTE.ordinal();
}