/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter.impl;

import android.util.Log;

import com.immomo.mls.adapter.ConsoleLoggerAdapter;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class DefaultConsoleLoggerAdapter implements ConsoleLoggerAdapter {
    @Override
    public void v(String tag, String formatLog, Object... format) {
        if (format == null || format.length == 0) {
            Log.v(tag, formatLog);
            return;
        }
        Log.v(tag, String.format(formatLog, format));
    }

    @Override
    public void i(String tag, String formatLog, Object... format) {
        if (format == null || format.length == 0) {
            Log.i(tag, formatLog);
            return;
        }
        Log.i(tag, String.format(formatLog, format));
    }

    @Override
    public void d(String tag, String formatLog, Object... format) {
        if (format == null || format.length == 0) {
            Log.d(tag, formatLog);
            return;
        }
        Log.d(tag, String.format(formatLog, format));
    }

    @Override
    public void w(String tag, String formatLog, Object... format) {
        if (format == null || format.length == 0) {
            Log.w(tag, formatLog);
            return;
        }
        Log.w(tag, String.format(formatLog, format));
    }

    @Override
    public void e(String tag, String formatLog, Object... format) {
        if (format == null || format.length == 0) {
            Log.e(tag, formatLog);
            return;
        }
        e(tag, null, formatLog, format);
    }

    @Override
    public void e(String tag, Throwable t, String formatLog, Object... format) {
        if (format == null || format.length == 0) {
            Log.e(tag, formatLog, t);
            return;
        }
        Log.e(tag, String.format(formatLog, format), t);
    }

    @Override
    public void e(String tag, Throwable t) {
        Log.e(tag, "", t);
    }
}