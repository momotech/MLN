/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;

import android.graphics.BlurMaskFilter;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Shader;

import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


/**
 * Created by zhang.ke
 * on 2019/7/18
 */
@LuaApiUsed
public class UDCanvas extends LuaUserdata {
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

            "translate"
    };

    private Canvas canvas;

    private RectF rectFTemp;

    @LuaApiUsed
    public UDCanvas(long L, LuaValue[] v) {
        super(L, v);
        this.canvas = null;
    }

    public UDCanvas(Globals g, Object jud) {
        super(g, jud);
        this.canvas = (Canvas) jud;
    }

    public void resetCanvas(Canvas canvas) {
        this.canvas = canvas;
    }

    //<editor-fold desc="api">

    @LuaApiUsed
    public LuaValue[] save(LuaValue[] values) {
        if (canvas != null) {
            canvas.save();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] restore(LuaValue[] values) {
        if (canvas != null) {
            canvas.restore();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawArc(LuaValue[] v) {
        if (canvas == null)
            return null;
        if (rectFTemp == null) {
            rectFTemp = new RectF();
        }
        rectFTemp.set(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()), DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()));
        UDPaint udPaint = v.length > 6 ? (UDPaint) v[6].toUserdata() : null;
        if (udPaint != null) {
            canvas.drawArc(rectFTemp, v[4].toFloat(), v[5].toFloat(), false, (Paint) udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawColor(LuaValue[] values) {
        if (canvas == null)
            return null;
        LuaValue value = values[0];
        if (value.isNumber()) {
            canvas.drawColor(value.toInt());
        } else {
            UDColor color = (UDColor) value.toUserdata();
            canvas.drawColor(color.getColor());
            color.destroy();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawLine(LuaValue[] v) {
        if (canvas == null)
            return null;
        UDPaint udPaint = v.length > 4 ? (UDPaint) v[4].toUserdata() : null;
        if (udPaint != null) {
            canvas.drawLine(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()),
                    DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()), (Paint) udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawPath(LuaValue[] v) {
        if (canvas == null)
            return null;
        UDPaint udPaint = v.length > 1 ? (UDPaint) v[1].toUserdata() : null;
        if (udPaint != null) {
            canvas.drawPath((Path) v[0].toUserdata().getJavaUserdata(), (Paint) udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawPoint(LuaValue[] v) {
        if (canvas == null)
            return null;
        UDPaint udPaint = v.length > 2 ? (UDPaint) v[2].toUserdata() : null;
        if (udPaint != null) {
            canvas.drawPoint(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()),
                    (Paint) udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawText(LuaValue[] v) {
        if (canvas == null)
            return null;
        UDPaint udPaint = v.length > 3 ? (UDPaint) v[3].toUserdata() : null;
        if (udPaint != null) {
            canvas.drawText(v[0].toJavaString(), DimenUtil.dpiToPx(v[1].toFloat()),
                    DimenUtil.dpiToPx(v[2].toFloat()), (Paint) udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawCircle(LuaValue[] v) {
        if (canvas == null)
            return null;
        UDPaint udPaint = v.length > 3 ? (UDPaint) v[3].toUserdata() : null;
        if (udPaint != null) {
            canvas.drawCircle(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()),
                    DimenUtil.dpiToPx(v[2].toFloat()), (Paint) udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawRect(LuaValue[] v) {
        if (canvas == null)
            return null;
        UDPaint udPaint = v.length > 4 ? (UDPaint) v[4].toUserdata() : null;
        if (udPaint != null) {
            canvas.drawRect(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()),
                    DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()), (Paint) udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawOval(LuaValue[] v) {
        if (canvas == null)
            return null;
        UDPaint udPaint = v.length > 4 ? (UDPaint) v[4].toUserdata() : null;
        if (udPaint != null) {
            if (rectFTemp == null) {
                rectFTemp = new RectF();
            }
            rectFTemp.set(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()), DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()));
            canvas.drawOval(rectFTemp, (Paint) udPaint.getJavaUserdata());
            udPaint.destroy();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] drawGradientColor(LuaValue[] v) {
        if (canvas == null)
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

        Paint backgroundPaint = (Paint) pait.getJavaUserdata();
        backgroundPaint.setStyle(Paint.Style.FILL);
        backgroundPaint.setShader(gradient);
        canvas.drawPath((Path) path.getJavaUserdata(), backgroundPaint);
        path.destroy();
        pait.destroy();
        return null;
    }

    /**
     * Android Test Only
     * translate(x, y)
     */
    @LuaApiUsed
    public LuaValue[] translate(LuaValue[] v) {
        if (canvas == null)
            return null;
        float dx = DimenUtil.dpiToPx(v[0].toDouble());
        float dy = DimenUtil.dpiToPx(v[1].toDouble());
        canvas.translate(dx, dy);
        return null;
    }
    //</editor-fold>

}