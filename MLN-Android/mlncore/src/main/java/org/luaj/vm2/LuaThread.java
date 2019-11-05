/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2019/2/22
 * <p>
 * Lua 线程，暂无接口
 */
@LuaApiUsed
public class LuaThread extends NLuaValue {

    @LuaApiUsed
    LuaThread(long L_state, long stackIndex) {
        super(L_state, stackIndex);
    }

    @Override
    public final int type() {
        return LUA_TTHREAD;
    }

    public final LuaThread toLuaThread() {
        return this;
    }
}