package com.immomo.mls.lite;

import com.immomo.mls.fun.globals.LuaView;
import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.wrapper.ScriptBundle;

import java.lang.ref.WeakReference;

public interface Call {
    ScriptBundle request();
    WeakReference<LuaView> window();
    ScriptResult execute();

    /**
     * 回收
     */
    void recycle();
    interface Factory {
        Call newCall(ScriptBundle request);
    }
}
