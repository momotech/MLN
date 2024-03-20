/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.view.ViewGroup;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mmui.ud.AdapterLuaFunction;
import com.immomo.mmui.ui.LuaGridLayoutManager;

import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed
public class UDCollectionAdapter extends UDBaseRecyclerAdapter<UDCollectionLayout> {
    public static final String LUA_CLASS_NAME = "CollectionViewAutoFitAdapter";

    private AdapterLuaFunction spanSizeLookUpDelegate;
    private GridLayoutManager layoutManager;
    protected UDCollectionLayout mLayout;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDCollectionAdapter(long L) {
        super(L);
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    //<editor-fold desc="api">
    @CGenerate(params = "F")
    @LuaApiUsed
    public void setSpanSizeLookUp(long f) {
        if (f == 0)
            spanSizeLookUpDelegate = null;
        else
            spanSizeLookUpDelegate = new AdapterLuaFunction(globals, f);
    }
    //</editor-fold>

    @Override
    public void setViewSize(int w, int h) {
        if (layout == null)
            throw new NullPointerException("view设置adapter之前必须先设置Layout");
        layout.setRecyclerViewSize(w, h);
        super.setViewSize(w, h);
        onLayoutSet(layout);
    }

    @Override
    public RecyclerView.LayoutManager getLayoutManager() {
        return layoutManager;
    }

    @Override
    public ViewGroup.LayoutParams newLayoutParams(ViewGroup.LayoutParams p, boolean fullSpan) {
        if (p == null) {
            if (orientation == RecyclerView.VERTICAL) {
                p = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            } else {
                p = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
            }
        }
        return p;
    }

    //<editor-fold desc="SpanSizeLookup">
    private GridLayoutManager.SpanSizeLookup lookup = new GridLayoutManager.SpanSizeLookup() {
        @Override
        public int getSpanSize(int position) {
            if (position == getTotalCount()) {//footer loading SpanSize
                if (loadViewDelegete.useAllSpanCountInGrid() || getAdapter().isUseAllSpanForLoading()) {
                    return layoutManager.getSpanCount();
                } else {
                    return 1;
                }
            }

            //暴露spanSize给lua层
            if (spanSizeLookUpDelegate != null) {
                int[] sr = getSectionAndRowIn(position);
                int size = spanSizeLookUpDelegate.fastInvokeII_I(sr[0] + 1, sr[1] + 1);
                if (size > 0) {//如果spanSize小于0，走下面的原有逻辑
                    int spanCount = layoutManager.getSpanCount();
                    return size > spanCount ? spanCount : size;//大于spanCount，取spanCount
                }
            }
            return 1;
        }
    };
    //</editor-fold>

    @Override
    public void onFooterAdded(boolean added) {
        if (layout != null) {
            layout.onFooterAdded(added);
        }
    }

    @Override
    protected void onLayoutSet(UDCollectionLayout layout) {
        mLayout = layout;
        int sc = layout.getSpanCount();
        if (sc <= 0) {
            sc = UDCollectionLayout.DEFAULT_SPAN_COUNT;
            // throw new IllegalStateException("cell size is illegal");
        }
        if (layoutManager != null) {
            layoutManager.setSpanCount(sc);
        } else {
            layoutManager = new LuaGridLayoutManager(getContext(), sc);
            layoutManager.setSpanSizeLookup(lookup);
        }
    }
}