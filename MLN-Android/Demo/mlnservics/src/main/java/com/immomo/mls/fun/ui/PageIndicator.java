package com.immomo.mls.fun.ui;

import androidx.viewpager.widget.ViewPager;

/**
 * Created by XiongFangyu on 2018/9/5.
 */
public interface PageIndicator extends ViewPager.OnPageChangeListener {
    void setViewPager(ViewPager view);

    void setCurrentItem(int item);

    void notifyDataSetChanged();

    void removeFromSuper();
}
