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
import com.facebook.yoga.YogaAlign;

/**
 * Created by zhang.ke
 * on 2020-06-01
 */
@ConstantClass
public interface CrossAxis {
    @Constant
    int AUTO = YogaAlign.AUTO.intValue();
    @Constant
    int START = YogaAlign.FLEX_START.intValue();
    @Constant
    int CENTER = YogaAlign.CENTER.intValue();
    @Constant
    int END = YogaAlign.FLEX_END.intValue();
    @Constant
    int STRETCH = YogaAlign.STRETCH.intValue();
    @Constant
    int BASELINE = YogaAlign.BASELINE.intValue();
    @Constant
    int SPACE_BETWEEN = YogaAlign.SPACE_BETWEEN.intValue();
    @Constant
    int SPACE_AROUND = YogaAlign.SPACE_AROUND.intValue();
}