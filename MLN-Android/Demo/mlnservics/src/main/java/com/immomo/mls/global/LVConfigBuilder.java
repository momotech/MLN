package com.immomo.mls.global;

import android.content.Context;

/**
 * Created by XiongFangyu on 2018/6/19.
 */
public class LVConfigBuilder {
    private Context context;
    private String rootDir;
    private String cacheDir;
    private String imageDir;
    private String globalResourceDir;

    public LVConfigBuilder(Context context) {
        this.context = context.getApplicationContext();
    }
    public LVConfigBuilder setRootDir(String path) {
        this.rootDir = path;
        return this;
    }
    public LVConfigBuilder setCacheDir(String path) {
        this.cacheDir = path;
        return this;
    }
    public LVConfigBuilder setImageDir(String path) {
        this.imageDir = path;
        return this;
    }
    public LVConfigBuilder setGlobalResourceDir(String dir) {
        this.globalResourceDir = dir;
        return this;
    }
    public LVConfig build() {
        LVConfig config = new LVConfig();
        config.context = context;
        config.rootDir = rootDir;
        config.cacheDir = cacheDir;
        config.imageDir = imageDir;
        config.globalResourceDir = globalResourceDir;
        return config;
    }
}
