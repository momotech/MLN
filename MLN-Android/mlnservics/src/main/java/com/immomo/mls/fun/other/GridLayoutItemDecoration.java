/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.other;

import android.view.View;

import com.immomo.mls.fun.ud.view.recycler.UDCollectionGridLayout;
import com.immomo.mls.fun.ud.view.recycler.UDCollectionLayout;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

@Deprecated
public class GridLayoutItemDecoration extends RecyclerView.ItemDecoration {

    private static final String TAG = GridLayoutItemDecoration.class.getSimpleName();

    public int horizontalSpace;
    public int verticalSpace;

    private int orientation = RecyclerView.VERTICAL;
    private int spanCount = UDCollectionLayout.DEFAULT_SPAN_COUNT;

    UDCollectionGridLayout mUDCollectionGridLayout;

   /* public GridLayoutItemDecoration(int d) {
        this(d, d, RecyclerView.VERTICAL, UDCollectionLayout.DEFAULT_SPAN_COUNT);
    }*/

    public GridLayoutItemDecoration(int hs, int vs, int orientation, int spanCount, UDCollectionGridLayout udCollectionGridLayout) {
        this.horizontalSpace = hs;
        this.verticalSpace = vs;
        this.orientation = orientation;
        this.spanCount = spanCount;

        this.mUDCollectionGridLayout = udCollectionGridLayout;
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

        int currentColumn = layoutManager.getSpanSizeLookup().getSpanGroupIndex(childPosition, spanCount);
        boolean canScroll2ScreenLeft = mUDCollectionGridLayout.isCanScrollTolScreenLeft();

        int totalColumn = layoutManager.getSpanSizeLookup().getSpanGroupIndex(parent.getAdapter().getItemCount() - 1, spanCount);

        int layoutInSetLeft = (int) mUDCollectionGridLayout.getPaddingValues()[0];
        int layoutInSetTop = (int) mUDCollectionGridLayout.getPaddingValues()[1];
        int layoutInSetRight = (int) mUDCollectionGridLayout.getPaddingValues()[2];
        int layoutInSetBottom = (int) mUDCollectionGridLayout.getPaddingValues()[3];


        if (orientation == RecyclerView.VERTICAL) {

            if (layoutManager.getSpanSizeLookup().getSpanGroupIndex(childPosition, spanCount) == 0) {   //第一行
                outRect.top = verticalSpace;
            }

            outRect.bottom = verticalSpace;

            if (lp.getSpanSize() == spanCount) {  //占满
                outRect.left = horizontalSpace;
                outRect.right = horizontalSpace;
            } else {

                outRect.left = Math.abs((int) (((float) (spanCount - lp.getSpanIndex())) / spanCount * horizontalSpace) );

                if (lp.getSpanIndex() != 0) { //  不是最左侧一列
                    outRect.left = Math.abs((int) (((float) (spanCount - lp.getSpanIndex())) / spanCount * horizontalSpace)    + layoutInSetLeft - horizontalSpace );
                }

                outRect.right = (int) (((float) horizontalSpace * (spanCount + 1) / spanCount) - outRect.left);
            }

            if (lp.getSpanIndex() == spanCount - 1 || lp.getSpanSize() == spanCount)
                outRect.right = layoutInSetRight;

            if (lp.getSpanIndex() == 0 || lp.getSpanSize() == spanCount) {
                outRect.left = layoutInSetLeft;
            }


            if (currentColumn == 0 && canScroll2ScreenLeft) {           // 第一行
                outRect.top = layoutInSetTop;
            } else if (currentColumn == totalColumn && canScroll2ScreenLeft) {    // 最后一行
                outRect.bottom = layoutInSetBottom;
            }


        } else {

            outRect.right = horizontalSpace;

            if (lp.getSpanSize() == spanCount) {   //占满
                outRect.top = verticalSpace;
                outRect.bottom = verticalSpace;
            } else {
                outRect.top = (int) (((float) (spanCount - lp.getSpanIndex())) / spanCount * verticalSpace);
                outRect.bottom = (int) (((float) verticalSpace * (spanCount + 1) / spanCount) - outRect.top) + verticalSpace / 2;
            }

           /* if (lp.getSpanIndex() == 0 || lp.getSpanSize() == spanCount) {
                outRect.left = layoutInSetLeft;
            }*/

            if (currentColumn == 0 && canScroll2ScreenLeft) {           // 第一列
                outRect.left = layoutInSetLeft;
                //outRect.top = layoutInSetTop;
            } else if (currentColumn == totalColumn && canScroll2ScreenLeft) {    // 最后一列
                outRect.right = layoutInSetRight;
            }

        }


//        LogUtil.d(TAG, " columns = " + layoutManager.getSpanSizeLookup().getSpanGroupIndex(childPosition, spanCount));
//
//        LogUtil.d(TAG, "childPosition =  " + childPosition + "     left = " + outRect.left + "      " +
//                "     right = " + outRect.right + "  itemCount = " + spanCount);
//
//        LogUtil.d(TAG, "childPosition =  " + childPosition + "     top = " + outRect.top + "      " +
//                "     bottom = " + outRect.bottom + "  itemCount = " + spanCount);
    }
}