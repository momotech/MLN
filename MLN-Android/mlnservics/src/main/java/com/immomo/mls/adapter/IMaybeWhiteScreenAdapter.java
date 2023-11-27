package com.immomo.mls.adapter;

import androidx.annotation.MainThread;

public interface IMaybeWhiteScreenAdapter {
    boolean isEnable();
    /**
     * @return second
     */
    int getCheckInterval();

    /**
     *
     * @return 检查次数
     */
    int getDetectTimes();

    @MainThread
    void onMaybeListWhiteScreen(String json);

}
