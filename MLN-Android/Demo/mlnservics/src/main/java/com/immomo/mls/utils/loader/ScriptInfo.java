package com.immomo.mls.utils.loader;

import com.immomo.mls.Constants;
import com.immomo.mls.InitData;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2018/11/13
 */
public final class ScriptInfo {
    public int loadType;
    public Globals globals;
    public Callback callback;
    public String[] preloadScripts;
    public String hotReloadUrl;
    public long timeout;

    public ScriptInfo(InitData initData) {
        preloadScripts = initData.preloadScripts;
        loadType = initData.loadType;
        timeout = initData.loadTimeout;
    }

    public ScriptInfo withLoadType(@Constants.LoadType int loadType) {
        this.loadType = loadType;
        return this;
    }

    public ScriptInfo withCallback(Callback callback) {
        this.callback = callback;
        return this;
    }

    public ScriptInfo withGlobals(Globals globals) {
        this.globals = globals;
        return this;
    }

    public ScriptInfo whitHotReloadUrl(String url) {
        this.hotReloadUrl = url;
        return this;
    }
}
