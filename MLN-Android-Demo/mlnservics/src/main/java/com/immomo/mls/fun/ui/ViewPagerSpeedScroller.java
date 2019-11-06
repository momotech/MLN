package com.immomo.mls.fun.ui;

import android.content.Context;
import android.view.animation.Interpolator;
import android.widget.Scroller;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019/2/27
 * Time         :   下午2:50
 * Description  :   控制ViewPager 自动滚动速度
 */

public class ViewPagerSpeedScroller extends Scroller {
    public int mDuration = 250;;

    public ViewPagerSpeedScroller(Context context) {
        super(context);
    }

    public ViewPagerSpeedScroller(Context context, Interpolator interpolator) {
        super(context, interpolator);
    }

    public ViewPagerSpeedScroller(Context context, Interpolator interpolator, boolean flywheel) {
        super(context, interpolator, flywheel);
    }

    @Override
    public void startScroll(int startX, int startY, int dx, int dy) {
        startScroll(startX, startY, dx, dy, mDuration);
    }

    @Override
    public void startScroll(int startX, int startY, int dx, int dy, int duration) {
        super.startScroll(startX, startY, dx, dy, mDuration);
    }

    public int getmDuration() {
        return mDuration;
    }

    public void setmDuration(int duration) {
        mDuration = duration;
    }
}

