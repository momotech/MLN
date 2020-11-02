/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils.loader;

import android.content.Context;

import com.immomo.mls.Constants;
import com.immomo.mls.InitData;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2018/11/13
 */
public final class ScriptInfo {
    public Context context;
    /**
     * @see Constants.LoadType
     */
    public int loadType;
    /**
     * 虚拟机
     */
    public Globals globals;
    /**
     * 回调
     */
    public Callback callback;
    /**
     * 需要预加载的脚本
     */
    public String[] preloadScripts;
    /**
     * 热重载使用的url
     */
    public String hotReloadUrl;
    /**
     * 超时，ms
     */
    public long timeout;

    public ScriptInfo(InitData initData) {
        preloadScripts = initData.preloadScripts;
        loadType = initData.loadType;
        timeout = initData.loadTimeout;
    }

    public ScriptInfo withContext(Context context) {
        this.context = context;
        return this;
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