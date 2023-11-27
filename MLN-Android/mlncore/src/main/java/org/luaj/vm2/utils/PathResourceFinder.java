/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

import java.io.File;

/**
 * Created by Xiong.Fangyu on 2019/3/20
 * <p>
 * 寻找存在的文件绝对路径
 */
public class PathResourceFinder implements ResourceFinder {
    private static final String LUA_SUFFIX = ".lua";
    private static final char LUA_PATH_SEPARATOR = '.';
    private static final String PARENT_PATH = "..";

    private final String basePath;
    private String errorMsg;

    /**
     * 需要传入根目录
     */
    public PathResourceFinder(String basePath) {
        this.basePath = basePath;
    }

    @Override
    public String preCompress(String name) {
        if (name.endsWith(LUA_SUFFIX))
            name = name.substring(0, name.length() - 4);
        if (!name.contains(PARENT_PATH))
            return StringReplaceUtils.replaceAllChar(name, LUA_PATH_SEPARATOR, File.separatorChar) + LUA_SUFFIX;
        return name + LUA_SUFFIX;
    }

    @Override
    public String findPath(String name) {
        errorMsg = null;
        File f = new File(basePath, name);
        if (f.isFile())
            return f.getAbsolutePath();
        errorMsg = "PRF: " + f.getAbsolutePath() + "不是文件,";
        try {
            errorMsg += "文件是否存在：" + f.exists() + "文件是否可读：" + f.canRead();
        } catch (Exception ignore) { }
        return null;
    }

    @Override
    public byte[] getContent(String name) {
        return null;
    }

    @Override
    public void afterContentUse(String name) {

    }

    @Override
    public String getError() {
        return errorMsg;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PathResourceFinder that = (PathResourceFinder) o;
        return basePath.equals(that.basePath);
    }

    @Override
    public int hashCode() {
        return basePath.hashCode();
    }
}