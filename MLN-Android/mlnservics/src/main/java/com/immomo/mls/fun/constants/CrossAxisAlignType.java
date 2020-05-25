/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.constants;


import com.immomo.mls.fun.weight.newui.CrossAxisAlignment;
import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

@ConstantClass(alias = "CrossAxisAlignment")
public interface CrossAxisAlignType {
    @Constant
    int START = CrossAxisAlignment.START;
    @Constant
    int CENTER = CrossAxisAlignment.CENTER;
    @Constant
    int END = CrossAxisAlignment.END;
}
