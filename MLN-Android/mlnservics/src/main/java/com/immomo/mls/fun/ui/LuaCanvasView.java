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

import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.fun.ud.view.UDCanvasView;
import com.immomo.mls.fun.weight.BorderRadiusView;

/**
 * Created by Zhang.ke on 2019/7/26.
 */
public class LuaCanvasView<U extends UDCanvasView> extends BorderRadiusView implements ILView<U> {
    protected U userdata;

    private ViewLifeCycleCallback cycleCallback;

    public LuaCanvasView(Context context, U userdata) {
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
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (getUserdata() != null) {
            ((ICanvasView) getUserdata()).onDrawCallback(canvas);
            getUserdata().drawOverLayout(canvas);
        }
    }

}