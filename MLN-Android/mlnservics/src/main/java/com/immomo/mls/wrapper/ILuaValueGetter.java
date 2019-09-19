/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019/3/19
 *
 * lua数据类型转换接口
 */
public interface ILuaValueGetter<L extends LuaValue, O> {
    /**
     * 不可返回null
     * 使用 {@link LuaValue#Nil()} 代替null
     * @param g     虚拟机信息
     * @param obj   原始数据
     * @return nonnull
     */
    L newInstance(Globals g, O obj);
}