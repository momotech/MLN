/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

/**
 * Created by Xiong.Fangyu on 2019/3/5
 *
 * @see NativeLog
 */
public interface ILog {
    /**
     * 打印日志
     * @param L 虚拟机地址，可通过 {@link org.luaj.vm2.Globals#getGlobalsByLState(long)}获取
     */
    void l(long L, String tag, String log);

    /**
     * 打印错误日志
     * @param L 虚拟机地址，可通过 {@link org.luaj.vm2.Globals#getGlobalsByLState(long)}获取
     */
    void e(long L, String tag, String log);
}