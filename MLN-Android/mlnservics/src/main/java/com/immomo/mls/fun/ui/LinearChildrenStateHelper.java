/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.view.View;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;

/**
 * Created by Xiong.Fangyu on 2019-09-16
 */
class LinearChildrenStateHelper {
    /**
     * 每个位置的值有两个含义
     * 1、前32位，表示上一次此位置view的高度
     * 2、后32位，表示此位置view的真实top值
     */
    private @Nullable
    long[] childrenState;

    private void initStateByIndex(int index, int h) {
        if (index == 0) {
            if (childrenState == null) {
                childrenState = new long[10];
            }
            childrenState[0] = (((long) h) << 32) | (h);
            return;
        }
        int pre = index - 1;
        if (childrenState == null || childrenState.length <= pre || childrenState[pre] == 0)
            return;
        long preH = childrenState[pre] & 0xffffffffL;
        if (childrenState.length == index) {
            resize();
        }
        long cache = childrenState[index];
        if ((cache >>> 32) != h) {
            childrenState[index] = (((long) h) << 32) | (preH + h);
        }
    }

    private void resize() {
        final long[] pre = childrenState;
        childrenState = new long[pre.length + 10];
        System.arraycopy(pre, 0, childrenState, 0, pre.length);
    }

    /**
     * Called by {@link androidx.recyclerview.widget.RecyclerView.LayoutManager#measureChildWithMargins}
     */
    void onMeasureChild(LinearLayoutManager manager, View child) {
        int index = manager.getPosition(child);
        int h = child.getMeasuredHeight();
        initStateByIndex(index, h);
    }

    /**
     * Called by {@link androidx.recyclerview.widget.RecyclerView.LayoutManager#computeVerticalScrollOffset}
     */
    int computeVerticalScrollOffset(LinearLayoutManager manager) {
        if (manager.getChildCount() == 0)
            return 0;
        if (childrenState == null)
            return 0;
        int p = manager.findFirstVisibleItemPosition();
        if (p < 0 || p >= childrenState.length)
            return 0;
        View v = manager.findViewByPosition(p);
        if (v == null)
            return 0;
        int y = -(int) (v.getY());
        y += p == 0 ? 0 : (childrenState[p - 1] & 0xffffffffL);
        return y;
    }
}