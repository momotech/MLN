/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.global;


import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.IFileCache;

/**
 * LuaView 全局设置
 *
 * @author song
 * @date 15/9/9
 */
public class LuaViewConfig {
    public static final String IP_KEY = "debugIp";
    public static final String PORT_KEY = "debugPort";
    private static boolean isOpenDebugger = false;//目前只支持模拟器下断点调试Lua，不支持真机，真机环境关闭该功能
    private static String debugIp = null;
    private static int port = 8172;
    private static LVConfig lvConfig;

    public static String getDebugIp() {
        if (debugIp == null) {
            IFileCache fileCache = MLSAdapterContainer.getFileCache();
            debugIp = fileCache.get(IP_KEY, "");
            port = Integer.parseInt(fileCache.get(PORT_KEY, port + ""));
        }
        return debugIp;
    }

    public static void setDebugIp(String debugIp) {
        LuaViewConfig.debugIp = debugIp;
        MLSAdapterContainer.getFileCache().save(IP_KEY, debugIp);
    }

    public static int getPort() {
        return port;
    }

    public static void setPort(int port) {
        LuaViewConfig.port = port;
        MLSAdapterContainer.getFileCache().save(PORT_KEY, port + "");
    }

    public static boolean isOpenDebugger() {
        return isOpenDebugger;
    }

    /**
     * 设置是否开启调试器用于断点调试
     *
     * @param openDebugger
     */
    public static void setOpenDebugger(boolean openDebugger) {
        if (openDebugger)
            MLSAdapterContainer.getToastAdapter().toast("Debug可能会导致热重载不可使用");
        isOpenDebugger = openDebugger;
    }

    public static LVConfig getLvConfig() {
        return lvConfig;
    }

    public static void setLvConfig(LVConfig lvConfig) {
        LuaViewConfig.lvConfig = lvConfig;
    }

    public static boolean isInit() {
        return lvConfig != null && lvConfig.isValid();
    }
}