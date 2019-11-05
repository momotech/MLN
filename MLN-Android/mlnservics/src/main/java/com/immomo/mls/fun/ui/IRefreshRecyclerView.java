/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import com.immomo.mls.fun.other.Point;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
public interface IRefreshRecyclerView {

    @NonNull RecyclerView getRecyclerView();

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
     * 设置偏移位置
     */
    void setContentOffset(Point p);

    Point getContentOffset();

    /**
     * 滑动到指定位置
     */
    void smoothScrollTo(Point p);

    void setSizeChangedListener(SizeChangedListener sizeChangedListener);
}