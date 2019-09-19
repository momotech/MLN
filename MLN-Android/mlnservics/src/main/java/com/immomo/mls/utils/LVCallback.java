/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import com.immomo.mls.wrapper.callback.Destroyable;

import androidx.annotation.Nullable;

/**
 * Created by XiongFangyu on 2018/7/2.
 */
public interface LVCallback extends Destroyable{
    /**
     * callback to lua
     * @param params
     * @return true if call success
     */
    boolean call(@Nullable Object... params);
}