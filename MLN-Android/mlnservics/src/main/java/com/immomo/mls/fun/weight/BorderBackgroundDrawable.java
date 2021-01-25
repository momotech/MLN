/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.weight;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Shader;
import android.graphics.drawable.Drawable;
import android.view.MotionEvent;

import com.immomo.mls.fun.constants.GradientType;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.view.IBorderRadiusView;
import com.immomo.mls.weight.BaseRippleDrawable;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class BorderBackgroundDrawable extends BorderDrawable implements IBorderRadiusView, Drawable.Callback {

    private int color = Color.TRANSPARENT;
    private final Paint backgroundPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    private final Path roundPath = new Path();
    private final RectF pathRect = new RectF();
    private int[] gradientColors;
    private int mGradientType;
    private boolean mGradientIsDirty = false;
    private BaseRippleDrawable rippleDrawable;
    private Drawable bgDrawable;
    private final float[] backRadii;
    private boolean drawRipple = false;

    public BorderBackgroundDrawable() {
        backgroundPaint.setStyle(Paint.Style.FILL);
        backgroundPaint.setColor(color);
        backRadii = new float[8];
    }

    @Override
    public void setBgColor(int color) {
        this.color = color;
        backgroundPaint.setColor(color);
        backgroundPaint.setShader(null);
        mGradientIsDirty = false;
        gradientColors = null;
        mGradientType = 0;
        invalidateSelf();
    }

    @Override
    public void setBgDrawable(Drawable drawable) {
        bgDrawable = drawable;
    }

    @Override
    public void setDrawRadiusBackground(boolean draw) {
    }

    @Override
    public int getBgColor() {
        return color;
    }

    @Override
    public void setGradientColor(int start, int end, int type) {
        if (gradientColors == null) {
            gradientColors = new int[2];
        }
        if (gradientColors.length == 2 && gradientColors[0] == start && gradientColors[1] == end && mGradientType == type) {
            return;
        }
        gradientColors[0] = start;
        gradientColors[1] = end;
        mGradientType = type;
        mGradientIsDirty = true;
        Rect r = getBounds();
        if (r.width() != 0 && r.height() != 0) {
            updatePaint();
            invalidateSelf();
        }
    }

    @Override
    public void setRadiusColor(int color) {

    }

    @Override
    public void setAddShadow(int color, Size offset, float radius, float alpha) {

    }

    @Override
    public void draw(@NonNull Canvas canvas) {
        if (hasRadii) {
            canvas.drawPath(roundPath, backgroundPaint);
        } else {
            canvas.drawRect(pathRect, backgroundPaint);
        }
        super.draw(canvas);
        if (drawRipple) {
            rippleDrawable.draw(canvas);
        }
        if (bgDrawable != null) {
            bgDrawable.setBounds(0, 0, getBounds().width(), getBounds().height());
            bgDrawable.draw(canvas);
        }
    }

    @Override
    public void setAlpha(int alpha) {
        super.setAlpha(alpha);
        color = Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color));
    }

    @Override
    protected void updatePath(int w, int h) {
        super.updatePath(w, h);
        roundPath.reset();
        if (w == 0 || h == 0) {
            pathRect.set(0, 0, w, h);
            return;
        }
        pathRect.set(0, 0, w, h);
        updatePaint();

        if (hasRadii) {
            for (int i = 0; i < radii.length; i++) {
                float radiu = radii[i];
                backRadii[i] = radiu > 0 ? radiu : 0;
            }
            roundPath.addRoundRect(pathRect, backRadii, Path.Direction.CW);
        }

        if (drawRipple && rippleDrawable != null) {
            rippleDrawable.updateSize(w, h);
            rippleDrawable.setMaxRadius(Math.max(w, h) >> 1);
            rippleDrawable.setMinRadius(Math.min(w, h) >> 2);
            rippleDrawable.setClipPath(roundPath);
        }
    }

    private void updatePaint() {
        if (!mGradientIsDirty)
            return;

        mGradientIsDirty = false;
        LinearGradient gradient = null;

        final Rect bounds = getBounds();

        int cx = bounds.centerX();
        int cy = bounds.centerY();

        switch (mGradientType) {

            // VERTICAL
            case GradientType.TOP_TO_BOTTOM:
                gradient = new LinearGradient(cx,
                        bounds.top + borderWidth, cx, bounds.bottom - borderWidth,
                        gradientColors, null, Shader.TileMode.CLAMP);
                break;

            case GradientType.BOTTOM_TO_TOP:
                gradient = new LinearGradient(cx, bounds.bottom - borderWidth, cx,
                        bounds.top + borderWidth,
                        gradientColors, null, Shader.TileMode.CLAMP);
                break;

            // HORIZONTAL
            case GradientType.LEFT_TO_RIGHT:

                gradient = new LinearGradient(bounds.left + borderWidth,
                        cy, bounds.right - borderWidth, cy,
                        gradientColors, null, Shader.TileMode.CLAMP);
                break;

            case GradientType.RIGHT_TO_LEFT:

                gradient = new LinearGradient(bounds.right - borderWidth, cy, bounds.left + borderWidth,
                        cy,
                        gradientColors, null, Shader.TileMode.CLAMP);
                break;
        }

        if (gradient != null) {
            backgroundPaint.setColor(Color.BLACK);
            backgroundPaint.setShader(gradient);
        }
    }

    @Override
    public void setDrawRipple(boolean drawRipple) {
        if (this.drawRipple == drawRipple) {
            return;
        }
        this.drawRipple = drawRipple;
        if (rippleDrawable == null) {
            initRippleDrawable();
        }
    }

    public void onRippleTouchEvent(MotionEvent event) {
        if (drawRipple && rippleDrawable != null) {
            rippleDrawable.onTouchEvent(event);
        }
    }

    private void initRippleDrawable() {
        rippleDrawable = new BaseRippleDrawable();
        rippleDrawable.setCancelWhenMoveOutside(false);
        rippleDrawable.setBackgroundColor(0X2FCCCCCC);
        rippleDrawable.setColor(0X6FCCCCCC);
        rippleDrawable.setRippleSpeed(8);
        rippleDrawable.setCallback(this);
        rippleDrawable.setOffsetScale(1);
    }

    @Override
    public void invalidateDrawable(@NonNull Drawable who) {
        invalidateSelf();
    }

    @Override
    public void scheduleDrawable(@NonNull Drawable who, @NonNull Runnable what, long when) {
        scheduleSelf(what, when);
    }

    @Override
    public void unscheduleDrawable(@NonNull Drawable who, @NonNull Runnable what) {
        unscheduleSelf(what);
    }
}