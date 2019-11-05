/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

/**
 * Created by Xiong.Fangyu on 2019/3/5
 * <p>
 * 配置信息
 */
public class LuaConfigs {
    public static final byte LOG_CLOSE = 0; //关闭日志
    public static final byte LOG_ERR = 1; //关闭普通日志，开启错误日志
    public static final byte LOG_ALL = 2; //开启所有日志
    /**
     * 日志开启状态
     */
    public static byte openLogLevel = LOG_ALL;
    /**
     * 设置虚拟机查询so的路径
     * 可使用;分割多个path
     * 可使用?代表文件名
     * eg: /usr/local/lib/lua/5.2/loadall.so;./?.so
     */
    public static String soPath;
}