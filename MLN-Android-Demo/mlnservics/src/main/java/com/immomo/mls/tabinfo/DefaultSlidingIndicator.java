package com.immomo.mls.tabinfo;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import com.immomo.mls.weight.BaseTabLayout;
import android.util.TypedValue;

public class DefaultSlidingIndicator implements BaseTabLayout.ISlidingIndicator {
    private Paint paint;
    private int width;
    private int height;
    private int radius;
    private int color = 0xff4a4a4a;

    private int paddingBottom;
    private Context context;

    public DefaultSlidingIndicator(Context context) {
        this(0);
        this.context = context;
        width = getPixels(6);
        height = getPixels(4);
        radius = getPixels(2);
    }

    public void setColor(int color) {
        this.color = color;
        if (paint != null) {
            paint.setColor(this.color);
        }
    }

    public DefaultSlidingIndicator(int paddingBottom) {
        paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(color);
        this.paddingBottom = paddingBottom;
    }

    @Override
    public void onDraw(Canvas canvas, int left, int top, int right, int bottom, float percent) {
        int newWidth = width + (int) ((0.5F - Math.abs(percent - 0.5F)) * width * 2);
        int drawableLeft = (left + right) / 2 - width / 2;
        int drawableRight = drawableLeft + newWidth;
        bottom = bottom - paddingBottom;
        canvas.drawRoundRect(new RectF(drawableLeft, bottom - height, drawableRight, bottom),
                radius, radius, paint);
    }

    private int getPixels(float dip) {
        return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dip, context.getResources().getDisplayMetrics()));
    }
}
