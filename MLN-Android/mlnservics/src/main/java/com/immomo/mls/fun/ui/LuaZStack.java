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
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.ud.view.UDViewGroup;
import com.immomo.mls.fun.weight.BorderRadiusFrameLayout;
import com.immomo.mls.fun.weight.BorderRadiusZStack;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class LuaZStack<U extends UDViewGroup> extends BorderRadiusZStack implements ILViewGroup<U> {
    protected U userdata;

    private ViewLifeCycleCallback cycleCallback;

    public LuaZStack(Context context, U userdata) {
        super(context);
        this.userdata = userdata;
        setViewLifeCycleCallback(userdata);
    }

    //<editor-fold desc="ILViewGroup">
    @Override
    public U getUserdata() {
        return userdata;
    }

    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        getUserdata().measureOverLayout(widthMeasureSpec, heightMeasureSpec);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        getUserdata().layoutOverLayout(left, top, right, bottom);
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);
        getUserdata().drawOverLayout(canvas);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (cycleCallback != null) {
            cycleCallback.onAttached();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (cycleCallback != null) {
            cycleCallback.onDetached();
        }
    }

    @Override
    public void bringSubviewToFront(UDView child) {
        View v = child.getView();
        v.bringToFront();
    }

    @Override
    public void sendSubviewToBack(UDView child) {
        View v = child.getView();
        removeView(v);
        addView(v, 0);
    }

    @Override
    public ViewGroup.LayoutParams applyLayoutParams(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        int l, t, r, b, gravity;
        l = udLayoutParams.realMarginLeft;
        t = udLayoutParams.realMarginTop;
        r = udLayoutParams.realMarginRight;
        b = udLayoutParams.realMarginBottom;
        if (udLayoutParams.isSetGravity) {
            gravity = udLayoutParams.gravity;
        } else {
            gravity = udLayoutParams.gravity = -1;
        }
        LayoutParams ret = parseLayoutParams(src);
        ret.setMargins(l, t, r, b);
        ret.gravity = gravity;
        return ret;
    }

    @NonNull
    @Override
    public ViewGroup.LayoutParams applyChildCenter(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        LayoutParams ret = parseLayoutParams(src);
        if (!Float.isNaN(udLayoutParams.centerX)) {
            if (ret.gravity == Gravity.CENTER_VERTICAL || ret.gravity == Gravity.CENTER) {
                ret.gravity = Gravity.CENTER;
            } else {
                ret.gravity = Gravity.CENTER_HORIZONTAL;
            }
            int w = getUserdata().getWidth();
            if (w > 0) {
                int cx = w >> 1;
                ret.leftMargin = (int) (udLayoutParams.centerX - cx);
            }
        }
        if (!Float.isNaN(udLayoutParams.centerY)) {
            if (ret.gravity == Gravity.CENTER_HORIZONTAL || ret.gravity == Gravity.CENTER) {
                ret.gravity = Gravity.CENTER;
            } else {
                ret.gravity = Gravity.CENTER_VERTICAL;
            }
            int h = getUserdata().getHeight();
            if (h > 0) {
                int ch = h >> 1;
                ret.topMargin = (int) (udLayoutParams.centerY - ch);
            }
        }
        return ret;
    }
    //</editor-fold>

    private LayoutParams parseLayoutParams(ViewGroup.LayoutParams src) {
        if (src == null) {
            src = generateNewWrapContentLayoutParams();
        } else if (!(src instanceof LayoutParams)) {
            if (src instanceof MarginLayoutParams) {
                src = generateNewLayoutParams((MarginLayoutParams) src);
            } else {
                src = generateNewLayoutParams(src);
            }
        }
        return (LayoutParams) src;
    }

    protected @NonNull
    ViewGroup.LayoutParams generateNewWrapContentLayoutParams() {
        return new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    protected @NonNull
    ViewGroup.LayoutParams generateNewLayoutParams(MarginLayoutParams src) {
        return new LayoutParams(src);
    }

    protected @NonNull
    ViewGroup.LayoutParams generateNewLayoutParams(ViewGroup.LayoutParams src) {
        return new LayoutParams(src);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        return isEnabled() && super.dispatchTouchEvent(ev);
    }
}
