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

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class BorderDrawable extends Drawable implements IBorderRadius {

    @NonNull
    protected final Path borderPath = new Path();
    protected final RectF borderPathRect = new RectF();
    @NonNull
    protected final Paint borderPathPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    protected float borderWidth;
    protected final float[] radii, radiiIn;//borderWith内圈;
    protected boolean hasRadii = false;//统一：addCornerMask模式不处理背景。其余圆角方式处理圆角
    protected boolean useAddMask = false;
    protected boolean isBorderBackground = true;//先绘制borderWidth(边框默认最后绘制，防止被挡住。部分View如Label，需要先绘制，不然被Gravity影响)

    private int width, height;

    public BorderDrawable() {
        radii = new float[8];
        radiiIn = new float[8];
    }

    //<editor-fold desc="Drawable">
    @Override
    public void draw(@NonNull Canvas canvas) {
        if (!isBorderBackground) {//先绘制border，作为背景drawable
            drawBorder(canvas);
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
        width = r.width();
        height = r.height();
        updatePath(width, height);
    }
    //</editor-fold>

    //<editor-fold desc="Private">
    private boolean initialPaint() {
        if (borderWidth > 0) {
            borderPathPaint.setStyle(Paint.Style.FILL);
            return true;
        }
        return false;
    }

    protected void updatePath(int w, int h) {
        if (borderWidth <= 0) {
            borderPath.reset();
            return;
        }
        borderPath.reset();
        borderPathRect.set(0, 0, w, h);
        borderPath.addRoundRect(borderPathRect, radii, Path.Direction.CW);

        if (borderWidth > w / 2 || borderWidth > h / 2) {
            return;  //边框大于view宽高，效果异常
        }

        borderPathRect.set(borderWidth, borderWidth, w - borderWidth, h - borderWidth);

        radiiIn[0] = radiiIn[1] = radii[0] - borderWidth > 0 ? radii[0] - borderWidth : 0;
        radiiIn[2] = radiiIn[3] = radii[2] - borderWidth > 0 ? radii[2] - borderWidth : 0;
        radiiIn[4] = radiiIn[5] = radii[4] - borderWidth > 0 ? radii[4] - borderWidth : 0;
        radiiIn[6] = radiiIn[7] = radii[6] - borderWidth > 0 ? radii[6] - borderWidth : 0;
        borderPath.addRoundRect(borderPathRect, radiiIn, Path.Direction.CCW);
    }
    //</editor-fold>

    //<editor-fold desc="IBroderRadius">

    @Override
    public void setStrokeWidth(float strokeWidth) {
        borderWidth = strokeWidth;
        initialPaint();
        updatePath(this.width, height);
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
        hasRadii = radius != 0;
        radius(direction, radius);
    }

    @Override
    public void setMaskRadius(int direction, float radius) {
        hasRadii = false;
        radius(direction, radius);
    }

    private void radius(@Direction int direction, float radius) {
        if ((direction & D_ALL_CORNERS) == D_ALL_CORNERS || direction == 0) {//统一direction == 0，为ALL_CORNERS
            radii[0] = radii[1] = radii[2] = radii[3] = radii[6] = radii[7] = radii[4] = radii[5] = radius;
        } else {
//            radii[0] = radii[1] = radii[2] = radii[3] = radii[6] = radii[7] = radii[4] = radii[5] = 0;
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


    public void setBorderForceGround(boolean borderBackGround) {
        this.isBorderBackground = borderBackGround;
    }
}