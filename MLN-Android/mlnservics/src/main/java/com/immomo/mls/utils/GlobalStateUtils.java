/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.MLSGlobalStateListener;
import com.immomo.mls.wrapper.ScriptBundle;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class GlobalStateUtils {

    public static void onStartLoadScript(String oldUrl, String tag) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onStartLoadScript(oldUrl, tag);
    }

    public static void onGlobalPrepared(String url, String tag) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onGlobalPrepared(url, tag);
    }

    public static void onEnvPrepared(String url, String tag) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onEnvPrepared(url, tag);
    }

    public static void onScriptLoaded(String url, ScriptBundle bundle, String tag) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptLoaded(url, bundle, tag);
    }

    public static void onScriptLoadFailed(String url, ScriptLoadException e, String tag) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptLoadFailed(url, e, tag);
    }

    public static void onScriptCompiled(String url, String tag) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptCompiled(url, tag);
    }

    public static void onScriptPrepared(String url, String tag) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptPrepared(url, tag);
    }

    public static void onScriptExecuted(String url, boolean success, String tag, String errorMsg) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptExecuted(url, success, tag, errorMsg);
    }
}