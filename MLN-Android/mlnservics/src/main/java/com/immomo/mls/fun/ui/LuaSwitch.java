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
import android.widget.Switch;

import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.fun.ud.view.UDSwitch;

import org.luaj.vm2.LuaValue;

/**
 * Created by zhang.ke
 * on 2018/12/18
 */
public class LuaSwitch extends Switch implements ILView<UDSwitch> {
    private UDSwitch udSwitch;
    private ViewLifeCycleCallback cycleCallback;

    public LuaSwitch(Context context, UDSwitch metaTable, LuaValue[] initParams) {
        super(context);

        udSwitch = metaTable;
        setViewLifeCycleCallback(udSwitch);

    }

    //<editor-fold desc="ILView">
    @Override
    public UDSwitch getUserdata() {
        return udSwitch;
    }


    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
    }

    @Override
    public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
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
    //</editor-fold>
}