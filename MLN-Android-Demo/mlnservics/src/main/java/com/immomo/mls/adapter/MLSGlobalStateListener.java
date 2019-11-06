package com.immomo.mls.adapter;

import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;

/**
 * Created by XiongFangyu on 2018/6/26.
 *
 * 监听脚本下载，脚本加载
 */
public interface MLSGlobalStateListener {

    void onStartLoadScript(String oldUrl);

    void onGlobalPrepared(String url);

    void onEnvPrepared(String url);

    void onScriptLoaded(String url, ScriptBundle bundle);

    void onScriptLoadFailed(String url, ScriptLoadException e);

    void onScriptCompiled(String url);

    void onScriptPrepared(String url);

    void onScriptExecuted(String url, boolean success);

    void onScriptDraw();
}
