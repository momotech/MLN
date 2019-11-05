/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.MLSGlobalStateListener;
import com.immomo.mls.wrapper.ScriptBundle;

import java.io.PrintStream;

// SDK 耗时打印到 输出窗口
public class GlobalStateSDKListener implements MLSGlobalStateListener {
    private DebugLog debugLog;

    public PrintStream STDOUT = null;

    protected DebugLog newLog() {
        return new DebugLog();
    }

    @Override
    public void onStartLoadScript(String url) {
        if (!MLSEngine.DEBUG)
            return;
        if (debugLog == null) {
            debugLog = newLog();
        }
        debugLog.onStart(url);
    }

    @Override
    public void onGlobalPrepared(String url) {
        if (!MLSEngine.DEBUG)
            return;
        debugLog.onGlobalPrepared();
    }

    @Override
    public void onEnvPrepared(String url) {
        if (!MLSEngine.DEBUG)
            return;
        debugLog.envPrepared();
    }

    @Override
    public void onScriptLoaded(String url, ScriptBundle bundle) {
        if (!MLSEngine.DEBUG)
            return;
        if (debugLog != null)
            debugLog.loaded(bundle);
    }

    @Override
    public void onScriptLoadFailed(String url, ScriptLoadException e) {

    }

    @Override
    public void onScriptCompiled(String url) {
        if (!MLSEngine.DEBUG)
            return;
        debugLog.compileEnd();
    }

    @Override
    public void onScriptPrepared(String url) {
        if (!MLSEngine.DEBUG)
            return;
        debugLog.prepared();
    }

    @Override
    public void onScriptExecuted(String url, boolean success) {
        if (!MLSEngine.DEBUG)
            return;
        debugLog.executedEnd(success);
        debugLog.log(STDOUT);
    }

}