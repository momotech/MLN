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

/**
 * Created by Xiong.Fangyu on 2019/3/21
 *
 * 封装{@link org.luaj.vm2.LuaFunction}的接口
 *
 * 回调Lua方法，不关心返回值
 */
public class DefaultVoidCallback extends BaseCallback implements IVoidCallback {

    public DefaultVoidCallback(LuaFunction f) {
        super(f);
    }

    public static final IJavaObjectGetter<LuaFunction, IVoidCallback> G = new IJavaObjectGetter<LuaFunction, IVoidCallback>() {
        @Override
        public IVoidCallback getJavaObject(LuaFunction lv) {
            return new DefaultVoidCallback(lv) ;
        }
    };

    @Override
    public void callback(Object... params) {
        invoke(params);
    }

    @Override
    public void callbackAndDestroy(Object... params) {
        invoke(params);
        destroy();
    }
}