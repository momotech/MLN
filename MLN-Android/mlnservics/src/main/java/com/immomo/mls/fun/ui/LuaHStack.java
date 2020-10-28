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
import android.view.MotionEvent;
import android.view.ViewGroup;

import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.fun.ud.view.UDHStack;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.weight.BorderRadiusHStack;
import com.immomo.mls.utils.ErrorUtils;

import androidx.annotation.NonNull;

public class LuaHStack<U extends UDHStack> extends BorderRadiusHStack implements ILViewGroup<U> {
    protected U userdata;
    private ViewLifeCycleCallback cycleCallback;

    public LuaHStack(Context context, U ud) {
        super(context);
        userdata = ud;
        setViewLifeCycleCallback(userdata);
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
    public void bringSubviewToFront(UDView child) {
        ErrorUtils.debugUnsupportError("Row does not support bringSubviewToFront method");
    }

    @Override
    public void sendSubviewToBack(UDView child) {
        ErrorUtils.debugUnsupportError("Row does not support sendSubviewToBack method");
    }

    @NonNull
    @Override
    public ViewGroup.LayoutParams applyLayoutParams(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        LayoutParams ret = parseLayoutParams(src);
        ret.setMargins(udLayoutParams.realMarginLeft, udLayoutParams.realMarginTop, udLayoutParams.realMarginRight, udLayoutParams.realMarginBottom);
        if (udLayoutParams.isSetGravity) {
            ret.gravity = udLayoutParams.gravity;
        } else {
            ret.gravity = udLayoutParams.gravity = -1;
        }
        ret.priority = udLayoutParams.priority;
        ret.weight = udLayoutParams.weight;
        return ret;
    }

    @NonNull
    @Override
    public ViewGroup.LayoutParams applyChildCenter(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        return src;
    }

    @Override
    public U getUserdata() {
        return userdata;
    }

    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
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
