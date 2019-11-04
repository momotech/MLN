package com.immomo.mls.weight.load;

import android.view.View;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/6/25.
 */
public interface ILoadViewDelegete {

    @NonNull <T extends View & ILoadWithTextView> T getLoadView();

    boolean onShowLoadView(boolean byClick);

    boolean canCallback();

    boolean canShowFoot();

    void resetLoading();

    void startLoading();

    void noMoreData();

    void loadError();

    void setEnable(boolean enable);

    boolean useAllSpanCountInGrid();

    int getCurrentState();
}
