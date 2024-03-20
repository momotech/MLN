/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ui;

import android.view.ViewGroup;

import com.immomo.mmui.ILViewGroup;
import com.immomo.mmui.ud.UDScrollView;
import com.immomo.mmui.weight.layout.NodeLayout;

/**
 * Created by XiongFangyu on 2018/8/3.
 */
public interface IScrollView<U extends UDScrollView> extends ILViewGroup<U> {

    NodeLayout getContentView();

    ViewGroup getScrollView();

    /**
     * 设置滚动位置
     */
    void scrollTo(int x, int y);
    /**
     * 带动画的滚动
     */
    void smoothScrollTo(int x, int y);

    int getScrollX();

    int getScrollY();

    void setScrollEnable(boolean scrollEnable);

    void setFlingSpeed(float speed);

    void setOnScrollListener(OnScrollListener l);

    void setTouchActionListener(touchActionListener l);

    void setFlingListener(FlingListener flingListener);

    void setHorizontalScrollBarEnabled(boolean enabled);

    void setVerticalScrollBarEnabled(boolean enabled);

    interface OnScrollListener {
        void onBeginScroll();

        void onScrolling();

        void onScrollEnd();
    }

    interface touchActionListener {
        void onActionUp();
    }

    interface FlingListener {
        void onFling();
    }
}