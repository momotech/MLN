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


import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.fun.ui.LuaGridLayoutManager;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;

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
            "setSpanSizeLookUp",
    };

    private LuaFunction cellSizeDelegate;
    private Map<String, LuaFunction> cellSizeDelegates;
    private LuaFunction spanSizeLookUpDelegate;
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
        cellSizeDelegate = values.length > 0 ? values[0].toLuaFunction() : null;
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

    @LuaApiUsed
    public LuaValue[] setSpanSizeLookUp(LuaValue[] values) {
        spanSizeLookUpDelegate = values.length > 0 ? values[0].toLuaFunction() : null;
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
            if (caller == null || !caller.isFunction()) {
                caller = cellSizeDelegate;//两端统一，sizeForCell和byReuseId可以混用
            }
        } else if (cellSizeDelegate != null) {
            caller = cellSizeDelegate;
        }
        if (caller == null || caller.isNil()) {
            if (!AssertUtils.assertNull(layout, "must set layout before!", getGlobals())) {
                return new Size(Size.WRAP_CONTENT, Size.WRAP_CONTENT);
            }

            if (!(UDCollectionAdapter.this instanceof UDCollectionAutoFitAdapter)) {
                //两端在不声明size for cell时，有UI差异。统一报错处理
                ErrorUtils.debugLuaError("sizeForCell must be Called when not using CollectionViewAutoFitAdapter", getGlobals());
            }
            return layout.getSize();
        }
        LuaValue[] rets = caller.invoke(varargsOf(s, r));
        LuaValue a1 = rets == null || rets.length == 0 ? Nil() : rets[0];
        if (AssertUtils.assertUserData(a1, UDSize.class, caller, getGlobals())) {
            UDSize udSize = (UDSize) a1;
            cellSize = udSize.getSize();
            sizeCache.put(position, cellSize);

            if (cellSize.getHeightPx() <= 0 || cellSize.getWidthPx() <= 0 || cellSize.getHeightPx() > mRecyclerView.getHeight() || cellSize.getWidthPx() > mRecyclerView.getWidth()) {
                //size 高宽不能小于0
                ErrorUtils.debugLuaError("size For Cell must be >0 and < View.getHeight()", getGlobals());
                if (cellSize.getHeightPx() < 0)//两端统一返回高度<0,默认为0。
                    cellSize.setHeight(0);
                if (cellSize.getWidthPx() < 0)
                    cellSize.setWidth(0);
            }
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
                LuaValue[] lr = spanSizeLookUpDelegate.invoke(varargsOf(toLuaInt(sr[0]), toLuaInt(sr[1])));

                LuaValue v = lr != null && lr.length > 0 ? lr[0] : Nil();//不return，返回null
                int size;
                if (!v.isNil() && AssertUtils.assertNumber(v, spanSizeLookUpDelegate, getGlobals())) {
                    size = v.toInt();
                    if (size > 0) {//如果spanSize小于0，走下面的原有逻辑
                        int spanCount = layoutManager.getSpanCount();
                        return size > spanCount ? spanCount : size;//大于spanCount，取spanCount
                    }
                }
            }

            if (mLayout != null) {
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

            if (mLayout != null) {
                int[] paddingValues = mLayout.getPaddingValues();
                int realWidth = realPositionSize.getWidthPx();
                int realHeight = realPositionSize.getHeightPx();
                if (recyclerViewWidth < (paddingValues[0] + paddingValues[2] + realWidth) ||
                        recyclerViewHeight < (paddingValues[1] + paddingValues[3] + realHeight)) {

                    if (!(UDCollectionAdapter.this instanceof UDCollectionAutoFitAdapter)) {
                        //layoutInset+cellSize 不能大于recyclerView宽高,两端统一报错
                        ErrorUtils.debugLuaError("The sum of cellWidth，leftInset，rightInset should not bigger than the width of collectionView", getGlobals());
                    }
                }

                if (realWidth < 0 || realHeight < 0) {//两端统一报错效果
                    ErrorUtils.debugLuaError("size for cell can`t < 0", getGlobals());
                    realWidth = 0;
                    realHeight = 0;
                }

                if (orientation == GridLayoutManager.HORIZONTAL) {
                    float singleHeight;
                    singleHeight = ((recyclerViewHeight - lineSpacing * (spanCount - 1) - paddingValues[1] - paddingValues[3]) / spanCount);//两端统一,GridLayout和waterFall四周无spacing,所以是(spanCount - 1)

                    if (singleHeight > 0) {
                        targetValue = (int) Math.ceil(((realHeight) / singleHeight));
                    } else {
                        targetValue = spanCount;//spanCount和lineSpacing过大时，singleHeight为负数，撑满一列
                    }
                } else {
                    float singleWidth;
                    singleWidth = ((recyclerViewWidth - itemSpacing * (spanCount - 1) - paddingValues[0] - paddingValues[2]) / spanCount);

                    if (singleWidth > 0) {
                        targetValue = (int) Math.ceil((realWidth) / singleWidth);
                    } else {
                        targetValue = spanCount;//spanCount和lineSpacing过大时，singleWidth为负数，撑满一行
                    }
                }
                targetValue = targetValue == 0 ? 1 : targetValue;//两端统一，cell宽/高为0，至少占一格
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
    public void onFooterAdded(boolean added) {
        if (layout != null) {
            layout.onFooterAdded(added);
        }
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
            layout.itemSize(varargsOf(new UDSize(getGlobals(), new Size(UDCollectionLayout.DEFAULT_ITEM_SIZE, UDCollectionLayout.DEFAULT_ITEM_SIZE))));

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