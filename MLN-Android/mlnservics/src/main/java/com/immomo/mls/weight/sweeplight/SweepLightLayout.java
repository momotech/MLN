package com.immomo.mls.weight.sweeplight;

import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ComposeShader;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.Shader;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.RelativeLayout;

import com.immomo.mls.R;

public class SweepLightLayout
        extends RelativeLayout {
    //默认动画单次时长
    private static final int DEFAULT_ANIMATION_DURATION = 1700;
    //默认倾斜角度
    private static final int DEFAULT_ANGLE = 20;
    //倾斜最小角度
    private static final int MIN_ANGLE_VALUE = -45;
    //倾斜最大角度
    private static final int MAX_ANGLE_VALUE = 45;
    //光柱最小比例
    private static final float MIN_MASK_WIDTH_VALUE = 0f;
    //光柱最大比例
    private static final float MAX_MASK_WIDTH_VALUE = 1f;
    //默认光柱比例
    private static final float DEFAULT_MASK_WIDTH_VALUE = 0.7f;
    //默认光柱起始颜色
    private static final int DEFAULT_START_COLOR = Color.parseColor("#F3F3F3");
    //默认光柱中心颜色
    private static final int DEFAULT_MIDDLE_COLOR = Color.parseColor("#E6E6E6");
    //默认光柱结束颜色
    private static final int DEFAULT_END_COLOR = Color.parseColor("#F3F3F3");

    //默认光柱起始颜色-暗色
    private static final int DEFAULT_DARK_START_COLOR = Color.parseColor("#111111");
    //默认光柱中心颜色-暗色
    private static final int DEFAULT_DARK_MIDDLE_COLOR = Color.parseColor("#222222");
    //默认光柱结束颜色-暗色
    private static final int DEFAULT_DARK_END_COLOR = Color.parseColor("#111111");


    private int maskOffsetX;
    private Rect maskRect;
    private Paint gradientTexturePaint;
    private ValueAnimator maskAnimator;

    private Bitmap localMaskBitmap;
    private Bitmap maskBitmap;
    private Canvas canvasForShimmerMask;

    private boolean isAnimationReversed;
    private boolean isAnimationStarted;
    private int shimmerAnimationDuration;
    private int shimmerMiddleColor;
    private int shimmerStartColor;
    private int shimmerEndColor;
    private int shimmerAngle;
    private float maskWidth;
    private Runnable startRunnable;


    public SweepLightLayout(Context context) {
        this(context, null);
    }

    public SweepLightLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SweepLightLayout(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

        setWillNotDraw(false);
        setBackgroundColor(Color.WHITE);

        TypedArray a = context.getTheme().obtainStyledAttributes(
                attrs,
                R.styleable.SweepLightLayout,
                0, 0);

        try {
            shimmerAngle = a.getInteger(R.styleable.SweepLightLayout_sll_angle, DEFAULT_ANGLE);
            shimmerAnimationDuration = a.getInteger(R.styleable.SweepLightLayout_sll_animation_duration, DEFAULT_ANIMATION_DURATION);
            shimmerStartColor = a.getColor(R.styleable.SweepLightLayout_sll_start_color, DEFAULT_START_COLOR);
            shimmerMiddleColor = a.getColor(R.styleable.SweepLightLayout_sll_middle_color, DEFAULT_MIDDLE_COLOR);
            shimmerEndColor = a.getColor(R.styleable.SweepLightLayout_sll_end_color, DEFAULT_END_COLOR);
            maskWidth = a.getFloat(R.styleable.SweepLightLayout_sll_mask_width, DEFAULT_MASK_WIDTH_VALUE);
            isAnimationReversed = a.getBoolean(R.styleable.SweepLightLayout_sll_reverse_animation, false);
        } finally {
            a.recycle();
        }

        setMaskWidth(maskWidth);
        setShimmerAngle(shimmerAngle);

        setLayerType(View.LAYER_TYPE_SOFTWARE, null);

        if (getVisibility() == VISIBLE) {
            startShimmerAnimation();
        }

    }

    @Override
    protected void onDetachedFromWindow() {
        removeCallbacks(startRunnable);
        resetShimmering();
        super.onDetachedFromWindow();
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        if (!isAnimationStarted || getWidth() <= 0 || getHeight() <= 0) {
            super.dispatchDraw(canvas);
        } else {
            try {
                dispatchDrawShimmer(canvas);
            } catch (Exception ignore) {
            }
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (visibility == VISIBLE) {
            startShimmerAnimation();
        } else {
            stopShimmerAnimation();
        }
    }

    public void startShimmerAnimation() {
        if (isAnimationStarted) {
            return;
        }
        removeCallbacks(startRunnable);
        startRunnable = new Runnable() {
            @Override
            public void run() {
                if (getWidth() > 0 && getHeight() > 0) {
                    Animator animator = getShimmerAnimation();
                    animator.start();
                    isAnimationStarted = true;
                }
            }
        };
        post(startRunnable);
    }


    public void stopShimmerAnimation() {
        resetShimmering();
    }

    public void setShimmerMiddleColor(int shimmerMiddleColor) {
        this.shimmerMiddleColor = shimmerMiddleColor;
        resetIfStarted();
    }

    public void setShimmerStartColor(int shimmerStartColor) {
        this.shimmerStartColor = shimmerStartColor;
        resetIfStarted();
    }

    public void setShimmerEndColor(int shimmerEndColor) {
        this.shimmerEndColor = shimmerEndColor;
        resetIfStarted();
    }

    public void setShimmerColor(int shimmerStartColor, int shimmerMiddleColor, int shimmerEndColor) {
        this.shimmerStartColor = shimmerStartColor;
        this.shimmerEndColor = shimmerEndColor;
        this.shimmerMiddleColor = shimmerMiddleColor;
        resetIfStarted();
    }

    public void setShimmerAnimationDuration(int durationMillis) {
        this.shimmerAnimationDuration = durationMillis;
        resetIfStarted();
    }

    public void setAnimationReversed(boolean animationReversed) {
        this.isAnimationReversed = animationReversed;
        resetIfStarted();
    }


    public void setShimmerAngle(int angle) {
        if (angle < MIN_ANGLE_VALUE) {
            this.shimmerAngle = MIN_ANGLE_VALUE;
        } else if (angle > MAX_ANGLE_VALUE) {
            this.shimmerAngle = MAX_ANGLE_VALUE;
        } else {
            this.shimmerAngle = angle;
        }
        resetIfStarted();
    }

    public void setMaskWidth(float maskWidth) {
        if (maskWidth <= MIN_MASK_WIDTH_VALUE || MAX_MASK_WIDTH_VALUE < maskWidth) {
            maskWidth = DEFAULT_MASK_WIDTH_VALUE;
        }

        this.maskWidth = maskWidth;
        resetIfStarted();
    }


    private void resetIfStarted() {
        if (isAnimationStarted) {
            resetShimmering();
            startShimmerAnimation();
        }
    }

    private void dispatchDrawShimmer(Canvas canvas) {
        super.dispatchDraw(canvas);

        localMaskBitmap = getMaskBitmap();
        if (localMaskBitmap == null) {
            return;
        }

        if (canvasForShimmerMask == null) {
            canvasForShimmerMask = new Canvas(localMaskBitmap);
        }

        canvasForShimmerMask.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);

        canvasForShimmerMask.save();
        canvasForShimmerMask.translate(-maskOffsetX, 0);

        super.dispatchDraw(canvasForShimmerMask);

        canvasForShimmerMask.restore();

        drawShimmer(canvas);

        localMaskBitmap = null;
    }

    private void drawShimmer(Canvas destinationCanvas) {
        createShimmerPaint();

        destinationCanvas.save();

        destinationCanvas.translate(maskOffsetX, 0);
        try {
            destinationCanvas.drawRect(maskRect.left, 0, maskRect.width(), maskRect.height(), gradientTexturePaint);
        } catch (NullPointerException ignored) {
        } finally {
            destinationCanvas.restore();
        }
    }

    private void resetShimmering() {
        if (maskAnimator != null) {
            maskAnimator.end();
            maskAnimator.removeAllUpdateListeners();
        }

        maskAnimator = null;
        gradientTexturePaint = null;
        isAnimationStarted = false;

        releaseBitMaps();
    }

    private void releaseBitMaps() {
        canvasForShimmerMask = null;

        if (maskBitmap != null) {
            maskBitmap.recycle();
            maskBitmap = null;
        }
    }

    private Bitmap getMaskBitmap() {
        if (maskBitmap == null && maskRect != null) {
            maskBitmap = createBitmap(maskRect.width(), getHeight());
        }

        return maskBitmap;
    }

    private void createShimmerPaint() {
        if (gradientTexturePaint != null) {
            return;
        }

        final int edgeColor = reduceColorAlphaValueToZero(shimmerStartColor);
        final float shimmerLineWidth = getWidth() / 2 * maskWidth;
        final float yPosition = (0 <= shimmerAngle) ? getHeight() : 0;

        LinearGradient gradient = new LinearGradient(
                0, yPosition,
                (float) Math.cos(Math.toRadians(shimmerAngle)) * shimmerLineWidth,
                yPosition + (float) Math.sin(Math.toRadians(shimmerAngle)) * shimmerLineWidth,
                new int[]{edgeColor, shimmerStartColor, shimmerMiddleColor, shimmerEndColor, edgeColor},
                getGradientColorDistribution(),
                Shader.TileMode.CLAMP);

        BitmapShader maskBitmapShader = new BitmapShader(localMaskBitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP);

        ComposeShader composeShader = new ComposeShader(gradient, maskBitmapShader, PorterDuff.Mode.DST_IN);

        gradientTexturePaint = new Paint();
        gradientTexturePaint.setAntiAlias(true);
        gradientTexturePaint.setDither(true);
        gradientTexturePaint.setFilterBitmap(true);
        gradientTexturePaint.setShader(composeShader);
    }

    private Animator getShimmerAnimation() {
        if (maskAnimator != null) {
            return maskAnimator;
        }

        if (maskRect == null) {
            maskRect = calculateBitmapMaskRect();
        }

        final int animationToX = getWidth();
        final int animationFromX;

        if (getWidth() > maskRect.width()) {
            animationFromX = -animationToX;
        } else {
            animationFromX = -maskRect.width();
        }

        final int shimmerBitmapWidth = maskRect.width();
        final int shimmerAnimationFullLength = animationToX - animationFromX;

        maskAnimator = isAnimationReversed ? ValueAnimator.ofInt(shimmerAnimationFullLength, 0)
                : ValueAnimator.ofInt(0, shimmerAnimationFullLength);
        maskAnimator.setDuration(shimmerAnimationDuration);
        maskAnimator.setRepeatCount(ObjectAnimator.INFINITE);

        maskAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                maskOffsetX = animationFromX + (int) animation.getAnimatedValue();
                if (maskOffsetX + shimmerBitmapWidth >= 0) {
                    invalidate();
                }
            }
        });

        return maskAnimator;
    }

    private Bitmap createBitmap(int width, int height) {
        try {
            return Bitmap.createBitmap(width, height, Bitmap.Config.ALPHA_8);
        } catch (OutOfMemoryError e) {
            return null;
        }
    }

    public void setDarkMode() {
        setBackgroundColor(Color.BLACK);
        setShimmerStartColor(DEFAULT_DARK_START_COLOR);
        setShimmerMiddleColor(DEFAULT_DARK_MIDDLE_COLOR);
        setShimmerEndColor(DEFAULT_DARK_END_COLOR);
    }

    public void setLightMode() {
        setBackgroundColor(Color.WHITE);
        setShimmerStartColor(DEFAULT_START_COLOR);
        setShimmerMiddleColor(DEFAULT_MIDDLE_COLOR);
        setShimmerEndColor(DEFAULT_END_COLOR);
    }

    private int reduceColorAlphaValueToZero(int actualColor) {
        return Color.argb(25, Color.red(actualColor), Color.green(actualColor), Color.blue(actualColor));
    }

    private Rect calculateBitmapMaskRect() {
        return new Rect(0, 0, calculateMaskWidth(), getHeight());
    }

    private int calculateMaskWidth() {
        final double shimmerLineBottomWidth = (getWidth() / 2 * maskWidth) / Math.cos(Math.toRadians(Math.abs(shimmerAngle)));
        final double shimmerLineRemainingTopWidth = getHeight() * Math.tan(Math.toRadians(Math.abs(shimmerAngle)));

        return (int) (shimmerLineBottomWidth + shimmerLineRemainingTopWidth);
    }

    private float[] getGradientColorDistribution() {
        final float[] colorDistribution = new float[5];

        colorDistribution[0] = 0F;
        colorDistribution[1] = 0.15F;
        colorDistribution[2] = 0.5F;
        colorDistribution[3] = 0.85F;
        colorDistribution[4] = 1F;

        return colorDistribution;
    }

}