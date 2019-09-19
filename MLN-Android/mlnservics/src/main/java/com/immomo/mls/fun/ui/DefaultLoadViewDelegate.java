/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.fun.constants.LoadingState;
import com.immomo.mls.weight.load.DefaultLoadWithTextView;
import com.immomo.mls.weight.load.ILoadViewDelegete;
import com.immomo.mls.weight.load.ILoadWithTextView;
import com.immomo.mls.weight.load.ScrollableView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by XiongFangyu on 2018/7/20.
 */
public class DefaultLoadViewDelegate implements ILoadViewDelegete {
    private static final String LOADING = "正在加载";
    private static final String NO_MORE_DATA = "已经全部加载完毕";
    private static final String ERROR = "点击重新加载";

    private static final byte STATE_INIT = LoadingState.STATE_INIT;
    private static final byte STATE_NOMOREDATA = LoadingState.STATE_NOMOREDATA;
    private static final byte STATE_ERROR = LoadingState.STATE_ERROR;

    private final ILoadWithTextView loadWithTextView;
    private ScrollableView scrollableView;
    private String loadingText = LOADING;

    private byte state = STATE_INIT;

    private boolean enable = false;
    private int orientation = RecyclerView.VERTICAL;

    public DefaultLoadViewDelegate(Context context, ScrollableView scrollableView) {
        this.scrollableView = scrollableView;
        DefaultLoadWithTextView loadWithTextView = new DefaultLoadWithTextView(context);
        loadWithTextView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        this.loadWithTextView = loadWithTextView;
    }

    @NonNull
    @Override
    public <T extends View & ILoadWithTextView> T getLoadView() {
        return (T) loadWithTextView;
    }

    @Override
    public boolean onShowLoadView(boolean byClick) {
        if (scrollableView != null && orientation != scrollableView.getOrientation()) {
            orientation = scrollableView.getOrientation();
            onOrientationChanged();
        }
        if (!canShowFoot()) {
            loadWithTextView.getView().setVisibility(View.GONE);
            return false;
        }
        if (scrollableView == null || scrollableView.findFirstCompletelyVisibleItemPosition() == 0) {
            loadWithTextView.stopAnim();
            loadWithTextView.getView().setVisibility(View.GONE);
            return false;
        }
        loadWithTextView.getView().setVisibility(View.VISIBLE);
        loadWithTextView.setLoadText(loadingText);
        if (state == STATE_INIT) {
            loadWithTextView.startAnim();
            loadWithTextView.showLoadAnimView();
            return true;
        }
        loadWithTextView.hideLoadAnimView();
        return false;
    }

    @Override
    public boolean canCallback() {
        return canShowFoot() && state == STATE_INIT;
    }

    @Override
    public boolean canShowFoot() {
        return enable;
    }

    @Override
    public void startLoading() {
        state = STATE_INIT;
        loadingText = LOADING;
        onShowLoadView(false);
    }

    @Override
    public void resetLoading() {
        state = STATE_INIT;
        loadingText = LOADING;
        onShowLoadView(false);
    }

    @Override
    public void noMoreData() {
        state = STATE_NOMOREDATA;
        loadingText = NO_MORE_DATA;
        onShowLoadView(false);
    }

    @Override
    public void loadError() {
        state = STATE_ERROR;
        loadingText = ERROR;
        onShowLoadView(false);
    }

    @Override
    public int getCurrentState() {
        return state;
    }

    @Override
    public void setEnable(boolean enable) {
        this.enable = enable;
    }

    @Override
    public boolean useAllSpanCountInGrid() {
        return true;
    }

    private void onOrientationChanged() {
        ViewGroup.LayoutParams p = loadWithTextView.getView().getLayoutParams();
        if (orientation == RecyclerView.VERTICAL) {
            p.width = ViewGroup.LayoutParams.MATCH_PARENT;
            p.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        } else {
            p.width = ViewGroup.LayoutParams.WRAP_CONTENT;
            p.height = ViewGroup.LayoutParams.MATCH_PARENT;
        }
        loadWithTextView.getView().setLayoutParams(p);
    }
}