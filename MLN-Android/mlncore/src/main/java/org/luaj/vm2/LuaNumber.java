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
 * Lua 数字封装类
 * 通过{@link #valueOf(int)} {@link #valueOf(double)}创建
 */
@LuaApiUsed
public final class LuaNumber extends LuaValue {
    private static final int MAX_CACHE = 256;
    private static final int low = -128;
    private static final int high = MAX_CACHE + low;
    private static final LuaNumber[] cache;

    static {
        cache = new LuaNumber[MAX_CACHE];
        for (int i = 0; i < MAX_CACHE; i++) {
            cache[i] = new LuaNumber(i - 128);
        }
    }

    @LuaApiUsed
    private final double value;

    private final boolean isInt;

    private LuaNumber(int value) {
        this.value = value;
        isInt = true;
    }

    @LuaApiUsed
    private LuaNumber(double value) {
        this.value = value;
        isInt = false;
    }

    /**
     * 将java int类型转换成LuaNumber
     * 若数字在-128 ~ 127之间，则使用缓存
     */
    @LuaApiUsed
    public static LuaNumber valueOf(int value) {
        if (value >= low && value < high) {
            return cache[value - low];
        }
        return new LuaNumber(value);
    }

    /**
     * 若value值为整形，则使用{@link #valueOf(int)}创建
     */
    public static LuaNumber valueOf(double value) {
        if (value == (int) value) {
            return valueOf((int) value);
        }
        return new LuaNumber(value);
    }

    @Override
    public int type() {
        return LUA_TNUMBER;
    }

    @Override
    public int toInt() {
        return (int) value;
    }

    @Override
    public double toDouble() {
        return value;
    }

    @Override
    public boolean isInt() {
        return isInt;
    }

    @Override
    public String toJavaString() {
        if (value == (int)value)
            return Integer.toString((int)value);
        return String.valueOf(value);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        LuaNumber luaNumber = (LuaNumber) o;
        return Double.compare(luaNumber.value, value) == 0;
    }

    @Override
    public int hashCode() {
        long bits = Double.doubleToLongBits(value);
        return 31 + (int) (bits ^ (bits >>> 32));
    }

    @Override
    public String toString() {
        return LUA_TYPE_NAME[type()] + "@" + value;
    }
}