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

public class LVConfig {
    Context context;
    File sdcardDir;
    File rootDir;
    File cacheDir;
    File imageDir;
    String globalResourceDir;

    LVConfig() {
    }

    public Context getContext() {
        return context;
    }

    public File getSdcardDir() {
        return sdcardDir;
    }

    public File getRootDir() {
        return rootDir;
    }

    public File getCacheDir() {
        return cacheDir;
    }

    public File getImageDir() {
        return imageDir;
    }

    public String getGlobalResourceDir() {
        return globalResourceDir;
    }

    public boolean isValid() {
        return context != null && rootDir != null && cacheDir != null && imageDir != null && globalResourceDir != null;
    }
}