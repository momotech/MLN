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
}