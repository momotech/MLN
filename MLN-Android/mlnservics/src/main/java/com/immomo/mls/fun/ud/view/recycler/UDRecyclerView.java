/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view.recycler;

import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.other.Adapter;
import com.immomo.mls.fun.other.ViewHolder;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.ud.view.UDViewGroup;
import com.immomo.mls.fun.ui.IRefreshRecyclerView;
import com.immomo.mls.fun.ui.IScrollEnabled;
import com.immomo.mls.fun.ui.LuaRecyclerView;
import com.immomo.mls.fun.ui.OnLoadListener;
import com.immomo.mls.fun.ui.SizeChangedListener;
import com.immomo.mls.fun.weight.MLSRecyclerView;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.weight.load.ILoadViewDelegete;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

/**
 * Created by XiongFangyu
 * (alias = {"CollectionView", "TableView", "WaterfallView"})
 */
@LuaApiUsed
public class UDRecyclerView<T extends ViewGroup & IRefreshRecyclerView & OnLoadListener,
        A extends UDBaseRecyclerAdapter, L extends UDBaseRecyclerLayout> extends UDViewGroup<T> implements SizeChangedListener {
    public static final String[] LUA_CLASS_NAME = {"CollectionView", "TableView", "WaterfallView"};

    public static final String[] methods = new String[]{
            "refreshEnable",
            "loadEnable",
            "scrollDirection",
            "loadThreshold",
            "openReuseCell",
            "reloadData",
            "setScrollEnable",
            "reloadAtRow",
            "reloadAtSection",
            "showScrollIndicator",
            "scrollToTop",
            "scrollToCell",
            "insertCellAtRow",
            "insertRow",
            "deleteCellAtRow",
            "deleteRow",
            "isRefreshing",
            "startRefreshing",
            "stopRefreshing",
            "isLoading",
            "stopLoading",
            "noMoreData",
            "resetLoading",
            "loadError",
            "adapter",
            "layout",
            "setRefreshingCallback",
            "setLoadingCallback",
            "setScrollingCallback",
            "setScrollBeginCallback",
            "setScrollEndCallback",
            "setEndDraggingCallback",
            "setStartDeceleratingCallback",
            "insertCellsAtSection",
            "insertRowsAtSection",
            "deleteRowsAtSection",
            "deleteCellsAtSection",
            "addHeaderView",
            "removeHeaderView",
            "setContentInset",
            "getContentInset",
            "useAllSpanForLoading",
            "getRecycledViewNum",
            "isStartPosition",
            "cellWithSectionRow",
            "visibleCells",
            "scrollEnabled",
            "setOffsetWithAnim",
    };

    private ILoadViewDelegete loadViewDelegete;

    protected boolean mScrollEnabled;
    protected boolean mRefreshEnabled;

    RecyclerView.LayoutManager mLayoutManager;

    @LuaApiUsed
    public UDRecyclerView(long L, LuaValue[] initParams) {
        super(L, initParams);
        mScrollEnabled = true;
        view.setSizeChangedListener(this);
    }

    @Override
    protected T newView(LuaValue[] init) {
        boolean loadEnable = false;
        if (init.length > 0) {
            mRefreshEnabled = init[0].toBoolean();
        }
        if (init.length > 1) {
            loadEnable = init[1].toBoolean();
        }
        return (T) new LuaRecyclerView(getContext(), this, mRefreshEnabled, loadEnable);
    }

    public void setLoadViewDelegete(ILoadViewDelegete loadViewDelegete) {
        this.loadViewDelegete = loadViewDelegete;
    }

    //---------------------------------------API--------------------------------------
    protected A adapter;
    protected L layout;
    private int orientation = RecyclerView.VERTICAL;
    private LuaFunction refreshCallback;
    private LuaFunction loadCallback;
    private LuaFunction scrollCallback;
    private LuaFunction scrollBeginCallback;
    private LuaFunction scrollEndCallback;
    private LuaFunction endDraggingCallback;
    private LuaFunction startDeceleratingCallback;
    private boolean scrollListenerAdded = false;
    private List<View> headerViews;
    private boolean useAllSpanForLoading = true;
    private float loadThreshold = 0;
    private boolean openReuseCell;
    private RecycledViewPoolManager poolManager;
    private float footerPaddingBottom = Float.MIN_VALUE;
    private LuaValue[] mContentInsetLuaValue;

    private int settedWidth;
    private int settedHeight;

    private boolean mAttachFirst = false;
    protected RecyclerView getRecyclerView() {
        return getView().getRecyclerView();
    }

    @Override
    public void onAttached() {
        super.onAttached();
        mAttachFirst = true;
    }

    //<editor-fold desc="API">

    //<editor-fold desc="Property">
    @Override
    @LuaApiUsed
    public LuaValue[] clipToBounds(LuaValue[] p) {
        boolean clip = p[0].toBoolean();
        view.setClipToPadding(clip);
        view.setClipChildren(clip);
        view.getRecyclerView().setClipToPadding(clip);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] refreshEnable(LuaValue[] values) {
        if (values != null && values.length > 0 && values[0].isBoolean()) {
            mRefreshEnabled = values[0].toBoolean();
            getView().setRefreshEnable(mRefreshEnabled);
            return null;
        }

        return LuaValue.rBoolean(getView().isRefreshEnable());
    }

    @LuaApiUsed
    public LuaValue[] loadEnable(LuaValue[] values) {
        if (values.length != 0 && values[0].isBoolean()) {
            LuaValue value = values[0];
            boolean enable = value.toBoolean();
            getView().setLoadEnable(enable);
            if (getRecyclerView().getAdapter() instanceof Adapter) {
                ((Adapter) getRecyclerView().getAdapter()).setFooterAdded(enable);
            }
            return null;
        }
        return LuaValue.rBoolean(getView().isLoadEnable());
    }


    @LuaApiUsed
    public LuaValue[] scrollDirection(LuaValue[] values) {
        if (values.length > 0) {
            orientation = parseDirection(values[0].toInt());
            setOrientation(getRecyclerView().getLayoutManager());
            return null;
        }
        return varargsOf(LuaNumber.valueOf(parseDirection(orientation)));
    }

    private int parseDirection(int old) {
        if (old == 0)
            return 1;
        return 0;
    }

    @LuaApiUsed
    public LuaValue[] loadThreshold(LuaValue[] values) {
        if (values.length != 0  && values[0].isNumber()) {
            this.loadThreshold = (float) values[0].toDouble();
            ((MLSRecyclerView) getRecyclerView()).setLoadThreshold(loadThreshold);
            return null;
        }
        return varargsOf(LuaNumber.valueOf(loadThreshold));
    }

    @LuaApiUsed
    public LuaValue[] openReuseCell(LuaValue[] values) {
        LuaValue isOpenReuseCell = values[0];
        if (isOpenReuseCell == null || !isOpenReuseCell.isBoolean()) {
            return LuaValue.rBoolean(openReuseCell);
        }

        openReuseCell = isOpenReuseCell.toBoolean();
        if (openReuseCell) {
            poolManager = RecycledViewPoolManager.getInstance(getGlobals());
            getRecyclerView().setRecycledViewPool(poolManager.getRecycleViewPoolInstance());
            if (adapter != null) {
                RecyclerView.LayoutManager layoutManager = adapter.getLayoutManager();
                if (layoutManager instanceof LinearLayoutManager) {
                    ((LinearLayoutManager) layoutManager).setRecycleChildrenOnDetach(true);
                }
                adapter.setRecycledViewPoolIDGenerator(poolManager.getIdGenerator());
            }
        } else {
            poolManager = null;
            if (adapter != null) {
                adapter.setRecycledViewPoolIDGenerator(null);
            }
        }
        return null;
    }

    //滑动到指定位置
    @LuaApiUsed
    public LuaValue[] setOffsetWithAnim(LuaValue[] values) {
//        Point point = ((UDPoint) values[0]).getPoint();
//        if (getRecyclerView() instanceof MLSRecyclerView) {
//            ((MLSRecyclerView) getRecyclerView()).smoothScrollTo((int) (point.getX()),
//                    (int) (point.getY()));
//        }
        return null;
    }
//</editor-fold>

    //<editor-fold desc="Method">

    /**
     * 重新渲染
     */
    @LuaApiUsed
    public LuaValue[] reloadData(LuaValue[] values) {
        if (adapter != null)
            adapter.reload();
        return null;
    }

    /**
     * 是否可以滚动
     */
    @LuaApiUsed
    public LuaValue[] setScrollEnable(LuaValue[] values) {
        setScrollEnable(values[0].toBoolean());
        return null;
    }

    private void setScrollEnable(boolean enable) {
        mScrollEnabled = enable;

        if (mLayoutManager instanceof IScrollEnabled) {
            ((IScrollEnabled) mLayoutManager).setScrollEnabled(mScrollEnabled);
        }

        getView().setRefreshEnable(mScrollEnabled && mRefreshEnabled);
    }

    /**
     * (section,row) 重新渲染某个item
     */
    @LuaApiUsed
    public LuaValue[] reloadAtRow(LuaValue[] values) {
        if (values.length == 3) {
            if (adapter != null)
                adapter.reloadAtRow(values[1].toInt() - 1, values[0].toInt() - 1, values[2].toBoolean());
        }
        return null;
    }

    /**
     * (section) 重新渲染某个section
     */
    @LuaApiUsed
    public LuaValue[] reloadAtSection(LuaValue[] values) {
        if (values.length == 2) {
            if (adapter != null)
                adapter.reloadAtSection(values[0].toInt() - 1, values[1].toBoolean());
        }
        return null;
    }

    /**
     * 设置滚动条的显隐
     */
    @LuaApiUsed
    public LuaValue[] showScrollIndicator(LuaValue[] values) {
        if (values.length >= 1) {
            boolean show = values[0].toBoolean();
            getRecyclerView().setVerticalScrollBarEnabled(show);
            getRecyclerView().setHorizontalScrollBarEnabled(show);
            return null;
        }

        boolean scrollBarEnabled = orientation == RecyclerView.VERTICAL ? getRecyclerView().isVerticalScrollBarEnabled() : getRecyclerView().isHorizontalScrollBarEnabled();
        return LuaValue.varargsOf(LuaBoolean.valueOf(scrollBarEnabled));
    }

    /**
     * 滚动到顶
     */
    @LuaApiUsed
    public LuaValue[] scrollToTop(LuaValue[] values) {
        boolean anim = false;
        if (values.length >= 1) {
            anim = values[0].toBoolean();
        }
        callScrollToTop(anim);
        return null;
    }

    /**
     * 滚动到某个item
     * <p>
     * row
     * section
     * anim
     */
    @LuaApiUsed
    public LuaValue[] scrollToCell(LuaValue[] values) {
        if (adapter != null && values.length >= 2) {
            int position = adapter.getPositionBySectionAndRow(values[1].toInt() - 1, values[0].toInt() - 1);
            RecyclerView recyclerView = getRecyclerView();
            if (recyclerView instanceof MLSRecyclerView && values.length >= 3) {
                ((MLSRecyclerView) recyclerView).smoothMoveToPosition(!values[2].toBoolean(), position + adapter.getAdapter().getHeaderCount());
            }
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] insertCellAtRow(LuaValue[] values) {
        if (adapter != null) {
            adapter.setItemAnimated(false);
            adapter.insertCellAtRow(values[1].toInt() - 1, values[0].toInt() - 1);
        }
        scroll2TopWhenInsertFirstPosition(values[1].toInt(), values[0].toInt());
        return null;
    }

    @LuaApiUsed
    public LuaValue[] insertRow(LuaValue[] values) {
        if (adapter == null || values.length < 2)
            return null;

        boolean animated = false;
        if (values.length >= 3) {
            animated = values[2].toBoolean();
        }

        adapter.insertCellAtRowAnimated(values[1].toInt() - 1, values[0].toInt() - 1, animated);
        scroll2TopWhenInsertFirstPosition(values[1].toInt(),values[0].toInt());
        return null;
    }

    @LuaApiUsed
    public LuaValue[] deleteCellAtRow(LuaValue[] values) {
        if (adapter != null) {
            adapter.setItemAnimated(false);
            adapter.deleteCellAtRow(values[1].toInt() - 1, values[0].toInt() - 1);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] deleteRow(LuaValue[] values) {

        if (adapter == null || values.length < 2)
            return null;

        boolean animated = false;
        if (values.length >= 3) {
            animated = values[2].toBoolean();
        }

        adapter.deleteCellAtRowAnimated(values[1].toInt() - 1, values[0].toInt() - 1, animated);
        return null;
    }

    /**
     * 判断是否正在刷新
     *
     * @return
     */
    @LuaApiUsed
    public LuaValue[] isRefreshing(LuaValue[] values) {
        return LuaValue.rBoolean(getView().isRefreshing());
    }

    /**
     * 执行下拉刷新动画，并回调 Android专用
     */
    @LuaApiUsed
    public LuaValue[] startRefreshing(LuaValue[] values) {
        getView().startRefreshing();
        return null;
    }

    /**
     * 停止下拉刷新动画
     */
    @LuaApiUsed
    public LuaValue[] stopRefreshing(LuaValue[] values) {
        getView().stopRefreshing();
        return null;
    }

    /**
     * 判断是否正在加载
     *
     * @return
     */
    @LuaApiUsed
    public LuaValue[] isLoading(LuaValue[] values) {
        return LuaValue.rBoolean(getView().isLoading());
    }

    /**
     * 停止加载
     */
    @LuaApiUsed
    public LuaValue[] stopLoading(LuaValue[] values) {
        getView().stopLoading();
        return null;
    }

    /**
     * 通知无更多数据，将加载动画删除
     */
    @LuaApiUsed
    public LuaValue[] noMoreData(LuaValue[] values) {
        getView().noMoreData();
        return null;
    }

    /**
     * 重置加载状态，和noMoreData相反
     */
    @LuaApiUsed
    public LuaValue[] resetLoading(LuaValue[] values) {
        getView().resetLoading();
        return null;
    }

    /**
     * 加载失败，显示点击加载
     */
    @LuaApiUsed
    public LuaValue[] loadError(LuaValue[] values) {
        getView().loadError();
        return null;
    }

    /**
     * 设置adapter，不同类型adapter类型不同
     * <p>
     * adapter
     */
    @LuaApiUsed
    public final LuaValue[] adapter(LuaValue[] values) {
        if (values.length > 0) {
            LuaValue value = values[0];
            if (value != null && value.isUserdata()) {
                A a = (A) value.toUserdata();
                onAdapterSet(a);
            }
            return null;
        }
        return varargsOf(adapter != null ? adapter : Nil());
    }

    /**
     * 设置layout，不同类型layout类型不同
     * <p>
     * UDBaseRecyclerLayout layout
     */
    @LuaApiUsed
    public LuaValue[] layout(LuaValue[] values) {
        if (values.length > 0) {
            LuaValue value = values[0];
            if (value != null && value.isUserdata()) {
                L l = (L) value.toUserdata();
                if (adapter != null) {
                    adapter.setLayout(l, getView());
                }
                this.layout = l;
            }
            return null;
        }

        return varargsOf(this.layout != null ? layout : Nil());
    }

    /**
     * 设置下拉刷新的回调
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] setRefreshingCallback(LuaValue[] values) {
        if (refreshCallback != null)
            refreshCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction())
            refreshCallback = value.toLuaFunction();
        return null;
    }

    /**
     * 设置上拉加载的回调
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] setLoadingCallback(LuaValue[] values) {
        if (loadCallback != null)
            loadCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction())
            loadCallback = value.toLuaFunction();
        return null;
    }

    /**
     * 滚动回调
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] setScrollingCallback(LuaValue[] values) {
        if (scrollCallback != null)
            scrollCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            scrollCallback = value.toLuaFunction();
            if (scrollCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    /**
     * 开始滚动回调
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] setScrollBeginCallback(LuaValue[] values) {
        if (scrollBeginCallback != null)
            scrollBeginCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            scrollBeginCallback = value.toLuaFunction();
            if (scrollBeginCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    /**
     * 结束滚动回调
     * <p>
     * fun
     */
    @LuaApiUsed
    public LuaValue[] setScrollEndCallback(LuaValue[] values) {
        if (scrollEndCallback != null)
            scrollEndCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            scrollEndCallback = value.toLuaFunction();
            if (scrollEndCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setEndDraggingCallback(LuaValue[] values) {
        if (endDraggingCallback != null)
            endDraggingCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            endDraggingCallback = value.toLuaFunction();
            if (endDraggingCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setStartDeceleratingCallback(LuaValue[] values) {
        if (startDeceleratingCallback != null)
            startDeceleratingCallback.destroy();
        LuaValue value = values[0];
        if (value != null && value.isFunction()) {
            startDeceleratingCallback = value.toLuaFunction();
            if (startDeceleratingCallback != null && !scrollListenerAdded) {
                getRecyclerView().addOnScrollListener(onScrollListener);
                scrollListenerAdded = true;
            }
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] insertCellsAtSection(LuaValue[] values) {
        if (adapter != null) {
            adapter.setItemAnimated(false);
            adapter.insertCellsAtSection(values[0].toInt() - 1, values[1].toInt() - 1, (values[2].toInt() - values[1].toInt()) + 1);
            scroll2TopWhenInsertFirstPosition(values[0].toInt(), values[1].toInt());
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] insertRowsAtSection(LuaValue[] values) {
        if (adapter != null) {
            adapter.setItemAnimated(values[3].toBoolean());
            adapter.insertCellsAtSection(values[0].toInt() - 1, values[1].toInt() - 1, (values[2].toInt() - values[1].toInt()) + 1);
            scroll2TopWhenInsertFirstPosition(values[0].toInt(), values[1].toInt());
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] deleteRowsAtSection(LuaValue[] values) {
        if (adapter != null) {
            adapter.setItemAnimated(values[3].toBoolean());
            checkEndRowBeyondBounds(values);
            adapter.deleteCellsAtSection(values[0].toInt() - 1, values[1].toInt() - 1, (values[2].toInt() - values[1].toInt()) + 1);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] deleteCellsAtSection(LuaValue[] values) {
        if (adapter != null) {
            adapter.setItemAnimated(false);
            checkEndRowBeyondBounds(values);
            adapter.deleteCellsAtSection(values[0].toInt() - 1, values[1].toInt() - 1, (values[2].toInt() - values[1].toInt()) + 1);
        }
        return null;
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] addHeaderView(LuaValue[] values) {
        UDView v = (UDView) values[0];
        if (adapter == null) {
            if (headerViews == null) {
                headerViews = new ArrayList<>();
            }
            headerViews.add(v.getView());
            return null;
        }
        adapter.getAdapter().addHeaderView(v.getView());
        return null;
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] removeHeaderView(LuaValue[] values) {
        if (headerViews != null) {
            headerViews.clear();
        }
        if (adapter != null) {
            adapter.getAdapter().removeAllHeaderView();
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setContentInset(LuaValue[] values) {
        mContentInsetLuaValue = values;
        if (values.length > 3) {
            footerPaddingBottom = DimenUtil.dpiToPx((float) values[2].toDouble());
        }
        setFooterViewMaigin();
        return null;
    }

    /**
     * function
     */
    @LuaApiUsed
    public LuaValue[] getContentInset(LuaValue[] values) {
        if (values.length >= 1 && values[0].isFunction()) {
            if (mContentInsetLuaValue != null)
                values[0].toLuaFunction().invoke(mContentInsetLuaValue, 4);
            else {
                LuaValue zero = LuaNumber.valueOf(0);
                values[0].toLuaFunction().invoke(varargsOf(zero, zero, zero, zero));
            }
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] useAllSpanForLoading(LuaValue[] values) {
        useAllSpanForLoading = values[0].toBoolean();
        if (adapter != null) {
            adapter.getAdapter().useAllSpanForLoading(useAllSpanForLoading);
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] getRecycledViewNum(LuaValue[] values) {
        return LuaValue.rNumber(poolManager != null ? poolManager.getRecycledViewNum() : 0);
    }

    @LuaApiUsed
    public LuaValue[] isStartPosition(LuaValue[] values) {
        if (orientation == RecyclerView.VERTICAL) {
            return LuaValue.rBoolean(!getRecyclerView().canScrollVertically(-1));
        } else {
            return LuaValue.rBoolean(!getRecyclerView().canScrollHorizontally(-1));
        }
    }

    /**
     * section
     * row
     *
     * @return 返回指定位置的cell，版本1.0.2
     */
    @LuaApiUsed
    public LuaValue[] cellWithSectionRow(LuaValue[] values) {
        if (adapter == null) {
            return LuaValue.rNil();
        }
        int position = adapter.getPositionBySectionAndRow(values[0].toInt() - 1, values[1].toInt() - 1);
        View view = getRecyclerView().getLayoutManager().findViewByPosition(position);
        if (view == null) {
            return LuaValue.rNil();
        }
        ViewHolder holder = (ViewHolder) getRecyclerView().getChildViewHolder(view);
        return varargsOf(holder.getCell());
    }

    /**
     * @return 返回当前屏幕展示的所有cell，版本1.0.2
     */
    @LuaApiUsed
    public LuaValue[] visibleCells(LuaValue[] values) {
        if (adapter == null) {
            return null;
        }
        List list = new ArrayList();
        int firstPosition = ((MLSRecyclerView) getRecyclerView()).findFirstVisibleItemPosition();
        int lastPosition = ((MLSRecyclerView) getRecyclerView()).findLastVisibleItemPosition();

        RecyclerView.LayoutManager layoutManager = getRecyclerView().getLayoutManager();
        if (layoutManager == null) {
            return null;
        }
        for (int i = firstPosition; i < lastPosition + 1; i++) {
            View view = layoutManager.findViewByPosition(i);
            if (view == null) {
                continue;
            }
            ViewHolder holder = (ViewHolder) getRecyclerView().getChildViewHolder(view);
            if (holder.getCell() != null) {//header、footer的getCell为空
                list.add(holder.getCell());
            }
        }
        return varargsOf(new UDArray(getGlobals(), list));
    }

    @LuaApiUsed
    public LuaValue[] scrollEnabled(LuaValue[] values) {
        if (values.length > 0) {
            LuaValue value = values[0];
            getRecyclerView().setLayoutFrozen(value.toBoolean());
            return null;
        }

        return LuaValue.rBoolean(getRecyclerView().isLayoutFrozen());
    }

    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="call by uirecyclerview">
    public void callbackRefresh() {
        if (refreshCallback != null)
            refreshCallback.invoke(null);
    }

    public void callbackLoading() {
        if (loadCallback != null)
            loadCallback.invoke(null);
    }

    public void setFooterViewMaigin() {
        if (loadViewDelegete != null && footerPaddingBottom != Float.MIN_VALUE) {
            View footer = loadViewDelegete.getLoadView().getView();
            footer.setPadding(footer.getPaddingLeft(), footer.getPaddingTop(), footer.getPaddingRight(), (int) footerPaddingBottom);
        }
    }
    //</editor-fold>

    //<editor-fold desc="OnScrollListener">
    private RecyclerView.OnScrollListener onScrollListener = new RecyclerView.OnScrollListener() {
        private boolean scrolling = false;

        private boolean newSettlingState;

        @Override
        public void onScrollStateChanged(RecyclerView recyclerView, int newState) {

            if (mLayoutManager instanceof StaggeredGridLayoutManager)
                ((StaggeredGridLayoutManager) mLayoutManager).invalidateSpanAssignments();

            if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                newSettlingState = false;
                scrolling = false;

                if (endDraggingCallback != null) {
                    callbackWithPoint(endDraggingCallback, false);
                }

                if (scrollEndCallback != null) {

                    SCROLL_TO_POSITION enumPosition = getScrollBottomOrTop();

                    callbackWithPoint(scrollEndCallback, enumPosition.position);
                }

                return;
            }

            if (newState == RecyclerView.SCROLL_STATE_SETTLING) {
                newSettlingState = true;
            }

            if (!scrolling) {
                scrolling = true;
                if (scrollBeginCallback != null) {
                    callbackWithPoint(scrollBeginCallback);
                }
            }
        }

        @NonNull
        private SCROLL_TO_POSITION getScrollBottomOrTop() {
            SCROLL_TO_POSITION scroll_to_position = SCROLL_TO_POSITION.SCROLL_TO_OTHER;

            if (!getRecyclerView().canScrollVertically(1))  // 底部
                scroll_to_position = SCROLL_TO_POSITION.SCROLL_TO_BOTTOM;
            else if (!getRecyclerView().canScrollVertically(-1)) {  // 顶部
                scroll_to_position = SCROLL_TO_POSITION.SCROLL_TO_TOP;
            }

            return scroll_to_position;
        }

        @Override
        public void onScrolled(RecyclerView recyclerView, int dx, int dy) {

            if (mAttachFirst)
                mAttachFirst = false;
            else if (scrollCallback != null)
                callbackWithPoint(scrollCallback);

            if (newSettlingState) {

                if (startDeceleratingCallback != null) {
                    callbackWithPoint(startDeceleratingCallback);
                }
            }
            newSettlingState = false;
        }


        private void callbackWithPoint(LuaFunction c, int top_middle_bottom) {
            float sx = getRecyclerView().computeHorizontalScrollOffset();
            float sy = getRecyclerView().computeVerticalScrollOffset();
            c.invoke(varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(sx)), LuaNumber.valueOf(DimenUtil.pxToDpi(sy)), LuaNumber.valueOf(top_middle_bottom)));
        }

        private void callbackWithPoint(LuaFunction c) {
            float sx = getRecyclerView().computeHorizontalScrollOffset();
            float sy = getRecyclerView().computeVerticalScrollOffset();
            c.invoke(varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(sx)), LuaNumber.valueOf(DimenUtil.pxToDpi(sy))));
        }

        private void callbackWithPoint(LuaFunction c, boolean decelerating) {
            float sx = getRecyclerView().computeHorizontalScrollOffset();
            float sy = getRecyclerView().computeVerticalScrollOffset();
            c.invoke(varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(sx)), LuaNumber.valueOf(DimenUtil.pxToDpi(sy)), decelerating ? LuaValue.True() : LuaValue.False()));
        }
    };
    //</editor-fold>

    //<editor-fold desc="SizeChangedListener">
    @Override
    public void onSizeChanged(int w, int h) {
        if (this.adapter != null) {
            if (settedWidth > 0 && settedWidth != w
                    || (settedHeight > 0 && settedHeight != h))
                return;
            this.adapter.setViewSize(w, h);
        }
    }
    //</editor-fold>

    @Override
    public void setWidth(float w) {
        super.setWidth(w);
        settedWidth = (int) w;
    }

    @Override
    public void setHeight(float h) {
        super.setHeight(h);
        settedHeight = (int) h;
    }

    @CallSuper
    protected void onAdapterSet(A a) {
        this.adapter = a;
        adapter.setLoadViewDelegete(loadViewDelegete);
        setFooterViewMaigin();
        final RecyclerView recyclerView = getRecyclerView();
        if (layout != null) {
            layout.setOrientation(orientation);
            adapter.setLayout(layout, getView());
            recyclerView.addItemDecoration(layout.getItemDecoration());

            if (layout instanceof UDCollectionGridLayout) {
                int paddingValues[] = ((UDCollectionGridLayout) layout).getPaddingValues();

                if (!((UDCollectionGridLayout) layout).isCanScrollTolScreenLeft())
                    recyclerView.setPadding(DimenUtil.dpiToPx((int) paddingValues[0]), DimenUtil.dpiToPx((int) paddingValues[1]), DimenUtil.dpiToPx((int) paddingValues[0]), DimenUtil.dpiToPx((int) paddingValues[3]));
            }
        }

        adapter.setRecyclerView(getView());

        if (headerViews != null) {
            adapter.getAdapter().addHeaderViews(headerViews);
            headerViews.clear();
            headerViews = null;
        }
        adapter.getAdapter().useAllSpanForLoading(useAllSpanForLoading);
        adapter.initWaterFallHeader();
        a.setOnLoadListener(getView());
        int w = recyclerView.getWidth();
        int h = recyclerView.getHeight();
        a.setViewSize(w, h);
        Adapter adapter = a.getAdapter();
        adapter.setFooterAdded(getView().isLoadEnable());

        recyclerView.setAdapter(adapter);

        mLayoutManager = a.getLayoutManager();
        recyclerView.setLayoutManager(mLayoutManager);

        setOrientation(mLayoutManager);

        if (openReuseCell) {
            if (mLayoutManager instanceof LinearLayoutManager) {
                ((LinearLayoutManager) mLayoutManager).setRecycleChildrenOnDetach(true);
            }
            if (this.adapter != null) {
                this.adapter.setRecycledViewPoolIDGenerator(poolManager.getIdGenerator());
            }
        } else {
            if (this.adapter != null) {
                this.adapter.setRecycledViewPoolIDGenerator(null);
            }
        }

        setScrollEnable(mScrollEnabled);
    }

    public void callScrollToTop(boolean anim) {
        if (!anim) {
            getRecyclerView().scrollToPosition(0);
        } else {
            getRecyclerView().smoothScrollToPosition(0);
        }
    }

    // 配合ios系统
    private void scroll2TopWhenInsertFirstPosition(int section, int row) {
        if (section == 1 && row == 1)
            getRecyclerView().scrollToPosition(0);
    }

    private void setOrientation(RecyclerView.LayoutManager layoutManager) {
        if (layoutManager instanceof LinearLayoutManager) {
            ((LinearLayoutManager) layoutManager).setOrientation(orientation);
        }
        if (layout != null) {
            layout.setOrientation(orientation);
        }
        if (adapter != null) {
            adapter.setOrientation(orientation);
        }
    }

    private int getOrientation() {
        RecyclerView.LayoutManager layoutManager = getRecyclerView().getLayoutManager();
        if (layoutManager instanceof LinearLayoutManager) {
            return ((LinearLayoutManager) layoutManager).getOrientation();
        }
        return RecyclerView.VERTICAL;
    }

    private void checkEndRowBeyondBounds(LuaValue[] values) {
        if (MLSEngine.DEBUG)
            adapter.getPositionBySectionAndRow(values[0].toInt() - 1, values[2].toInt() - 1);
    }

    // 是否 滑动到最底部和最顶部
    public enum SCROLL_TO_POSITION {
        SCROLL_TO_TOP(1),
        SCROLL_TO_BOTTOM(2),

        SCROLL_TO_OTHER(-1);

        private int position = -1;

        SCROLL_TO_POSITION(int s) {
            this.position = s;
        }
    }

}