package com.immomo.mmui.weight.impl;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.Shader;
import android.graphics.drawable.Drawable;
import android.view.MotionEvent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.fun.constants.GradientType;
import com.immomo.mls.weight.BaseRippleDrawable;
import com.immomo.mmui.weight.IBackgroundDrawable;

import static com.immomo.mls.fun.constants.RectCorner.ALL_CORNERS;
import static com.immomo.mls.fun.constants.RectCorner.BOTTOM_LEFT;
import static com.immomo.mls.fun.constants.RectCorner.BOTTOM_RIGHT;
import static com.immomo.mls.fun.constants.RectCorner.TOP_LEFT;
import static com.immomo.mls.fun.constants.RectCorner.TOP_RIGHT;

/**
 * Created by Xiong.Fangyu on 2020/11/10
 */
public class BackgroundDrawable extends Drawable
        implements IBackgroundDrawable, Drawable.Callback {
    private int color = Color.TRANSPARENT;
    private final Paint backgroundPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    private int[] gradientColors;
    private @GradientType.Type int mGradientType;
    private boolean mGradientIsDirty = false;

    private Drawable bgDrawable;

    private Path roundPath;
    private float[] radii;

    private BaseRippleDrawable rippleDrawable;
    private boolean drawRipple = false;

    public BackgroundDrawable() {
        backgroundPaint.setStyle(Paint.Style.FILL);
        backgroundPaint.setColor(color);
    }

    @Override
    protected void onBoundsChange(Rect bounds) {
        if (roundPath != null)
            roundPath.reset();
        updatePaint();
    }

    @Override
    public void draw(@NonNull Canvas canvas) {
        Rect r = getBounds();
        int w = r.width();
        int h = r.height();
        final boolean round = roundPath != null && checkRadii();
        if (round) {
            if (roundPath.isEmpty())
                roundPath.addRoundRect(0, 0, w, h, radii, Path.Direction.CW);
        }
        if (drawRipple) {
            rippleDrawable.updateSize(w, h);
            rippleDrawable.setMaxRadius(Math.max(w, h) >> 1);
            rippleDrawable.setMinRadius(Math.min(w, h) >> 2);
            rippleDrawable.setClipPath(roundPath);
            rippleDrawable.draw(canvas);
        }
        if (bgDrawable != null) {
            bgDrawable.setBounds(0, 0, w, h);
            if (round) {
                canvas.save();
                canvas.clipPath(roundPath);
                bgDrawable.draw(canvas);
                canvas.restore();
            } else {
                bgDrawable.draw(canvas);
            }
        } else {
            if (round) {
                canvas.drawPath(roundPath, backgroundPaint);
            } else {
                canvas.drawRect(0, 0, w, h, backgroundPaint);
            }
        }
    }

    @Override
    public void setAlpha(int alpha) {
        backgroundPaint.setAlpha(alpha);
    }

    @Override
    public void setColorFilter(@Nullable ColorFilter colorFilter) {
        backgroundPaint.setColorFilter(colorFilter);
    }

    @Override
    public int getOpacity() {
        return PixelFormat.OPAQUE;
    }

    @Override
    public void setBackgroundRadius(float r) {
        setBackgroundRadius(r, r, r, r);
    }

    @Override
    public void setBackgroundRadius(float topLeft, float topRight, float bottomLeft, float bottomRight) {
        if (radii == null)
            radii = new float[8];
        radii[0] = radii[1] = topLeft;
        radii[2] = radii[3] = topRight;
        radii[4] = radii[5] = bottomRight;
        radii[6] = radii[7] = bottomLeft;
        if (roundPath == null)
            roundPath = new Path();
        else
            roundPath.reset();
    }

    @Override
    public void setBackgroundRadius(int direction, float radius) {
        if (radii == null)
            radii = new float[8];
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
        if (roundPath == null)
            roundPath = new Path();
        else
            roundPath.reset();
    }

    @Override
    public float getBackgroundRadius(int direction) {
        if (radii == null)
            return 0;
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

    private boolean checkRadii() {
        return radii[0] != 0 || radii[2] != 0 || radii[4] != 0 || radii[6] != 0;
    }

    @Override
    public void setBackgroundColor(int color) {
        this.color = color;
        backgroundPaint.setColor(color);
        backgroundPaint.setShader(null);
        mGradientIsDirty = false;
        gradientColors = null;
        mGradientType = 0;
        invalidateSelf();
    }

    @Override
    public int getBackgroundColor() {
        return color;
    }

    @Override
    public void setBGDrawable(Drawable d) {
        bgDrawable = d;
    }

    @Override
    public void setGradientColor(int start, int end, @GradientType.Type int type) {
        if (gradientColors == null) {
            gradientColors = new int[2];
        }
        if (gradientColors[0] == start
                && gradientColors[1] == end
                && mGradientType == type) {
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

    private void updatePaint() {
        if (!mGradientIsDirty)
            return;

        mGradientIsDirty = false;
        LinearGradient gradient = null;

        final Rect bounds = getBounds();

        int cx = bounds.centerX();
        int cy = bounds.centerY();

        switch (mGradientType) {
            case GradientType.TOP_TO_BOTTOM:
                gradient = new LinearGradient(cx,
                        bounds.top, cx, bounds.bottom,
                        gradientColors, null, Shader.TileMode.CLAMP);
                break;
            case GradientType.BOTTOM_TO_TOP:
                gradient = new LinearGradient(cx, bounds.bottom, cx,
                        bounds.top,
                        gradientColors, null, Shader.TileMode.CLAMP);
                break;
            case GradientType.LEFT_TO_RIGHT:
                gradient = new LinearGradient(bounds.left,
                        cy, bounds.right, cy,
                        gradientColors, null, Shader.TileMode.CLAMP);
                break;

            case GradientType.RIGHT_TO_LEFT:
                gradient = new LinearGradient(bounds.right, cy, bounds.left,
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

    @Override
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
