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

    public static void onStartLoadScript(String oldUrl) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onStartLoadScript(oldUrl);
    }

    public static void onGlobalPrepared(String url) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onGlobalPrepared(url);
    }

    public static void onEnvPrepared(String url) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onEnvPrepared(url);
    }

    public static void onScriptLoaded(String url, ScriptBundle bundle) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptLoaded(url, bundle);
    }

    public static void onScriptLoadFailed(String url, ScriptLoadException e) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptLoadFailed(url, e);
    }

    public static void onScriptCompiled(String url) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptCompiled(url);
    }

    public static void onScriptPrepared(String url) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptPrepared(url);
    }

    public static void onScriptExecuted(String url, boolean success) {
        MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
        if (adapter != null)
            adapter.onScriptExecuted(url, success);
    }
}