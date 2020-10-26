/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud;

import android.graphics.BlurMaskFilter;
import android.graphics.DashPathEffect;
import android.graphics.Paint;
import android.text.TextUtils;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.TypeFaceAdapter;
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
public class UDPaint extends LuaUserdata<Paint> {
    public static final String LUA_CLASS_NAME = "Paint";

    public static final String[] methods = {
            "fontSize",
            "fontNameSize",
            "setShadowLayer",
            "setDash",
            "paintColor",
            "alpha",
            "width",
            "style",
            "cap",
            "setBlurMask",
            "a_setAntiAlias",
    };

    @LuaApiUsed
    protected UDPaint(long L, LuaValue[] v) {
        super(L, v);
        javaUserdata = new Paint();
        init();
    }

    public UDPaint(Globals g, Paint jud) {
        super(g, jud);
        init();
    }

    private void init() {
        javaUserdata.setStyle(Paint.Style.STROKE);
        javaUserdata.setStrokeWidth(DimenUtil.dpiToPx(1));
    }

    //<editor-fold desc="api">
    @LuaApiUsed
    public LuaValue[] fontSize(LuaValue[] values) {
        if (javaUserdata != null)
            javaUserdata.setTextSize(DimenUtil.spToPx(values[0].toFloat()));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] fontNameSize(LuaValue[] values) {
        String fontName = values.length > 0 ? values[0].toJavaString() : null;
        int size = values.length > 1 ? DimenUtil.spToPx(values[1].toInt()) : 0;

        if (javaUserdata != null) {
            if (!TextUtils.isEmpty(fontName)) {
                TypeFaceAdapter a = MLSAdapterContainer.getTypeFaceAdapter();
                if (a != null)
                    javaUserdata.setTypeface(a.create(fontName));
            }
            javaUserdata.setTextSize(size);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setShadowLayer(LuaValue[] values) {//Android Only
        int raduis = values.length > 0 ? DimenUtil.spToPx(values[0].toInt()) : 0;
        int dx = values.length > 1 ? DimenUtil.spToPx(values[1].toInt()) : 0;
        int dy = values.length > 2 ? DimenUtil.spToPx(values[2].toInt()) : 0;
        UDColor shadowColor = values.length > 3 ? (UDColor) values[3].toUserdata() : null;
        if (shadowColor != null) {
            javaUserdata.setShadowLayer(raduis, dx, dy, shadowColor.getColor());
            shadowColor.destroy();
        }

        return null;
    }

    @LuaApiUsed
    public LuaValue[] setDash(LuaValue[] values) {
        LuaTable dashsArray = values.length > 0 ? values[0].toLuaTable() : null;
        int phase = values.length > 1 ? values[1].toInt() - 1 : 0;
        if (dashsArray != null) {
            float[] fDashs = new float[dashsArray.getn()];
            for (int i = 0; i < fDashs.length; i++) {
                fDashs[i] = DimenUtil.dpiToPx(dashsArray.get(i + 1).toFloat());
            }
            DashPathEffect pathEffect = new DashPathEffect(fDashs, phase);
            javaUserdata.setPathEffect(pathEffect);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] paintColor(LuaValue[] values) {
        if (values.length > 0) {
            LuaValue value = values[0];
            if (value.isNumber()) {
                javaUserdata.setColor((int) value.toLong());
            } else {
                UDColor color = (UDColor) values[0].toUserdata();
                javaUserdata.setColor(color.getColor());
                color.destroy();
            }
            return null;
        }
        return varargsOf(new UDColor(getGlobals(), javaUserdata.getColor()));
    }

    @LuaApiUsed
    public LuaValue[] width(LuaValue[] values) {
        int width = values.length > 0 ? DimenUtil.dpiToPx(values[0].toInt()) : -1;
        if (width != -1) {
            javaUserdata.setStrokeWidth(width);
            return null;
        }
        return varargsOf(LuaValue.rNumber(javaUserdata.getStrokeWidth()));
    }

    @LuaApiUsed
    public LuaValue[] alpha(LuaValue[] values) {
        int alpha = values.length > 0 ? (int) (values[0].toFloat() * 255) : -1;
        if (alpha != -1) {
            javaUserdata.setAlpha(alpha);
            return null;
        }
        return varargsOf(LuaValue.rNumber(javaUserdata.getAlpha()));
    }

    @LuaApiUsed
    public LuaValue[] style(LuaValue[] values) {
        int styleCode = values.length > 0 ? values[0].toInt() : -1;
        if (styleCode != -1) {
            Paint.Style style = null;
            switch (styleCode) {
                case 0:
                    style = Paint.Style.FILL;
                    break;
                case 1:
                    style = Paint.Style.STROKE;
                    break;
                case 2:
                    style = Paint.Style.FILL_AND_STROKE;
                    break;
            }
            if (style != null) {
                javaUserdata.setStyle(style);
            }
            return null;
        }
        return varargsOf(LuaValue.rNumber(javaUserdata.getStyle().ordinal()));
    }


    @LuaApiUsed
    public LuaValue[] cap(LuaValue[] values) {//Android Only
        int capCode = values.length > 0 ? values[0].toInt() : -1;
        if (capCode != -1) {

            Paint.Cap cap = null;
            switch (capCode) {
                case 0:
                    cap = Paint.Cap.BUTT;
                    break;
                case 1:
                    cap = Paint.Cap.ROUND;
                    break;
                case 2:
                    cap = Paint.Cap.SQUARE;
                    break;
            }
            if (cap != null) {
                javaUserdata.setStrokeCap(cap);
            }
            return null;
        }
        return varargsOf(LuaValue.rNumber(javaUserdata.getStrokeCap().ordinal()));
    }

    @LuaApiUsed
    public LuaValue[] setBlurMask(LuaValue[] v) {
        float radius = v.length > 0 ? v[0].toFloat() : 0;
        int blurCode = v.length > 1 ? v[1].toInt() : 0;

        BlurMaskFilter.Blur code = BlurMaskFilter.Blur.NORMAL;
        switch (blurCode) {
            case 0:
                code = BlurMaskFilter.Blur.NORMAL;
                break;
            case 1:
                code = BlurMaskFilter.Blur.SOLID;
                break;
            case 2:
                code = BlurMaskFilter.Blur.OUTER;
                break;
            case 3:
                code = BlurMaskFilter.Blur.INNER;
                break;
        }
        if (javaUserdata.getAlpha() == 255) {//255透明度，会黑屏。
            javaUserdata.setAlpha(254);
        }
        if (radius > 0) {
            javaUserdata.setMaskFilter(new BlurMaskFilter(radius, code));
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] a_setAntiAlias(LuaValue[] v) {
        boolean isAnitiAlias = v.length > 0 && v[0].toBoolean();
        javaUserdata.setAntiAlias(isAnitiAlias);

        return null;
    }
    //</editor-fold>
}