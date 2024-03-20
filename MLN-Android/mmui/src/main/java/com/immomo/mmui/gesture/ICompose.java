/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.gesture;

/**
 * 判断是否是组合控件，是对lua提供的展示view，即不是LuaxxView（即lua对外提供的控件是由原生多个控件组合而来），组合控件的手势事件要特殊处理
 * Created by wang.yang on 2020/9/30
 */
public interface ICompose {

    /**
     * 获取本组合控件的子控件的事件传递链（必须提供线性结构）
     *
     * @return 子控件
     */
    ArgoTouchLink getTouchLink();
}
