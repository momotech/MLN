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
 * Created by Xiong.Fangyu on 2019/2/26
 * <p>
 * 调用函数报错，由Native抛出
 */
@LuaApiUsed
public class InvokeError extends RuntimeException {
    private int type = 0;

    @LuaApiUsed
    public InvokeError(String msg) {
        super(msg);
        if ("function is destroyed.".equals(msg)) {
            type = 1;
        }
    }

    @LuaApiUsed
    public InvokeError(String msg, Throwable t) {
        super(msg, t);
    }

    public InvokeError(String msg, int type) {
        super(msg);
        this.type = type;
    }

    public int getType() {
        return type;
    }
}