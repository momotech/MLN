/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.weight;

import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

/**
 * Created by Xiong.Fangyu on 2019-12-10
 */
public class AutoGravityLayout extends FrameLayout {

    private static final int[] gravitys = new int[]{
            Gravity.TOP | Gravity.LEFT | Gravity.START,
            Gravity.TOP | Gravity.CENTER_HORIZONTAL,
            Gravity.TOP | Gravity.RIGHT | Gravity.END,
            Gravity.CENTER_VERTICAL | Gravity.LEFT | Gravity.START,
            Gravity.CENTER_VERTICAL | Gravity.RIGHT | Gravity.END,
            Gravity.BOTTOM | Gravity.LEFT | Gravity.START,
            Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL,
            Gravity.BOTTOM | Gravity.RIGHT | Gravity.END,
    };

    public AutoGravityLayout(@NonNull Context context) {
        super(context);
    }

    public AutoGravityLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public AutoGravityLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public AutoGravityLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    private View center;

    public void setCenter(View center) {
        this.center = center;
        addView(center);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        int index = 0;
        for (int i = 0, l = getChildCount(); i < l; i++, index++) {
            View child = getChildAt(i);
            if (child == center) {
                ((LayoutParams) child.getLayoutParams()).gravity = Gravity.CENTER;
                index--;
            } else if (child.getVisibility() == GONE) {
                index--;
            } else {
                index = index % gravitys.length;
                ((LayoutParams) child.getLayoutParams()).gravity = gravitys[index];
            }
        }
        super.onLayout(changed, left, top, right, bottom);
    }
}
