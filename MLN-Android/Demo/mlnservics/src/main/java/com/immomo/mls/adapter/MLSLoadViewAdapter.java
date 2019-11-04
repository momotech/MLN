package com.immomo.mls.adapter;

import android.content.Context;
import androidx.annotation.NonNull;

import com.immomo.mls.weight.load.ILoadViewDelegete;
import com.immomo.mls.weight.load.ScrollableView;

/**
 * Created by XiongFangyu on 2018/7/23.
 */
public interface MLSLoadViewAdapter {

    @NonNull
    ILoadViewDelegete newLoadViewDelegate(Context context, ScrollableView scrollableView);
}
