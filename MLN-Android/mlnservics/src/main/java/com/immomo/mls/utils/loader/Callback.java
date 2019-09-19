/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils.loader;

import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;

/**
 * Created by Xiong.Fangyu on 2018/11/13
 */
public interface Callback {
    void onScriptLoadSuccess(ScriptBundle scriptFile);

    void onScriptLoadFailed(ScriptLoadException e);
}