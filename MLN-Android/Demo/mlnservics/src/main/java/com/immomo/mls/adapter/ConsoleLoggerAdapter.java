package com.immomo.mls.adapter;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public interface ConsoleLoggerAdapter {
    void v(String tag, String formatLog, Object... format);
    void i(String tag, String formatLog, Object... format);
    void d(String tag, String formatLog, Object... format);
    void w(String tag, String formatLog, Object... format);
    void e(String tag, String formatLog, Object... format);
    void e(String tag, Throwable t, String formatLog, Object... format);
    void e(String tag, Throwable t);
}
