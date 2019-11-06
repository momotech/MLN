package com.immomo.mls.utils;

import android.os.Looper;

import com.immomo.mls.base.exceptions.CalledFromWrongThreadException;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.Translator;
import com.immomo.mls.wrapper.callback.DefaultVoidCallback;

import org.luaj.vm2.LuaFunction;

/**
 * Created by XiongFangyu on 2018/7/2.
 */
public class SimpleLVCallback extends DefaultVoidCallback implements LVCallback {
    private Looper myLooper;

    public SimpleLVCallback(LuaFunction f) {
        super(f);
        myLooper = Looper.myLooper();
    }

    public static final IJavaObjectGetter<LuaFunction, LVCallback> G = new IJavaObjectGetter<LuaFunction, LVCallback>() {
        @Override
        public LVCallback getJavaObject(LuaFunction f) {
            return new SimpleLVCallback(f);
        }
    };

    @Override
    public boolean call(Object... params) {
        if (luaFunction == null || luaFunction.isDestroyed())
            return false;
        checkThread();
        try {
            super.callback(params);
            return true;
        } catch (Throwable ignore) {}
        return false;
    }

    private void checkThread() {
        if (myLooper != Looper.myLooper())
            throw new CalledFromWrongThreadException(
                "Only the original thread that created lua stack can touch its stack.");
    }
}
