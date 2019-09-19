/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.exception;

import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2019/3/14
 *
 * for native
 */
@LuaApiUsed
public class UndumpError extends RuntimeException {

    @LuaApiUsed
    public UndumpError(String msg) {
        super(msg);
    }
}