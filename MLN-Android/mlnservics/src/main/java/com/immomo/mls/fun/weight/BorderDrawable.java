/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.weight;

import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;

import com.immomo.mls.fun.ud.view.IBorderRadius;
import com.immomo.mls.fun.ud.view.UDView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class BorderDrawable extends Drawable implements IBorderRadius {

    @NonNull
    protected final Path borderPath = new Path();
    protected final RectF pathRect = new RectF();
    @NonNull
    private final Paint borderPathPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    protected float borderWidth;
    protected final float[] radii;
    protected boolean hasRadii = false;

    private int width, height;

    public BorderDrawable() {
        radii = new float[8];
    }

    //<editor-fold desc="Drawable">
    @Override
    public void draw(@NonNull Canvas canvas) {
        drawBorder(canvas);
    }

    @Override
    public void setAlpha(int alpha) {
        borderPathPaint.setAlpha(alpha);
    }

    @Override
    public void setColorFilter(@Nullable ColorFilter colorFilter) {
        borderPathPaint.setColorFilter(colorFilter);
    }

    @Override
    public int getOpacity() {
        return PixelFormat.OPAQUE;
    }

    @Override
    protected void onBoundsChange(Rect r) {
        width = r.width();
        height = r.height();
        updatePath(width, height);
    }
    //</editor-fold>

    //<editor-fold desc="Private">
    private boolean initialPaint() {
        if (borderWidth > 0) {
            borderPathPaint.setStrokeWidth(borderWidth);
            borderPathPaint.setStyle(Paint.Style.STROKE);
            borderPathPaint.setStrokeJoin(Paint.Join.ROUND);
            borderPathPaint.setStrokeCap(Paint.Cap.ROUND);
            return true;
        }
        return false;
    }

    protected void updatePath(int w, int h) {
        if (borderWidth <= 0) {
            borderPath.reset();
            return;
        }
        float borderPathPadding = borderWidth * 1F / 2;
        borderPath.reset();
        pathRect.set(borderPathPadding, borderPathPadding, w - borderPathPadding, h - borderPathPadding);
        borderPath.addRoundRect(pathRect, radii, Path.Direction.CW);
    }
    //</editor-fold>

    //<editor-fold desc="IBroderRadius">

    @Override
    public void setStrokeWidth(float strokeWidth) {
        borderWidth = strokeWidth;
        initialPaint();
        updatePath(this.width,height);
        invalidateSelf();
    }

    @Override
    public void setStrokeColor(int color) {
        borderPathPaint.setColor(color);
        invalidateSelf();
    }

    @Override
    public void setCornerRadius(float radius) {
        setRadius(radius, radius, radius, radius);
    }

    @Override
    public void setRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
        hasRadii = topLeft != 0 || topRight != 0 || bottomLeft != 0 || bottomRight != 0;
        radii[0] = radii[1] = topLeft;
        radii[2] = radii[3] = topRight;
        radii[4] = radii[5] = bottomRight;
        radii[6] = radii[7] = bottomLeft;
        if (width != 0 && height != 0)
            updatePath(width, height);
        invalidateSelf();
    }

    @Override
    public void setRadius(@Direction int direction, float radius) {
        if (direction == 0)
            return;
        hasRadii = radius != 0;
        if ((direction & D_ALL_CORNERS) == D_ALL_CORNERS) {
            radii[0] = radii[1] = radii[2] = radii[3] = radii[6] = radii[7] = radii[4] = radii[5] = radius;
        } else {
            if ((direction & D_LEFT_TOP) == D_LEFT_TOP) {
                 radii[0] = radii[1] = radius;
            }
            if ((direction & D_RIGHT_TOP) == D_RIGHT_TOP) {
                radii[2] = radii[3] = radius;
            }
            if ((direction & D_LEFT_BOTTOM) == D_LEFT_BOTTOM) {
                radii[6] = radii[7] = radius;
            }
            if ((direction & D_RIGHT_BOTTOM) == D_RIGHT_BOTTOM) {
                radii[4] = radii[5] = radius;
            }
        }
        if (width != 0 && height != 0)
            updatePath(width, height);
        invalidateSelf();
    }

    @Override
    public void setUDView(UDView udView) {

    }

    @Override
    public float getStrokeWidth() {
        return borderWidth;
    }

    @Override
    public int getStrokeColor() {
        return borderPathPaint.getColor();
    }

    @Override
    public float getCornerRadiusWithDirection(int direction) {

        if ((direction & D_LEFT_TOP) == D_LEFT_TOP) {
            return radii[0];
        }

        if ((direction & D_RIGHT_TOP) == D_RIGHT_TOP) {
            return radii[2];
        }
        if ((direction & D_LEFT_BOTTOM) == D_LEFT_BOTTOM) {
            return radii[6];
        }
        if ((direction & D_RIGHT_BOTTOM) == D_RIGHT_BOTTOM) {
            return radii[4];
        }
        return radii[0];
    }

    @Override
    public float getRadius(@Direction int direction) {
        return radii[direction * 2];
    }

    @Override
    public float[] getRadii() {
        return radii;
    }

    @Override
    public void drawBorder(Canvas canvas) {
        if (borderWidth > 0 && !borderPath.isEmpty()) {
            canvas.drawPath(borderPath, borderPathPaint);
        }
    }
    //</editor-fold>
}