/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper.callback;

import com.immomo.mls.wrapper.IJavaObjectGetter;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019/3/21
 *
 * 封装{@link org.luaj.vm2.LuaFunction}的接口
 *
 * 原始回调Lua方法，返回值为boolean类型
 */
public class DefaultBoolCallback extends BaseCallback implements IBoolCallback {


    public DefaultBoolCallback(LuaFunction f) {
        super(f);
    }

    public static final IJavaObjectGetter<LuaFunction, IBoolCallback> G = new IJavaObjectGetter<LuaFunction, IBoolCallback>() {
        @Override
        public DefaultBoolCallback getJavaObject(LuaFunction lv) {
            return new DefaultBoolCallback(lv) ;
        }
    };

    @Override
    public boolean callback(Object... params) throws IllegalStateException {
        LuaValue[] r = invoke(params);
        if (r.length == 0)
            throw new IllegalStateException(function.getInvokeError());
        return r[0].toBoolean();
    }

    @Override
    public boolean callbackAndDestroy(Object... params) throws IllegalStateException {
        LuaValue[] r = invoke(params);
        if (r.length == 0)
            throw new IllegalStateException(function.getInvokeError());
        destroy();
        return r[0].toBoolean();
    }
}