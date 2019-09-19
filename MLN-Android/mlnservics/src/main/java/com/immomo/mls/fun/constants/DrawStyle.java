/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.constants;

import android.graphics.Paint;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by zhang.ke
 * on 2019/7/25
 */
@ConstantClass
public interface DrawStyle {
    @Constant
    int Fill = Paint.Style.FILL.ordinal();
    @Constant
    int Stroke = Paint.Style.STROKE.ordinal();
    @Constant
    int FillStroke = Paint.Style.FILL_AND_STROKE.ordinal();
}