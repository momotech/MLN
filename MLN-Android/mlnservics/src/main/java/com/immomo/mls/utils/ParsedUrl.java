/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import androidx.annotation.NonNull;

import android.text.TextUtils;
import android.webkit.URLUtil;

import static com.immomo.mls.Constants.ASSETS_PREFIX;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.RelativePathUtils;


import static com.immomo.mls.utils.MLSUtils.isLuaBytecode;
import static com.immomo.mls.utils.MLSUtils.isLuaScript;

/**
 * Created by XiongFangyu on 2018/6/27.
 */
public class ParsedUrl {
    private static final String DEFAULT_LUA_PATH = ".lua";

    public static final byte URL_TYPE_UNKNOWN = 0;
    public static final byte URL_TYPE_SCRIPT = 1;
    public static final byte URL_TYPE_BYTECODE = 1 << 1;
    public static final byte URL_TYPE_ONLINE = 1 << 2;
    public static final byte URL_TYPE_ASSETS = 1 << 3;
    public static final byte URL_TYPE_FILE = 1 << 4;

    private String oldUlr;
    private UrlParams urlParams;
    private String name;
    private String suffix;
    private String nameWithoutSuffix;

    private String urlWithoutParams;
    private byte urlType = URL_TYPE_UNKNOWN;

    public ParsedUrl(@NonNull String url) {
        setUrl(url);
    }

    public void setUrl(@NonNull String url) {
        urlType = URL_TYPE_UNKNOWN;
        oldUlr = url;
        urlParams = new UrlParams(url);
        urlWithoutParams = urlParams.getUrlWithoutParams();
        if (URLUtil.isNetworkUrl(urlWithoutParams)) {
            urlType |= URL_TYPE_ONLINE;
        } else if (isAssetsPath()) {
            urlType |= URL_TYPE_ASSETS;
        } else if (isLocalPath()) {
            urlType |= URL_TYPE_FILE;
        }
        if (isLuaScript(urlWithoutParams)) {
            urlType |= URL_TYPE_SCRIPT;
        }
        if (isLuaBytecode(urlWithoutParams)) {
            urlType |= URL_TYPE_BYTECODE;
        }
        int index = urlWithoutParams.lastIndexOf('/');
        if (index >= 0) {
            name = urlWithoutParams.substring(index + 1);
        } else {
            name = urlWithoutParams;
        }
        index = name.lastIndexOf('.');
        if (index >= 0) {
            suffix = name.substring(index + 1);
            nameWithoutSuffix = name.substring(0, index);
        } else {
            suffix = name;
            nameWithoutSuffix = name;
        }
    }

    public UrlParams getUrlParams() {
        return urlParams;
    }

    public String getUrlWithoutParams() {
        if (isAssetsType())
            return getAssetsPath();
        if (isFileType())
            return getFilePath();
        return urlWithoutParams;
    }

    public byte getUrlType() {
        return urlType;
    }

    public boolean isNetworkType() {
        return (urlType & URL_TYPE_ONLINE) == URL_TYPE_ONLINE;
    }

    private boolean isAssetsType() {
        return (urlType & URL_TYPE_ASSETS) == URL_TYPE_ASSETS;
    }

    private boolean isFileType() {
        return (urlType & URL_TYPE_FILE) == URL_TYPE_FILE;
    }

    public boolean isAssetsPath() {
        return !isNetworkType() && !isFileType() && (isAssetsType() || urlWithoutParams.startsWith(ASSETS_PREFIX));
    }

    public boolean isLocalPath() {
        if (isNetworkType() || isAssetsType())
            return false;
        if (isFileType())
            return true;
        String path = getFilePath();
        if (!TextUtils.isEmpty(path) && FileUtil.exists(path))
            return true;
        return false;
    }

    public String getAssetsPath() {
        if (!urlWithoutParams.startsWith(ASSETS_PREFIX))
            return urlWithoutParams;
        return urlWithoutParams.substring(ASSETS_PREFIX.length());
    }

    public String getFilePath() {
        String url = urlWithoutParams;
        if (RelativePathUtils.isLocalUrl(url))
            url = RelativePathUtils.getAbsoluteUrl(url);
        if (url.startsWith("/"))
            return url;
        return null;
    }

    public String getName() {
        return name;
    }

    public String getSuffix() {
        return suffix;
    }

    public String getNameWithoutSuffix() {
        return nameWithoutSuffix;
    }

    public String getEntryFile() {
        String entry = urlParams.getEntryFile();
        if (TextUtils.isEmpty(entry)) {
            entry = nameWithoutSuffix + DEFAULT_LUA_PATH;
        }
        return entry;
    }

    @Override
    public String toString() {
        return oldUlr;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ParsedUrl url = (ParsedUrl) o;
        return equals(oldUlr, url.oldUlr);
    }

    @Override
    public int hashCode() {
        return oldUlr != null ? oldUlr.hashCode() : 0;
    }

    public static boolean equals(Object a, Object b) {
        return (a == b) || (a != null && a.equals(b));
    }
}