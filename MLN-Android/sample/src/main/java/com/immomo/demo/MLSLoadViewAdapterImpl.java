/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.immomo.mls.adapter.MLSLoadViewAdapter;
import com.immomo.mls.fun.constants.LoadingState;
import com.immomo.mls.weight.load.ILoadViewDelegete;
import com.immomo.mls.weight.load.ILoadWithTextView;
import com.immomo.mls.weight.load.ScrollableView;

/**
 * Created by XiongFangyu on 2018/7/26.
 */
public class MLSLoadViewAdapterImpl implements MLSLoadViewAdapter {
    @NonNull
    @Override
    public ILoadViewDelegete newLoadViewDelegate(Context context, ScrollableView scrollableView) {
        return new LoadViewDelegate(context, scrollableView);
    }

    private static final class LoadViewDelegate implements ILoadViewDelegete {
        private static final String LOADING = "正在加载...";
        private static final String NO_MORE_DATA = "已加载全部";
        private static final String ERROR = "点击重试";
        private static final String FIRST_SCREEN = "点击加载更多";

        private static final byte STATE_INIT = LoadingState.STATE_INIT;
        private static final byte STATE_NOMOREDATA = LoadingState.STATE_NOMOREDATA;
        private static final byte STATE_ERROR = LoadingState.STATE_ERROR;
        private static final byte STATE_CLICK_TO_LOAD_MORE = LoadingState.STATE_CLICK_TO_LOAD_MORE;

        private LoadWithTextView root;
        private ScrollableView scrollableView;

        private boolean enabled;
        private String loadingText = LOADING;
        private byte state = STATE_INIT;
        private int orientation = -1;

        LoadViewDelegate(Context context, ScrollableView scrollableView) {
            root = new LoadWithTextView(context);
            this.scrollableView = scrollableView;
        }

        @NonNull
        @Override
        public <T extends View & ILoadWithTextView> T getLoadView() {
            return (T) root;
        }

        @Override
        public boolean onShowLoadView(boolean byClick) {
            if (scrollableView != null && orientation != scrollableView.getOrientation()) {
                orientation = scrollableView.getOrientation();
                onOrientationChanged();
            }
            if (!enabled) {
                root.stopAnim();
                root.setVisibility(View.GONE);
                return false;
            }
            if (state == STATE_NOMOREDATA) {
                root.stopAnim();
                root.hideLoadAnimView();
                root.setLoadText(loadingText);
                root.setVisibility(View.VISIBLE);
                return false;
            }
            if (!byClick
                    && (scrollableView == null
                        || (scrollableView.findFirstCompletelyVisibleItemPosition() <= 0 && !scrollableView.scrolled()))) {
                root.stopAnim();
                root.setLoadText(FIRST_SCREEN);
                root.setVisibility(View.VISIBLE);
                return false;
            }
            root.setVisibility(View.VISIBLE);

            if (state == STATE_ERROR || state == STATE_CLICK_TO_LOAD_MORE) {
                if (byClick) {
                    startLoading();
                    return true;
                } else if (state == STATE_ERROR) {
                    loadingText = ERROR;
                } else {
                    root.setLoadText(loadingText);
                    root.stopAnim();
                    root.hideLoadAnimView();
                    return false;
                }
            }

            root.setLoadText(loadingText);
            if (state == STATE_INIT) {
                root.startAnim();
                root.showLoadAnimView();
                return true;
            }

            root.hideLoadAnimView();
            return false;
        }

        @Override
        public boolean canCallback() {
            return enabled && state == STATE_INIT;
        }

        @Override
        public boolean canShowFoot() {
            return enabled;
        }

        @Override
        public void startLoading() {
            state = STATE_INIT;
            loadingText = LOADING;
            root.setLoadText(loadingText);
            root.startAnim();
            root.showLoadAnimView();
        }

        @Override
        public void resetLoading() {
            state = STATE_CLICK_TO_LOAD_MORE;
            loadingText = FIRST_SCREEN;
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
            enabled = enable;
            if (!enable) {
                onShowLoadView(false);
            }
        }

        @Override
        public boolean useAllSpanCountInGrid() {
            return true;
        }

        private void onOrientationChanged() {
            ViewGroup.LayoutParams p = root.getView().getLayoutParams();
            if (p == null) {
                p = new ViewGroup.LayoutParams(0,0);
            }
            if (orientation == RecyclerView.VERTICAL) {
                p.width = ViewGroup.LayoutParams.MATCH_PARENT;
                p.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            } else {
                p.width = ViewGroup.LayoutParams.WRAP_CONTENT;
                p.height = ViewGroup.LayoutParams.MATCH_PARENT;
            }
            root.getView().setLayoutParams(p);
        }
    }

}