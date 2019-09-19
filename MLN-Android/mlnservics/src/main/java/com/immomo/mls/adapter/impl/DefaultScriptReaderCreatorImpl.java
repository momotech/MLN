/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter.impl;

import com.immomo.mls.adapter.ScriptReaderCreator;
import com.immomo.mls.adapter.ScriptReader;

/**
 * Created by Xiong.Fangyu on 2018/11/13
 */
public class DefaultScriptReaderCreatorImpl implements ScriptReaderCreator {
    @Override
    public ScriptReader newScriptLoader(String src) {
        return new DefaultScriptReaderImpl(src);
    }
}