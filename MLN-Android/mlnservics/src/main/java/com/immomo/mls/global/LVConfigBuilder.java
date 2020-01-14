/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.global;

import android.content.Context;

import java.io.File;

/**
 * Created by XiongFangyu on 2018/6/19.
 */
public class LVConfigBuilder {
    private Context context;
    private File rootDir;
    private File cacheDir;
    private File imageDir;
    private File sdcardDir;
    private String globalResourceDir;

    public LVConfigBuilder(Context context) {
        this.context = context.getApplicationContext();
    }
    public LVConfigBuilder setRootDir(String path) {
        this.rootDir = new File(path);
        return this;
    }
    public LVConfigBuilder setCacheDir(String path) {
        this.cacheDir = new File(path);
        return this;
    }
    public LVConfigBuilder setImageDir(String path) {
        this.imageDir = new File(path);
        return this;
    }
    public LVConfigBuilder setGlobalResourceDir(String dir) {
        this.globalResourceDir = dir;
        return this;
    }
    public LVConfigBuilder setSdcardDir(String dir) {
        sdcardDir = new File(dir);
        return this;
    }

    public LVConfig build() {
        LVConfig config = new LVConfig();
        config.context = context;
        config.rootDir = rootDir;
        config.cacheDir = cacheDir;
        config.imageDir = imageDir;
        config.globalResourceDir = globalResourceDir;
        config.sdcardDir = sdcardDir;
        return config;
    }
}