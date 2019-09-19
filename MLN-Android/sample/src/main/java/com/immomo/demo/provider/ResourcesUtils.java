/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo.provider;

import android.content.res.Resources;
import android.text.TextUtils;

import androidx.collection.LruCache;

import com.immomo.demo.App;

/**
 * Created by XiongFangyu on 2018/8/9.
 */

public class ResourcesUtils {

    public static final String NINE_PATCH_PNG = ".9.png";
    public static final String NORMAL_PNG = ".png";

    private static final LruCache<String, Integer> IdCache = new LruCache<>(50);

    public static enum TYPE {
        DRAWABLE("drawable"),
        ID("id"),
        DIMEN("dimen"),
        RAW("raw"),;

        private String s;

        TYPE(String s) {
            this.s = s;
        }

        @Override
        public String toString() {
            return s;
        }
    }

    public static int getResourceIdByUrl(String url, String suffix, TYPE type) {
        if (TextUtils.isEmpty(url) || type == null)
            return -1;
        String key = url + type.toString();
        Integer result = IdCache.get(key);
        if (result != null)
            return result;
        int start = url.lastIndexOf('/');
        int end = TextUtils.isEmpty(suffix) ? url.length() : url.lastIndexOf(suffix);
        if ((start < 0 && end < 0) || (end <= start)) {
            IdCache.put(key, -1);
            return -1;
        }
        String name = url.substring(start + 1, end);
        if (TextUtils.isEmpty(name)) {
            IdCache.put(key, -1);
            return -1;
        }
        int id = getResourceIdByName(name, type);
        IdCache.put(key, id);
        return id;
    }

    public static int getResourceIdByName(String name, TYPE type) {
        return getResources().getIdentifier(name, type.toString(), App.getPackageNameImpl());
    }

    public static int getPngResourceIdByUrl(String url) {
        return getResourceIdByUrl(url, NORMAL_PNG, TYPE.DRAWABLE);
    }

    public static int getNinePatchResourceIdByUrl(String url) {
        return getResourceIdByUrl(url, NINE_PATCH_PNG, TYPE.DRAWABLE);
    }

    public static Resources getResources() {
        return App.getApp().getResources();
    }
}