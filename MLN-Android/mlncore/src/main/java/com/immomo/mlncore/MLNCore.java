/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mlncore;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019-07-31
 */
public class MLNCore {
    public static boolean DEBUG = true;

    private static Callback callback;

    /**
     * 设置回调
     */
    public static void setCallback(Callback callback) {
        MLNCore.callback = callback;
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
    }
}