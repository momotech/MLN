package com.immomo.mls.utils;

import com.immomo.mls.MLSConfigs;

/**
 * Created by Xiong.Fangyu on 2018/11/5
 */
public class ClickEventLimiter {

    private long lastEventTime = 0;
    private long minEventLimit = MLSConfigs.defaultClickEventTimeLimit;

    public boolean canDoClick() {
        if (minEventLimit <= 0)
            return true;
        long now = now();
        long duration = now - lastEventTime;
        if (duration >= minEventLimit || duration < 0) {
            lastEventTime = now;
            return true;
        }
        return false;
    }

    public void setMinEventLimit(long limit) {
        minEventLimit = limit;
    }

    private long now() {
        return System.currentTimeMillis();
    }
}
