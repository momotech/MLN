/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.ui;

import android.view.View;

import androidx.recyclerview.widget.GridLayoutManager;

import com.immomo.mmui.ud.recycler.UDCollectionLayout;

/**
 * viewPager 用于计算layout的偏移量 需要根据业务需求自己算
 * Created by wang.yang on 2020-07-20
 */
public class ViewPagerOffsetCompute {

    /**
     * 需要了解其布局信息
     *
     * @param layoutManager 布局管理器
     * @param layout        布局信息
     */
    public static int computeHorizontalScrollOffset(GridLayoutManager layoutManager, UDCollectionLayout layout) {
        if (layoutManager == null || layoutManager.getChildCount() == 0) {
            return 0;
        }
        try {
            int firstVisiablePosition = layoutManager.findFirstVisibleItemPosition();
            View firstVisiableView = layoutManager.findViewByPosition(firstVisiablePosition);
            if (firstVisiableView == null) {
                return 0;
            }
            int itemSpacingPx;
            int leftPadding;
            if (layout == null) {
                itemSpacingPx = 0;
                leftPadding = 0;
            } else {
                itemSpacingPx = layout.getItemSpacingPx();
                leftPadding = layout.getPaddingValues()[0];
            }
            int offsetX = -firstVisiableView.getLeft() + leftPadding;
            for (int i = 0; i < firstVisiablePosition; i++) {
                offsetX += firstVisiableView.getWidth();
                offsetX += itemSpacingPx;
            }
            return offsetX;
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * 需要了解其布局信息
     *
     * @param layoutManager 布局管理器
     * @param layout        布局信息
     */
    public static int computeVerticalScrollOffset(GridLayoutManager layoutManager, UDCollectionLayout layout) {
        if (layoutManager == null || layoutManager.getChildCount() == 0) {
            return 0;
        }
        try {
            int firstVisiablePosition = layoutManager.findFirstVisibleItemPosition();
            View firstVisiableView = layoutManager.findViewByPosition(firstVisiablePosition);
            if (firstVisiableView == null) {
                return 0;
            }
            int lineSpacingPx;
            int topPadding;
            if (layout == null) {
                lineSpacingPx = 0;
                topPadding = 0;
            } else {
                lineSpacingPx = layout.getlineSpacingPx();
                topPadding = layout.getPaddingValues()[1];
            }
            int offsetY = -firstVisiableView.getTop() + topPadding;
            for (int i = 0; i < firstVisiablePosition; i++) {
                offsetY += firstVisiableView.getHeight();
                offsetY += lineSpacingPx;
            }
            return offsetY;
        } catch (Exception e) {
            return 0;
        }
    }
}
