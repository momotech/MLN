/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.view.View;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * 修复原UDCollectionGridLayout 两端差异
 */
public class GridLayoutItemDecoration extends RecyclerView.ItemDecoration {

    public int horizontalSpace;
    public int verticalSpace;


    UDCollectionLayout mUDCollectionGridLayout;
    private boolean hasFooter = false;//两端footer实现不同，Android的footer受Spacing影响。因此需要判断有无

    public void setHasFooter(boolean hasFooter) {
        this.hasFooter = hasFooter;
    }

    public GridLayoutItemDecoration(int orientation, UDCollectionLayout udCollectionGridLayout) {
        this.horizontalSpace = udCollectionGridLayout.getItemSpacingPx();
        this.verticalSpace = udCollectionGridLayout.getlineSpacingPx();

        this.mUDCollectionGridLayout = udCollectionGridLayout;
    }

    public boolean isSame(int h, int v) {
        return ((h) == horizontalSpace)
                && ((v) == verticalSpace);
    }

    /**
     * GridLayout的item布局方式：
     * 因为有layoutInset, RecyclerView四周的itemSpacing、lineSpacing统一为0
     * 思路：
     * 方法中给layoutInset的padding减去spacing，使边缘的item，spacing为0
     * <p>
     * footer才是最后1行，所以最后2行bottom都需要为0
     */
    @Override
    public void getItemOffsets(android.graphics.Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        int horizontalSpace = mUDCollectionGridLayout.getItemSpacingPx();
        int verticalSpace = mUDCollectionGridLayout.getlineSpacingPx();
        int orientation = mUDCollectionGridLayout.getOrientation();

        GridLayoutManager layoutManager = (GridLayoutManager) parent.getLayoutManager();
        final GridLayoutManager.LayoutParams lp = (GridLayoutManager.LayoutParams) view.getLayoutParams();
        final int spanCount = layoutManager.getSpanCount();

        super.getItemOffsets(outRect, view, parent, state);
        int childPosition = parent.getChildAdapterPosition(view);
        //当前行
        int currentColumn = layoutManager.getSpanSizeLookup().getSpanGroupIndex(childPosition, spanCount);
        //总行数
        int totalColumn = layoutManager.getSpanSizeLookup().getSpanGroupIndex(parent.getAdapter().getItemCount() - 1, spanCount);

        int layoutInSetBottom = (int) mUDCollectionGridLayout.getPaddingValues()[3];
        int layoutInSetRight = (int) mUDCollectionGridLayout.getPaddingValues()[2];

        //因为有layoutInset, RecyclerView四周的itemSpacing、lineSpacing统一为0
        if (orientation == RecyclerView.VERTICAL) {
            outRect.bottom = verticalSpace;

            if (hasFooter) {
                if (currentColumn == totalColumn - 1) {
                    outRect.bottom = layoutInSetBottom;
                }
                if (currentColumn == totalColumn) {//footer才是最后1行，所以最后2行bottom都需要为0
                    outRect.bottom = 0;
                }
            } else {
                if (currentColumn == totalColumn) {
                    outRect.bottom = layoutInSetBottom;
                }
            }

            if (lp.getSpanSize() == spanCount) {  //占满
                outRect.left = horizontalSpace;
                outRect.right = horizontalSpace;
            } else {
                outRect.left = (int) (((float) (spanCount - lp.getSpanIndex())) / spanCount * horizontalSpace);
                outRect.right = (int) (((float) horizontalSpace * (spanCount + 1) / spanCount) - outRect.left);
            }
        } else {
            outRect.right = horizontalSpace;

            if (hasFooter) {
                if (currentColumn == totalColumn - 1) {
                    outRect.right = layoutInSetRight;
                }
                if (currentColumn == totalColumn) {//footer才是最后1行，所以最后2行bottom都需要为0
                    outRect.right = 0;
                }
            } else {
                if (currentColumn == totalColumn) {
                    outRect.right = layoutInSetRight;
                }
            }


            if (lp.getSpanSize() == spanCount) {   //占满
                outRect.top = verticalSpace;
                outRect.bottom = verticalSpace;
            } else {
                outRect.top = (int) (((float) (spanCount - lp.getSpanIndex())) / spanCount * verticalSpace);
                outRect.bottom = (int) (((float) verticalSpace * (spanCount + 1) / spanCount) - outRect.top);
            }
        }
    }
}