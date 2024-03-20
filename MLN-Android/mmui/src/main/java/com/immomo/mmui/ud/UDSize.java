package com.immomo.mmui.ud;

import androidx.annotation.NonNull;

import com.immomo.mls.MLSBuilder;
import com.immomo.mls.fun.constants.MeasurementType;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.Objects;

/**
 * Created by MLN Template
 * 注册方法：
 * registerNewUD(UDSize.class);
 */
@LuaApiUsed
public class UDSize extends LuaUserdata<Size> {
    public static final String LUA_CLASS_NAME = "Size";

    //<editor-fold desc="constructor">

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDSize(long L) {
        this(L, 0, 0);
    }

    @CGenerate
    @LuaApiUsed
    protected UDSize(long L, float w) {
        this(L, w, 0);
    }

    @CGenerate
    @LuaApiUsed
    protected UDSize(long L, float w, float h) {
        super(L, null);
        this.width = w;
        this.height = h;
    }

    /**
     * 提供给Java的构造函数
     *
     * @param g 虚拟机
     * @param o 初始化对象
     */
    @LuaApiUsed
    public UDSize(@NonNull Globals g, Size o) {
        super(g, o);
        this.width = toLuaSize(o.getWidth());
        this.height = toLuaSize(o.getHeight());
    }

    public UDSize(@NonNull Globals g, float w, float h) {
        super(g, null);
        this.width = w;
        this.height = h;
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

    private float width;
    private float height;

    //<editor-fold desc="Bridge API">

    @LuaApiUsed
    public float getWidth() {
        return width;
    }

    @LuaApiUsed
    public void setWidth(float width) {
        this.width = width;
    }

    @LuaApiUsed
    public float getHeight() {
        return height;
    }

    @LuaApiUsed
    public void setHeight(float height) {
        this.height = height;
    }

    //</editor-fold>

    public int getWidthPx() {
        return Size.toPx(Size.toSize(width));
    }

    public int getHeightPx() {
        return Size.toPx(Size.toSize(height));
    }

    private static float toLuaSize(float v) {
        if (v == Size.MATCH_PARENT) {
            return MeasurementType.MATCH_PARENT;
        }
        if (v == Size.WRAP_CONTENT) {
            return MeasurementType.WRAP_CONTENT;
        }
        return v;
    }
    //<editor-fold desc="Other">

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        UDSize udSize = (UDSize) o;
        return Float.compare(udSize.width, width) == 0 &&
                Float.compare(udSize.height, height) == 0;
    }

    @Override
    public int hashCode() {
        return Objects.hash( width, height);
    }

    @Override
    public Size getJavaUserdata() {
        if (javaUserdata == null)
            javaUserdata = new Size();
        javaUserdata.setWidth(Size.toSize(width));
        javaUserdata.setHeight(Size.toSize(height));
        return javaUserdata;
    }

    @Override
    public String toString() {
        return "{" +
                "width=" + width +
                ", height=" + height +
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
    public static final ILuaValueGetter<UDSize, Size> L = new ILuaValueGetter<UDSize, Size>() {
        @Override
        public UDSize newInstance(Globals g, Size obj) {
            return new UDSize(g, obj);
        }
    };
    //</editor-fold>
}
