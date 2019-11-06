package com.immomo.mls.utils;

import android.graphics.Color;
import android.net.Uri;
import androidx.annotation.NonNull;

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

    private static final String TRUE = "1";

    private String urlWithoutParams;

    public UrlParams(@NonNull String url) {
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

    private static boolean isEmpty(CharSequence s) {
        return s == null || s.length() == 0;
    }

    public static boolean isInteger(String str) {
        Pattern pattern = Pattern.compile("^[-+]?[\\d]*$");
        return pattern.matcher(str).matches();
    }
}
