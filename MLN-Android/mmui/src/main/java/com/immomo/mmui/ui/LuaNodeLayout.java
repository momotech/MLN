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
import com.immomo.mmui.gesture.ArgoTouchUtil;
import com.immomo.mmui.ud.UDNodeGroup;
import com.immomo.mmui.weight.BaseNodeLayout;

import androidx.annotation.NonNull;

public class LuaNodeLayout<U extends UDNodeGroup> extends BaseNodeLayout implements ILViewGroup<U> {
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

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        // 无论自己的事件流还是子view的事件流均会走此方法，因此可以在此处进行事件流控制
        ArgoTouchUtil.resetTouchTarget(userdata, ev);
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