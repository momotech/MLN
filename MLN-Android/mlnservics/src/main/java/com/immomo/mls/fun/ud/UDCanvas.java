/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Shader;

import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.List;


/**
 * Created by zhang.ke
 * on 2019/7/18
 */
@LuaApiUsed
public class UDCanvas extends LuaUserdata<Canvas> {
    public static final String LUA_CLASS_NAME = "Canvas";

    public static final String[] methods = {
            "save",
            "restore",
            "drawArc",
            "drawColor",
            "drawLine",
            "drawPath",
            "drawPoint",
            "drawText",
            "drawCircle",
            "drawRect",
            "drawOval",
            "drawGradientColor",
    };

    private RectF rectFTemp;

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public UDCanvas(long L, LuaValue[] v) {
        super(L, v);
    }

    public UDCanvas(Globals g, Canvas jud) {
        super(g, jud);
    }

    public void resetCanvas(Canvas javaUserdata) {
        this.javaUserdata = javaUserdata;
    }

    //<editor-fold desc="api">

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] save(LuaValue[] values) {
        if (javaUserdata != null) {
            return rNumber(javaUserdata.save());
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] restore(LuaValue[] values) {
        if (javaUserdata != null) {
            if (values.length > 0 && values[0].isNumber()) {
                javaUserdata.restoreToCount(values[0].toInt());
            } else {
                javaUserdata.restore();
            }
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(UDPaint.class),
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawArc(LuaValue[] v) {
        if (javaUserdata == null)
            return null;
        if (rectFTemp == null) {
            rectFTemp = new RectF();
        }
        rectFTemp.set(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()), DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()));
        UDPaint udPaint = v.length > 6 ? (UDPaint) v[6].toUserdata() : null;
        if (udPaint != null) {
            javaUserdata.drawArc(rectFTemp, v[4].toFloat(), v[5].toFloat(), false, udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Integer.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class)),
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDColor.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawColor(LuaValue[] values) {
        if (javaUserdata == null)
            return null;
        LuaValue value = values[0];
        if (value.isNumber()) {
            javaUserdata.drawColor(value.toInt());
        } else {
            UDColor color = (UDColor) value.toUserdata();
            javaUserdata.drawColor(color.getColor());
            color.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(UDPaint.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawLine(LuaValue[] v) {
        if (javaUserdata == null)
            return null;
        UDPaint udPaint = v.length > 4 ? (UDPaint) v[4].toUserdata() : null;
        if (udPaint != null) {
            javaUserdata.drawLine(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()),
                    DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()), udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(UDPaint.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawPath(LuaValue[] v) {
        if (javaUserdata == null)
            return null;
        UDPaint udPaint = v.length > 1 ? (UDPaint) v[1].toUserdata() : null;
        if (udPaint != null) {
            javaUserdata.drawPath((Path) v[0].toUserdata().getJavaUserdata(), udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(UDPaint.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawPoint(LuaValue[] v) {
        if (javaUserdata == null)
            return null;
        UDPaint udPaint = v.length > 2 ? (UDPaint) v[2].toUserdata() : null;
        if (udPaint != null) {
            javaUserdata.drawPoint(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()),
                    udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(String.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(UDPaint.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawText(LuaValue[] v) {
        if (javaUserdata == null)
            return null;
        UDPaint udPaint = v.length > 3 ? (UDPaint) v[3].toUserdata() : null;
        if (udPaint != null) {
            javaUserdata.drawText(v[0].toJavaString(), DimenUtil.dpiToPx(v[1].toFloat()),
                    DimenUtil.dpiToPx(v[2].toFloat()), udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(UDPaint.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawCircle(LuaValue[] v) {
        if (javaUserdata == null)
            return null;
        UDPaint udPaint = v.length > 3 ? (UDPaint) v[3].toUserdata() : null;
        if (udPaint != null) {
            javaUserdata.drawCircle(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()),
                    DimenUtil.dpiToPx(v[2].toFloat()), udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(UDPaint.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawRect(LuaValue[] v) {
        if (javaUserdata == null)
            return null;
        UDPaint udPaint = v.length > 4 ? (UDPaint) v[4].toUserdata() : null;
        if (udPaint != null) {
            javaUserdata.drawRect(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()),
                    DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()), udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(UDPaint.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawOval(LuaValue[] v) {
        if (javaUserdata == null)
            return null;
        UDPaint udPaint = v.length > 4 ? (UDPaint) v[4].toUserdata() : null;
        if (udPaint != null) {
            if (rectFTemp == null) {
                rectFTemp = new RectF();
            }
            rectFTemp.set(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()), DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()));
            javaUserdata.drawOval(rectFTemp, udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(Float.class),
                    @LuaApiUsed.Type(value = UDArray.class),
                    @LuaApiUsed.Type(UDPath.class),
                    @LuaApiUsed.Type(UDPaint.class)
            }, returns = @LuaApiUsed.Type(UDCanvas.class))
    })
    public LuaValue[] drawGradientColor(LuaValue[] v) {
        if (javaUserdata == null)
            return null;
        float startX = v.length > 0 ? DimenUtil.dpiToPx(v[0].toFloat()) : 0;
        float startY = v.length > 1 ? DimenUtil.dpiToPx(v[1].toFloat()) : 0;
        float endX = v.length > 2 ? DimenUtil.dpiToPx(v[2].toFloat()) : 0;
        float endY = v.length > 3 ? DimenUtil.dpiToPx(v[3].toFloat()) : 0;
        LuaTable colors = v.length > 4 ? v[4].toLuaTable() : null;
        UDPath path = v.length > 5 ? (UDPath) v[5].toUserdata() : null;
        UDPaint pait = v.length > 6 ? (UDPaint) v[6].toUserdata() : null;
        if (colors == null || path == null || pait == null) {
            return null;
        }
        int[] intColors = new int[colors.getn()];
        for (int i = 0; i < intColors.length; i++) {
            String colorString = colors.get(i + 1).toJavaString();
            String[] colorSplit = colorString.split(",");
            if (colorSplit.length == 4) {
                intColors[i] = Color.argb((int) (Float.valueOf(colorSplit[3]) * 255), Integer.valueOf(colorSplit[0]), Integer.valueOf(colorSplit[1]), Integer.valueOf(colorSplit[2]));
            }
        }
        //这里不好缓存，等用H5 Canvas直接淘汰这个类
        LinearGradient gradient = new LinearGradient(DimenUtil.dpiToPx(startX), DimenUtil.dpiToPx(startY)
                , DimenUtil.dpiToPx(endX), DimenUtil.dpiToPx(endY), intColors, null, Shader.TileMode.CLAMP);

        Paint backgroundPaint = pait.getJavaUserdata();
        backgroundPaint.setStyle(Paint.Style.FILL);
        backgroundPaint.setShader(gradient);
        javaUserdata.drawPath(path.getJavaUserdata(), backgroundPaint);
        path.destroy();
        pait.destroy();
        return null;
    }
    //</editor-fold>

}