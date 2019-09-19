/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.view.ViewGroup;

import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.view.UDScrollView;

/**
 * Created by XiongFangyu on 2018/8/3.
 */
public interface IScrollView<U extends UDScrollView> extends ILViewGroup<U> {

    void setContentSize(Size size);

    ViewGroup getContentView();

    Size getContentSize();

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

    Point getContentOffset();

    void setOnScrollListener(OnScrollListener l);

    interface OnScrollListener {
        void onBeginScroll();

        void onScrolling();

        void onScrollEnd();
    }
}