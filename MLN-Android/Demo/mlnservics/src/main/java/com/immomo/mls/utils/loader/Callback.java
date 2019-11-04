package com.immomo.mls.utils.loader;

import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;

/**
 * Created by Xiong.Fangyu on 2018/11/13
 */
public interface Callback {
    void onScriptLoadSuccess(ScriptBundle scriptFile);

    void onScriptLoadFailed(ScriptLoadException e);
}
