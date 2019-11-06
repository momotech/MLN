package com.immomo.mls.util;

import com.immomo.mls.MLSAdapterContainer;

/**
 * Log Util
 *
 * @author song
 */
public class LogUtil {
    private static final String DEFAULT_PREFIX = "[LuaView]";

    /**
     * log a info message
     *
     * @param msg
     */
    public static void i(Object... msg) {
        MLSAdapterContainer.getConsoleLoggerAdapter().i(DEFAULT_PREFIX, getMsg(msg));
    }

    /**
     * log a debug message
     *
     * @param msg
     */
    public static void d(Object... msg) {
        MLSAdapterContainer.getConsoleLoggerAdapter().d(DEFAULT_PREFIX, getMsg(msg));
    }

    public static void w(Object... msg) {
        MLSAdapterContainer.getConsoleLoggerAdapter().w(DEFAULT_PREFIX, getMsg(msg));
    }

    /**
     * log a debug message
     *
     * @param msg
     */
    public static void e(Object... msg) {
        MLSAdapterContainer.getConsoleLoggerAdapter().e(DEFAULT_PREFIX, getMsg(msg));
    }

    public static void e(Throwable t, Object... msg) {
        MLSAdapterContainer.getConsoleLoggerAdapter().e(DEFAULT_PREFIX, t, getMsg(msg));
    }

    /**
     * get message
     *
     * @param msg
     * @return
     */
    private static String getMsg(Object... msg) {
        StringBuffer sb = new StringBuffer();
        if (msg != null) {
            for (Object s : msg) {
                sb.append(s).append(" ");
            }
        }
        return sb.toString();
    }
}
