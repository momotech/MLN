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
