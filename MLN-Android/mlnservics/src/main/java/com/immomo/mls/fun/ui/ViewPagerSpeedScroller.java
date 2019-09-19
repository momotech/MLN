/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
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