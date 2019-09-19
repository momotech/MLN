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
 * <p>
 * Lua string 类型包装类
 *
 * 使用{@link #valueOf(String)} 创建
 */
@LuaApiUsed
public final class LuaString extends LuaValue {
    @LuaApiUsed
    private final String value;

    @LuaApiUsed
    private LuaString(String value) {
        this.value = value;
    }

    /**
     * 使用此方法创建LuaString
     * @param value 可为空的字符串
     * @return nil if value is null
     */
    public static LuaValue valueOf(String value) {
        if (value == null)
            return LuaValue.Nil();
        return new LuaString(value);
    }

    @Override
    public int type() {
        return LUA_TSTRING;
    }

    @Override
    public String toJavaString() {
        return value;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        LuaString luaString = (LuaString) o;
        return value.equals(luaString.value);
    }

    @Override
    public int hashCode() {
        return 31 + value.hashCode();
    }

    @Override
    public String toString() {
        return LUA_TYPE_NAME[type()] + "@" + value;
    }
}