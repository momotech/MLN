/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.callback.DefaultVoidCallback;

import org.luaj.vm2.LuaFunction;

/**
 * Created by XiongFangyu on 2018/7/2.
 */
public class SimpleLVCallback extends DefaultVoidCallback implements LVCallback {

    public static final IJavaObjectGetter<LuaFunction, LVCallback> G = new IJavaObjectGetter<LuaFunction, LVCallback>() {
        @Override
        public LVCallback getJavaObject(LuaFunction f) {
            return new SimpleLVCallback(f);
        }
    };

    public SimpleLVCallback(LuaFunction f) {
        super(f);
    }

    @Override
    public boolean call(Object... params) {
        if (isDestroy())
            return false;
        try {
            super.callback(params);
            return true;
        } catch (Throwable ignore) {}
        return false;
    }
}