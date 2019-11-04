package org.luaj.vm2.utils;

import java.io.File;

/**
 * Created by Xiong.Fangyu on 2019/3/20
 *
 * 寻找存在的文件绝对路径
 */
public class PathResourceFinder implements ResourceFinder {
    private static final String LUA_SUFFIX          = ".lua";
    private static final String LUA_BINSP           = "b";
    private static final String LUA_PATH_SEPARATOR  = "\\.";
    private static final String PARENT_PATH         = "..";

    private final String basePath;

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
            return name.replaceAll(LUA_PATH_SEPARATOR, File.separator) + LUA_SUFFIX;
        return name + LUA_SUFFIX;
    }

    @Override
    public String findPath(String name) {
        File f = new File(basePath, name + LUA_BINSP);
        if (f.isFile())
            return f.getAbsolutePath();
        f = new File(basePath, name);
        if (f.isFile())
            return f.getAbsolutePath();
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
