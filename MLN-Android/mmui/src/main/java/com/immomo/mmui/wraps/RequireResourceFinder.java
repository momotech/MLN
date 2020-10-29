/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.wraps;

import android.content.Context;
import android.text.TextUtils;

import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.IOUtil;

import org.luaj.vm2.utils.ResourceFinder;
import org.luaj.vm2.utils.StringReplaceUtils;

import java.io.File;
import java.io.InputStream;

/**
 * Description: require资源路径查找器
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020/9/23 下午2:05
 */
public class RequireResourceFinder implements ResourceFinder {
    private String rootPath;
    private String errorMsg;
    private final Context context;

    public RequireResourceFinder(Context context,String rootPath) {
        this.rootPath = rootPath;
        this.context = context.getApplicationContext();
    }

    @Override
    public String preCompress(String name) {
        if (name.endsWith(".lua"))
            name = name.substring(0, name.length() - 4);
        if (!name.contains(".."))
            return StringReplaceUtils.replaceAllChar(name, '.', File.separatorChar) + ".lua";
        return FileUtil.dealRelativePath("", name + ".lua");
    }

    @Override
    public String findPath(String name) {
        return null;
    }

    @Override
    public byte[] getContent(String name) {
        errorMsg = null;
        InputStream is = null;
        try {
            String filePath = !TextUtils.isEmpty(rootPath) ? rootPath + File.separator + name : name;
            is = context.getAssets().open(filePath);
            byte[] data = new byte[is.available()];
            if (is.read(data) == data.length)
                return data;
        } catch (Throwable e) {
            errorMsg = "ARF: " + e.toString();
        } finally {
            IOUtil.closeQuietly(is);
        }
        return null;
    }

    @Override
    public String getError() {
        return errorMsg;
    }

    @Override
    public void afterContentUse(String name) {

    }
}
