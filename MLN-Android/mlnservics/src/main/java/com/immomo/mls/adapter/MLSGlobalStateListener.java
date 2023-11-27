/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter;

import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;

/**
 * Created by XiongFangyu on 2018/6/26.
 * <p>
 * 监听脚本下载，脚本加载
 */
public interface MLSGlobalStateListener {

    void onStartLoadScript(String oldUrl, String tag);

    void onGlobalPrepared(String url, String tag);

    void onEnvPrepared(String url, String tag);

    void onScriptLoaded(String url, ScriptBundle bundle, String tag);

    void onScriptLoadFailed(String url, ScriptLoadException e, String tag);

    void onScriptCompiled(String url, String tag);

    void onScriptPrepared(String url, String tag);

    void onScriptExecuted(String url, boolean success, String tag, String errorMsg);
}