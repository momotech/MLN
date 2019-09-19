/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.constants;

import com.immomo.mls.fun.weight.span.DynamicDrawableSpan;
import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by zhang.ke
 * StyleString 富文本，图片依赖方向
 * on 2019/7/30
 */
@ConstantClass
public interface StyleImageAlign {
    @Constant
    int Default = DynamicDrawableSpan.ALIGN_BOTTOM;//默认
    @Constant
    int Top = DynamicDrawableSpan.ALIGN_TOPLINE;   //图片上边沿与文字上边沿对齐
    @Constant
    int Center = DynamicDrawableSpan.ALIGN_CENTERVERTICAL;   //图片在一条水平线上
    @Constant
    int Bottom = DynamicDrawableSpan.ALIGN_BOTTOM;   //图片下边沿与文字下边沿对齐
}