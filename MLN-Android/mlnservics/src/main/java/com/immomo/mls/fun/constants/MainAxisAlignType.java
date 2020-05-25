/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.constants;


import com.immomo.mls.fun.weight.newui.MainAxisAlignment;
import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

@ConstantClass(alias = "MainAxisAlignment")
public interface MainAxisAlignType {
    @Constant
    int START = MainAxisAlignment.START;
    @Constant
    int CENTER = MainAxisAlignment.CENTER;
    @Constant
    int END = MainAxisAlignment.END;

    @Constant
    int SPACE_BETWEEN = MainAxisAlignment.SPACE_BETWEEN;
    @Constant
    int SPACE_AROUND = MainAxisAlignment.SPACE_AROUND;
    @Constant
    int SPACE_EVENLY = MainAxisAlignment.SPACE_EVENLY;
}
