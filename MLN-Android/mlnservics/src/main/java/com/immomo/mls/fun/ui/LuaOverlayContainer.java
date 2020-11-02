/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ui;


import android.content.Context;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.fun.ud.view.UDViewGroup;

import java.util.ArrayList;

/**
 * Created by XiongFangyu on 2018/9/27.
 */
public class LuaOverlayContainer extends LuaViewGroup {

    public LuaOverlayContainer(Context context, UDViewGroup userdata) {
        super(context, userdata);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int maxHeight = 0;
        int maxWidth = 0;

        for (int i = 0; i < getChildCount(); i++) {
            final View child = getChildAt(i);
            if (child.getVisibility() != GONE) {
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();
                boolean reMeasure = false;
                maxWidth = Math.max(maxWidth,
                    child.getMeasuredWidth() + lp.leftMargin + lp.rightMargin);
                final int width = Math.max(0, getMeasuredWidth()
                    - getPaddingLeft() - getPaddingRight());

                if (maxWidth > width) {
                    reMeasure = true;
                    lp.width = width;
                }

                maxHeight = Math.max(maxHeight,
                    child.getMeasuredHeight() + lp.topMargin + lp.bottomMargin);
                final int height = Math.max(0, getMeasuredHeight()
                    - getPaddingTop() - getPaddingBottom());
                if (maxHeight > height) {
                    reMeasure = true;
                    lp.height = height;
                }
                if (reMeasure) {
                    measureChildWithMargins(child, widthMeasureSpec, 0, heightMeasureSpec, 0);
                }
            }
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);
    }

}
