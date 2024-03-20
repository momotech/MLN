package com.immomo.mmui.ui;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.fun.ui.SizeChangedListener;

/**
 * Created by Xiong.Fangyu on 2020/11/20
 */
public interface IRefreshRecyclerView {

    @NonNull
    RecyclerView getRecyclerView();

    void setRefreshEnable(boolean enable);

    boolean isRefreshEnable();

    boolean isRefreshing();

    void startRefreshing();

    void stopRefreshing();

    void setLoadEnable(boolean enable);

    boolean isLoadEnable();

    boolean isLoading();

    void startLoading();

    void stopLoading();

    void noMoreData();

    void resetLoading();

    void loadError();

    int getCurrentState();

    /**
     * 设置滚动位置
     */
    void scrollTo(int x, int y);
    /**
     * 带动画的滚动
     */
    void smoothScrollTo(int x, int y);

    int getScrollOffsetX();

    int getScrollOffsetY();

    void setSizeChangedListener(SizeChangedListener sizeChangedListener);
}
