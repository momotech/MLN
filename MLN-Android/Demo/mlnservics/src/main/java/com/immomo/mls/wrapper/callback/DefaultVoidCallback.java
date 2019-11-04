package com.immomo.mls.wrapper.callback;

import com.immomo.mls.wrapper.IJavaObjectGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;

/**
 * Created by Xiong.Fangyu on 2019/3/21
 *
 * 封装{@link org.luaj.vm2.LuaFunction}的接口
 *
 * 回调Lua方法，不关心返回值
 */
public class DefaultVoidCallback implements IVoidCallback {

    protected LuaFunction luaFunction;

    public DefaultVoidCallback(LuaFunction f) {
        luaFunction = f;
    }

    public static final IJavaObjectGetter<LuaFunction, IVoidCallback> G = new IJavaObjectGetter<LuaFunction, IVoidCallback>() {
        @Override
        public IVoidCallback getJavaObject(LuaFunction lv) {
            return new DefaultVoidCallback(lv) ;
        }
    };

    @Override
    public void callback(Object... params) {
        Utils.check(luaFunction);
        Utils.invoke(luaFunction, params);
    }

    @Override
    public void callbackAndDestroy(Object... params) {
        Utils.check(luaFunction);
        Utils.invoke(luaFunction, params);
        luaFunction.destroy();
        luaFunction = null;
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
