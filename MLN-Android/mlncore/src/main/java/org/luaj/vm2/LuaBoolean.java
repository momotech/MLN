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
 * Created by Xiong.Fangyu on 2019/2/21
 *
 * Lua boolean 数据
 * 通过 {@link LuaValue#True()} {@link LuaValue#False()}获取
 *
 * 不要随意修改！see luajapi.c
 */
@LuaApiUsed
public final class LuaBoolean extends LuaValue {

    private static volatile LuaBoolean TRUE;
    private static volatile LuaBoolean FALSE;

    @LuaApiUsed
    static LuaBoolean TRUE() {
        if (TRUE == null) {
            synchronized (LuaBoolean.class) {
                if (TRUE == null) {
                    TRUE = new LuaBoolean(true);
                }
            }
        }
        return TRUE;
    }

    @LuaApiUsed
    static LuaBoolean FALSE() {
        if (FALSE == null) {
            synchronized (LuaBoolean.class) {
                if (FALSE == null) {
                    FALSE = new LuaBoolean(false);
                }
            }
        }
        return FALSE;
    }

    @LuaApiUsed
    private final boolean value;

    private LuaBoolean(boolean v) {
        value = v;
    }

    @Override
    public int type() {
        return LUA_TBOOLEAN;
    }

    @Override
    public boolean toBoolean() {
        return value;
    }

    @Override
    public String toJavaString() {
        return String.valueOf(value);
    }

    @Override
    public String toString() {
        return LUA_TYPE_NAME[type()] + "@" + value;
    }

    public static LuaValue valueOf(boolean value) {
        return new LuaBoolean(value);
    }
}