/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter;

import com.immomo.mls.utils.loader.ScriptInfo;

/**
 * Created by Xiong.Fangyu on 2018/11/1
 */
public interface ScriptReader {

    void loadScriptImpl(final ScriptInfo info);

    String getScriptVersion();

    Object getTaskTag();

    void onDestroy();
}