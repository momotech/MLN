/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by zhang.ke
 * on 2018/11/27
 */
@ConstantClass
public interface ValueType {
    @Constant
    int NONE = 0;

    @Constant
    int CURRENT = Integer.MAX_VALUE;
}