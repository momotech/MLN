/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ui;

import android.content.Context;
import android.view.MotionEvent;
import android.view.ViewGroup;

import com.immomo.mmui.ILView;
import com.immomo.mmui.ILViewGroup;
import com.immomo.mmui.ud.UDNodeGroup;
import com.immomo.mmui.weight.BorderRadiusNodeLayout;

import androidx.annotation.NonNull;

public class LuaNodeLayout<U extends UDNodeGroup> extends BorderRadiusNodeLayout implements ILViewGroup<U> {
    protected U userdata;
    private ILView.ViewLifeCycleCallback cycleCallback;


    public LuaNodeLayout(Context context, U ud) {
        this(context, ud,false);
    }

    public LuaNodeLayout(Context context, U ud, boolean isVirtual) {
        super(context, isVirtual);
        userdata = ud;
        setViewLifeCycleCallback(userdata);
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

    private ViewGroup.LayoutParams parseLayoutParams(ViewGroup.LayoutParams src) {
        if (src == null) {
            src = generateNewWrapContentLayoutParams();
        } else if (!(src instanceof ViewGroup.LayoutParams)) {
            if (src instanceof ViewGroup.MarginLayoutParams) {
                src = generateNewLayoutParams((ViewGroup.MarginLayoutParams) src);
            } else {
                src = generateNewLayoutParams(src);
            }
        }
        return src;
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

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        Boolean notDispatch = userdata.isNotDispatch();
        if (notDispatch == null) { // 默认由控件自己处理
            return super.onInterceptTouchEvent(ev);
        } else {
            return notDispatch;
        }
    }
}