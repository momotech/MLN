/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mlncore;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;

/**
 * Created by Xiong.Fangyu on 2019-07-31
 */
public class MLNCore {
    /**
     * remove阶段不做任何事情
     */
    public static final byte TYPE_NONE = 0;
    /**
     * 直接remove
     */
    public static final byte TYPE_REMOVE = 1;
    /**
     * remove后保存到新的cache里
     */
    public static final byte TYPE_REMOVE_CACHE = 2;
    /**
     * core debug控制
     */
    public static boolean DEBUG = true;
    /**
     * cache类型
     * @see org.luaj.vm2.UserdataCache
     */
    public static byte UserdataCacheType = TYPE_REMOVE;
    /**
     * 回调
     */
    private static Callback callback;
    /**
     * 全局Globals销毁回调
     */
    private static OnGlobalsDestroy onGlobalsDestroy;

    /**
     * 设置回调
     */
    public static void setCallback(Callback callback) {
        MLNCore.callback = callback;
    }

    public static void setOnGlobalsDestroy(OnGlobalsDestroy onGlobalsDestroy) {
        MLNCore.onGlobalsDestroy = onGlobalsDestroy;
    }

    /**
     * 设置bridge统计回调
     */
    public static void setStatisticCallback(StatisticCallback c) {
        Statistic.callback = c;
    }

    /**
     * 从native创建虚拟机（isolate）
     * @param g isolate lua vm
     */
    public static void onNativeCreateGlobals(Globals g, boolean isStatic) {
        if (callback != null)
            callback.onNativeCreateGlobals(g, isStatic);
    }

    /**
     * lua中有异常发生，将回调
     * @param t 异常信息
     * @param g 虚拟机
     * @return true: 消费异常；false: 不消费，将抛出
     */
    public static boolean hookLuaError(Throwable t, Globals g) {
        if (callback != null)
            return callback.hookLuaError(t, g);
        return false;
    }

    /**
     * lua gc 耗时
     * @param g 虚拟机
     * @param ms 耗时，单位ms
     */
    public static void luaGcCast(Globals g, long ms) {
        if (callback != null)
            callback.luaGcCast(g, ms);
    }

    /**
     * 通过id获取userdata为空，但removecache中不为空时回调
     * @param id userdata对象id
     * @param cache 已remove的对象
     * @return 可返回空，或返回cache
     */
    public static LuaUserdata onNullGet(long id, @NonNull LuaUserdata cache) {
        if (callback != null)
            return callback.onNullGet(id, cache);
        return cache;
    }

    /**
     * Globals自身调用
     */
    public static void onGlobalsDestroy(Globals g) {
        if (onGlobalsDestroy != null)
            onGlobalsDestroy.onDestroy(g);
    }

    /**
     * 可监听从native创建虚拟机的回调（isolate）
     * 或监听lua中的报错
     */
    public interface Callback {
        /**
         * 从native创建虚拟机（isolate）
         * @param g isolate lua vm
         * @param isStatic 是否是全局globals
         */
        void onNativeCreateGlobals(Globals g, boolean isStatic);

        /**
         * lua中的异常
         * @param t 异常信息
         * @param g 虚拟机
         * @return true: 消费异常；false: 不消费，将抛出
         */
        boolean hookLuaError(Throwable t, Globals g);

        /**
         * 回调执行lua gc耗时
         * @param g 虚拟机
         * @param ms gc耗时，ms
         */
        void luaGcCast(Globals g, long ms);

        /**
         * 通过id获取userdata为空，但removecache中不为空时回调
         * @param id userdata对象id
         * @param cache 已remove的对象
         * @return 可返回空，或返回cache
         */
        @Nullable LuaUserdata onNullGet(long id, @NonNull LuaUserdata cache);
    }

    /**
     * 可监听
     */
    public interface StatisticCallback {
        /**
         * Bridge统计监听，可使用{@link Statistic#getBridgeInfo(String, Statistic.Info)}获取信息
         * @param jsonData json字符串
         */
        void onBridgeCallback(String jsonData);

        /**
         * Require统计监听，可使用{@link Statistic#getRequireInfo(String, Statistic.Info)}获取信息
         * @param jsonData json字符串
         */
        void onRequireCallback(String jsonData);
    }

    /**
     * 虚拟机销毁时调用
     */
    public interface OnGlobalsDestroy {
        void onDestroy(Globals g);
    }
}