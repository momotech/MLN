/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ui;

import android.content.Context;
import android.view.View;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSFlag;
import com.immomo.mmui.gesture.ArgoTouchLink;
import com.immomo.mmui.gesture.ICompose;
import com.immomo.mls.fun.ui.OnLoadListener;
import com.immomo.mls.fun.ui.SizeChangedListener;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.weight.load.ILoadViewDelegete;
import com.immomo.mmui.ILViewGroup;
import com.immomo.mmui.ud.recycler.UDBaseRecyclerAdapter;
import com.immomo.mmui.ud.recycler.UDBaseRecyclerLayout;
import com.immomo.mmui.ud.recycler.UDCollectionLayout;
import com.immomo.mmui.ud.recycler.UDRecyclerView;
import com.immomo.mmui.weight.BaseSwipeRefreshLayout;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
public class LuaRecyclerView<A extends UDBaseRecyclerAdapter, L extends UDBaseRecyclerLayout>
        extends BaseSwipeRefreshLayout
        implements ILViewGroup<UDRecyclerView>,
            IRefreshRecyclerView,
            OnLoadListener,
            SwipeRefreshLayout.OnRefreshListener,
            IPager,
            ICompose {
    private final MLSRecyclerView recyclerView;
    private final UDRecyclerView userdata;
    private final ILoadViewDelegete loadViewDelegete;
    private SizeChangedListener sizeChangedListener;
    private boolean loadEnable = false;
    private boolean isLoading = false;
    private boolean isViewPager = false;
    private ViewLifeCycleCallback cycleCallback;
    private ArgoTouchLink touchLink = new ArgoTouchLink();

    public LuaRecyclerView(Context context, UDRecyclerView javaUserdata, boolean refreshEnable, boolean loadEnable) {
        super(context);
        userdata = javaUserdata;
        /// 使用layoutinflater多耗时4ms
        recyclerView = new MLSRecyclerView(context, null);//(MLSRecyclerView) LayoutInflater.from(context).inflate(R.layout.mmui_layout_recycler_view, null);
        loadViewDelegete = MLSAdapterContainer.getLoadViewAdapter().newLoadViewDelegate(context, recyclerView);
        recyclerView.setLoadViewDelegete(loadViewDelegete);
        recyclerView.setOnLoadListener(this);
        recyclerView.setCycleCallback(userdata);
        recyclerView.setClipToPadding(false);
        recyclerView.setUserdata(userdata);
        userdata.setLoadViewDelegete(loadViewDelegete);
        setColorSchemeColors(MLSFlag.getRefreshColor());
        setProgressViewOffset(MLSFlag.isRefreshScale(), 0, MLSFlag.getRefreshEndPx());
//        setDistanceToTriggerSync(MLSFlag.getRefreshEndPx());
        addView(recyclerView, LuaViewUtil.createRelativeLayoutParamsMM());
        setRefreshEnable(refreshEnable);
        setLoadEnable(loadEnable);
        // 处理组合控件
        touchLink.setHead(this);
        touchLink.addChild(recyclerView);
    }

    //<editor-fold desc="ILView">

    @Override
    public UDRecyclerView getUserdata() {
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
    }
    //</editor-fold>

    //<editor-fold desc="IRefreshRecyclerView">
    @Override
    public RecyclerView getRecyclerView() {
        return recyclerView;
    }

    @Override
    public void setRefreshEnable(boolean enable) {
        setEnabled(enable);
        if (enable) {
            setOnRefreshListener(this);
        }
    }

    @Override
    public boolean isRefreshEnable() {
        return isEnabled();
    }

    @Override
    public void startRefreshing() {
        userdata.callScrollToTop(false);
        setRefreshing(true);
        MainThreadExecutor.post(new Runnable() {
            @Override
            public void run() {
                onRefresh();
            }
        });
    }

    @Override
    public void stopRefreshing() {
        setRefreshing(false);
        if (isLoading)
            return;
        loadViewDelegete.setEnable(loadEnable);
    }

    @Override
    public void setLoadEnable(boolean enable) {
        if (loadEnable == enable)
            return;
        loadEnable = enable;
        loadViewDelegete.setEnable(enable);
    }

    @Override
    public boolean isLoadEnable() {
        return loadEnable;
    }

    @Override
    public boolean isLoading() {
        return isLoading;
    }

    @Override
    public void stopLoading() {
        isLoading = false;
        loadViewDelegete.getLoadView().stopAnim();
    }

    @Override
    public void noMoreData() {
        loadViewDelegete.noMoreData();
    }

    @Override
    public void startLoading() {
        loadViewDelegete.startLoading();
    }

    @Override
    public void resetLoading() {
        loadViewDelegete.resetLoading();
    }

    @Override
    public void loadError() {
        isLoading = false;
        loadViewDelegete.loadError();
    }

    @Override
    public int getCurrentState() {
        return loadViewDelegete.getCurrentState();
    }

    @Override
    public void setSizeChangedListener(SizeChangedListener sizeChangedListener) {
        this.sizeChangedListener = sizeChangedListener;
    }
    //</editor-fold>

    //<editor-fold desc="OnLoadListener">

    @Override
    public void onLoad() {
        if (isLoading)
            return;
        isLoading = true;
        userdata.callbackLoading();
    }
    //</editor-fold>

    //<editor-fold desc="OnRefreshListener">

    @Override
    public void onRefresh() {
        loadViewDelegete.setEnable(false);
        userdata.callbackRefresh();
    }
    //</editor-fold>

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        if (sizeChangedListener != null) {
            sizeChangedListener.onSizeChanged(w, h);
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        final int childLeft = getPaddingLeft() + left;
        final int childTop = getPaddingTop() + top;
        for (int index = 0, l = getChildCount(); index < l; index++) {
            View c = getChildAt(index);
            if (c == recyclerView)
                continue;
            LayoutParams lp = c.getLayoutParams();
            if (!(lp instanceof MarginLayoutParams))
                continue;
            MarginLayoutParams mlp = (MarginLayoutParams) lp;
            int cl = childLeft + mlp.leftMargin;
            int ct = childTop + mlp.topMargin;
            c.layout(cl, ct, cl + c.getMeasuredWidth(), ct + c.getMeasuredHeight());
        }

    }

    @Override
    public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        for (int index = 0, l = getChildCount(); index < l; index++) {
            View c = getChildAt(index);
            if (c == recyclerView)
                continue;
            if (!(c.getLayoutParams() instanceof MarginLayoutParams))
                continue;
            measureChildWithMargins(c, widthMeasureSpec, 0, heightMeasureSpec, 0);
        }
    }

    //<editor-fold desc="ILViewGroup">

    /**
     * 设置滚动位置
     */
    public void scrollTo(int x, int y) {
        final RecyclerView v = getRecyclerView();
        v.scrollBy(x - v.computeHorizontalScrollOffset(),
                y - v.computeVerticalScrollOffset());
    }
    /**
     * 带动画的滚动
     */
    public void smoothScrollTo(int x, int y) {
        final RecyclerView v = getRecyclerView();
        v.smoothScrollBy(x - v.computeHorizontalScrollOffset(),
                y - v.computeVerticalScrollOffset());
    }

    public int getScrollOffsetX() {
        return getRecyclerView().computeHorizontalScrollOffset();
    }

    public int getScrollOffsetY() {
        return getRecyclerView().computeVerticalScrollOffset();
    }

    @Override
    public boolean isViewPager() {
        return isViewPager;
    }

    @Override
    public void setViewpager(boolean viewpager) {
        isViewPager = viewpager;
    }

    // 针对viewPager单独设计的接口
    @Override
    public void setPagerContentOffset(int x, int y) {
        UDCollectionLayout layout = (UDCollectionLayout) userdata.getLayout();  // viewPager 是基于CollectionView底层做的
        GridLayoutManager layoutManager = (GridLayoutManager) getRecyclerView().getLayoutManager();
        getRecyclerView().scrollBy(x - ViewPagerOffsetCompute.computeHorizontalScrollOffset(layoutManager, layout),
                y - ViewPagerOffsetCompute.computeVerticalScrollOffset(layoutManager, layout));
    }

    @Override
    public int getPagerContentOffsetX() {
        UDCollectionLayout layout = (UDCollectionLayout) userdata.getLayout();  // viewPager 是基于CollectionView底层做的
        GridLayoutManager layoutManager = (GridLayoutManager) getRecyclerView().getLayoutManager();
        return ViewPagerOffsetCompute.computeHorizontalScrollOffset(layoutManager, layout);
    }

    @Override
    public int getPagerContentOffsetY() {
        UDCollectionLayout layout = (UDCollectionLayout) userdata.getLayout();  // viewPager 是基于CollectionView底层做的
        GridLayoutManager layoutManager = (GridLayoutManager) getRecyclerView().getLayoutManager();
        return ViewPagerOffsetCompute.computeVerticalScrollOffset(layoutManager, layout);
    }

    //</editor-fold>

    @Override
    public ArgoTouchLink getTouchLink() {
        return touchLink;
    }
}