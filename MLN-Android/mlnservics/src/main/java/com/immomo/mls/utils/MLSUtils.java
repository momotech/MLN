/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.immomo.mls.Constants;
import com.immomo.mls.util.FileUtil;

import org.luaj.vm2.Globals;

import static com.immomo.mls.Constants.*;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class MLSUtils {

    public static boolean isLuaScript(String url) {
        return FileUtil.isSuffix(url, POSTFIX_LUA);
    }

    public static boolean isLuaBytecode(String url) {
        return FileUtil.isSuffix(url, POSTFIX_B_LUA);
    }

    public static String getUrlName(@NonNull String url) {
        int index = url.lastIndexOf('/');
        if (index > 0)
            url = url.substring(index + 1);
        index = url.indexOf('.');
        if (index > 0)
            url = url.substring(0, index);
        return url;
    }

    /**
     * 检查lua Arm版本，默认x32，兼容老版本。新版x64加载"64"目录下文件
     * lua打包目录结构：
     * x32: testFile/testFile.lua
     * x64: testFile/64/testFile.lua
     *
     * @param path 加载目录
     * @return 加载目录
     */
    public static String checkArm64(String path) {
        if (TextUtils.isEmpty(path) || Globals.is32bit()) {
            return path;
        }
        String nameWithPostfix = path;
        if (!path.endsWith("/")) {
            nameWithPostfix = String.format("%s/", nameWithPostfix);
        }
        nameWithPostfix = String.format("%s%s", nameWithPostfix, Constants.POSTFIX_X64);
        return nameWithPostfix;
    }
}