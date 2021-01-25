/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.ud.anim;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;

import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by MLN Template
 * 注册方法：
 * registerNewUD(InteractiveBehavior.class);
 */
@LuaApiUsed
public class InteractiveBehavior extends LuaUserdata<GestureBehavior> {
    public static final String LUA_CLASS_NAME = "InteractiveBehavior";

    /**
     * 提供给Lua的构造函数
     * 必须存在
     *
     * @param L 虚拟机底层地址
     */
    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected InteractiveBehavior(long L) {
        super(L, null);
        /// 必须完成包裹对象的初始化
        javaUserdata = new GestureBehavior();
    }

    //<editor-fold desc="init">

    /**
     * 初始化方法
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     *
     * @param l 虚拟机C层地址
     * @see Globals#getL_State()
     */
    public static native void _register(long l, String parent);
    //</editor-fold>

    //<editor-fold desc="Bridge API">
    @LuaApiUsed
    public void setDirection(int d) {
        javaUserdata.direction = d;
    }

    @LuaApiUsed
    public int getDirection() {
        return javaUserdata.direction;
    }

    @LuaApiUsed
    public void setEndDistance(double dis) {
        javaUserdata.setEndDistance(DimenUtil.dpiToPx(dis));
    }

    @LuaApiUsed
    public double getEndDistance() {
        return javaUserdata.getEndDistance();
    }

    @LuaApiUsed
    public void setOverBoundary(boolean overBoundary) {
        javaUserdata.overBoundary = overBoundary;
    }

    @LuaApiUsed
    public boolean isOverBoundary() {
        return javaUserdata.overBoundary;
    }

    @LuaApiUsed
    public void setEnable(boolean enable) {
        javaUserdata.enable = enable;
    }

    @LuaApiUsed
    public boolean isEnable() {
        return javaUserdata.enable;
    }

    @LuaApiUsed
    public void setFollowEnable(boolean followEnable) {
        javaUserdata.followEnable = followEnable;
    }

    @LuaApiUsed
    public boolean isFollowEnable() {
        return javaUserdata.followEnable;
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchBlock(long fun) {
        if (fun == 0)
            javaUserdata.callback = null;
        else
        javaUserdata.callback = new InteractiveBehaviorCallback(globals.getL_State(), fun);
    }

    @LuaApiUsed
    public void targetView(UDView view) {
        javaUserdata.targetView(view);
    }
    //</editor-fold>

    /**
     * 此对象被Lua GC时调用，可不实现
     * 可做相关释放操作
     */
    @CallSuper
    @Override
    protected void __onLuaGc() {
        super.__onLuaGc();
        if (javaUserdata != null)
            javaUserdata.__onLuaGc();
    }
}
