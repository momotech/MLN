/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.constants;

import android.graphics.Path;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by zhang.ke
 * on 2019/7/25
 */
@ConstantClass
public interface FillType {
    @Constant
    int WINDING = Path.FillType.WINDING.ordinal();
    @Constant
    int EVEN_ODD = Path.FillType.EVEN_ODD.ordinal();
    @Constant
    int INVERSE_WINDING = Path.FillType.INVERSE_WINDING.ordinal();
    @Constant
    int INVERSE_EVEN_ODD = Path.FillType.INVERSE_EVEN_ODD.ordinal();
}