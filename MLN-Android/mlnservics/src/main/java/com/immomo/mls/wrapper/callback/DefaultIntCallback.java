/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper.callback;


import com.immomo.mls.wrapper.IJavaObjectGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019/3/21
 *
 * 封装{@link org.luaj.vm2.LuaFunction}的接口
 *
 * 原始回调Lua方法，返回值为int数字类型
 */
public class DefaultIntCallback implements IIntCallback {

    private LuaFunction luaFunction;

    public DefaultIntCallback(LuaFunction f) {
        luaFunction = f;
    }

    public static final IJavaObjectGetter<LuaFunction, IIntCallback> G = new IJavaObjectGetter<LuaFunction, IIntCallback>() {
        @Override
        public IIntCallback getJavaObject(LuaFunction lv) {
            return new DefaultIntCallback(lv) ;
        }
    };

    @Override
    public int callback(Object... params) {
        Utils.check(luaFunction);
        LuaValue[] r = Utils.invoke(luaFunction, params);
        return r[0].toInt();
    }

    @Override
    public int callbackAndDestroy(Object... params) {
        Utils.check(luaFunction);
        LuaValue[] r = Utils.invoke(luaFunction, params);
        luaFunction.destroy();
        luaFunction = null;
        return r[0].toInt();
    }

    @Override
    public void destroy() {
        if (luaFunction != null)
            luaFunction.destroy();
        luaFunction = null;
    }

    @Override
    public Globals getGlobals() {
        return luaFunction != null ? luaFunction.getGlobals() : null;
    }
}