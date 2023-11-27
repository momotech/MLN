package com.immomo.mls.adapter.impl;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.IMaybeWhiteScreenAdapter;

public class DefaultMaybeWhiteScreenAdapter implements IMaybeWhiteScreenAdapter {

    @Override
    public boolean isEnable() {
        return true;
    }

    @Override
    public int getCheckInterval() {
        return 6;
    }

    @Override
    public int getDetectTimes() {
        return 2;
    }


    @Override
    public void onMaybeListWhiteScreen(String url) {
        MLSAdapterContainer.getConsoleLoggerAdapter().i("DefaultMaybeWhiteScreenAdapter", "url: %s @timestamp:%s"
                , url, System.currentTimeMillis());
    }
}
