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
    public int callback(Object... params) throws IllegalStateException {
        Utils.check(luaFunction);
        LuaValue[] r = Utils.invoke(luaFunction, params);
        if (r.length == 0)
            throw new IllegalStateException(luaFunction.getInvokeError());
        return r[0].toInt();
    }

    @Override
    public int callbackAndDestroy(Object... params) throws IllegalStateException {
        Utils.check(luaFunction);
        LuaValue[] r = Utils.invoke(luaFunction, params);
        if (r.length == 0)
            throw new IllegalStateException(luaFunction.getInvokeError());
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
