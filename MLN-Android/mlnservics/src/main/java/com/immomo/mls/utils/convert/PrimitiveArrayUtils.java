/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils.convert;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.exception.LuaTypeError;

/**
 * Created by Xiong.Fangyu on 2019-10-10
 *
 * 基本数据类型数组转换工具
 *
 * lua ---> java
 *  必须由lua数组转换，比如 table {1,2,1} 可转换为 java [1,2,1]
 *  必须满足lua数组规范：下标从1开始，中间没有nil值
 *  当数组中类型不一致时，发生异常{@link LuaTypeError}
 *
 * java ---> lua
 *  转换为lua的table，且下标从1开始
 *  不在虚拟机线程中调用，发生异常{@link IllegalStateException}
 *
 * 非基本数据类型可通过
 * @see org.luaj.vm2.jse.Utils#toNativeArray(LuaTable, Class)
 * @see org.luaj.vm2.jse.Utils#toLuaArray(Globals, Object[])
 */
public class PrimitiveArrayUtils {
    //<editor-fold desc="lua --> java">
    /**
     * 将lua数组转换层java的boolean数组
     *
     * @param t lua的table数组类型，满足lua数组规范
     * @return null: lua数组为空
     *
     * @throws LuaTypeError 数组中有类型不是boolean值，则抛出异常
     */
    public static @Nullable boolean[] toBooleanArray(@Nullable LuaTable t) {
        int len = t == null ? 0 : t.getn();
        if (len == 0) return null;
        boolean[] ret = new boolean[len];
        for (int i = 0; i < len; i ++) {
            ret[i] = t.get(i + 1).toBoolean();
        }
        return ret;
    }

    /**
     * 将lua数组转换层java的byte数组
     *
     * @param t lua的table数组类型，满足lua数组规范
     * @return null: lua数组为空
     *
     * @throws LuaTypeError 数组中有类型不是number值，则抛出异常
     */
    public static @Nullable byte[] toByteArray(@Nullable LuaTable t) {
        int len = t == null ? 0 : t.getn();
        if (len == 0) return null;
        byte[] ret = new byte[len];
        for (int i = 0; i < len; i ++) {
            ret[i] = (byte) t.get(i + 1).toInt();
        }
        return ret;
    }

    /**
     * 将lua数组转换层java的char数组
     *
     * @param t lua的table数组类型，满足lua数组规范
     * @return null: lua数组为空
     *
     * @throws LuaTypeError 数组中有类型不是number值，则抛出异常
     */
    public static @Nullable char[] toCharArray(@Nullable LuaTable t) {
        int len = t == null ? 0 : t.getn();
        if (len == 0) return null;
        char[] ret = new char[len];
        for (int i = 0; i < len; i ++) {
            ret[i] = (char) t.get(i + 1).toInt();
        }
        return ret;
    }

    /**
     * 将lua数组转换层java的int数组
     *
     * @param t lua的table数组类型，满足lua数组规范
     * @return null: lua数组为空
     *
     * @throws LuaTypeError 数组中有类型不是number值，则抛出异常
     */
    public static @Nullable int[] toIntArray(@Nullable LuaTable t) {
        int len = t == null ? 0 : t.getn();
        if (len == 0) return null;
        int[] ret = new int[len];
        for (int i = 0; i < len; i ++) {
            ret[i] = t.get(i + 1).toInt();
        }
        return ret;
    }

    /**
     * 将lua数组转换层java的float数组
     *
     * @param t lua的table数组类型，满足lua数组规范
     * @return null: lua数组为空
     *
     * @throws LuaTypeError 数组中有类型不是number值，则抛出异常
     */
    public static @Nullable float[] toFloatArray(@Nullable LuaTable t) {
        int len = t == null ? 0 : t.getn();
        if (len == 0) return null;
        float[] ret = new float[len];
        for (int i = 0; i < len; i ++) {
            ret[i] = t.get(i + 1).toFloat();
        }
        return ret;
    }

    /**
     * 将lua数组转换层java的double数组
     *
     * @param t lua的table数组类型，满足lua数组规范
     * @return null: lua数组为空
     *
     * @throws LuaTypeError 数组中有类型不是number值，则抛出异常
     */
    public static @Nullable double[] toDoubleArray(@Nullable LuaTable t) {
        int len = t == null ? 0 : t.getn();
        if (len == 0) return null;
        double[] ret = new double[len];
        for (int i = 0; i < len; i ++) {
            ret[i] = t.get(i + 1).toDouble();
        }
        return ret;
    }

    /**
     * 将lua数组转换层java的long数组
     *
     * @param t lua的table数组类型，满足lua数组规范
     * @return null: lua数组为空
     *
     * @throws LuaTypeError 数组中有类型不是number值，则抛出异常
     */
    public static @Nullable long[] toLongArray(@Nullable LuaTable t) {
        int len = t == null ? 0 : t.getn();
        if (len == 0) return null;
        long[] ret = new long[len];
        for (int i = 0; i < len; i ++) {
            ret[i] = (long) t.get(i + 1).toDouble();
        }
        return ret;
    }
    //</editor-fold>

    //<editor-fold desc="java --> lua">

    /**
     * 将java的boolean数组转换为lua的table数组
     * 转换后的数组满足lua数组规范，下标从1开始
     * 必须在主线程中调用
     * @param g 虚拟机
     * @param ba boolean数组
     * @return null: 数组为空，或虚拟机以销毁
     * @throws IllegalStateException 如果不在主线程中执行，抛出异常
     */
    @MainThread
    public static @Nullable LuaTable toTable(@NonNull Globals g, @Nullable boolean[] ba) {
        if (g.isDestroyed())
            return null;
        int len = ba == null ? 0 : ba.length;
        if (len == 0) return null;

        LuaTable table = LuaTable.create(g);
        for (int i = 0; i < len ; i ++) {
            table.set(i + 1, ba[i]);
        }
        return table;
    }

    /**
     * 将java的byte数组转换为lua的table数组
     * 转换后的数组满足lua数组规范，下标从1开始
     * 必须在主线程中调用
     * @param g 虚拟机
     * @param ba byte数组
     * @return null: 数组为空，或虚拟机以销毁
     * @throws IllegalStateException 如果不在主线程中执行，抛出异常
     */
    @MainThread
    public static @Nullable LuaTable toTable(@NonNull Globals g, @Nullable byte[] ba) {
        if (g.isDestroyed())
            return null;
        int len = ba == null ? 0 : ba.length;
        if (len == 0) return null;

        LuaTable table = LuaTable.create(g);
        for (int i = 0; i < len ; i ++) {
            table.set(i + 1, ba[i]);
        }
        return table;
    }

    /**
     * 将java的char数组转换为lua的table数组
     * 转换后的数组满足lua数组规范，下标从1开始
     * 必须在主线程中调用
     * @param g 虚拟机
     * @param ba char数组
     * @return null: 数组为空，或虚拟机以销毁
     * @throws IllegalStateException 如果不在主线程中执行，抛出异常
     */
    @MainThread
    public static @Nullable LuaTable toTable(@NonNull Globals g, @Nullable char[] ba) {
        if (g.isDestroyed())
            return null;
        int len = ba == null ? 0 : ba.length;
        if (len == 0) return null;

        LuaTable table = LuaTable.create(g);
        for (int i = 0; i < len ; i ++) {
            table.set(i + 1, ba[i]);
        }
        return table;
    }

    /**
     * 将java的int数组转换为lua的table数组
     * 转换后的数组满足lua数组规范，下标从1开始
     * 必须在主线程中调用
     * @param g 虚拟机
     * @param ba int数组
     * @return null: 数组为空，或虚拟机以销毁
     * @throws IllegalStateException 如果不在主线程中执行，抛出异常
     */
    @MainThread
    public static @Nullable LuaTable toTable(@NonNull Globals g, @Nullable int[] ba) {
        if (g.isDestroyed())
            return null;
        int len = ba == null ? 0 : ba.length;
        if (len == 0) return null;

        LuaTable table = LuaTable.create(g);
        for (int i = 0; i < len ; i ++) {
            table.set(i + 1, ba[i]);
        }
        return table;
    }

    /**
     * 将java的float数组转换为lua的table数组
     * 转换后的数组满足lua数组规范，下标从1开始
     * 必须在主线程中调用
     * @param g 虚拟机
     * @param ba float数组
     * @return null: 数组为空，或虚拟机以销毁
     * @throws IllegalStateException 如果不在主线程中执行，抛出异常
     */
    @MainThread
    public static @Nullable LuaTable toTable(@NonNull Globals g, @Nullable float[] ba) {
        if (g.isDestroyed())
            return null;
        int len = ba == null ? 0 : ba.length;
        if (len == 0) return null;

        LuaTable table = LuaTable.create(g);
        for (int i = 0; i < len ; i ++) {
            table.set(i + 1, ba[i]);
        }
        return table;
    }

    /**
     * 将java的long数组转换为lua的table数组
     * 转换后的数组满足lua数组规范，下标从1开始
     * 必须在主线程中调用
     * @param g 虚拟机
     * @param ba long数组
     * @return null: 数组为空，或虚拟机以销毁
     * @throws IllegalStateException 如果不在主线程中执行，抛出异常
     */
    @MainThread
    public static @Nullable LuaTable toTable(@NonNull Globals g, @Nullable long[] ba) {
        if (g.isDestroyed())
            return null;
        int len = ba == null ? 0 : ba.length;
        if (len == 0) return null;

        LuaTable table = LuaTable.create(g);
        for (int i = 0; i < len ; i ++) {
            table.set(i + 1, ba[i]);
        }
        return table;
    }

    /**
     * 将java的double数组转换为lua的table数组
     * 转换后的数组满足lua数组规范，下标从1开始
     * 必须在主线程中调用
     * @param g 虚拟机
     * @param ba double数组
     * @return null: 数组为空，或虚拟机以销毁
     * @throws IllegalStateException 如果不在主线程中执行，抛出异常
     */
    @MainThread
    public static @Nullable LuaTable toTable(@NonNull Globals g, @Nullable double[] ba) {
        if (g.isDestroyed())
            return null;
        int len = ba == null ? 0 : ba.length;
        if (len == 0) return null;

        LuaTable table = LuaTable.create(g);
        for (int i = 0; i < len ; i ++) {
            table.set(i + 1, ba[i]);
        }
        return table;
    }
    //</editor-fold>
}