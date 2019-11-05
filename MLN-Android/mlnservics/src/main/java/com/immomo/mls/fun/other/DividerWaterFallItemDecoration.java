/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.other;

import android.graphics.Rect;
import androidx.recyclerview.widget.RecyclerView;
import android.view.View;

/**
 * {@link DividerWaterFallItemDecoration}有两端差异，使用{@link WaterFallItemDecoration}解决差异
 * Created by XiongFangyu on 2018/7/19.
 */
public class DividerWaterFallItemDecoration extends RecyclerView.ItemDecoration {

    public int horizontalSpace;
    public int verticalSpace;

    public DividerWaterFallItemDecoration(int d) {
        this(d, d);
    }

    public DividerWaterFallItemDecoration(int hs, int vs) {
        this.horizontalSpace = hs;
        this.verticalSpace = vs;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        outRect.set(horizontalSpace, verticalSpace, horizontalSpace, verticalSpace);
    }
}