/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ui;

import android.view.ViewGroup;

import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.other.Size;
import com.immomo.mmui.ILViewGroup;
import com.immomo.mmui.ud.UDScrollView;
import com.immomo.mmui.weight.layout.NodeLayout;

/**
 * Created by XiongFangyu on 2018/8/3.
 */
public interface IScrollView<U extends UDScrollView> extends ILViewGroup<U> {

    void setContentSize(Size size);

    NodeLayout getContentView();

    Size getContentSize();

    ViewGroup getScrollView();

    /**
     * 设置滚动位置
     * @param p
     */
    void setContentOffset(Point p);

    void setScrollEnable(boolean scrollEnable);

    /**
     * 带动画的滚动
     * @param p
     */
    void setOffsetWithAnim(Point p);

    void setFlingSpeed(float speed);

    Point getContentOffset();

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
        void onTouchDown();
    }

    interface FlingListener {
        void onFling();
    }
}