/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;

import android.graphics.Path;
import android.graphics.RectF;

import com.immomo.mls.util.DimenUtil;

import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2019-05-27
 */
@LuaApiUsed
public class UDPath extends LuaUserdata<Path> {
    public static final String LUA_CLASS_NAME = "Path";

    public static final String[] methods = {
            "reset",
            "moveTo",
            "lineTo",
            "arcTo",
            "quadTo",
            "cubicTo",
            "addPath",
            "close",
            "setFillType",
            "addArc",
            "addRect",
            "addCircle",
    };

    @LuaApiUsed
    protected UDPath(long L, LuaValue[] v) {
        super(L, v);
        javaUserdata = new Path();
    }

    //<editor-fold desc="api">
    @LuaApiUsed
    LuaValue[] reset(LuaValue[] v) {
        javaUserdata.reset();
        return null;
    }

    @LuaApiUsed
    LuaValue[] moveTo(LuaValue[] v) {
        javaUserdata.moveTo(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()));
        return null;
    }

    @LuaApiUsed
    LuaValue[] lineTo(LuaValue[] v) {
        javaUserdata.lineTo(DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()));
        return null;
    }

    @LuaApiUsed
    LuaValue[] quadTo(LuaValue[] v) {
        javaUserdata.quadTo(DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()), DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()));
        return null;
    }

    @LuaApiUsed
    LuaValue[] cubicTo(LuaValue[] v) {
        javaUserdata.cubicTo(DimenUtil.dpiToPx(v[2].toFloat()), DimenUtil.dpiToPx(v[3].toFloat()), DimenUtil.dpiToPx(v[4].toFloat()), DimenUtil.dpiToPx(v[5].toFloat()), DimenUtil.dpiToPx(v[0].toFloat()), DimenUtil.dpiToPx(v[1].toFloat()));
        return null;
    }


    @LuaApiUsed
    LuaValue[] arcTo(LuaValue[] values) {
        float centerX = values.length > 0 ? DimenUtil.dpiToPx(values[0].toFloat()) : 0;
        float centerY = values.length > 1 ? DimenUtil.dpiToPx(values[1].toFloat()) : 0;
        int radius = values.length > 2 ? DimenUtil.dpiToPx(values[2].toInt()) : 0;
        int startAngle = values.length > 3 ? values[3].toInt() : 0;
        int endAngle = values.length > 4 ? values[4].toInt() : 0;

        javaUserdata.arcTo(new RectF(centerX - radius, centerY - radius, centerX + radius,
            centerY + radius), startAngle, endAngle - startAngle);
        return null;
    }

    @LuaApiUsed
    LuaValue[] addPath(LuaValue[] v) {
        UDPath udPath = v.length > 0 ? (UDPath) v[0].toUserdata() : null;
        if (udPath != null) {
            javaUserdata.addPath(udPath.javaUserdata);
            udPath.destroy();
        }
        return null;
    }

    @LuaApiUsed
    LuaValue[] close(LuaValue[] v) {
        javaUserdata.close();
        return null;
    }

    @LuaApiUsed
    LuaValue[] setFillType(LuaValue[] values) {
        int code = values.length > 0 ? values[0].toInt() : -1;
        if (code != -1) {
            Path.FillType type = Path.FillType.WINDING;
            switch (code) {
                case 0:
                    type = Path.FillType.WINDING;
                    break;
                case 1:
                    type = Path.FillType.EVEN_ODD;
                    break;
                case 2:
                    type = Path.FillType.INVERSE_WINDING;
                    break;
                case 3:
                    type = Path.FillType.INVERSE_EVEN_ODD;
                    break;
            }
            javaUserdata.setFillType(type);
        }
        return null;
    }

    @LuaApiUsed
    LuaValue[] addRect(LuaValue[] values) {
        int left = values.length > 0 ? DimenUtil.dpiToPx(values[0].toInt()) : 0;
        int top = values.length > 1 ? DimenUtil.dpiToPx(values[1].toInt()) : 0;
        int right = values.length > 2 ? DimenUtil.dpiToPx(values[2].toInt()) : 0;
        int bottom = values.length > 3 ? DimenUtil.dpiToPx(values[3].toInt()) : 0;
        boolean clockwise = values.length > 4 && values[4].toBoolean();

        Path.Direction direction = Path.Direction.CCW;
        if (clockwise) {
            direction = Path.Direction.CW;
        }
        javaUserdata.addRect(left, top, right, bottom, direction);

        return null;
    }

    @LuaApiUsed
    LuaValue[] addArc(LuaValue[] values) {
        float centerX = values.length > 0 ? DimenUtil.dpiToPx(values[0].toFloat()) : 0;
        float centerY = values.length > 1 ? DimenUtil.dpiToPx(values[1].toFloat()) : 0;
        int radius = values.length > 2 ? DimenUtil.dpiToPx(values[2].toInt()) : 0;
        int startAngle = values.length > 3 ? values[3].toInt() : 0;
        int endAngle = values.length > 4 ? values[4].toInt() : 0;
//        boolean clockwise = values.length > 5 && values[5].toBoolean();


        javaUserdata.addArc(new RectF(centerX - radius, centerY - radius, centerX + radius,
                centerY + radius), startAngle, endAngle - startAngle);
        return null;
    }

    @LuaApiUsed
    LuaValue[] addCircle(LuaValue[] values) {
        int x = values.length > 0 ? DimenUtil.dpiToPx(values[0].toInt()) : -1;
        int y = values.length > 1 ? DimenUtil.dpiToPx(values[1].toInt()) : -1;
        int radius = values.length > 2  ? DimenUtil.dpiToPx(values[2].toInt()) : -1;
        boolean clockwise = values.length > 3 && values[3].toBoolean();

        Path.Direction direction = Path.Direction.CCW;
        if (clockwise) {
            direction = Path.Direction.CW;
        }
        javaUserdata.addCircle(x, y, radius, direction);

        return null;
    }
    //</editor-fold>
}