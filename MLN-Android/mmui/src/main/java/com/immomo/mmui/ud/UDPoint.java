package com.immomo.mmui.ud;

import androidx.annotation.NonNull;

import com.immomo.mls.MLSBuilder;
import com.immomo.mls.fun.other.Point;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.Objects;

/**
 * Created by MLN Template
 * 注册方法：
 * registerNewUD(UDPoint.class);
 */
@LuaApiUsed
public class UDPoint extends LuaUserdata<Point> {
    public static final String LUA_CLASS_NAME = "Point";

    //<editor-fold desc="Constructors">

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDPoint(long L) {
        this(L, 0, 0);
    }

    @CGenerate
    @LuaApiUsed
    protected UDPoint(long L, float x) {
        this(L, x, 0);
    }

    @CGenerate
    @LuaApiUsed
    protected UDPoint(long L, float x, float y) {
        super(L, null);
        this.x = x;
        this.y = y;
    }

    /**
     * 提供给Java的构造函数
     *
     * @param g 虚拟机
     * @param o 初始化对象
     */
    public UDPoint(@NonNull Globals g, Point o) {
        super(g, o);
        this.x = o.getX();
        this.y = o.getY();
    }

    /**
     * 提供给java的构造函数
     */
    public UDPoint(@NonNull Globals g, float x, float y) {
        super(g, null);
        this.x = x;
        this.y = y;
    }
    //</editor-fold>

    //<editor-fold desc="init method">

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

    private float x;
    private float y;

    //<editor-fold desc="Bridge API">

    @LuaApiUsed
    public float getX() {
        return x;
    }

    @LuaApiUsed
    public void setX(float x) {
        this.x = x;
    }

    @LuaApiUsed
    public float getY() {
        return y;
    }

    @LuaApiUsed
    public void setY(float y) {
        this.y = y;
    }

    //</editor-fold>

    public int getXPx() {
        return DimenUtil.dpiToPx(x);
    }

    public int getYPx() {
        return DimenUtil.dpiToPx(y);
    }

    //<editor-fold desc="Other">

    @Override
    public int hashCode() {
        return Objects.hash(x, y);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        UDPoint udPoint = (UDPoint) o;
        return Float.compare(udPoint.x, x) == 0 &&
                Float.compare(udPoint.y, y) == 0;
    }

    @Override
    public Point getJavaUserdata() {
        if (javaUserdata == null)
            javaUserdata = new Point();
        javaUserdata.setX(x);
        javaUserdata.setY(y);
        return javaUserdata;
    }

    @Override
    public String toString() {
        return "{" +
                "x=" + x +
                ", y=" + y +
                '}';
    }
    //</editor-fold>

    //<editor-fold desc="Auto Convert">

    /**
     * 将Java类型转换为Lua类型，一般在基础类中使用，或选择默认转换方式
     * 注册方法：
     * @see com.immomo.mls.MLSBuilder#registerCovert(MLSBuilder.CHolder...)
     * @see MLSBuilder.CHolder
     */
    public static final ILuaValueGetter<UDPoint, Point> L = new ILuaValueGetter<UDPoint, Point>() {
        @Override
        public UDPoint newInstance(Globals g, Point obj) {
            return new UDPoint(g, obj);
        }
    };
    //</editor-fold>
}
