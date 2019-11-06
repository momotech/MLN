package com.immomo.mls.global;

import android.content.Context;

/**
 * Created by XiongFangyu on 2018/6/19.
 */

public class LVConfig {
    Context context;
    String rootDir;
    String cacheDir;
    String imageDir;
    String globalResourceDir;

    LVConfig() {
    }

    public Context getContext() {
        return context;
    }

    public String getRootDir() {
        return rootDir;
    }

    public String getCacheDir() {
        return cacheDir;
    }

    public String getImageDir() {
        return imageDir;
    }

    public String getGlobalResourceDir() {
        return globalResourceDir;
    }

    public boolean isValid() {
        return context != null && rootDir != null && cacheDir != null && imageDir != null && globalResourceDir != null;
    }
}
