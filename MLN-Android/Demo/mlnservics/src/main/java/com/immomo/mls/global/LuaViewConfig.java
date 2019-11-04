package com.immomo.mls.global;


/**
 * LuaView 全局设置
 *
 * @author song
 * @date 15/9/9
 */
public class LuaViewConfig {
    private static boolean isOpenDebugger = false;//目前只支持模拟器下断点调试Lua，不支持真机，真机环境关闭该功能
    private static String debugIp = null;
    private static int port = 8173;
    private static LVConfig lvConfig;

    public static String getDebugIp() {
        return debugIp;
    }

    public static void setDebugIp(String debugIp) {
        LuaViewConfig.debugIp = debugIp;
    }

    public static int getPort() {
        return port;
    }

    public static void setPort(int port) {
        LuaViewConfig.port = port;
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
