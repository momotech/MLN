/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import android.view.ViewGroup;

import com.immomo.mls.fun.ui.LuaStaggeredGridLayoutManager;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

/**
 * Created by XiongFangyu on 2018/7/20.
 */
@LuaApiUsed(ignoreTypeArgs = true)
public class UDWaterFallAdapter extends UDBaseNeedHeightAdapter<UDWaterFallLayout> {
    public static final String LUA_CLASS_NAME = "WaterfallAdapter";
    public static final String[] methods = new String[]{

    };
    private LuaStaggeredGridLayoutManager layoutManager;

    @LuaApiUsed({
            @LuaApiUsed.Func(returns = @LuaApiUsed.Type(UDWaterFallAdapter.class)),
    })
    public UDWaterFallAdapter(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    public void setViewSize(int w, int h) {
        if (layout == null)
            throw new NullPointerException("view设置adapter之前必须先设置Layout");
        layout.setRecyclerViewSize(w, h);
        super.setViewSize(w, h);
    }

    @Override
    public RecyclerView.LayoutManager getLayoutManager() {
        return layoutManager;
    }

    @Override
    public int getCellViewWidth() {
        if (viewWidth == 0)
            return 0;
        int sc = layout.getSpanCount();
        return (viewWidth - sc * 2 * layout.getItemSpacingPx()) / sc;
    }

    @Override
    public ViewGroup.LayoutParams newLayoutParams(ViewGroup.LayoutParams p, boolean fullSpan) {
        StaggeredGridLayoutManager.LayoutParams ret = null;
        if (p instanceof ViewGroup.MarginLayoutParams) {
            ret = new StaggeredGridLayoutManager.LayoutParams((ViewGroup.MarginLayoutParams) p);
        } else {
            if (p == null) {
                p = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            }
            if (p instanceof StaggeredGridLayoutManager.LayoutParams) {
                ret = (StaggeredGridLayoutManager.LayoutParams) p;
            } else {
                ret = new StaggeredGridLayoutManager.LayoutParams(p);
            }
        }
        ret.setFullSpan(fullSpan);
        return ret;
    }

    @Override
    protected void onLayoutSet(UDWaterFallLayout layout) {
        if (layoutManager == null) {
            layoutManager = new LuaStaggeredGridLayoutManager(layout.getSpanCount(), RecyclerView.VERTICAL);
        } else {
            layoutManager.setSpanCount(layout.getSpanCount());
        }

        layoutManager.setGapStrategy(StaggeredGridLayoutManager.GAP_HANDLING_NONE);  //不设置的话，图片闪烁错位，有可能有整列错位的情况。
    }
}