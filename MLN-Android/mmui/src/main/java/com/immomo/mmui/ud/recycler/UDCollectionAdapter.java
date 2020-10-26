/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.util.SparseArray;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ud.AdapterLuaFunction;
import com.immomo.mmui.ui.LuaGridLayoutManager;

import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
@LuaApiUsed
public class UDCollectionAdapter extends UDBaseRecyclerAdapter<UDCollectionLayout> {
    public static final String LUA_CLASS_NAME = "CollectionViewAdapter";

    private AdapterLuaFunction cellSizeDelegate;
    private Map<String, AdapterLuaFunction> cellSizeDelegates;
    private AdapterLuaFunction spanSizeLookUpDelegate;
    private GridLayoutManager layoutManager;

    private SparseArray<Size> sizeCache;
    Size initSize;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDCollectionAdapter(long L) {
        super(L);
        initSize = initSize();
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    protected Size initSize() {
        return new Size(Size.MATCH_PARENT, Size.WRAP_CONTENT);
    }

//<editor-fold desc="api">

    /**
     * function(section,row) 返回item的宽高
     * <p>
     * fun
     */
    @CGenerate(params = "F")
    @LuaApiUsed
    public void sizeForCell(long f) {
        if (f == 0)
            cellSizeDelegate = null;
        else
            cellSizeDelegate = new AdapterLuaFunction(globals, f);
    }

    @CGenerate(params = "0F")
    @LuaApiUsed
    public void sizeForCellByReuseId(String t, long f) {
        if (cellSizeDelegates == null) {
            cellSizeDelegates = new HashMap<>();
        }
        if (f == 0)
            cellSizeDelegates.put(t, null);
        else
            cellSizeDelegates.put(t, new AdapterLuaFunction(globals, f));
    }

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

        AdapterLuaFunction caller = null;
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
            if (!AssertUtils.assertNull(layout, "必须先设置layout!", getGlobals())) {
                return new Size(Size.WRAP_CONTENT, Size.WRAP_CONTENT);
            }

            if (MLSEngine.DEBUG && !(UDCollectionAdapter.this instanceof UDCollectionAutoFitAdapter)) {
                //两端在不声明size for cell时，有UI差异。统一报错处理
                ErrorUtils.debugLuaError("如果不使用CollectionViewAutoFitAdapter，则必须设置sizeForCell", getGlobals());
            }
            return layout.getSize();
        }
        LuaUserdata ret = caller.fastInvokeII_U(sr[0] + 1, sr[1] + 1);
        if (AssertUtils.assertUserData(ret, UDSize.class, caller, getGlobals())) {
            UDSize udSize = (UDSize) ret;
            cellSize = udSize.getSize();
            sizeCache.put(position, cellSize);

            if (cellSize.getHeightPx() < 0
                    || cellSize.getWidthPx() < 0) {
                if (MLSEngine.DEBUG)
                    ErrorUtils.debugLuaError("sizeForCell返回的size必须都大于0,实际返回:" +
                                "(" + cellSize.getWidthPx() + "px," + cellSize.getHeightPx() + "px)",
                        getGlobals());
                if (cellSize.getHeightPx() < 0)//两端统一返回高度<0,默认为0。
                    cellSize.setHeight(0);
                if (cellSize.getWidthPx() < 0)
                    cellSize.setWidth(0);
            }

            if (cellSize.getHeightPx() > mRecyclerView.getHeight()
                    || cellSize.getWidthPx() > mRecyclerView.getWidth()) {
                if (MLSEngine.DEBUG)
                    ErrorUtils.debugLuaError("sizeForCell返回的size必须都小于容器大小," +
                                "实际返回:(" + cellSize.getWidthPx() + "px," + cellSize.getHeightPx() + ")px," +
                                "容器大小:(" + mRecyclerView.getWidth() + "px," + mRecyclerView.getHeight() + "px)",
                        getGlobals());
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
                int size = spanSizeLookUpDelegate.fastInvokeII_I(sr[0] + 1, sr[1] + 1);
                if (size > 0) {//如果spanSize小于0，走下面的原有逻辑
                    int spanCount = layoutManager.getSpanCount();
                    return size > spanCount ? spanCount : size;//大于spanCount，取spanCount
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
                if (MLSEngine.DEBUG && !(UDCollectionAdapter.this instanceof UDCollectionAutoFitAdapter)) {
                    if (recyclerViewWidth < (paddingValues[0] + paddingValues[2] + realWidth)) {
                        ErrorUtils.debugLuaError("容器宽度小于cell宽度和padding的和，" +
                                "容器宽度:" + recyclerViewWidth + "px " +
                                "padding:" + (paddingValues[0] + paddingValues[2]) + "px " +
                                "cell宽度" + realWidth + "px", getGlobals());
                    }
                    if (recyclerViewHeight < (paddingValues[1] + paddingValues[3] + realHeight)) {
                        ErrorUtils.debugLuaError("容器高度小于cell高度和padding的和，" +
                                "容器高度:" + recyclerViewHeight + "px " +
                                "padding:" + (paddingValues[1] + paddingValues[3]) + "px " +
                                "cell高度" + realHeight + "px", getGlobals());
                    }
                }

                if (realWidth < 0 || realHeight < 0 &&
                        (!realPositionSize.isMatchOrWrapHeight()
                                && !realPositionSize.isMatchOrWrapWidth())) {//两端统一报错效果
                    if (MLSEngine.DEBUG)
                        ErrorUtils.debugLuaError(
                            String.format("sizeForCell返回Size必须大于0,实际返回:(%dpx, %dpx)",
                                    realWidth, realHeight),
                            getGlobals());
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

        if (layout.getItemSize() == null)
            layout.setItemSize(new UDSize(globals, new Size(100, 100)));

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