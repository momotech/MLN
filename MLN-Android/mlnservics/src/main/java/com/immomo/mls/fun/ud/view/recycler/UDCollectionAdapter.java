/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import android.util.SparseArray;
import android.view.ViewGroup;

import com.immomo.mls.MLSEngine;


import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.fun.ui.LuaGridLayoutManager;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.AssertUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed
public class UDCollectionAdapter extends UDBaseRecyclerAdapter<UDCollectionLayout> {
    public static final String LUA_CLASS_NAME = "CollectionViewAdapter";
    public static final String[] methods = new String[]{
            "sizeForCell",
            "sizeForCellByReuseId",
    };

    private LuaFunction cellSizeDelegate;
    private Map<String, LuaFunction> cellSizeDelegates;
    private GridLayoutManager layoutManager;

    private SparseArray<Size> sizeCache;
    Size initSize;

    @LuaApiUsed
    public UDCollectionAdapter(long L, LuaValue[] v) {
        super(L, v);
        initSize = initSize();
    }

    protected Size initSize() {
        return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
    }

//<editor-fold desc="api">

    /**
     * function(section,row) 返回item的宽高
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] sizeForCell(LuaValue[] values) {
        cellSizeDelegate = values[0] == null ? null : values[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] sizeForCellByReuseId(LuaValue[] values) {
        if (cellSizeDelegates == null) {
            cellSizeDelegates = new HashMap<>();
        }
        cellSizeDelegates.put(values[0].toJavaString(), values[1].toLuaFunction());
        return null;
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
    public int getCellViewWidth() {
        return layout.getSize().getWidthPx();
    }

    @Override
    public int getCellViewHeight() {
        return layout.getSize().getHeightPx();
    }

    @Override
    public boolean hasCellSize() {
        return cellSizeDelegate != null || (layout != null && layout.getSize() != null);
    }

    @Override
    public boolean hasHeaderSize() {
        return false;
    }

    @NonNull
    @Override
    public Size getCellSize(int position) {
        if (sizeCache == null)
            sizeCache = new SparseArray<>();
        Size cellSize = sizeCache.get(position);
        if (cellSize != null) {
            return cellSize;
        }

        int[] sr = getSectionAndRowIn(position);

        if (sr == null)
            return new Size(Size.WRAP_CONTENT, Size.WRAP_CONTENT);

        LuaValue s = toLuaInt(sr[0]);
        LuaValue r = toLuaInt(sr[1]);
        LuaFunction caller = null;
        if (cellSizeDelegates != null) {
            String id = getReuseIdByType(getAdapter().getItemViewType(position));
            caller = cellSizeDelegates.get(id);
            if (!AssertUtils.assertFunction(caller,
                    "if sizeForCellByReuseId is setted once, all type must setted by invoke sizeForCellByReuseId",
                    getGlobals())) {
                return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
            }
        } else if (cellSizeDelegate != null) {
            caller = cellSizeDelegate;
        }
        if (caller == null || caller.isNil()) {
            if (!AssertUtils.assertNull(layout, "must set layout before!", getGlobals())) {
                return new Size(Size.WRAP_CONTENT, Size.WRAP_CONTENT);
            }
            return layout.getSize();
        }
        LuaValue a1 = caller.invoke(varargsOf(s, r))[0];
        if (AssertUtils.assertUserData(a1, UDSize.class, caller, getGlobals())) {
            UDSize udSize = (UDSize) a1;
            cellSize = udSize.getSize();
            sizeCache.put(position, cellSize);
            return cellSize;
        }
        return new Size(Size.WRAP_CONTENT, Size.WRAP_CONTENT);
    }

    @NonNull
    @Override
    public Size getHeaderSize(int position) {
        return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
    }

    @NonNull
    @Override
    public Size getInitCellSize(int type) {
        return initSize;
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

            if (position == getTotalCount()) {
                if (loadViewDelegete.useAllSpanCountInGrid() || getAdapter().isUseAllSpanForLoading()) {
                    return layoutManager.getSpanCount();
                } else {
                    return 1;
                }
            }

            if (mLayout instanceof UDCollectionGridLayout) {
                return getGridLayoutSpanSize(position);
            }

            if (cellSizeDelegate == null && cellSizeDelegates == null)
                return 1;

            final int orientation = layoutManager.getOrientation();
            final Size realSize = getCellSize(position);
            final Size initSize = layout.getSize();

            final int realValue, initValue;
            if (orientation == GridLayoutManager.HORIZONTAL) {
                realValue = realSize.getHeightPx();
                initValue = initSize.getHeightPx();
            } else {
                realValue = realSize.getWidthPx();
                initValue = initSize.getWidthPx();
            }

            if (realValue <= initValue)
                return 1;

            int ret = (int) Math.ceil(realValue / (float) initValue);
            int sc = layoutManager.getSpanCount();

            return ret > sc ? sc : ret;
        }

        private int getGridLayoutSpanSize(int position) {
            int recyclerViewWidth = mRecyclerView.getWidth();
            if (recyclerViewWidth == 0)
                recyclerViewWidth = AndroidUtil.getScreenWidth(MLSEngine.getContext());


            int recyclerViewHeight = mRecyclerView.getHeight();
            if (recyclerViewHeight == 0)
                recyclerViewHeight = AndroidUtil.getScreenHeight(MLSEngine.getContext());


            int spanCount = mLayout.getSpanCount();
            float itemSpacing = DimenUtil.dpiToPx(mLayout.getItemSpacing());
            float lineSpacing = DimenUtil.dpiToPx(mLayout.getLineSpacing());

            final int orientation = layoutManager.getOrientation();
            int targetValue = 1;
            final Size realPositionSize = getCellSize(position);

            if (orientation == GridLayoutManager.HORIZONTAL) {

                float singleHeight = ((recyclerViewHeight - lineSpacing * (spanCount + 1)) / spanCount);
                targetValue = (int) Math.ceil(((realPositionSize.getHeightPx()) / singleHeight));

            } else {

                float singleWidth = ((recyclerViewWidth - itemSpacing * (spanCount + 1)) / spanCount);

                targetValue = (int) Math.ceil((realPositionSize.getWidthPx() - itemSpacing) / singleWidth);
            }


            return targetValue > spanCount ? spanCount : targetValue;
        }
    };
    //</editor-fold>

    @Override
    protected void onOrientationChanged() {
        if (orientation == RecyclerView.HORIZONTAL) {
            initSize.setWidth(Size.WRAP_CONTENT);
            initSize.setHeight(Size.MATCH_PARENT);
        } else {
            initSize.setHeight(Size.WRAP_CONTENT);
            initSize.setWidth(Size.MATCH_PARENT);
        }
        if (layout != null) {
            onLayoutSet(layout);
        }
    }

    @Override
    protected void onReload() {
        super.onReload();
        if (sizeCache != null)
            sizeCache.clear();
    }

    @Override
    protected void onClearFromIndex(int index) {
        super.onClearFromIndex(index);
        removeSparseArrayFromStart(sizeCache, index);
    }

    UDCollectionLayout mLayout;

    @Override
    protected void onLayoutSet(UDCollectionLayout layout) {
        mLayout = layout;

        if (layout.getitemSize() == null)
            layout.itemSize(varargsOf(new UDSize(getGlobals(), new Size(UDCollectionGridLayout.DEFAULT_ITEM_SIZE, UDCollectionGridLayout.DEFAULT_ITEM_SIZE))));

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