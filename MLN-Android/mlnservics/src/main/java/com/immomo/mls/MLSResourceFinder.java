/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.IOUtil;
import com.immomo.mls.utils.LuaUrlUtils;
import com.immomo.mls.utils.ParsedUrl;

import org.luaj.vm2.utils.ResourceFinder;
import org.luaj.vm2.utils.StringReplaceUtils;

import java.io.File;
import java.io.InputStream;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
public class MLSResourceFinder implements ResourceFinder {
    protected String path;
    protected String assetsPath;
    protected String src;
    protected ParsedUrl parsedUrl;
    protected final StringBuilder errorMsg;

    public MLSResourceFinder(String src, ParsedUrl url) {
        this.src = src;
        this.parsedUrl = url;
        path = LuaUrlUtils.getUrlPath(url.getUrlWithoutParams());
        errorMsg = new StringBuilder();
        if (!path.endsWith(File.separator)) {
            path += File.separator;
        }
        if (url.isAssetsPath()) {
            assetsPath = url.getAssetsPath();
            int index = assetsPath.lastIndexOf(File.separator);
            if (index >= 0) {
                String n = assetsPath.substring(index + 1);
                if (n.indexOf('.') > 0) {
                    assetsPath = assetsPath.substring(0, index + 1);
                }
            }
        }
    }

    protected byte[] getAssetsData(String name) {
        if (assetsPath == null) {
            errorMsg.append("\tAnd ").append("assetsPath is null.");
            return null;
        }
        InputStream is = null;
        try {
            is = MLSEngine.getContext().getAssets().open(FileUtil.dealRelativePath(assetsPath, name));
            byte[] data = new byte[is.available()];
            if (is.read(data) == data.length)
                return data;
        } catch (Throwable t) {
            errorMsg.append("\tAnd ").append(t.toString());
        } finally {
            IOUtil.closeQuietly(is);
        }
        return null;
    }

    @Override
    public String preCompress(String name) {
        if (name.endsWith(".lua"))
            name = name.substring(0, name.length() - 4);
        if (!name.contains(".."))
            return StringReplaceUtils.replaceAllChar(name, '.', File.separatorChar) + ".lua";
        return name + ".lua";
    }

    @Override
    public String findPath(String name) {
        name = path + name;
        File f = new File(name);
        if (f.exists()) {
            return name;
        } else {
            errorMsg.append("file ").append(name).append(" not exists.");
        }
        return null;
    }

    @Override
    public byte[] getContent(String name) {
        return getAssetsData(name);
    }

    @Override
    public void afterContentUse(String name) {

    }

    @Override
    public String getError() {
        if (errorMsg.length() == 0)
            return null;
        return "MLSRF: " + errorMsg.toString();
    }
}