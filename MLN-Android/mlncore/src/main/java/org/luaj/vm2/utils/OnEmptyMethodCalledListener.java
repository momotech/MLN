/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package org.luaj.vm2.utils;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2020-03-27
 *
 * 一般用了在debug阶段查看日志的
 */
public interface OnEmptyMethodCalledListener {
    /**
     * 空方法被调用时回调
     * @param g 虚拟机
     * @param clz 调用者类名，如果时静态调用，则为Unknown
     * @param mn 空方法名称
     */
    void onCalled(Globals g, String clz, String mn);
}
