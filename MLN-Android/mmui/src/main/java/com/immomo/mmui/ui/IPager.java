/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.ui;

/**
 * Created by Xiong.Fangyu on 2020/8/31
 */
public interface IPager {

    boolean isViewPager();

    void setViewpager(boolean viewpager);
    /**
     * 只针对viewPager设计的接口
     */
    void setPagerContentOffset(int x, int y);

    /**
     * 只针对viewPager设计的接口
     */
    int getPagerContentOffsetX();
    int getPagerContentOffsetY();
}
