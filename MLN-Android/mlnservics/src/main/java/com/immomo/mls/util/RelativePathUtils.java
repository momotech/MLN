/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.util;

import android.text.TextUtils;

import com.immomo.mls.LuaViewManager;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.IGlobalsUserdata;

import java.io.File;

import static com.immomo.mls.util.FileUtil.*;

/**
 * Created by Xiong.Fangyu on 2019-11-22
 * 相对路径相关工具
 */
public class RelativePathUtils {
    /**
     * 本地相对路径scheme
     */
    private static final String LOCAL_SCHEME = "file://";
    /**
     * 表示路径是以lua包为根目录的相对路径
     */
    private static final String PACKET_SCHEME = "packet://";
    /**
     * 表示路径以工程资源文件夹（assets/或res资源）为根目录的相对路径
     */
    private static final String ASSET_SCHEME = "assets://";

    private RelativePathUtils() {}

    //<editor-fold desc="本地相对路径">
    /**
     * 是否是相对路径
     * @param url
     * @return
     */
    public static boolean isLocalUrl(String url) {
        return url.startsWith(LOCAL_SCHEME);
    }

    /**
     * 将相对路径转换成绝对路径
     * @param url
     * @return
     */
    public static String getAbsoluteUrl(String url) {
        File root = getRootDir();
        if (root == null)
            return null;
        String rootPath = root.getAbsolutePath();
        if (TextUtils.isEmpty(rootPath))
            return null;
        url = getUrlPath(url);
        File file = new File(rootPath, url);
        return file.getAbsolutePath();
    }

    /**
     * 将绝对路径转换为相对路径
     * @param absoluteUrl
     * @return
     */
    public static String getLocalUrl(String absoluteUrl) {
        if (absoluteUrl == null || !absoluteUrl.startsWith("/"))
            return absoluteUrl;
        File root = getRootDir();
        if (root == null)
            return absoluteUrl;
        String rootPath = root.getAbsolutePath();
        if (TextUtils.isEmpty(rootPath))
            return absoluteUrl;
        if (!absoluteUrl.startsWith(rootPath))
            return absoluteUrl;
        String url = absoluteUrl.replace(rootPath, "").substring(1);
        return LOCAL_SCHEME + url;
    }
    
    //</editor-fold>

    //<editor-fold desc="lua包相对路径">

    /**
     * url是否为包相对路径
     */
    public static boolean isPacketUrl(String url) {
        return url.startsWith(PACKET_SCHEME);
    }

    /**
     * 通过包相对路径获取绝对路径
     * @param packetPath 包路径
     * @param url        相对路径
     */
    public static String getAbsolutePacketUrl(String packetPath, String url) {
        if (!packetPath.endsWith(File.separator)) {
            return packetPath + File.separator + getUrlPath(url);
        }
        return packetPath + getUrlPath(url);
    }

    /**
     * 通过包相对路径获取绝对路径
     * @param g   虚拟机
     * @param url 相对路径
     */
    public static String getAbsolutePacketUrl(Globals g, String url) {
        IGlobalsUserdata u = g.getJavaUserdata();
        final LuaViewManager m;
        if (u instanceof LuaViewManager) {
            m = (LuaViewManager) u;
        } else {
            m = null;
        }
        if (m == null)
            return getUrlPath(url);
        return getAbsolutePacketUrl(m.baseFilePath, url);
    }

    /**
     * 通过绝对路径，获取包相对路径
     * @param packetPath 包路径
     * @param abUrl      绝对路径
     */
    public static String getLocalPacketUrl(String packetPath, String abUrl) {
        if (!packetPath.endsWith(File.separator)) {
            packetPath = packetPath + File.separator;
        }
        if (!abUrl.startsWith(packetPath)) {
            return abUrl;
        }
        return PACKET_SCHEME + abUrl.replace(packetPath, "");
    }

    /**
     * 通过绝对路径，获取包相对路径
     * @param g 虚拟机
     * @param abUrl 绝对路径
     */
    public static String getLocalPacketUrl(Globals g, String abUrl) {
        IGlobalsUserdata u = g.getJavaUserdata();
        final LuaViewManager m;
        if (u instanceof LuaViewManager) {
            m = (LuaViewManager) u;
        } else {
            m = null;
        }
        if (m == null)
            return abUrl;
        return getLocalPacketUrl(m.baseFilePath, abUrl);
    }
    //</editor-fold>

    //<editor-fold desc="Asset相对路径">

    /**
     * url是否为工程相对路径
     */
    public static boolean isAssetUrl(String url) {
        return url.startsWith(ASSET_SCHEME);
    }

    /**
     * 获取assets路径，只是把scheme去掉
     */
    public static String getAbsoluteAssetUrl(String url) {
        return url.substring(ASSET_SCHEME.length());
    }

    //</editor-fold>

    private static String getUrlPath(String url) {
        int index = url.indexOf("://") + 3;
        return url.substring(index);
    }
}
