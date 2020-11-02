/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.weight;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.fun.constants.LoadingState;
import com.immomo.mls.fun.ud.view.recycler.MLSRecyclerViewPool;
import com.immomo.mls.fun.ui.OnLoadListener;
import com.immomo.mls.provider.ImageProvider;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.weight.load.ILoadViewDelegete;
import com.immomo.mls.weight.load.ScrollableView;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

/**
 * Created by XiongFangyu on 2018/7/20.
 */
public class MLSRecyclerView extends RecyclerView implements ScrollableView {
    private boolean scrolled = false;
    private boolean footerShow = false;
    private boolean disallowFling = false;
    private ILoadViewDelegete loadViewDelegete;
    private OnLoadListener onLoadListener;
    private int[] staggeredGridCache = null;
    private float loadThreshold = 0;
    private int mToPosition; //记录scrollCellToPosition的 位置
    private ILView.ViewLifeCycleCallback cycleCallback;

    public MLSRecyclerView(Context context, AttributeSet attr) {
        super(context, attr);
        setRecycledViewPool(new MLSRecyclerViewPool(MLSConfigs.maxRecyclerPoolSize));
        setItemAnimator(null);//new DefaultItemAnimator());
        setFocusableInTouchMode(true);
        addOnScrollListener(new RecyclerView.OnScrollListener() {
            private int nx = 0, ny = 0;

            @Override
            public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                if (MLSConfigs.lazyFillCellData) {
                    Adapter adapter = getAdapter();
                    if (adapter instanceof com.immomo.mls.fun.other.Adapter) {
                        ((com.immomo.mls.fun.other.Adapter) adapter).setRecyclerState(newState);
                    }
                }
                if (newState == RecyclerView.SCROLL_STATE_IDLE) {
                    final ImageProvider provider = MLSAdapterContainer.getImageProvider();
                    if (provider != null) {
                        provider.resumeRequests(recyclerView, recyclerView.getContext());
                    }
                } else {
                    final ImageProvider provider = MLSAdapterContainer.getImageProvider();
                    if (provider != null) {
                        provider.pauseRequests(recyclerView, recyclerView.getContext());
                    }
                }

                voidGridLayoutDisorder(recyclerView, newState);

            }

            private void voidGridLayoutDisorder(RecyclerView recyclerView, int newState) {
                LayoutManager layoutManager = recyclerView.getLayoutManager();

                if (newState == RecyclerView.SCROLL_STATE_IDLE && layoutManager instanceof StaggeredGridLayoutManager) {

                    if (!recyclerView.canScrollVertically(-1))
                        ((StaggeredGridLayoutManager) layoutManager).invalidateSpanAssignments();
                }
            }

            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                nx += dx;
                ny += dy;
                if (footerShow) {
                    footerShow = false;
                    return;
                }

                RecyclerView.LayoutManager layoutManager = recyclerView.getLayoutManager();

                if (loadThreshold > 0) {
                    if (!loadViewDelegete.canCallback())
                        return;
                    int visibleItemCount = layoutManager.getChildCount();
                    if (visibleItemCount > 0) {
                        //loadThreshold统一为recyclerView高的比例，计算偏移量用以下方法：Range-(offset+height)
                        int bottomOffset = recyclerView.computeVerticalScrollRange() - recyclerView.computeVerticalScrollOffset() - recyclerView.getHeight();
                        int loadThresholdValue = (int) (loadThreshold * recyclerView.getHeight());

                        if (bottomOffset <= loadThresholdValue) {
                            if (loadViewDelegete.onShowLoadView(false)) {//STATE_INIT 走onShowLoadView()
                                if (onLoadListener != null)
                                    onLoadListener.onLoad();
                            } else if (loadViewDelegete.getCurrentState() == LoadingState.STATE_ERROR //非STATE_INIT 走startLoading()
                                    || loadViewDelegete.getCurrentState() == LoadingState.STATE_CLICK_TO_LOAD_MORE) {
                                if (onLoadListener != null) {
                                    loadViewDelegete.startLoading();
                                    onLoadListener.onLoad();
                                }
                            }
                        }
                    }
                    return;
                }
                if (findLastViewType() == com.immomo.mls.fun.other.Adapter.TYPE_FOOT) {
                    footerShow = true;
                    if (loadViewDelegete.onShowLoadView(false)) {
                        if (onLoadListener != null) {
                            onLoadListener.onLoad();
                            return;
                        }
                    }
                }

                if (loadViewDelegete.canCallback()) {
                    // 修复： 出现“点击重试”  上下滑动列表都无法使列表底部自动加载
                    int lastCompletelyVisibleItemPosition = findLastVisibleItemPosition();
                    if (lastCompletelyVisibleItemPosition == layoutManager.getItemCount() - 1 && (loadViewDelegete.getCurrentState() == LoadingState.STATE_ERROR || loadViewDelegete.getCurrentState() == LoadingState.STATE_CLICK_TO_LOAD_MORE)) {
                        if (onLoadListener != null) {
                            loadViewDelegete.startLoading();
                            onLoadListener.onLoad();
                        }
                    }
                }
            }
        });
        setVerticalScrollBarEnabled(false);
        setHorizontalScrollBarEnabled(false);
    }

    public void setLoadThreshold(float loadThreshold) {
        this.loadThreshold = loadThreshold;
    }

    public void setLoadViewDelegete(ILoadViewDelegete loadViewDelegete) {
        this.loadViewDelegete = loadViewDelegete;
    }

    public void setOnLoadListener(OnLoadListener onLoadListener) {
        this.onLoadListener = onLoadListener;
    }

    private int findLastViewType() {
        int p = findLastVisiblePosition();
        if (p != -1) {
            return getAdapter().getItemViewType(p);
        }
        return -1;
    }

    private int findLastVisiblePosition() {
        LayoutManager lm = getLayoutManager();
        if (lm instanceof LinearLayoutManager) {
            return ((LinearLayoutManager) lm).findLastVisibleItemPosition();
        }
        if (lm instanceof StaggeredGridLayoutManager) {
            checkCacheLenght((StaggeredGridLayoutManager) lm);
            staggeredGridCache = ((StaggeredGridLayoutManager) lm).findLastVisibleItemPositions(staggeredGridCache);
            return findMax(staggeredGridCache);
        }
        return -1;
    }

    @Override
    public void setAdapter(@Nullable Adapter adapter) {
        super.setAdapter(adapter);
    }

    @Override
    public void setLayoutManager(@Nullable LayoutManager layout) {
        super.setLayoutManager(layout);
    }

    private int findMax(int[] lastPositions) {
        int max = lastPositions[0];
        for (int value : lastPositions) {
            if (value > max) {
                max = value;
            }
        }
        return max;
    }

    //<editor-fold desc="ScrollableView">

    @Override
    public int findFirstCompletelyVisibleItemPosition() {
        LayoutManager lm = getLayoutManager();
        if (lm instanceof LinearLayoutManager) {
            return ((LinearLayoutManager) lm).findFirstCompletelyVisibleItemPosition();
        }
        if (lm instanceof StaggeredGridLayoutManager) {
            checkCacheLenght((StaggeredGridLayoutManager) lm);
            staggeredGridCache = ((StaggeredGridLayoutManager) lm).findFirstCompletelyVisibleItemPositions(staggeredGridCache);
            return staggeredGridCache[0];
        }
        return -1;
    }

    @Override
    public int getOrientation() {
        LayoutManager lm = getLayoutManager();
        if (lm instanceof LinearLayoutManager) {
            return ((LinearLayoutManager) lm).getOrientation();
        }
        return RecyclerView.VERTICAL;
    }

    @Override
    public boolean scrolled() {
        return scrolled;
    }
    //</editor-fold>

    @Override
    public void requestChildFocus(View child, View focused) {
        if (focused instanceof MLSRecyclerView) {
            return;
        }
        super.requestChildFocus(child, focused);
    }

    @Override
    public void onScrolled(int dx, int dy) {
        if (!scrolled) {
            scrolled = dx > 0 || dy > 0;
        }
        super.onScrolled(dx, dy);
    }

    /**
     * 滑动指定的cell到顶部，此效果和IOS同步。
     * 之前的smoothScrollToPosition，只能把cell滑入屏幕，与IOS不一致
     *
     * @param noSmooth
     * @param n
     */
    public void smoothMoveToPosition(boolean noSmooth, int n) {
        //滑动到指定的item
        this.mToPosition = n;//记录一下 在第三种情况下会用到
        //拿到当前屏幕可见的第一个position跟最后一个postion
        int firstItem = findFirstVisibleItemPosition();
        int lastItem = findLastVisibleItemPosition();
        //区分情况
        if (n <= firstItem) {
            //当要置顶的项在当前显示的第一个项的前面时
            if (noSmooth) {
                scrollToPosition(n);
            } else {
                smoothScrollToPosition(n);
            }
        } else if (n <= lastItem) {
            //当要置顶的项已经在屏幕上显示时
            int top = getChildAt(n - firstItem).getTop();
            if (noSmooth) {
                scrollBy(0, top);
            } else {
                smoothScrollBy(0, top);
            }
        } else {
            //当要置顶的项在当前显示的最后一项的后面时
            if (noSmooth) {
                scrollToPosition(n);
            } else {
                smoothScrollToPosition(n);
            }
        }
    }

    public int findFirstVisibleItemPosition() {
        LayoutManager lm = getLayoutManager();
        if (lm instanceof LinearLayoutManager) {
            return ((LinearLayoutManager) lm).findFirstVisibleItemPosition();
        }
        if (lm instanceof StaggeredGridLayoutManager) {
            checkCacheLenght((StaggeredGridLayoutManager) lm);
            staggeredGridCache = ((StaggeredGridLayoutManager) lm).findFirstVisibleItemPositions(staggeredGridCache);
            return staggeredGridCache[0];
        }
        return -1;
    }

    public int findLastVisibleItemPosition() {
        return findLastVisiblePosition();
    }

    private void checkCacheLenght(StaggeredGridLayoutManager lm) {
        if (staggeredGridCache != null && lm.getSpanCount() != staggeredGridCache.length) {
            staggeredGridCache = null;
        }
    }

    public void setCycleCallback(ILView.ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
    }

    @Override
    protected void onDetachedFromWindow() {
        if (cycleCallback != null)
            cycleCallback.onDetached();
        super.onDetachedFromWindow();
    }

    public void setDisallowFling(boolean disallow) {
        disallowFling = disallow;
    }

    public boolean isDisallowFling() {
        return disallowFling;
    }

    @Override
    public boolean fling(int velocityX, int velocityY) {
        if (disallowFling) {
            return false;
        } else {
            return super.fling(velocityX, velocityY);
        }
    }
}