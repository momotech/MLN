/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.graphics.Rect;

import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by zhang.ke
 * on 2020-01-19
 * 安全区域适配器。主要用于自定义安全区域的偏移
 */
@LuaApiUsed
public class UDSafeAreaRect extends LuaUserdata<Rect> {
    public static final String LUA_CLASS_NAME = "SafeAreaAdapter";

    public UDSafeAreaRect(Globals g, Rect jud) {
        super(g, jud);
    }

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDSafeAreaRect(long L) {
        super(L, null);
        javaUserdata = new Rect();
    }

    //<editor-fold desc="native method">
    /**
     * 初始化方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>
    @LuaApiUsed
    public void insetsTop(float top) {
        javaUserdata.top = DimenUtil.dpiToPx(top);
    }

    @LuaApiUsed
    public void insetsBottom(float v) {
        javaUserdata.bottom = DimenUtil.dpiToPx(v);
    }

    @LuaApiUsed
    public void insetsLeft(float v) {
        javaUserdata.left = DimenUtil.dpiToPx(v);
    }

    @LuaApiUsed
    public void insetsRight(float v) {
        javaUserdata.right = DimenUtil.dpiToPx(v);
    }

    public Rect getRect() {
        return javaUserdata;
    }
}