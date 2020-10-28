/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui;

import org.luaj.vm2.LuaValue;

/**
 * Created by wang.yang on 2020/8/20.
 * VM数据自动装配
 */
public class MMUIAutoFillCApi {

    /**
     * 加载lua函数function字符串，并执行
     *
     * @param L              虚拟机指针
     * @param function       Lua源码
     *                       此函数字符串 必须要有return语句，eg：
     *                       "local function XX()
     *                                          ……
     *                        end
     *                        return XX"
     * @param compareSwitch  判断是否需要执行 compareKeypath 功能。
     * @param params 参数
     * @param returnCount 返回值个数， -1 代表可变参数个数
     * @return  函数返回值
     */
    public static native LuaValue[] _autoFill(long L, String function, boolean compareSwitch, LuaValue[] params, int returnCount);
}
