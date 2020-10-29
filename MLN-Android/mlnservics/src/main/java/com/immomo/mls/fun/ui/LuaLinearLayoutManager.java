/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.LinearSmoothScroller;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.util.LogUtil;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019/2/12
 * Time         :   下午5:34
 * Description  :
 */
public class LuaLinearLayoutManager extends LinearLayoutManager implements IScrollEnabled {
    private boolean isScrollEnabled = true;
    private final LinearChildrenStateHelper childrenStateHelper = new LinearChildrenStateHelper();
    private TopLinearSmoothScroller linearSmoothScroller;

    public LuaLinearLayoutManager(Context context) {
        super(context);
    }

    public LuaLinearLayoutManager(Context context, int orientation, boolean reverseLayout) {
        super(context, orientation, reverseLayout);
    }

    public LuaLinearLayoutManager(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    public void setScrollEnabled(boolean scrollEnabled) {
        isScrollEnabled = scrollEnabled;
    }

    @Override
    public boolean canScrollVertically() {
        return isScrollEnabled && super.canScrollVertically();
    }

    @Override
    public boolean canScrollHorizontally() {
        return isScrollEnabled && super.canScrollHorizontally();
    }

    @Override
    public void measureChildWithMargins(@NonNull View child, int widthUsed, int heightUsed) {
        super.measureChildWithMargins(child, widthUsed, heightUsed);
        childrenStateHelper.onMeasureChild(this, child);
    }

    @Override
    public int computeVerticalScrollOffset(RecyclerView.State state) {
        return childrenStateHelper.computeVerticalScrollOffset(this);
    }

    @Override
    public int scrollVerticallyBy(int dy, RecyclerView.Recycler recycler, RecyclerView.State state) {
        try {
            return super.scrollVerticallyBy(dy, recycler, state);
        } catch (Throwable e) {
            if (MLSEngine.DEBUG)
                LogUtil.e(e);
        }
        return 0;
    }

    @Override
    public void smoothScrollToPosition(RecyclerView recyclerView, RecyclerView.State state, int position) {
        if (linearSmoothScroller == null) {
            linearSmoothScroller =
                    new TopLinearSmoothScroller(recyclerView.getContext());
        }
        linearSmoothScroller.setTargetPosition(position);
        startSmoothScroll(linearSmoothScroller);
    }


    public class TopLinearSmoothScroller extends LinearSmoothScroller {

        public TopLinearSmoothScroller(Context context) {
            super(context);
        }

        @Override
        protected int getVerticalSnapPreference() {
            return SNAP_TO_START;
        }
    }

}