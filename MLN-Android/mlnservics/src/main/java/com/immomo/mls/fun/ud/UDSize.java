/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;


import com.immomo.mls.fun.constants.MeasurementType;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.view.UDScrollView;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by LuaViewPlugin
 */
@LuaApiUsed
public class UDSize extends LuaUserdata {
    public static final String LUA_CLASS_NAME = "Size";
    public static final String[] methods = new String[]{
            "width",
            "height",
    };

    private final Size mSize;

    /**
     * 由java层创建
     *
     * @param g   虚拟机信息
     * @param jud java中保存的对象，可为空
     * @see #javaUserdata
     */
    public UDSize(Globals g, Object jud) {
        super(g, jud);
        mSize = (Size) jud;
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
    @LuaApiUsed(ignore = true)
    protected UDSize(long L, LuaValue[] v) {
        super(L, null);
        mSize = new Size();
        javaUserdata = mSize;
        init(v);
    }

    public static final ILuaValueGetter<UDSize, Size> G = new ILuaValueGetter<UDSize, Size>() {
        @Override
        public UDSize newInstance(Globals g, Size obj) {
            return new UDSize(g, obj);
        }
    };

    private void init(LuaValue[] initParams) {
        if (initParams != null) {
            if (initParams.length >= 1) {
                setWidth((float) initParams[0].toDouble());
            }
            if (initParams.length >= 2) {
                setHeight((float) initParams[1].toDouble());
            }
        }
    }

    public Size getSize() {
        return mSize;
    }

    public int getWidthPx() {
        return mSize.getWidthPx();
    }

    public int getHeightPx() {
        return mSize.getHeightPx();
    }

    //-----------------------API-------------------------
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(UDSize.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] width(LuaValue[] var) {
        if (var.length == 1) {
            setWidth((float) var[0].toDouble());
            return null;
        }
        return varargsOf(LuaNumber.valueOf(mSize.getWidth()));
    }

    public void setWidth(float p0) {
        mSize.setWidth(Size.toSize(p0));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class)
            }, returns = @LuaApiUsed.Type(UDSize.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] height(LuaValue[] var) {
        if (var.length == 1) {
            setHeight((float) var[0].toDouble());
            return null;
        }
        return varargsOf(LuaNumber.valueOf(mSize.getHeight()));
    }

    public void setHeight(float p0) {
        mSize.setHeight(Size.toSize(p0));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(String.class))
    })
    @Override
    public String toString() {
        return mSize.toString();
    }
}