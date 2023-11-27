/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.weight;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PixelFormat;
import android.graphics.Region;
import android.graphics.drawable.Drawable;
import android.os.Build;
import androidx.core.view.MotionEventCompat;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.LinearInterpolator;

import java.lang.ref.WeakReference;

/**
 * Created by XiongFangyu on 16/7/11.
 * 模拟Android 5.0以上触摸view的动画
 * 适用于Android 5.0以下的自定义view
 * 或 覆盖了{@link View#onTouchEvent(MotionEvent)}的自定义view
 * <p>
 * 简单使用方法:
 * <pre>
 *     public class RippleView extends View{
 *
 *         private RippleDrawable rippleDrawable;
 *
 *         public RippleView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
 *             super(context, attrs, defStyleAttr, defStyleRes);
 *             rippleDrawable = RippleDrawable.bindView(this,attrs,defStyleAttr,defStyleRes);
 *         }
 *         @Override
 *         public void onDraw(Canvas canvas) {
 *             super.onDraw(canvas);
 *             rippleDrawable.draw(canvas);
 *         }
 *         @Override
 *         public boolean onTouchEvent(MotionEvent event) {
 *             rippleDrawable.onTouchEvent(event);
 *             return super.onTouchEvent(event);
 *         }
 *     }
 * </pre>
 * <p>
 * <p>
 * <b>XML attributes</b>
 *
 * @attr ref com.immomo.momo.R.styleable#RippleDrawable_rpd_style
 * @attr ref com.immomo.momo.R.styleable#RippleDrawable_rpd_max_radius
 * @attr ref com.immomo.momo.R.styleable#RippleDrawable_rpd_color
 * @attr ref com.immomo.momo.R.styleable#RippleDrawable_rpd_ripple_speed
 * @attr ref com.immomo.momo.R.styleable#RippleDrawable_rpd_offset_scale
 * @attr ref com.immomo.momo.R.styleable#RippleDrawable_rpd_min_radius
 * @attr ref com.immomo.momo.R.styleable#RippleDrawable_rpd_cancel_when_outside
 * @attr ref com.immomo.momo.R.styleable#RippleDrawable_rpd_background_color
 */
public class BaseRippleDrawable extends Drawable {

    /**
     * 默认持续时间10s
     */
    protected static final int DEFAULT_DURATION = 10;
    /**
     * 最终动画持续时间
     */
    protected static final int DEFAULT_END_DURATION = 300;
    /**
     * 背景动画持续时间
     */
    protected static final int DEFAULT_BACK_ANIM_DURATION = 500;
    /**
     * 结束动画radius差值
     */
    protected static final int END_RADIUS_OFFSET = 700;
    /**
     * 滑动出view时取消
     */
    protected static final int CANCEL_OFFSET = 30;
    /**
     * 当滑动超过{@link #offsetScale}时,每次添加这个距离
     */
    protected static final int OFFSET_PX = 2;

    /**
     * 圈圈最小半径
     */
    protected float minRadius = 10f;
    /**
     * 圈圈的大小
     */
    protected float mRadius;
    /**
     * 圈圈颜色的透明度
     */
    protected int internalAlpha = 255;
    /**
     * 圆心坐标
     */
    protected float centerX, centerY;
    /**
     * 最大大小
     */
    protected int maxRadius = (int) (minRadius * 2);
    /**
     * 圈圈的颜色
     */
    protected int rippleColor = Color.GRAY;
    /**
     * 背景颜色
     */
    protected int backgroundColor = Color.LTGRAY;
    /**
     * 是否能画ripple
     */
    protected boolean canDrawRipple = true;
    /**
     * 是否能画背景
     */
    protected boolean canDrawBackground = false;
    /**
     * 是否能画
     */
    protected boolean enable = true;
    /**
     * 触摸动作不为down时是否执行动作
     */
    protected boolean enableMove = true;
    /**
     * 滑动出view时取消
     */
    protected boolean cancelWhenMoveOutside = true;
    /**
     * 动画扩大的速度 1~10 值越大,速度越快
     */
    protected int rippleSpeed = 5;
    /**
     * view的长和高
     */
    protected int viewWidth, viewHeight;
    /**
     * 背景alpha,0 ~ {@link #backgroundColor}的alpha
     */
    protected int backgroundAlpha;
    /**
     * {@link #setCenterX(float)} {@link #setCenterY(float)}
     */
    protected float offsetScale = 0.7f;

    private Path clipPath;

    private WeakReference<View> viewRef;

    protected Paint ripplePaint;
    protected Paint backPaint;

    protected ValueAnimator animator;

    protected AnimatorSet endAnimator;

    protected ValueAnimator backgroundAnimator;

    protected Animator.AnimatorListener rippleListener;

    protected Animator.AnimatorListener endListener;

    public BaseRippleDrawable() {
        this(null, null);
    }

    public BaseRippleDrawable(Context context, AttributeSet attrs) {
        this(context, attrs, 0, 0);
    }

    public BaseRippleDrawable(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {

        ripplePaint = new Paint();
        ripplePaint.setAntiAlias(true);
        backPaint = new Paint();
        backPaint.setAntiAlias(true);

        if (context == null || attrs == null) {
            return;
        }
    }

    public static BaseRippleDrawable bindView(View view) {
        return bindView(view, null);
    }

    public static BaseRippleDrawable bindView(View view, AttributeSet attrs) {
        return bindView(view, attrs, 0);
    }

    public static BaseRippleDrawable bindView(View view, AttributeSet attrs, int defStyleAttr) {
        return bindView(view, attrs, defStyleAttr, 0);
    }

    public static BaseRippleDrawable bindView(final View view, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        final BaseRippleDrawable drawable;
        if (attrs == null && defStyleAttr == 0 && defStyleRes == 0) {
            drawable = initRippleDrawable(view);
        } else {
            drawable = new BaseRippleDrawable(view.getContext(), attrs, defStyleAttr, defStyleRes);
        }
        view.getViewTreeObserver().addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
            @Override
            public boolean onPreDraw() {
                view.getViewTreeObserver().removeOnPreDrawListener(this);
                drawable.setMaxRidiusByView(view);
                return true;
            }
        });
        drawable.viewRef = new WeakReference<View>(view);
        view.setClickable(true);
        return drawable;
    }

    private static BaseRippleDrawable initRippleDrawable(View view) {
        BaseRippleDrawable rippleDrawable = new BaseRippleDrawable();
        rippleDrawable.setViewRect(view);
        rippleDrawable.setCancelWhenMoveOutside(false);
        rippleDrawable.setBackgroundColor(0X2FCCCCCC);
        rippleDrawable.setColor(0X6FCCCCCC);
        rippleDrawable.setRippleSpeed(10);

        rippleDrawable.setRadius(view);
        rippleDrawable.setCallback(view);
        rippleDrawable.setOffsetScale(1);
        return rippleDrawable;
    }

    public void setRadius(View view) {
        final int min = Math.min(view.getMeasuredHeight(), view.getMeasuredWidth()) / 2;
        this.setMaxRadius(min);
        this.setMinRadius(min / 2);
    }

    @Override
    public void draw(Canvas canvas) {
        if (enable) {
            canvas.save();
            if (clipPath != null && isSupportClippath(canvas) && !clipPath.isEmpty()) {
//                canvas.clipPath(clipPath, Region.Op.REPLACE);
            }
            if (canDrawBackground) {
                backPaint.setColor(backgroundColor);
                backPaint.setAlpha(backgroundAlpha);
                canvas.drawPaint(backPaint);
            }
            if (canDrawRipple)
                canvas.drawCircle(centerX, centerY, mRadius, ripplePaint);
            canvas.restore();
        }
    }

    /**
     * 是否支持{@link Canvas#clipPath(Path)}
     * 若开启了硬件加速，并且系统版本<18 不支持{@link Canvas#clipPath(Path)}
     *
     * @param canvas
     * @return
     */
    public static boolean isSupportClippath(Canvas canvas) {
        return true;
    }

    protected void setRadius(float radius) {
        if (radius < 0)
            radius = 0;
//        if (radius > maxRadius)
//            radius = maxRadius;
        mRadius = radius;

//        if (mRadius > 0) {
//            RadialGradient radialGradient = new RadialGradient(
//                    centerX, centerY, maxRadius, rippleColor, rippleColor, Shader.TileMode.MIRROR);
//            ripplePaint.setShader(radialGradient);
//        }
        invalidateSelf();
    }

    protected void setRippleAlpha(int alpha) {
        internalAlpha = alpha;
        ripplePaint.setAlpha(internalAlpha);
        invalidateSelf();
    }

    protected void setBackAlpha(int alpha) {
        backgroundAlpha = alpha;
        backPaint.setAlpha(backgroundAlpha);
    }

    private final ValueAnimator.AnimatorUpdateListener updateRadiusListener =
            new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    final float radius = (float) animation.getAnimatedValue();
                    setRadius(radius);
                }
            };

    private final ValueAnimator.AnimatorUpdateListener updateAlphaListener =
            new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    final int alpha = (int) animation.getAnimatedValue();
                    setRippleAlpha(alpha);
                }
            };

    private final ValueAnimator.AnimatorUpdateListener updateBackAlphaListener =
            new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    final int alpha = (int) animation.getAnimatedValue();
                    setBackAlpha(alpha);
                }
            };

    @Override
    public void setAlpha(int alpha) {
        rippleColor = Color.argb(
                alpha,
                Color.red(rippleColor),
                Color.green(rippleColor),
                Color.blue(rippleColor)
        );
        ripplePaint.setColor(rippleColor);
    }

    @Override
    public int getAlpha() {
        return Color.alpha(rippleColor);
    }

    public int getInternalAlpha() {
        return internalAlpha;
    }

    @Override
    public void setColorFilter(ColorFilter colorFilter) {

    }

    @Override
    public int getOpacity() {
        return PixelFormat.UNKNOWN;
    }

    @Override
    public void invalidateSelf() {
        if (viewRef != null) {
            View view = viewRef.get();
            if (view != null) {
                view.invalidate();
                return;
            }
        }
        super.invalidateSelf();
    }

//public method

    /**
     * 处理touch事件,在{@link View#onTouchEvent(MotionEvent)}中调用
     *
     * @param ev
     */
    public void onTouchEvent(MotionEvent ev) {
        final int action = MotionEventCompat.getActionMasked(ev);
        if (action != MotionEvent.ACTION_DOWN && !enableMove)
            return;
        enableMove = true;
        final float x = ev.getX();
        final float y = ev.getY();
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                startRipple(x, y);
                startBackgroundAnim();
                break;
            case MotionEvent.ACTION_MOVE:
                setCenterX(x);
                setCenterY(y);
                invalidateSelf();
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                startEndAnim();
                break;
        }
    }

    public void updateSize(int w, int h) {
        viewWidth = w;
        viewHeight = h;
    }

    /**
     * 保证在{@link View#measure(int, int)}或{@link View#onSizeChanged(int, int, int, int)}后调用此方法
     *
     * @param view
     */
    public void setMaxRidiusByView(View view) {
        setViewRect(view);
        maxRadius = Math.max(viewWidth, viewHeight);
    }

    public void setViewRect(View view) {
        viewWidth = view.getMeasuredWidth();
        viewHeight = view.getMeasuredHeight();
    }

    /**
     * 开始动画
     *
     * @param x 圆心x坐标
     * @param y 圆心y坐标
     */
    public void startRipple(float x, float y) {
        stopRipple();
        canDrawRipple = true;
        canDrawBackground = true;
        setCenterX(x);
        setCenterY(y);
        ripplePaint.setAlpha(internalAlpha);
        ripplePaint.setColor(rippleColor);
        if (animator == null) {
            animator = new ValueAnimator();
            animator.setInterpolator(new LinearInterpolator());
            animator.addUpdateListener(updateRadiusListener);
            if (rippleListener != null)
                animator.addListener(rippleListener);
        }
        animator.setFloatValues(minRadius, maxRadius);
        animator.setDuration((long) ((maxRadius - minRadius) / rippleSpeed * DEFAULT_DURATION));
        animator.start();
    }

    public void startRipple() {
        stopRipple();
        canDrawRipple = true;
        canDrawBackground = true;
        ripplePaint.setAlpha(internalAlpha);
        ripplePaint.setColor(rippleColor);
        if (animator == null) {
            animator = new ValueAnimator();
            animator.setInterpolator(new LinearInterpolator());
            animator.addUpdateListener(updateRadiusListener);
            if (rippleListener != null)
                animator.addListener(rippleListener);
        }
        animator.setFloatValues(minRadius, maxRadius);
        animator.setDuration((long) ((maxRadius - minRadius) / rippleSpeed * DEFAULT_DURATION));
        animator.start();
    }

    private ValueAnimator radius, alpha, backAlpha;

    /**
     * 开始结束动画,在{@link MotionEvent#ACTION_CANCEL}或{@link MotionEvent#ACTION_UP}时调用
     */
    public void startEndAnim() {
        stopRipple();
        canDrawRipple = true;
        canDrawBackground = true;

        if (radius == null) {
            radius = new ValueAnimator();
            radius.addUpdateListener(updateRadiusListener);
        }
        radius.setFloatValues(mRadius, mRadius + END_RADIUS_OFFSET);

        if (alpha == null) {
            alpha = ValueAnimator.ofInt(255, 0);
            alpha.addUpdateListener(updateAlphaListener);
        }

        if (backAlpha == null) {
            backAlpha = new ValueAnimator();
            backAlpha.addUpdateListener(updateBackAlphaListener);
        }
        backAlpha.setIntValues(backgroundAlpha, 0);

        if (endAnimator == null) {
            endAnimator = new AnimatorSet();
            endAnimator.setInterpolator(new LinearInterpolator());
            endAnimator.setDuration(DEFAULT_END_DURATION);
            endAnimator.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    canDrawRipple = false;
                    canDrawBackground = false;
                    mRadius = 0;
                    internalAlpha = 255;
                    centerX = 0;
                    centerY = 0;
                }
            });
            endAnimator.playTogether(radius, alpha, backAlpha);
        }
        endAnimator.start();
    }

    public void startBackgroundAnim() {
        if (backgroundAnimator != null) {
            backgroundAnimator.cancel();
        }
        if (backgroundAnimator == null) {
            backgroundAnimator = ValueAnimator.ofInt(0, Color.alpha(backgroundColor));
            backgroundAnimator.setInterpolator(new AccelerateInterpolator());
            backgroundAnimator.setDuration(DEFAULT_BACK_ANIM_DURATION);
            backgroundAnimator.addUpdateListener(updateBackAlphaListener);
            backgroundAnimator.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationCancel(Animator animation) {
                    setBackAlpha(0);
                }
            });
        }

        backgroundAnimator.start();
    }

    public void setRippleAnimatorListener(Animator.AnimatorListener listener) {
        this.rippleListener = listener;
    }

    public void setEndListener(Animator.AnimatorListener endListener) {
        this.endListener = endListener;
    }

    /**
     * 结束动画,并清空画布
     */
    public void stopRipple() {
        if (animator != null)
            animator.cancel();
        if (endAnimator != null)
            endAnimator.cancel();
        if (backgroundAnimator != null)
            backgroundAnimator.cancel();
        canDrawRipple = false;
        canDrawBackground = false;
    }

    public float getCenterX() {
        return centerX;
    }

    public float getCenterY() {
        return centerY;
    }

    protected float getOffset(float dest, float old, int max) {
        if (cancelWhenMoveOutside) {
            if (old < -CANCEL_OFFSET || old > max + CANCEL_OFFSET) {
                startEndAnim();
                enableMove = false;
            }
        }

        if (offsetScale == 1) {
            return old;
        }

        final int center = max / 2;
        final float scale = center * offsetScale;
        final float mi = center - scale;
        final float ma = center + scale;
        if (old < mi) {
            if (dest <= 0)
                dest = mi;
            else
                dest -= OFFSET_PX;
        } else if (old > ma) {
            if (dest <= 0)
                dest = ma;
            else
                dest += OFFSET_PX;
        } else
            dest = old;
        return dest;
    }

    public void setClipCircleRadius(float x, float y, float radius) {
        if (radius == 0)
            clipPath.reset();
        else {
            if (clipPath == null) {
                clipPath = new Path();
            }
            clipPath.reset();
            clipPath.addCircle(x, y, radius, Path.Direction.CCW);
        }
    }

    public void setClipPath(Path p) {
        if (clipPath == null) {
            clipPath = new Path();
        }
        clipPath.reset();
        clipPath.set(p);
    }

    public void setCenterX(float centerX) {
        this.centerX = getOffset(this.centerX, centerX, viewWidth);
    }

    public void setCenterY(float centerY) {
        this.centerY = getOffset(this.centerY, centerY, viewHeight);
    }

    public int getMaxRadius() {
        return maxRadius;
    }

    public void setMaxRadius(int maxRadius) {
        this.maxRadius = maxRadius;
    }

    public int getColor() {
        return rippleColor;
    }

    public void setColor(int mColor) {
        this.rippleColor = mColor;
    }

    public int getBackgroundColor() {
        return backgroundColor;
    }

    public void setBackgroundColor(int backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    public void setOffsetScale(float offsetScale) {
        if (offsetScale < 0 || offsetScale > 1)
            return;
        this.offsetScale = offsetScale;
    }

    public void setMinRadius(float minRadius) {
        if (minRadius < 0)
            minRadius = 0;
        this.minRadius = minRadius;
    }

    public boolean isEnable() {
        return enable;
    }

    public void setEnable(boolean enable) {
        this.enable = enable;
    }

    public int getRippleSpeed() {
        return rippleSpeed;
    }

    public void setRippleSpeed(int rippleSpeed) {
        if (rippleSpeed < 1)
            rippleSpeed = 1;
        if (rippleSpeed > 10)
            rippleSpeed = 10;
        this.rippleSpeed = rippleSpeed;
    }

    public boolean isCancelWhenMoveOutside() {
        return cancelWhenMoveOutside;
    }

    public void setCancelWhenMoveOutside(boolean cancelWhenMoveOutside) {
        this.cancelWhenMoveOutside = cancelWhenMoveOutside;
    }
}