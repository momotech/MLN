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
import com.facebook.yoga.YogaJustify;

/**
 * Created by zhang.ke
 * on 2020-06-01
 */
@ConstantClass
public interface MainAxis {
    @Constant
    int START = YogaJustify.FLEX_START.ordinal();
    @Constant
    int CENTER = YogaJustify.CENTER.ordinal();
    @Constant
    int END = YogaJustify.FLEX_END.ordinal();
    @Constant
    int SPACE_BETWEEN = YogaJustify.SPACE_BETWEEN.ordinal();
    @Constant
    int SPACE_AROUND = YogaJustify.SPACE_AROUND.ordinal();
    @Constant
    int SPACE_EVENLY = YogaJustify.SPACE_EVENLY.ordinal();


}