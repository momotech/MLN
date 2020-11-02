/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDPoint;
import com.immomo.mls.fun.ud.view.IClipRadius;
import com.immomo.mls.fun.ui.IPager;
import com.immomo.mls.fun.ui.IRefreshRecyclerView;
import com.immomo.mls.fun.ui.IScrollEnabled;
import com.immomo.mls.fun.ui.OnLoadListener;
import com.immomo.mls.fun.ui.SizeChangedListener;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.weight.load.ILoadViewDelegete;
import com.immomo.mmui.ILView;
import com.immomo.mmui.ud.RecyclerLuaFunction;
import com.immomo.mmui.ud.UDView;
import com.immomo.mmui.ui.LuaRecyclerView;
import com.immomo.mmui.ui.MLSRecyclerView;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.List;

import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_CLIP;
import static com.immomo.mls.fun.ud.view.IClipRadius.LEVEL_FORCE_NOTCLIP;

/**
 * Created by XiongFangyu
 * (alias = {"CollectionView", "TableView", "WaterfallView"})
 */
@LuaApiUsed
public class UDRecyclerView<T extends ViewGroup & IRefreshRecyclerView & OnLoadListener & ILView,
        A extends UDBaseRecyclerAdapter, L extends UDBaseRecyclerLayout> extends UDView<T> implements SizeChangedListener {
    public static final String LUA_META_NAME = "_C_UDRecyclerView";
    public static final String[] LUA_CLASS_NAME = {"CollectionView", "TableView", "WaterfallView"};

    private ILoadViewDelegete loadViewDelegete;

    protected boolean mScrollEnabled;
    protected boolean mRefreshEnabled;

    RecyclerView.LayoutManager mLayoutManager;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDRecyclerView(long L) {
        this(L, false, false, false);
    }

    @CGenerate
    @LuaApiUsed
    public UDRecyclerView(long L, boolean refresh) {
        this(L, refresh, false, false);
    }

    @CGenerate
    @LuaApiUsed
    public UDRecyclerView(long L, boolean refresh, boolean load) {
        this(L, refresh, load, false);
    }

    @CGenerate
    @LuaApiUsed
    public UDRecyclerView(long L, boolean refresh, boolean load, boolean viewpager) {
        super(L, null);
        mScrollEnabled = true;
        view.setSizeChangedListener(this);
        getRecyclerView().setOnFlingListener(onFlingListener);
        mRefreshEnabled = refresh;
        view.setRefreshEnable(refresh);
        view.setLoadEnable(load);
        if (view instanceof IPager)
            ((IPager) view).setViewpager(viewpager);
    }

    public static native void _init();
    public static native void _register(long l, String parent);

    @Override
    protected T newView(LuaValue[] init) {
        return (T) new LuaRecyclerView(getContext(), this, false, false);
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
    private LuaFunction onFlingCallback;
    private boolean scrollListenerAdded = false;
    private boolean disallowFling = false;
    private List<View> headerViews;
    private boolean useAllSpanForLoading = true;
    private float loadThreshold = 0;
    private boolean openReuseCell;
    private RecycledViewPoolManager poolManager;
    private float footerPaddingBottom = Float.MIN_VALUE;
    private final float[] mContentInsetLuaValue = new float[4];

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
    //<editor-fold desc="override">

    @Override
    @LuaApiUsed
    public LuaValue[] clipToBounds(LuaValue[] p) {
        boolean clip = p[0].toBoolean();
        view.setClipToPadding(clip);
        view.setClipChildren(clip);
        view.getRecyclerView().setClipToPadding(clip);
        view.getRecyclerView().setClipChildren(clip);
        if (view instanceof IClipRadius) {//统一：clipToBounds(true)，切割圆角
            ((IClipRadius) view).forceClipLevel(clip ? LEVEL_FORCE_CLIP : LEVEL_FORCE_NOTCLIP);
        }
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="Property">

    //<editor-fold desc="native">

    @LuaApiUsed
    public boolean isRefreshEnable() {
        return getView().isRefreshEnable();
    }

    @LuaApiUsed
    public void setRefreshEnable(boolean refreshEnable) {
        mRefreshEnabled = refreshEnable;
        getView().setRefreshEnable(mRefreshEnabled);
    }

    @LuaApiUsed
    public boolean isLoadEnable() {
        return getView().isLoadEnable();
    }

    @LuaApiUsed
    public void setLoadEnable(boolean loadEnable) {
        getView().setLoadEnable(loadEnable);
        if (getRecyclerView().getAdapter() instanceof Adapter) {
            ((Adapter) getRecyclerView().getAdapter()).setFooterAdded(loadEnable);
        }
    }

    @LuaApiUsed
    public int getScrollDirection() {
        return parseDirection(orientation);
    }

    @LuaApiUsed
    public void setScrollDirection(int scrollDirection) {
        scrollDirection = parseDirection(scrollDirection);
        boolean change = orientation != scrollDirection;
        orientation = scrollDirection;
        //动态设置，需要重新计算inset和spacing，两端统一差异
        if (change && adapter != null && layout != null) {
            layout.setOrientation(orientation);
            if (layout instanceof ILayoutInSet) {
                removeAllItemDecorations(getRecyclerView());//移除之前的decoration
                getRecyclerView().addItemDecoration(layout.getItemDecoration());
                adapter.setMarginForVerticalGridLayout(getRecyclerView());
            }
        }
        setOrientation(getRecyclerView().getLayoutManager());
    }

    private int parseDirection(int old) {
        if (old == 0)
            return 1;
        return 0;
    }

    @LuaApiUsed
    public float getLoadThreshold() {
        return loadThreshold;
    }

    @LuaApiUsed
    public void setLoadThreshold(float loadThreshold) {
        this.loadThreshold = loadThreshold;
        ((MLSRecyclerView) getRecyclerView()).setLoadThreshold(loadThreshold);
    }

    @LuaApiUsed
    public boolean isOpenReuseCell() {
        return openReuseCell;
    }

    @LuaApiUsed
    public void setOpenReuseCell(boolean openReuseCell) {
        this.openReuseCell = openReuseCell;
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
    }

    @LuaApiUsed
    public UDPoint getContentOffset() {
        return new UDPoint(globals, getView().getContentOffset());
    }

    @LuaApiUsed
    public void setContentOffset(UDPoint contentOffset) {
        getView().setContentOffset(contentOffset.getPoint());
        contentOffset.destroy();
    }

    @LuaApiUsed
    public void i_bounces() {}

    @LuaApiUsed
    public void i_pagingEnabled() {}

    @LuaApiUsed
    public boolean isShowScrollIndicator() {
        return orientation == RecyclerView.VERTICAL
                ? getRecyclerView().isVerticalScrollBarEnabled()
                : getRecyclerView().isHorizontalScrollBarEnabled();
    }

    @LuaApiUsed
    public void setShowScrollIndicator(boolean showScrollIndicator) {
        getRecyclerView().setVerticalScrollBarEnabled(showScrollIndicator);
        getRecyclerView().setHorizontalScrollBarEnabled(showScrollIndicator);
    }
    //</editor-fold>

    @LuaApiUsed
    public float[] getPagerContentOffset() {
        if (view instanceof IPager) {
            return ((IPager) view).getPagerContentOffset();
        }
        return null;
    }

    @LuaApiUsed
    public void setPagerContentOffset(float x, float y) {
        if (view instanceof IPager) {
            ((IPager) view).pagerContentOffset(x, y);
        }
    }
    //</editor-fold>

    //<editor-fold desc="Method">

    //<editor-fold desc="native">
    //滑动到指定位置
    @LuaApiUsed
    public void setOffsetWithAnim(UDPoint point) {
        getView().smoothScrollTo(point.getPoint());
        point.destroy();
    }

    /**
     * 重新渲染
     */
    @LuaApiUsed
    public void reloadData() {
        if (adapter != null)
            adapter.reload();
    }

    /**
     * 是否可以滚动
     */
    @LuaApiUsed
    public void setScrollEnable(boolean enable) {
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
    public void reloadAtRow(int r, int s, boolean a) {
        if (adapter != null)
            adapter.reloadAtRow(s - 1, r - 1, a);
    }

    /**
     * (section) 重新渲染某个section
     */
    @LuaApiUsed
    public void reloadAtSection(int s, boolean a) {
        if (adapter != null)
            adapter.reloadAtSection(s - 1, a);
    }

    @LuaApiUsed
    public void scrollToTop() {
        scrollToTop(false);
    }

    @LuaApiUsed
    public void scrollToTop(boolean anim) {
        if (mScrollEnabled)
            callScrollToTop(anim);
    }

    @LuaApiUsed
    public void scrollToCell(int r, int s) {
        scrollToCell(r, s, false);
    }

    @LuaApiUsed
    public void scrollToCell(int r, int s, boolean smooth) {
        if (adapter != null) {
            if (!mScrollEnabled) {
                return;
            }
            int position = adapter.getPositionBySectionAndRow(s - 1, r - 1);
            RecyclerView recyclerView = getRecyclerView();
            if (recyclerView instanceof MLSRecyclerView) {
                ((MLSRecyclerView) recyclerView).smoothMoveToPosition(!smooth, position + adapter.getAdapter().getHeaderCount());
            }
        }
    }

    @LuaApiUsed
    public void insertCellAtRow(int r, int s) {
        if (adapter != null) {
            adapter.setItemAnimated(false);
            adapter.insertCellAtRow(s - 1, r - 1);
        }
    }

    @LuaApiUsed
    public void insertRow(int r, int s) {
        insertRow(r, s, false);
    }

    @LuaApiUsed
    public void insertRow(int r, int s, boolean animated) {
        if (adapter == null)
            return;
        adapter.insertCellAtRowAnimated(s - 1, r - 1, animated);
    }

    @LuaApiUsed
    public void deleteCellAtRow(int r, int s) {
        if (adapter != null) {
            adapter.setItemAnimated(false);
            adapter.deleteCellAtRow(s - 1, r - 1);
        }
    }

    @LuaApiUsed
    public void deleteRow(int r, int s) {
        deleteRow(r, s, false);
    }

    @LuaApiUsed
    public void deleteRow(int r, int s, boolean animated) {
        if (adapter == null)
            return;
        adapter.deleteCellAtRowAnimated(s - 1, r - 1, animated);
    }

    @LuaApiUsed
    public boolean isRefreshing() {
        return getView().isRefreshing();
    }

    /**
     * 执行下拉刷新动画，并回调 Android专用
     */
    @LuaApiUsed
    public void startRefreshing() {
        getView().startRefreshing();
    }

    @LuaApiUsed
    public void stopRefreshing() {
        getView().stopRefreshing();
    }

    @LuaApiUsed
    public boolean isLoading() {
        return getView().isLoading();
    }

    @LuaApiUsed
    public void stopLoading() {
        getView().stopLoading();
    }

    /**
     * 通知无更多数据，将加载动画删除
     */
    @LuaApiUsed
    public void noMoreData() {
        getView().noMoreData();
    }

    /**
     * 重置加载状态，和noMoreData相反
     */
    @LuaApiUsed
    public void resetLoading() {
        getView().resetLoading();
    }

    /**
     * 加载失败，显示点击加载
     */
    @LuaApiUsed
    public void loadError() {
        getView().loadError();
    }
    //</editor-fold>

    //<editor-fold desc="adapter layout">

    @LuaApiUsed
    public UDBaseRecyclerAdapter getAdapter() {
        return adapter;
    }

    @LuaApiUsed
    public void setAdapter(final UDBaseRecyclerAdapter adapter) {
        MainThreadExecutor.postAtFrontOfQueue(new Runnable() {
            @Override//解决adapter 与其他方法的时序问题
            public void run() {
                onAdapterSet((A)adapter);
            }
        });
    }

    @LuaApiUsed
    public void setLayout(UDBaseRecyclerLayout layout) {
        if (adapter != null) {
            adapter.setLayout(layout, getView());
        }
        this.layout = (L) layout;
    }

    @LuaApiUsed
    public UDBaseRecyclerLayout getLayout() {
        return layout;
    }
    //</editor-fold>

    //<editor-fold desc="callback">

    @LuaApiUsed
    public void setRefreshingCallback(LuaFunction f) {
        if (refreshCallback != null)
            refreshCallback.destroy();
        refreshCallback = f;
    }

    @LuaApiUsed
    public void setLoadingCallback(LuaFunction f) {
        if (loadCallback != null)
            loadCallback.destroy();
        loadCallback = f;
    }

    @LuaApiUsed
    public void setScrollingCallback(LuaFunction f) {
        if (scrollCallback != null)
            scrollCallback.destroy();
        scrollCallback = f;
        if (scrollCallback != null && !scrollListenerAdded) {
            getRecyclerView().addOnScrollListener(onScrollListener);
            scrollListenerAdded = true;
        }
    }

    @LuaApiUsed
    public void setScrollBeginCallback(LuaFunction f) {
        if (scrollBeginCallback != null)
            scrollBeginCallback.destroy();
        scrollBeginCallback = f;
        if (scrollBeginCallback != null && !scrollListenerAdded) {
            getRecyclerView().addOnScrollListener(onScrollListener);
            scrollListenerAdded = true;
        }
    }

    @LuaApiUsed
    public void setScrollEndCallback(LuaFunction f) {
        if (scrollEndCallback != null)
            scrollEndCallback.destroy();
        scrollEndCallback = f;
        if (scrollEndCallback != null && !scrollListenerAdded) {
            getRecyclerView().addOnScrollListener(onScrollListener);
            scrollListenerAdded = true;
        }
    }

    @LuaApiUsed
    public void setEndDraggingCallback(LuaFunction f) {
        if (endDraggingCallback != null)
            endDraggingCallback.destroy();
        endDraggingCallback = f;
        if (endDraggingCallback != null && !scrollListenerAdded) {
            getRecyclerView().addOnScrollListener(onScrollListener);
            scrollListenerAdded = true;
        }
    }

    @LuaApiUsed
    public void setScrollWillEndDraggingCallback(LuaFunction f) {
        if (onFlingCallback != null)
            onFlingCallback.destroy();
        onFlingCallback = f;
        ((MLSRecyclerView) getRecyclerView()).setFlingListener(true);
    }

    @LuaApiUsed
    public void setStartDeceleratingCallback(LuaFunction f) {
        if (startDeceleratingCallback != null)
            startDeceleratingCallback.destroy();
        startDeceleratingCallback = f;
        if (startDeceleratingCallback != null && !scrollListenerAdded) {
            getRecyclerView().addOnScrollListener(onScrollListener);
            scrollListenerAdded = true;
        }
    }

    //</editor-fold>

    //<editor-fold desc="insert delete">

    @LuaApiUsed
    public void insertCellsAtSection(int s, int sr, int er) {
        insertRowsAtSection(s, sr, er, false);
    }

    @LuaApiUsed
    public void insertRowsAtSection(int s, int sr, int er, boolean anim) {
        if (adapter != null) {
            adapter.setItemAnimated(anim);
            adapter.insertCellsAtSection(s - 1, sr - 1, (er - sr) + 1);
        }
    }

    @LuaApiUsed
    public void deleteRowsAtSection(int s, int sr, int er, boolean anim) {
        if (adapter != null) {
            adapter.setItemAnimated(anim);
            checkEndRowBeyondBounds(s, er);
            adapter.deleteCellsAtSection(s - 1, sr - 1, (er - sr) + 1);
        }
    }

    @LuaApiUsed
    public void deleteCellsAtSection(int s, int sr, int er) {
        deleteRowsAtSection(s, sr, er, false);
    }
    //</editor-fold>

    @LuaApiUsed
    public void setContentInset(float t, float r, float b, float l) {
        mContentInsetLuaValue[0] = t;
        mContentInsetLuaValue[1] = r;
        mContentInsetLuaValue[2] = b;
        mContentInsetLuaValue[3] = l;
        footerPaddingBottom = DimenUtil.dpiToPx(b);
        setFooterViewMaigin();
    }

    @CGenerate(alias = "getContentInset", params = "F")
    @LuaApiUsed
    public void getContentInsetByFunction(long fun) {
        if (fun != 0) {
            RecyclerLuaFunction f = new RecyclerLuaFunction(globals, fun);
            f.fastInvoke(mContentInsetLuaValue[0],
                    mContentInsetLuaValue[1],
                    mContentInsetLuaValue[2],
                    mContentInsetLuaValue[3]);
            f.destroy();
        }
    }

    @LuaApiUsed
    public void useAllSpanForLoading(boolean useAllSpanForLoading) {
        this.useAllSpanForLoading = useAllSpanForLoading;
        if (adapter != null) {
            adapter.getAdapter().useAllSpanForLoading(useAllSpanForLoading);
        }
    }

    @LuaApiUsed
    public int getRecycledViewNum() {
        return poolManager != null ? poolManager.getRecycledViewNum() : 0;
    }

    @LuaApiUsed
    public boolean isStartPosition() {
        if (orientation == RecyclerView.VERTICAL) {
            return !getRecyclerView().canScrollVertically(-1);
        } else {
            return !getRecyclerView().canScrollHorizontally(-1);
        }
    }

    @CGenerate(returnType = "T")
    @LuaApiUsed
    public long cellWithSectionRow(int s, int r) {
        if (adapter == null) {
            return 0;
        }
        int position = adapter.getPositionBySectionAndRow(s - 1, r - 1);
        View view = getRecyclerView().getLayoutManager().findViewByPosition(position);
        if (view == null) {
            return 0;
        }
        ViewHolder holder = (ViewHolder) getRecyclerView().getChildViewHolder(view);
        LuaValue v = holder.getCell();
        if (v != null)
            return v.nativeGlobalKey();
        return 0;
    }

    @LuaApiUsed
    public UDArray visibleCells() {
        List list = new ArrayList();
        if (adapter == null) {
            return new UDArray(getGlobals(), list);
        }

        RecyclerView.LayoutManager layoutManager = getRecyclerView().getLayoutManager();
        if (layoutManager == null) {
            return new UDArray(getGlobals(), list);
        }

        int firstPosition = ((MLSRecyclerView) getRecyclerView()).findFirstVisibleItemPosition();
        int lastPosition = ((MLSRecyclerView) getRecyclerView()).findLastVisibleItemPosition();
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
        return new UDArray(getGlobals(), list);
    }

    @LuaApiUsed
    public boolean isDisallowFling() {
        return disallowFling;
    }

    @LuaApiUsed
    public void setDisallowFling(boolean disallowFling) {
        this.disallowFling = disallowFling;
        ((MLSRecyclerView) getRecyclerView()).setDisallowFling(disallowFling);
    }

    @CGenerate(returnType = "T")
    @LuaApiUsed
    public long visibleCellsRows() {
        int firstPos = ((MLSRecyclerView) getRecyclerView()).findFirstVisibleItemPosition() + 1;
        int lastPos = ((MLSRecyclerView) getRecyclerView()).findLastVisibleItemPosition() + 1;
        LuaTable table = LuaTable.create(globals);
        for (int i = firstPos; i < lastPos + 1; i++) {
            table.set(i - firstPos + 1, i);
        }

        return table.nativeGlobalKey();
    }

    //</editor-fold>
    //</editor-fold>

    //<editor-fold desc="call by uirecyclerview">
    public void callbackRefresh() {
        if (refreshCallback != null)
            refreshCallback.fastInvoke();
    }

    public void callbackLoading() {
        if (loadCallback != null)
            loadCallback.fastInvoke();
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
        private boolean isDragging = false;
        private boolean newSettlingState;

        @Override
        public void onScrollStateChanged(RecyclerView recyclerView, int newState) {

            //停止拖拽，触发时机：拖拽中-->非拖拽状态。
            if (isDragging && newState != RecyclerView.SCROLL_STATE_DRAGGING) {
                if (endDraggingCallback != null) {
                    callbackWithPoint(endDraggingCallback, false);
                }
            }
            isDragging = newState == RecyclerView.SCROLL_STATE_DRAGGING;//更新拖拽状态

            if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                newSettlingState = false;
                scrolling = false;

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
            c.fastInvoke(DimenUtil.pxToDpi(sx), DimenUtil.pxToDpi(sy));
        }

        private void callbackWithPoint(LuaFunction c, boolean decelerating) {
            float sx = getRecyclerView().computeHorizontalScrollOffset();
            float sy = getRecyclerView().computeVerticalScrollOffset();
            c.invoke(varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(sx)), LuaNumber.valueOf(DimenUtil.pxToDpi(sy)), decelerating ? LuaValue.True() : LuaValue.False()));
        }
    };
    //</editor-fold>

    private RecyclerView.OnFlingListener onFlingListener = new RecyclerView.OnFlingListener() {
        private mRunnable runnable;

        @Override
        public boolean onFling(int velocityX, int velocityY) {
            if (onFlingCallback != null) {
                if (runnable == null) {
                    runnable = new mRunnable();
                }
                runnable.velocityY = (Math.abs(velocityY / 8000f) < 0.1) ? 0 : velocityY / 8000f;
                view.post(runnable);
            }
            return disallowFling;
        }

        class mRunnable implements Runnable {
            float velocityY;

            @Override
            public void run() {
                onFlingCallback.fastInvoke(velocityY);
            }
        }
    };

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
            layout.setAdapter(adapter);
            adapter.setLayout(layout, getView());
            removeAllItemDecorations(recyclerView);//移除之前的decoration
            recyclerView.addItemDecoration(layout.getItemDecoration());

            if (layout instanceof ILayoutInSet) {//修复原CollectionViewGridLayout 两端差异
                adapter.setMarginForVerticalGridLayout(recyclerView);
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

    //setApater前，移除所有decoration，防止重复设置添加多个
    private void removeAllItemDecorations(RecyclerView recyclerView) {
        for (int i = 0; i < recyclerView.getItemDecorationCount(); i++) {
            recyclerView.removeItemDecorationAt(i);
        }
    }

    public void callScrollToTop(boolean anim) {
        if (!anim) {
            getRecyclerView().scrollToPosition(0);
        } else {
            getRecyclerView().smoothScrollToPosition(0);
        }
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

    private void checkEndRowBeyondBounds(int s, int r) {
        if (MLSEngine.DEBUG)
            adapter.getPositionBySectionAndRow(s, r - 1);
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