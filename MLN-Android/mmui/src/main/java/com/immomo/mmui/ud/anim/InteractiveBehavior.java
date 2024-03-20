/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.ud.anim;

import androidx.annotation.CallSuper;

import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by MLN Template
 * 注册方法：
 * registerNewUD(InteractiveBehavior.class);
 */
@LuaApiUsed
public class InteractiveBehavior extends JavaUserdata<BaseGestureBehavior> {
    public static final String LUA_CLASS_NAME = "InteractiveBehavior";

    /**
     * 提供给Lua的构造函数
     * 必须存在
     *
     * @param L 虚拟机底层地址
     */
    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected InteractiveBehavior(long L, int type) {
        super(L, null);
        switch (type) {
            case InteractiveType.GESTURE:
                javaUserdata = new GestureBehavior();
                break;
            case InteractiveType.SCALE:
                javaUserdata = new ScaleBehavior();
                break;
            default:
                throw new IllegalArgumentException("暂不支持"+type+"类型");
        }
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
    public void setMax(double dis) {
        javaUserdata.setMax(DimenUtil.dpiToPx(dis));
    }

    @LuaApiUsed
    public double getMax() {
        return DimenUtil.pxToDpi(javaUserdata.getMax());
    }

    @LuaApiUsed
    public void setOverBoundary(boolean overBoundary) {
        javaUserdata.setOverBoundary(overBoundary);
    }

    @LuaApiUsed
    public boolean isOverBoundary() {
        return javaUserdata.isOverBoundary();
    }

    @LuaApiUsed
    public void setEnable(boolean enable) {
        javaUserdata.setEnable(enable);
    }

    @LuaApiUsed
    public boolean isEnable() {
        return javaUserdata.isEnable();
    }

    @LuaApiUsed
    public void setFollowEnable(boolean followEnable) {
        javaUserdata.setFollowEnable(followEnable);
    }

    @LuaApiUsed
    public boolean isFollowEnable() {
        return javaUserdata.isFollowEnable();
    }

    @CGenerate(params = "F")
    @LuaApiUsed
    public void touchBlock(long fun) {
        javaUserdata.setTouchBlock(globals, fun);
    }

    @LuaApiUsed
    public void targetView(UDView view) {
        javaUserdata.setTargetView(view);
    }

    @LuaApiUsed
    public void setDirection(int d) {
        if (javaUserdata instanceof GestureBehavior) {
            ((GestureBehavior)javaUserdata).setDirection(d);
        }
    }

    @LuaApiUsed
    public int getDirection() {
        if (javaUserdata instanceof GestureBehavior)
            return ((GestureBehavior)javaUserdata).getDirection();
        return 0;
    }

    @LuaApiUsed
    public void clearAnim() {
        javaUserdata.clearAnim();
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
            javaUserdata.clear();
    }
}
