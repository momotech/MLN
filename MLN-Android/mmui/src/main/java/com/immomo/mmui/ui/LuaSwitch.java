/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ui;

import android.content.Context;
import android.graphics.Canvas;
import android.widget.Switch;

import com.immomo.mmui.ILView;
import com.immomo.mmui.ud.UDSwitch;

import org.luaj.vm2.LuaValue;

/**
 * Created by zhang.ke
 * on 2018/12/18
 */
public class LuaSwitch extends Switch implements ILView<UDSwitch> {
    private UDSwitch udSwitch;
    private ILView.ViewLifeCycleCallback cycleCallback;

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