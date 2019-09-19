/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.content.Context;

import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.fun.ud.view.UDTabLayout;
import com.immomo.mls.weight.BaseTabLayout;

import org.luaj.vm2.LuaValue;

/**
 * Created by fanqiang on 2018/9/14.
 */
public class LuaTabLayout extends BaseTabLayout implements ILView<UDTabLayout> {
    private final UDTabLayout userdata;
    private ViewLifeCycleCallback cycleCallback;


    public LuaTabLayout(Context context, UDTabLayout metaTable, LuaValue[] initParams) {
        super(context);
        userdata = metaTable;
        setViewLifeCycleCallback(userdata);
    }

    @Override
    public UDTabLayout getUserdata() {
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
}