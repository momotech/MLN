package com.immomo.mls.lite.data;

import android.util.SparseBooleanArray;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.lite.Call;
import com.immomo.mls.lite.LuaClient;
import com.immomo.mls.utils.sparse.SparseIntArray;

public class LuaClientRecyclerViewPool extends RecyclerView.RecycledViewPool {
    final LuaClient client;
    public static final String VIEW_TAG = "LuaClientRecyclerViewPool";
    SparseIntArray viewTypeMaxCount = new SparseIntArray();
    protected int max = 8;
    private final SparseBooleanArray settled = new SparseBooleanArray();

    public LuaClientRecyclerViewPool(LuaClient client, int max) {
        super();
        this.max = max;
        this.client = client;
    }

    @Override
    public void putRecycledView(RecyclerView.ViewHolder scrap) {
        try {
            final int viewType = scrap.getItemViewType();
            if (!settled.get(viewType)) {
                setMaxRecycledViews(viewType, max);
                settled.put(viewType, true);
            }
            if (viewTypeMaxCount.get(viewType) <= getRecycledViewCount(viewType)) {
                Call scrapCall = null;
                for (Call call : client.dispatcher().runningCalls()) {
                    ViewGroup itemView = (ViewGroup) scrap.itemView;
                    if (itemView.findViewWithTag(VIEW_TAG) == call.window().get()) {
                        scrapCall = call;
                        call.recycle();
                        break;
                    }
                }

                if (scrapCall != null) {
                    client.dispatcher().finished(scrapCall);
                    return;
                }
            }
        } catch (Exception e) {
            MLSAdapterContainer.getConsoleLoggerAdapter().e("LuaClientRecyclerViewPool", e);
        }
        super.putRecycledView(scrap);
    }

    @Override
    public void setMaxRecycledViews(int viewType, int max) {
        super.setMaxRecycledViews(viewType, max);
        viewTypeMaxCount.put(viewType, max);
    }
}
