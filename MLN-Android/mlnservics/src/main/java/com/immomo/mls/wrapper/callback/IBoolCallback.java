/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper.callback;

import com.immomo.mls.wrapper.GlobalsContainer;

/**
 * Created by Xiong.Fangyu on 2019/3/21
 *
 * 封装{@link org.luaj.vm2.LuaFunction}的接口
 *
 * 回调Lua方法，返回值为boolean类型
 */
public interface IBoolCallback extends Destroyable, ICheckDestroy, GlobalsContainer {
    /**
     * 回调lua方法
     * @param params 参数
     */
    boolean callback(Object... params) throws IllegalStateException;

    /**
     * 回调lua方法，调用之后，将不能再次使用此回调
     * @param params 参数
     */
    boolean callbackAndDestroy(Object... params) throws IllegalStateException;
}