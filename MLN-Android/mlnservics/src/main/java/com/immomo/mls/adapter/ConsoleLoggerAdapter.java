/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
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