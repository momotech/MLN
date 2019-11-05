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
import com.immomo.mls.fun.weight.BorderRadiusFrameLayout;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.weight.BaseTabLayout;

import org.luaj.vm2.LuaValue;

/**
 * Created by fanqiang on 2018/9/14.
 * 圆角切割，引起TabLayout屏幕外部分，不显示。
 * 用FrameLayout包裹解决
 */
public class LuaTabLayout extends BorderRadiusFrameLayout implements ILView<UDTabLayout> {
    private final UDTabLayout userdata;
    private ViewLifeCycleCallback cycleCallback;
    private BaseTabLayout baseTabLayout;

    public LuaTabLayout(Context context, UDTabLayout metaTable, LuaValue[] initParams) {
        super(context);
        userdata = metaTable;
        baseTabLayout = new BaseTabLayout(context);
        setViewLifeCycleCallback(userdata);
        addView(baseTabLayout, LuaViewUtil.createRelativeLayoutParamsMM());
    }

    @Override
    public UDTabLayout getUserdata() {
        return userdata;
    }

    public BaseTabLayout getTabLayout() {
        return baseTabLayout;
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