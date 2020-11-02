/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.recycler;

import android.util.SparseBooleanArray;

import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by Xiong.Fangyu on 2018/11/14
 */
public class MLSRecyclerViewPool extends RecyclerView.RecycledViewPool {
    private SparseBooleanArray setted = new SparseBooleanArray();

    private int max = 8;
    public MLSRecyclerViewPool(int max) {
        this.max = max;
    }

    @Override
    public void putRecycledView(RecyclerView.ViewHolder scrap) {
        final int viewType = scrap.getItemViewType();
        if (!setted.get(viewType)) {
            setMaxRecycledViews(viewType, max);
            setted.put(viewType, true);
        }
        super.putRecycledView(scrap);
    }
}