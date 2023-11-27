/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;


import com.immomo.mls.fun.other.Point;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
@LuaApiUsed
public class UDPoint extends LuaUserdata {
    public static final String LUA_CLASS_NAME = "Point";
    public static final String[] methods = new String[] {
            "x","y"
    };

    private final Point point;

    public static final ILuaValueGetter<UDPoint, Point> G = new ILuaValueGetter<UDPoint, Point>() {
        @Override
        public UDPoint newInstance(Globals g, Point obj) {
            return new UDPoint(g, obj);
        }
    };

    /**
     * 由java层创建
     *
     * @param g   虚拟机信息
     * @param jud java中保存的对象，可为空
     * @see #javaUserdata
     */
    public UDPoint(Globals g, Object jud) {
        super(g, jud);
        point = (Point) jud;
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
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class)
            })
    })
    protected UDPoint(long L, LuaValue[] v) {
        super(L, null);
        point = new Point();
        javaUserdata = point;
        init(v);
    }

    private void init(LuaValue[] initParams) {
        if (initParams != null) {
            if (initParams.length >= 1) {
                setX((float) initParams[0].toDouble());
            }
            if (initParams.length >= 2) {
                setY((float) initParams[1].toDouble());
            }
        }
    }

    //<editor-fold desc="API">
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDPoint.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] x(LuaValue[] varargs) {
        if (varargs.length == 1) {
            setX((float) varargs[0].toDouble());
            return null;
        }
        return rNumber(getX());
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
            }, returns = @LuaApiUsed.Type(UDPoint.class)),
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(Float.class))
    })
    public LuaValue[] y(LuaValue[] varargs) {
        if (varargs.length == 1) {
            setY((float) varargs[0].toDouble());
            return null;
        }
        return rNumber(getY());
    }
    //</editor-fold>

    public Point getPoint() {
        return point;
    }

    private void setX(float x) {
        point.setX(x);
    }

    private float getX() {
        return point.getX();
    }

    private void setY(float y) {
        point.setY(y);
    }

    private float getY() {
        return point.getY();
    }

    @Override
    public String toString() {
        return point.toString();
    }
}