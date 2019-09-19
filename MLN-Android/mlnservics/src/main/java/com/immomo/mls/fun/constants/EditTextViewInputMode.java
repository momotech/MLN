/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.constants;

import android.text.InputType;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@ConstantClass
public interface EditTextViewInputMode {
    // 修改Lua编辑框默认为多行模式，避免Label中lines对于多行的影响
    @Constant
    int Normal = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE;
    @Constant
    int Number = InputType.TYPE_CLASS_NUMBER ;
}