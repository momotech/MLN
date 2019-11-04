package com.immomo.mls.fun.other;

import android.graphics.Rect;
import android.view.View;

import com.immomo.mls.fun.ud.view.recycler.UDWaterfallLayoutFix;
import com.immomo.mls.fun.ui.LuaStaggeredGridLayoutManager;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * {@link DividerWaterFallItemDecoration}有两端差异，避免影响现有业务，新建{@link WaterFallItemDecoration}解决差异
 * Created by zhang.ke on 2019/9/14.
 */
public class WaterFallItemDecoration extends RecyclerView.ItemDecoration {

    public int horizontalSpace;
    public int verticalSpace;

    private UDWaterfallLayoutFix layout;
    private boolean hasFooter = false;//两端footer实现不同，Android的footer受Spacing影响。因此需要判断有无

    public void setHasFooter(boolean hasFooter) {
        this.hasFooter = hasFooter;
    }

    public WaterFallItemDecoration(UDWaterfallLayoutFix layout) {
        this.layout = layout;
        this.horizontalSpace = layout.getItemSpacingPx();
        this.verticalSpace = layout.getlineSpacingPx();
    }

    /**
     * WaterFall的item布局方式：
     * 因为有layoutInset, RecyclerView四周的itemSpacing、lineSpacing统一为0
     * 思路：
     * 在{@link com.immomo.mls.fun.ud.view.recycler.UDBaseRecyclerAdapter#setMarginForVerticalGridLayout(RecyclerView)}
     * 方法中给layoutInset的padding减去itemSpacing，使边缘item的itemSpacing为0
     * <p>
     * item水平之间用：horizontalSpace/2
     * item竖直之间：给botom = verticalSpace（为了去掉第一行top的lineSpacing）
     * footer才是最后1行，所以最后2行bottom都需要为0
     */
    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        int horizontalSpace = layout.getItemSpacingPx();
        int verticalSpace = layout.getlineSpacingPx();

        LuaStaggeredGridLayoutManager layoutManager = (LuaStaggeredGridLayoutManager) parent.getLayoutManager();
        super.getItemOffsets(outRect, view, parent, state);

        int spanCount = layoutManager.getSpanCount();
        int totalCount = parent.getAdapter().getItemCount();
        int childPosition = parent.getChildAdapterPosition(view);

        int currentColumn = getSpanGroupIndex(childPosition, spanCount);//当前行
        int totalColumn = getSpanGroupIndex(totalCount - 1, spanCount);//当前行

        int layoutInSetBottom = layout.getPaddingValues()[3];

        outRect.bottom = verticalSpace;

        if (currentColumn == totalColumn) {
            outRect.bottom = layoutInSetBottom;
        }

        outRect.left = horizontalSpace / 2;
        outRect.right = horizontalSpace / 2;
    }

    /**
     * 获取行数，参考方法：
     * {@link GridLayoutManager#getSpanGroupIndex(RecyclerView.Recycler, RecyclerView.State, int)}
     *
     * @param adapterPosition
     * @param spanCount
     * @return
     */
    public int getSpanGroupIndex(int adapterPosition, int spanCount) {
        int span = 0;
        int group = 0;
        for (int i = 0; i < adapterPosition; i++) {
            span += 1;
            if (span == spanCount) {
                span = 0;
                group++;
            } else if (span > spanCount) {
                // did not fit, moving to next row / column
                span = 1;
                group++;
            }
        }
        if (span + 1 > spanCount) {
            group++;
        }
        return group;
    }
}
