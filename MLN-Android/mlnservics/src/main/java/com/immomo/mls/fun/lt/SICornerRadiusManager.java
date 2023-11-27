/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.lt;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by zhang.ke
 * 圆角全局管理器、辅助圆角切割，默认为：false，不做辅助
 * <p>
 * 圆角 与 子View越界绘制 合并方案
 * <p>
 * 前提：clipTobounds()默认效果：
 * Android为true：切割子View
 * IOS为false   ：不切子View
 * <p>
 * <p>
 * 1. setCornerRadiusWithDirection()
 * 两端统一 ：采用图层切割。
 * 不受 clipToBounds 和 CornerManager 影响。
 * 所有情况下，都切圆角、切子View
 * <p>
 * <p>
 * 2. cornerRadius()
 * 两端统一 : 默认不切圆角
 * 主动调clipTobounds(true): 切割圆角、切割子View
 * 主动调clipTobounds(false): 不切圆角、不切子View
 * <p>
 * <p>
 * CornerManager() 参数含义：
 * true：有圆角时，会帮所有View调用clipTobounds(true)（效果：切割圆角、切割子View）
 * （默认）false：不做任何操作
 * <p>
 * PS：因为Android默认：clipTobounds(true)，两端有差异。
 * 因此，Android的逻辑，有所改动：
 * a、CornerManager(false)：无论有无圆角，默认不切割圆角区域
 * b、CornerManager(true)：有圆角时，切割圆角
 * 无圆角时，不走切割
 * c、主动调用clipTobounds(true)：视为，强制切割圆角
 * d、主动调用clipTobounds(false): 视为，强制不切割圆角
 * on 2019/10/28
 */

@LuaClass(name = "CornerManager", isSingleton = true)
public class SICornerRadiusManager {
    public static final String LUA_CLASS_NAME = "CornerManager";
    private final Globals globals;


    public SICornerRadiusManager(Globals globals, LuaValue[] init) {
        this.globals = globals;
    }

    public void __onLuaGc() {
    }

    /**
     * 此方法，只能在lua项目开始时设置。不能动态更改
     *
     * @param open 开启圆角辅助
     */
    @LuaBridge
    public void openDefaultClip(boolean open) {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        if (m != null) {
            m.setDefaltCornerClip(open);
        }
    }
}
