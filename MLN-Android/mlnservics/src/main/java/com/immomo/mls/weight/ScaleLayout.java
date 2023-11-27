/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.weight;

import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

public class ScaleLayout extends ViewGroup {
    private float childScaleX = 1F;
    private float childScaleY = 1F;

    public ScaleLayout(Context context) {
        super(context);
    }

    public ScaleLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ScaleLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public ScaleLayout(View view) {
        super(view.getContext());
        addView(view);
    }

    public void setChildScale(float scaleX, float scaleY) {
        childScaleX = scaleX;
        childScaleY = scaleY;
        if (!isInLayout()) {
            requestLayout();
        }
    }

    private float truncateScale(int measure, float scale) {
        if (measure == 0) return scale;
        int after = (int) (measure * scale + 0.5F);
        return after * 1F / measure;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int measuredWidth = 0;
        int measuredHeight = 0;

        final int count = getChildCount();
        for (int childIndex = 0; childIndex < count; childIndex++) {
            View child = getChildAt(childIndex);
            measureChild(child, widthMeasureSpec, heightMeasureSpec);

            measuredWidth = Math.max(measuredWidth, (int) (child.getMeasuredWidth() *
                    truncateScale(child.getMeasuredWidth(), childScaleX)));
            measuredHeight = Math.max(measuredHeight, (int) (child.getMeasuredHeight() *
                    truncateScale(child.getMeasuredHeight(), childScaleY)));
        }
        setMeasuredDimension(measuredWidth, measuredHeight);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        final int count = getChildCount();
        for (int childIndex = 0; childIndex < count; childIndex++) {
            View child = getChildAt(childIndex);

            float scaleX = truncateScale(child.getMeasuredWidth(), childScaleX);
            float scaleY = truncateScale(child.getMeasuredHeight(), childScaleY);
            child.setPivotX(0);
            child.setPivotY(0);
            child.setScaleX(scaleX);
            child.setScaleY(scaleY);

            final int childWidth = (int) (child.getMeasuredWidth() * scaleX);
            final int childHeight = (int) (child.getMeasuredHeight() * scaleY);
            child.layout(0, 0, childWidth, childHeight);
        }
    }
}