/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.tabinfo;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.TypedValue;

import com.immomo.mls.fun.ud.view.UDTabLayout;
import com.immomo.mls.weight.BaseTabLayout;

public class DefaultSlidingIndicator implements BaseTabLayout.ISlidingIndicator {
    private Paint paint;
    private int height;
    private int radius;
    private int color = UDTabLayout.DEFAULT_COLOR;

    private int paddingBottom;
    private Context context;

    public DefaultSlidingIndicator(Context context) {
        this(0);
        this.context = context;
        height = getPixels(2);
        radius = getPixels(2);
    }

    public void setColor(int color) {
        this.color = color;
        if (paint != null) {
            paint.setColor(this.color);
        }
    }

    public void setHeight(int height) {
        this.height = getPixels(height);
    }

    public int getHeight() {
        return height;
    }

    public DefaultSlidingIndicator(int paddingBottom) {
        paint = new Paint(Paint.ANTI_ALIAS_FLAG);
        paint.setColor(color);
        this.paddingBottom = paddingBottom;
    }

    @Override
    public void onDraw(Canvas canvas, int left, int top, int right, int bottom, float percent) {
        bottom = bottom - paddingBottom;
        canvas.drawRoundRect(new RectF(left, bottom - height, right, bottom),
                radius, radius, paint);
    }

    private int getPixels(float dip) {
        return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dip, context.getResources().getDisplayMetrics()));
    }
}