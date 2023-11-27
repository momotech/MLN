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
import java.util.HashMap;
import java.util.Map;

// SDK 耗时打印到 输出窗口
public class GlobalStateSDKListener implements MLSGlobalStateListener {
    private final Map<String, DebugLog> debugLogs;

    public PrintStream STDOUT = null;

    public GlobalStateSDKListener() {
        debugLogs = new HashMap<>();
    }

    protected DebugLog newLog() {
        return new DebugLog();
    }

    @Override
    public void onStartLoadScript(String url, String tag) {
        if (!MLSEngine.DEBUG)
            return;
        DebugLog debugLog = debugLogs.get(url);
        if (debugLog == null) {
            debugLog = newLog();
            debugLogs.put(url, debugLog);
        }
        debugLog.onStart(url);
    }

    @Override
    public void onGlobalPrepared(String url, String tag) {
        if (!MLSEngine.DEBUG)
            return;
        DebugLog debugLog = debugLogs.get(url);
        if (debugLog == null) return;
        debugLog.onGlobalPrepared();
    }

    @Override
    public void onEnvPrepared(String url, String tag) {
        if (!MLSEngine.DEBUG)
            return;
        DebugLog debugLog = debugLogs.get(url);
        if (debugLog == null) return;
        debugLog.envPrepared();
    }

    @Override
    public void onScriptLoaded(String url, ScriptBundle bundle, String tag) {
        if (!MLSEngine.DEBUG)
            return;
        DebugLog debugLog = debugLogs.get(url);
        if (debugLog == null) return;
        debugLog.loaded(bundle);
    }

    @Override
    public void onScriptLoadFailed(String url, ScriptLoadException e, String tag) {

    }

    @Override
    public void onScriptCompiled(String url, String tag) {
        if (!MLSEngine.DEBUG)
            return;
        DebugLog debugLog = debugLogs.get(url);
        if (debugLog == null) return;
        debugLog.compileEnd();
    }

    @Override
    public void onScriptPrepared(String url, String tag) {
        if (!MLSEngine.DEBUG)
            return;
        DebugLog debugLog = debugLogs.get(url);
        if (debugLog == null) return;
        debugLog.prepared();
    }

    @Override
    public void onScriptExecuted(String url, boolean success, String tag, String errorMsg) {
        if (!MLSEngine.DEBUG)
            return;
        DebugLog debugLog = debugLogs.get(url);
        if (debugLog == null) return;
        debugLog.executedEnd(success);
        debugLog.log(STDOUT);
    }

}