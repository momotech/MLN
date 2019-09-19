/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019-08-21
 */
public interface GlobalsContainer {

    Globals getGlobals();
}