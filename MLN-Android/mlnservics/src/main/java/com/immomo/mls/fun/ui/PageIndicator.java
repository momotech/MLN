/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
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