package com.immomo.mls.wrapper;


import org.luaj.vm2.utils.ResourceFinder;
import org.luaj.vm2.utils.StringReplaceUtils;

import java.io.File;


public class CacheResourceFinder implements ResourceFinder {

    private final ScriptBundle scriptBundle;
    private static final String LUA_SUFFIX = ".lua";
    private static final char LUA_PATH_SEPARATOR = '.';
    private static final String PARENT_PATH = "..";
    /**
     * 需传入{@link ScriptBundle}实例
     */
    public CacheResourceFinder(ScriptBundle scriptBundle) {
        this.scriptBundle = scriptBundle;
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
        return null;
    }

    @Override
    public byte[] getContent(String name) {
        ScriptFile sf = scriptBundle.getChild(name);
        if (sf == null)
            return null;
        return sf.getSourceData();
    }

    @Override
    public void afterContentUse(String name) {
    }

    @Override
    public String getError() {
        return null;
    }
}
