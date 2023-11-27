/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;

import com.immomo.mls.fun.other.Rect;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by XiongFangyu on 2018/7/31.
 */
@LuaApiUsed
public class UDRect extends LuaUserdata {
    public static final String LUA_CLASS_NAME = "Rect";
    public static final String[] methods = new String[] {
            "x",
            "y",
            "width",
            "height",
            "point",
            "size",
    };

    private final Rect rect;

    public static final ILuaValueGetter<UDRect, Rect> G = new ILuaValueGetter<UDRect, Rect>() {
        @Override
        public UDRect newInstance(Globals g, Rect obj) {
            return new UDRect(g, obj);
        }
    };

    /**
     * 由java层创建
     *
     * @param g   虚拟机信息
     * @param jud java中保存的对象，可为空
     * @see #javaUserdata
     */
    public UDRect(Globals g, Object jud) {
        super(g, jud);
        rect = (Rect) jud;
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
    @LuaApiUsed({@LuaApiUsed.Func(params = {
            @LuaApiUsed.Type(Double.class),
            @LuaApiUsed.Type(Double.class),
            @LuaApiUsed.Type(Double.class),
            @LuaApiUsed.Type(Double.class)
    }, returns = @LuaApiUsed.Type(value = UDRect.class))})
    protected UDRect(long L, LuaValue[] v) {
        super(L, null);
        rect = new Rect();
        javaUserdata = rect;
        init(v);
    }

    private void init(LuaValue[] initParams) {
        if (initParams != null) {
            if (initParams.length >= 1) {
                rect.setX((float) initParams[0].toDouble());
            }
            if (initParams.length >= 2) {
                rect.setY((float) initParams[1].toDouble());
            }
            if (initParams.length >= 3) {
                rect.setWidth((float) initParams[2].toDouble());
            }
            if (initParams.length >= 4) {
                rect.setHeight((float) initParams[3].toDouble());
            }
        }
    }

    //<editor-fold desc="API">
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDRect.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] x(LuaValue[] varargs) {
        if (varargs.length == 1) {
            rect.setX((float) varargs[0].toDouble());
            return null;
        }
        return rNumber(rect.getX());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDRect.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] y(LuaValue[] varargs) {
        if (varargs.length == 1) {
            rect.setY((float) varargs[0].toDouble());
            return null;
        }
        return rNumber(rect.getY());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDRect.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] width(LuaValue[] varargs) {
        if (varargs.length == 1) {
            rect.setWidth((float) varargs[0].toDouble());
            return null;
        }
        return rNumber(rect.getWidth());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDRect.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] height(LuaValue[] varargs) {
        if (varargs.length == 1) {
            rect.setHeight((float) varargs[0].toDouble());
            return null;
        }
        return rNumber(rect.getHeight());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDRect.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] point(LuaValue[] varargs) {
        if (varargs.length == 1) {
            UDPoint udPoint = (UDPoint) varargs[0];
            rect.setPoint(udPoint.getPoint());
            return null;
        }
        return varargsOf(new UDPoint(getGlobals(), rect.getPoint()));
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDRect.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] size(LuaValue[] varargs) {
        if (varargs.length == 1) {
            UDSize udSize = (UDSize) varargs[0];
            rect.setSize(udSize.getSize());
            return null;
        }

        return varargsOf(new UDSize(getGlobals(), rect.getSize()));
    }
    //</editor-fold>

    public Rect getRect() {
        return rect;
    }

    @Override
    public String toString() {
        return rect.toString();
    }
}