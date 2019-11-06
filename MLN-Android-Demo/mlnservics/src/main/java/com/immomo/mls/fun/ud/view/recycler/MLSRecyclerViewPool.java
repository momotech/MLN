package com.immomo.mls.fun.ud.view.recycler;

import androidx.recyclerview.widget.RecyclerView;
import android.util.SparseBooleanArray;

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
