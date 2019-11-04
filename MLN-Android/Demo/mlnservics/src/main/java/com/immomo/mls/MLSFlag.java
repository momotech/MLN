package com.immomo.mls;

import android.graphics.Color;

import com.immomo.mls.util.DimenUtil;

/**
 * Created by XiongFangyu on 2018/7/11.
 */
public class MLSFlag {
    private static int refreshColor = Color.BLACK;
    private static boolean refreshScale = true;
    private static int refreshEndPx = DimenUtil.dpiToPx(64);

    public static int getRefreshColor() {
        return refreshColor;
    }

    public static void setRefreshColor(int refreshColor) {
        MLSFlag.refreshColor = refreshColor;
    }

    public static boolean isRefreshScale() {
        return refreshScale;
    }

    public static void setRefreshScale(boolean refreshScale) {
        MLSFlag.refreshScale = refreshScale;
    }

    public static int getRefreshEndPx() {
        return refreshEndPx;
    }

    public static void setRefreshEndPx(int refreshEndPx) {
        MLSFlag.refreshEndPx = refreshEndPx;
    }
}
