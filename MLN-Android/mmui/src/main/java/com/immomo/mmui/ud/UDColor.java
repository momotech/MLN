/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.graphics.Color;

import com.immomo.mls.util.ColorUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mmui.databinding.bean.MMUIColor;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by XiongFangyu on 2018/7/31.
 */
@LuaApiUsed
public class UDColor extends LuaUserdata<MMUIColor> {

    public static final String LUA_CLASS_NAME = "Color";

    public UDColor(Globals g, int color) {
        super(g, new MMUIColor(color));
    }

    @CGenerate
    @LuaApiUsed
    protected UDColor(long L) {
        super(L, null);
        javaUserdata = new MMUIColor(0);
    }

    @CGenerate
    @LuaApiUsed
    protected UDColor(long L, int r, int g, int b) {
        super(L, null);
        javaUserdata = new MMUIColor(Color.rgb(r, g, b));
    }

    @CGenerate
    @LuaApiUsed
    protected UDColor(long L, int r, int g, int b, float a) {
        super(L, null);
        javaUserdata = new MMUIColor(Color.argb((int) (dealAlphaVal(a) * 255), r, g, b));
    }

    public UDColor(Globals g, MMUIColor color) {
        super(g, color);
    }

    public static native void _init();
    public static native void _register(long l, String parent);

    //<editor-fold desc="API">
    //<editor-fold desc="Property">

    @LuaApiUsed
    public int getHex() {
        return javaUserdata.getColor();
    }

    @LuaApiUsed
    public void setHex(int hex) {
        int a = javaUserdata.getAlpha();
        javaUserdata.setColor(hex);
        javaUserdata.setAlpha(a);
    }

    @LuaApiUsed
    public float getAlpha() {
        return javaUserdata.getAlpha() / 255f;
    }

    @LuaApiUsed
    public void setAlpha(float alpha) {
        javaUserdata.setAlpha((int) (dealAlphaVal(alpha) * 255));
    }

    @LuaApiUsed
    public int getRed() {
        return javaUserdata.getRed();
    }

    @LuaApiUsed
    public void setRed(int red) {
        javaUserdata.setRed(red);
    }

    @LuaApiUsed
    public int getGreen() {
        return javaUserdata.getGreen();
    }

    @LuaApiUsed
    public void setGreen(int green) {
        javaUserdata.setGreen(green);
    }

    @LuaApiUsed
    public int getBlue() {
        return javaUserdata.getBlue();
    }

    @LuaApiUsed
    public void setBlue(int blue) {
        javaUserdata.setBlue(blue);
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public void setHexA(int h, float a) {
        javaUserdata.setColor(h);
        javaUserdata.setAlpha((int) (dealAlphaVal(a) * 255));
    }

    @LuaApiUsed
    public void setRGBA(int r, int g, int b, float a) {
        javaUserdata.setColor(Color.argb((int) (dealAlphaVal(a) * 255),
                dealColorVal(r),
                dealColorVal(g),
                dealColorVal(b)));
    }

    @LuaApiUsed
    public void clear() {
        javaUserdata.setColor(Color.TRANSPARENT);
    }

    @LuaApiUsed
    public void setAColor(String colorStr) {
        if (colorStr == null || colorStr.length() == 0) {
            throw new IllegalArgumentException("Unknown color");
        }
        colorStr = colorStr.trim().toLowerCase();
        if (colorStr.charAt(0) == '#') {
            javaUserdata.setColor(Color.parseColor(colorStr));
        }
    }

    @LuaApiUsed
    public void setColor(String colorStr) {
        javaUserdata.setColor(ColorUtils.setColorString(colorStr));
    }

    //</editor-fold>
    //</editor-fold>

    public int getColor() {
        return javaUserdata.getColor();
    }

    public void setColor(int color) {
        javaUserdata.setColor(color);
    }

    private int dealColorVal(int val) {
        if (val > 255) {
            return 255;
        }
        if (val < 0)
            return 0;

        return val;
    }

    private double dealAlphaVal(double val) {
        if (val > 1) {
            return 1;
        }

        if (val < 0)
            return 0;
        return val;
    }

    @Override
    public String toString() {
        return ColorUtils.toHexColorString(getColor()) + " " + ColorUtils.toRGBAColorString(getColor());
    }

    public static final IJavaObjectGetter<UDColor, Integer> J = new IJavaObjectGetter<UDColor, Integer>() {
        @Override
        public Integer getJavaObject(UDColor lv) {
            return lv.getColor();
        }
    };
}