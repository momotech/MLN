/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import android.graphics.Color;
import android.net.Uri;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.lite.LuaClient;

import java.util.HashMap;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Created by XiongFangyu on 2018/6/27.
 */
public class UrlParams extends HashMap<String, String> {
    private static final String MAIN_INDEX_KEY = "entryFile";
    private static final String VERSION_KEY = "version";
    private static final String STATUS_BAR_COLOR = "statusBarColor";
    private static final String STATUS_BAR_STYLE = "statusBarStyle";
    private static final String PRE_LOAD = "preload";
    private static final String SHOW_LOADING = "showLoading";
    private static final String MIN_SDK_VERSION = "msv";
    public static final String LOAD_TYPE = "loadType";
    public static final String NET__TIME = "netTime";
    public static final String PREPARE_TIME = "prepareTime";
    public static final String LOAD_TIME = "loadTime";
    public static final String RENDER_TIME = "renderTime";
    public static final String LUA_VERSION_KEY = "luaVersion";
    public static final String LUA_VERSION_NUM_KEY = "luaVersionNum";
    private static final String TRUE = "1";

    private String urlWithoutParams;
    private String url;

    public UrlParams(@NonNull String url) {
        this.url=url;
        Uri uri = Uri.parse(url);
        Set<String> keys = uri.getQueryParameterNames();
        if (keys != null && !keys.isEmpty()) {
            for (String key : keys) {
                put(key, uri.getQueryParameter(key));
            }
            int index = url.indexOf('?');
            urlWithoutParams = url.substring(0, index);
        } else {
            urlWithoutParams = url;
        }
    }

    public String getEntryFile() {
        return get(MAIN_INDEX_KEY);
    }

    public void putEntryFile(String file) {
        put(MAIN_INDEX_KEY, file);
    }

    public String getVersion() {
        return get(VERSION_KEY);
    }

    public String[] getPreload() {
        String p = get(PRE_LOAD);
        if (p == null || p.length() == 0)
            return null;
        p = p.substring(1, p.length() - 1);
        return p.split(",");
    }


    public Integer getStatusBarColor() {
        String c = get(STATUS_BAR_COLOR);
        if (c == null || c.length() == 0) {
            return null;
        }
        return Color.parseColor("#" + c);
    }

    public Integer getStatusBarStyle() {
        String c = get(STATUS_BAR_STYLE);
        if (c == null || c.length() == 0 || !isInteger(c)) {
            return null;
        }
        return Integer.valueOf(c);
    }

    public int getMinSdkVersion() {
        String v = get(MIN_SDK_VERSION);
        if (v == null || v.length() == 0) {
            return -1;
        }
        return Integer.valueOf(v);
    }

    public boolean showLoading() {
        String show = get(SHOW_LOADING);
        if (isEmpty(show)) {
            return true;
        }
        return TRUE.equals(show);
    }

    public String getUrlWithoutParams() {
        return urlWithoutParams;
    }

    public String getUrl() {
        return url;
    }

    private static boolean isEmpty(CharSequence s) {
        return s == null || s.length() == 0;
    }

    public static boolean isInteger(String str) {
        Pattern pattern = Pattern.compile("^[-+]?[\\d]*$");
        return pattern.matcher(str).matches();
    }

    public String getLoadTime() {
        return get(LOAD_TIME);
    }

    public void putLoadTime(long time) {
        put(LOAD_TIME, String.valueOf(time));
    }

    public String getRenderTime() {
        return get(RENDER_TIME);
    }

    public void putRenderTime(long time) {
        put(RENDER_TIME, String.valueOf(time));
    }

    public String getPrepareTime() {
        return get(PREPARE_TIME);
    }

    public void putPrepareTime(long time) {
        put(PREPARE_TIME, String.valueOf(time));
    }


    public void increasePrepareTime(long inc) {
        String prev = get(PREPARE_TIME);
        try {
            long temp = 0;
            if (!TextUtils.isEmpty(prev)) {
                temp = Long.parseLong(prev);
            }
            temp += inc;
            putPrepareTime(temp);
        } catch (Exception e) {
            MLSAdapterContainer.getConsoleLoggerAdapter().e(LuaClient.TAG, e);
        }
    }

}