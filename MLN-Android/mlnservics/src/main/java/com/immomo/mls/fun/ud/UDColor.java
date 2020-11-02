/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;

import android.graphics.Color;

import com.immomo.mls.util.ColorUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mls.wrapper.IJavaObjectGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by XiongFangyu on 2018/7/31.
 */
@LuaApiUsed
public class UDColor extends LuaUserdata {

    public static final String LUA_CLASS_NAME = "Color";
    public static final String[] methods = new String[]{
            "hex",
            "alpha",
            "red",
            "green",
            "blue",
            "setHexA",
            "setRGBA",
            "clear",
            "setAColor",
            "setColor",
    };

    private int color;

    public UDColor(Globals g, int color) {
        super(g, color);
        this.color = color;
    }

    @LuaApiUsed
    protected UDColor(long L, LuaValue[] v) {
        super(L, v);
        init(v);
    }

    private void init(LuaValue[] initParams) {
        if (initParams != null) {
            if (initParams.length == 4) {
                color = Color.argb((int) (dealAlphaVal(initParams[3].toDouble()) * 255),
                        dealColorVal(initParams[0].toInt()),
                        dealColorVal(initParams[1].toInt()),
                        dealColorVal(initParams[2].toInt()));
            } else if (initParams.length == 3) {
                color = Color.argb(255,
                        dealColorVal(initParams[0].toInt()),
                        dealColorVal(initParams[1].toInt()),
                        dealColorVal(initParams[2].toInt()));

            } else if (initParams.length != 0) {
                ErrorUtils.debugLuaError("Color only zero or three or four parameters can be used for constructor method", getGlobals());
            }
        }
    }

    public static final IJavaObjectGetter<UDColor, Integer> J = new IJavaObjectGetter<UDColor, Integer>() {
        @Override
        public Integer getJavaObject(UDColor lv) {
            return lv.color;
        }
    };

    //<editor-fold desc="API">
    //<editor-fold desc="Property">
    @LuaApiUsed
    public LuaValue[] hex(LuaValue[] p) {
        if (p.length == 1) {
            int a = getAlpha();
            color = p[0].toInt();
            setAlpha(a);
            return null;
        }
        return rNumber(color);
    }

    @LuaApiUsed
    public LuaValue[] alpha(LuaValue[] p) {
        if (p.length == 1) {
            setAlpha((int) (dealAlphaVal(p[0].toDouble()) * 255));
            return null;
        }
        return rNumber(getAlpha() / 255f);
    }

    @LuaApiUsed
    public LuaValue[] red(LuaValue[] p) {
        if (p.length == 1) {
            setRed(dealColorVal(p[0].toInt()));
            return null;
        }
        return rNumber(getRed());
    }

    @LuaApiUsed
    public LuaValue[] green(LuaValue[] p) {
        if (p.length == 1) {
            setGreen(dealColorVal(p[0].toInt()));
            return null;
        }
        return rNumber(getGreen());
    }

    @LuaApiUsed
    public LuaValue[] blue(LuaValue[] p) {
        if (p.length == 1) {
            setBlue(dealColorVal(p[0].toInt()));
            return null;
        }
        return rNumber(getBlue());
    }

    private void setAlpha(int a) {
        color = Color.argb(a, getRed(), getGreen(), getBlue());
    }

    private void setRed(int r) {
        color = Color.argb(getAlpha(), r, getGreen(), getBlue());
    }

    private void setGreen(int g) {
        color = Color.argb(getAlpha(), getRed(), g, getBlue());
    }

    private void setBlue(int b) {
        color = Color.argb(getAlpha(), getRed(), getGreen(), b);
    }

    private int getAlpha() {
        return (color == 0) ? 255 : Color.alpha(color);
    }

    private int getRed() {
        return Color.red(color);
    }

    private int getGreen() {
        return Color.green(color);
    }

    private int getBlue() {
        return Color.blue(color);
    }
    //</editor-fold>

    //<editor-fold desc="Method">
    @LuaApiUsed
    public LuaValue[] setHexA(LuaValue[] p) {
        color = p[0].toInt();
        setAlpha((int) (dealAlphaVal(p[1].toDouble()) * 255));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setRGBA(LuaValue[] p) {
        color = Color.argb((int) (dealAlphaVal(p[3].toDouble()) * 255),
                dealColorVal(p[0].toInt()),
                dealColorVal(p[1].toInt()),
                dealColorVal(p[2].toInt()));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] clear(LuaValue[] p) {
        color = Color.TRANSPARENT;
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setAColor(LuaValue[] p) {
        String colorStr = p[0].toJavaString();
        if (colorStr == null || colorStr.length() == 0) {
            throw new IllegalArgumentException("Unknown color");
        }
        colorStr = colorStr.trim().toLowerCase();
        if (colorStr.charAt(0) == '#') {
            color = Color.parseColor(colorStr);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setColor(LuaValue[] p) {
        String colorStr = p[0].toJavaString();
        this.color = ColorUtils.setColorString(colorStr);
        return null;
    }

    //</editor-fold>
    //</editor-fold>

    public int getColor() {
        return color;
    }

    public void setColor(int color) {
        this.color = color;
    }

    public int dealColorVal(int val) {
        if (val > 255) {
            return 255;
        }
        if (val < 0)
            return 0;

        return val;
    }

    public double dealAlphaVal(double val) {
        if (val > 1) {
            return 1;
        }

        if (val < 0)
            return 0;
        return val;
    }

    @Override
    public String toString() {
        return ColorUtils.toHexColorString(color) + " " + ColorUtils.toRGBAColorString(color);
    }
}