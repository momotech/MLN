/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Region;
import android.os.Build;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.immomo.mls.MLSConfigs;
import com.immomo.mls.fun.ud.view.IBorderRadius;
import com.immomo.mls.fun.ud.view.IClipRadius.ClipLevel;
import com.immomo.mls.fun.ud.view.IClipRadius.CornerType;

import static android.graphics.Path.FillType.INVERSE_EVEN_ODD;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_NOTCLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_NORMAL_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.TYPE_CORNER_DIRECTION;
import static com.immomo.mls.fun.ud.view.IClipRadius.TYPE_CORNER_MASK;
import static com.immomo.mls.fun.ud.view.IClipRadius.TYPE_CORNER_NONE;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
public class ViewClipHelper {
    private float topLeftRadius = 0;
    private float topRightRadius = 0;
    private float bottomLeftRadius = 0;
    private float bottomRightRadius = 0;

    private int lastWidth;
    private int lastHeight;
    private float lastExtraRadius;

    private boolean radiusChanged = false;

    private static final Rect canvasBounds = new Rect();

    @NonNull
    private final RectF clipRect = new RectF();
    @NonNull
    private final float[] radii = new float[8];
    @NonNull
    private final RadiusDrawer radiusDrawer;

    @NonNull
    private final Path clipPath = new Path();
    @NonNull
    private final Path surfaceViewClipPath = new Path();

    @NonNull
    private static final Paint clipPaint;
    @NonNull
    private static final Paint surfaceViewClipPaint;
    static {
        final PorterDuffXfermode CLEAR = new PorterDuffXfermode(PorterDuff.Mode.CLEAR);
        final PorterDuffXfermode mode;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            mode = CLEAR;
        } else {
            mode = new PorterDuffXfermode(PorterDuff.Mode.DST_IN);
        }
        clipPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        clipPaint.setStyle(Paint.Style.FILL_AND_STROKE);
        clipPaint.setXfermode(mode);

        surfaceViewClipPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        surfaceViewClipPaint.setStyle(Paint.Style.FILL_AND_STROKE);
        surfaceViewClipPaint.setXfermode(CLEAR);
    }

    private boolean doNotClip = MLSConfigs.defaultNotClip;
    /**
     * 方案WIKI：{@link com.immomo.mls.fun.lt.SICornerRadiusManager}
     * {@link com.immomo.mls.LuaViewManager#defaltCornerClip}
     */
    private boolean openCornerManager = false;//新属性，替代doNotClip，默认切割：false
    private boolean hasRadius = false;//是否设置了圆角，默认false
    private int forceClipLevel = LEVEL_NORMAL_CLIP;//切割等级
    private int cornerType = TYPE_CORNER_NONE;//圆角类型
    private boolean isTextView;

    public ViewClipHelper() {
        this(null);
    }

    public ViewClipHelper(View v) {
        radiusDrawer = new RadiusDrawer();
        isTextView = (v instanceof TextView);
    }

    public void setDrawRadiusBackground(boolean draw) {
        doNotClip = draw;
    }

    public void openDefaultClip(boolean open) {
        this.openCornerManager = open;
    }

    public void setForceClipLevel(@ClipLevel int clipLevel) {
        this.forceClipLevel = clipLevel;
    }

    public void setRadius(float radius) {
        setRadius(radius, radius, radius, radius);
    }

    public void setRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
        hasRadius = true;
        radiusChanged = topLeftRadius != topLeft || topRightRadius != topRight || bottomLeft != bottomLeftRadius || bottomRight != bottomRightRadius;
        topLeftRadius = topLeft;
        topRightRadius = topRight;
        bottomLeftRadius = bottomLeft;
        bottomRightRadius = bottomRight;
        updatePath(lastWidth, lastHeight, lastExtraRadius);
    }

    public void setRadius(IBorderRadius borderRadius) {
        float[] radii = borderRadius.getRadii();
        setRadius(radii[0], radii[2], radii[6], radii[4]);
    }

    public void setRadiusColor(int color) {
        radiusDrawer.setRadiusColor(color);
        setCornerType(TYPE_CORNER_MASK);
    }

    public void setCornerType(@CornerType int cornerType) {
        this.cornerType = cornerType;
    }

    public void updatePath(int w, int h, float extraRadius) {
        if (!radiusChanged && lastWidth == w && lastHeight == h && lastExtraRadius == extraRadius)
            return;
        lastWidth = w;
        lastHeight = h;
        lastExtraRadius = extraRadius;
        if (lastWidth == 0 || lastHeight == 0) {
            clipPath.reset();
            surfaceViewClipPath.reset();
            return;
        }
        float clipTLRadius = topLeftRadius;
        float clipTRRadius = topRightRadius;
        float clipBLRadius = bottomLeftRadius;
        float clipBRRadius = bottomRightRadius;
        if (cornerType == TYPE_CORNER_MASK) {
            radiusDrawer.update(clipTLRadius, clipTRRadius, clipBLRadius, clipBRRadius);
            return;
        }
        clipPath.reset();
        surfaceViewClipPath.reset();
        clipRect.set(0, 0, w, h);
        radii[0] = radii[1] = clipTLRadius;
        radii[2] = radii[3] = clipTRRadius;
        radii[4] = radii[5] = clipBRRadius;
        radii[6] = radii[7] = clipBLRadius;
        clipPath.addRoundRect(clipRect, radii, Path.Direction.CW);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            this.clipPath.setFillType(INVERSE_EVEN_ODD);
        }
        surfaceViewClipPath.addRoundRect(clipRect, radii, Path.Direction.CW);
    }

    public boolean needClicp() {
        return topLeftRadius != 0 || topRightRadius != 0
                || bottomLeftRadius != 0 || bottomRightRadius != 0;
    }

    public void clip(@NonNull Canvas canvas, SuperDrawAction action) {
        clip(canvas, action, false);
    }

    public void clip(@NonNull Canvas canvas, SuperDrawAction action, boolean containSurface) {
        if (cornerType == TYPE_CORNER_MASK) {
            action.innerDraw(canvas);
            radiusDrawer.clip(canvas);
            return;
        }

        //新版统一方案
        boolean needClip = false;
        switch (this.forceClipLevel) {
            case LEVEL_NORMAL_CLIP:
                needClip = openCornerManager && hasRadius;
                break;
            case LEVEL_FORCE_CLIP:
                needClip = true;
                break;
            case LEVEL_FORCE_NOTCLIP:
                needClip = false;
                break;
        }
        needClip = needClip || cornerType == TYPE_CORNER_DIRECTION;//统一：CORNER_DIRECTION，强制图层切割

        //doNotClip 已废弃，保留兼容老版本
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP || (doNotClip && !needClip)) {
            action.innerDraw(canvas);
            return;
        }

        if (containSurface) {
            canvas.drawPath(surfaceViewClipPath, surfaceViewClipPaint);
        }
        canvas.getClipBounds(canvasBounds); /// 某些view(textview且设置了setGravity)，canvas的原点不在(0,0)
        if (isTextView && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            canvas.save();
            canvas.translate(canvasBounds.left, canvasBounds.top);
            canvas.clipPath(clipPath, Region.Op.DIFFERENCE);
            canvas.translate(-canvasBounds.left, -canvasBounds.top);
            action.innerDraw(canvas);
            canvas.restore();
            return;
        }
        clipRect.offset(canvasBounds.left, canvasBounds.top);
        int sc = canvas.saveLayer(clipRect, null, Canvas.ALL_SAVE_FLAG);
        clipRect.offset(-canvasBounds.left, - canvasBounds.top);
        action.innerDraw(canvas);
        canvas.drawPath(clipPath, clipPaint);
        canvas.restoreToCount(sc);//将图层合并
    }

    public interface SuperDrawAction {
        void innerDraw(Canvas canvas);
    }

    private static boolean containsSurfaceView(@NonNull ViewGroup parent, boolean detectOnlyChild) {
        int childCount = parent.getChildCount();
        for (int i = 0; i < childCount; i = i + 1) {
            View v = parent.getChildAt(i);
            if (v instanceof SurfaceView || v instanceof ISurfaceView) {
                return true;
            }
        }
        if (childCount == 1 && detectOnlyChild) {
            View onlyChild = parent.getChildAt(0);
            if (onlyChild instanceof ViewGroup || onlyChild instanceof ISurfaceView) {
                return containsSurfaceView((ViewGroup) onlyChild, false);
            }
        }
        return false;
    }

    public static boolean containsSurfaceView(@NonNull ViewGroup parent) {
        return containsSurfaceView(parent, true);
    }

    public static interface ISurfaceView {

    }
}