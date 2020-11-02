/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud;

import android.graphics.Rect;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by zhang.ke
 * on 2020-01-19
 * 安全区域适配器。主要用于自定义安全区域的偏移
 */
@LuaApiUsed
public class UDSafeAreaRect extends LuaUserdata {
    public static final String LUA_CLASS_NAME = "SafeAreaAdapter";
    public static final String[] methods = new String[]{
            "insetsTop",
            "insetsBottom",
            "insetsLeft",
            "insetsRight",
    };

    private Rect safeArea;

    /**
     * 由java层创建
     *
     * @param g   虚拟机信息
     * @param jud java中保存的对象，可为空
     * @see #javaUserdata
     */
    public UDSafeAreaRect(Globals g, Object jud) {
        super(g, jud);
        safeArea = new Rect();
    }

    /**
     * 必须有传入long和LuaValue[]的构造方法，且不可混淆
     * 由native创建
     * <p>
     * 子类可在此构造函数中初始化{@link #javaUserdata}
     * <p>
     * 必须有此构造方法！！！！！！！！
     *
     * @param L 虚拟机地址
     * @param v lua脚本传入的构造参数
     */
    @LuaApiUsed
    protected UDSafeAreaRect(long L, LuaValue[] v) {
        super(L, v);
        safeArea = new Rect();
    }


    @LuaApiUsed
    public LuaValue[] insetsTop(LuaValue[] v) {
        safeArea.top = v.length > 0 ? v[0].toInt() : 0;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] insetsBottom(LuaValue[] v) {
        safeArea.bottom = v.length > 0 ? v[0].toInt() : 0;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] insetsLeft(LuaValue[] v) {
        safeArea.left = v.length > 0 ? v[0].toInt() : 0;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] insetsRight(LuaValue[] v) {
        safeArea.right = v.length > 0 ? v[0].toInt() : 0;
        return null;
    }

    public Rect getRect() {
        return safeArea;
    }
}
