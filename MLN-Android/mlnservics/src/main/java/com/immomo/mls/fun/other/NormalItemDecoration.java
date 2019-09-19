/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.other;

import android.view.View;

import com.immomo.mls.fun.ud.view.recycler.UDCollectionLayout;
import com.immomo.mls.util.LogUtil;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by XiongFangyu on 2018/8/16.
 */
public class NormalItemDecoration extends RecyclerView.ItemDecoration {

    private static final String TAG = NormalItemDecoration.class.getSimpleName();

    public int horizontalSpace;
    public int verticalSpace;

    private int orientation = RecyclerView.VERTICAL;
    private int spanCount = UDCollectionLayout.DEFAULT_SPAN_COUNT;

    public NormalItemDecoration(int d) {
        this(d, d, RecyclerView.VERTICAL, UDCollectionLayout.DEFAULT_SPAN_COUNT);
    }

    public NormalItemDecoration(int hs, int vs, int orientation, int spanCount) {
        this.horizontalSpace = hs;
        this.verticalSpace = vs;
        this.orientation = orientation;
        this.spanCount = spanCount;
    }

    public boolean isSame(int h, int v) {
        return ((h) == horizontalSpace)
                && ((v) == verticalSpace);
    }

    @Override
    public void getItemOffsets(android.graphics.Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        GridLayoutManager layoutManager = (GridLayoutManager) parent.getLayoutManager();
        final GridLayoutManager.LayoutParams lp = (GridLayoutManager.LayoutParams) view.getLayoutParams();
        final int spanCount = layoutManager.getSpanCount();

        super.getItemOffsets(outRect, view, parent, state);
        int childPosition = parent.getChildAdapterPosition(view);

        if (orientation == RecyclerView.VERTICAL) {
            //判断是否在第一排
            if (layoutManager.getSpanSizeLookup().getSpanGroupIndex(childPosition, spanCount) == 0) {//第一排的需要上面
                outRect.top = verticalSpace;
            }
            outRect.bottom = verticalSpace;
            //这里忽略和合并项的问题，只考虑占满和单一的问题
            if (lp.getSpanSize() == spanCount) {//占满
                outRect.left = horizontalSpace;
                outRect.right = horizontalSpace;
            } else {
                outRect.left = (int) (((float) (spanCount - lp.getSpanIndex())) / spanCount * horizontalSpace);
                outRect.right = (int) (((float) horizontalSpace * (spanCount + 1) / spanCount) - outRect.left);
            }

        } else {
            if (layoutManager.getSpanSizeLookup().getSpanGroupIndex(childPosition, spanCount) == 0) {//第一排的需要left
                outRect.left = horizontalSpace;
            }
            outRect.right = horizontalSpace;
            //这里忽略和合并项的问题，只考虑占满和单一的问题
            if (lp.getSpanSize() == spanCount) {//占满
                outRect.top = verticalSpace;
                outRect.bottom = verticalSpace;
            } else {
                outRect.top = (int) (((float) (spanCount - lp.getSpanIndex())) / spanCount * verticalSpace);
                outRect.bottom = (int) (((float) verticalSpace * (spanCount + 1) / spanCount) - outRect.top);
            }
        }

        LogUtil.d(TAG, "childPosition =  " + childPosition + "     left = " + outRect.left + "      " +
                "     right = " + outRect.right + "  itemCount = " + spanCount);
    }
}