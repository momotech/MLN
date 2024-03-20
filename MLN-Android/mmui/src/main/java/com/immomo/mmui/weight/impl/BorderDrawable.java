package com.immomo.mmui.weight.impl;

import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mmui.weight.IBorder;
import static com.immomo.mls.fun.constants.RectCorner.*;

/**
 * Created by Xiong.Fangyu on 2020/11/3
 */
public class BorderDrawable extends Drawable implements IBorder {
    @NonNull
    protected final Path borderPath = new Path();
    @NonNull
    protected final Paint borderPathPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    protected float borderWidth;
    /// border外圈
    @NonNull
    protected final float[] radii;
    ///borderWith内圈 外圈与内圈差borderWidth
    @NonNull
    protected final float[] radiiIn;

    private int width, height;

    public BorderDrawable() {
        radii = new float[8];
        radiiIn = new float[8];
    }

    //<editor-fold desc="Drawable">
    @Override
    public void draw(@NonNull Canvas canvas) {
        if (borderWidth > 0 && !borderPath.isEmpty()) {
            canvas.drawPath(borderPath, borderPathPaint);
        }
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
        int width = r.width();
        int height = r.height();
        if (width != this.width || height != this.height)
            updatePath(width, height);
    }
    //</editor-fold>

    //<editor-fold desc="Private">
    private void initialPaint() {
        if (borderWidth > 0) {
            borderPathPaint.setStyle(Paint.Style.FILL);
        }
    }

    protected void updatePath(int w, int h) {
        borderPath.reset();
        if (w <= 0 || h <= 0)
            return;
        if (borderWidth <= 0)
            return;
        if (borderWidth > (w >> 1) || borderWidth > (h >> 1))
            return;  //边框大于view宽高，效果异常
        borderPath.addRoundRect(0, 0, w, h, radii, Path.Direction.CW);
        borderPath.addRoundRect(borderWidth, borderWidth, w - borderWidth, h - borderWidth, radiiIn, Path.Direction.CCW);
    }

    private void updateRadii() {
        radiiIn[0] = radiiIn[1] = radii[0] - borderWidth > 0 ? radii[0] - borderWidth : 0;
        radiiIn[2] = radiiIn[3] = radii[2] - borderWidth > 0 ? radii[2] - borderWidth : 0;
        radiiIn[4] = radiiIn[5] = radii[4] - borderWidth > 0 ? radii[4] - borderWidth : 0;
        radiiIn[6] = radiiIn[7] = radii[6] - borderWidth > 0 ? radii[6] - borderWidth : 0;
    }
    //</editor-fold>

    //<editor-fold desc="IBorder">

    @Override
    public void setStrokeWidth(float strokeWidth) {
        borderWidth = strokeWidth;
        initialPaint();
        updatePath(width, height);
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
        radii[0] = radii[1] = topLeft;
        radii[2] = radii[3] = topRight;
        radii[4] = radii[5] = bottomRight;
        radii[6] = radii[7] = bottomLeft;
        updateRadii();
        if (width != 0 && height != 0)
            updatePath(width, height);
        invalidateSelf();
    }

    @Override
    public void setRadius(@Direction int direction, float radius) {
        if ((direction & ALL_CORNERS) == ALL_CORNERS || direction == 0) {//统一direction == 0，为ALL_CORNERS
            radii[0] = radii[1] = radii[2] = radii[3] = radii[6] = radii[7] = radii[4] = radii[5] = radius;
        } else {
            if ((direction & TOP_LEFT) == TOP_LEFT) {
                radii[0] = radii[1] = radius;
            }
            if ((direction & TOP_RIGHT) == TOP_RIGHT) {
                radii[2] = radii[3] = radius;
            }
            if ((direction & BOTTOM_LEFT) == BOTTOM_LEFT) {
                radii[6] = radii[7] = radius;
            }
            if ((direction & BOTTOM_RIGHT) == BOTTOM_RIGHT) {
                radii[4] = radii[5] = radius;
            }
        }
        updateRadii();
        if (width != 0 && height != 0)
            updatePath(width, height);
        invalidateSelf();
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
    public float getRadius(@Direction int direction) {
        if ((direction & TOP_LEFT) == TOP_LEFT) {
            return radii[0];
        }
        if ((direction & TOP_RIGHT) == TOP_RIGHT) {
            return radii[2];
        }
        if ((direction & BOTTOM_LEFT) == BOTTOM_LEFT) {
            return radii[6];
        }
        if ((direction & BOTTOM_RIGHT) == BOTTOM_RIGHT) {
            return radii[4];
        }
        return radii[0];
    }

    @Override
    public float[] getRadii() {
        return radii;
    }
    //</editor-fold>
}
