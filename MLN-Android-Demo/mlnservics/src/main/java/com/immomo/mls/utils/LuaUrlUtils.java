package com.immomo.mls.utils;

import android.net.Uri;
import androidx.annotation.NonNull;

/**
 * Created by Xiong.Fangyu on 2018/11/13
 */
public class LuaUrlUtils {

    public static String getUrlName(@NonNull String url) {
        int index = url.lastIndexOf('/');
        if (index >= 0) {
            url = url.substring(index + 1);
        }
        index = url.indexOf('?');
        if (index >= 0) {
            url = url.substring(0, index);
        }
        return url;
    }

    public static String getUrlPath(String url) {
        Uri uri = Uri.parse(url);
        String host = uri.getHost();
        String path = uri.getPath();
        int index = path.lastIndexOf('.');
        if (index >= 0) {
            path = path.substring(0, index);
        }
        if (host != null) {
            if (!path.startsWith("/")) {
                return host + "/" + path;
            } else {
                return host + path;
            }
        } else {
            if (!path.startsWith("/")) {
                return path;
            }
            return path.substring(1);
        }
    }
}
