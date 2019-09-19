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
 * Created by Xiong.Fangyu on 2019/2/21
 * <p>
 * Lua类型转换错误
 *
 * @see org.luaj.vm2.LuaValue
 */
@LuaApiUsed
public class LuaTypeError extends RuntimeException {

    public LuaTypeError() {
    }

    public LuaTypeError(Throwable cause) {
        super(cause);
    }

    public LuaTypeError(String msg) {
        super(msg);
    }

    public LuaTypeError(String msg, Throwable cause) {
        super(msg, cause);
    }
}