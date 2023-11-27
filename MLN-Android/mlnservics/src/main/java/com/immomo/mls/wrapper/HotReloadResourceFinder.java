package com.immomo.mls.wrapper;

import com.immomo.mls.util.FileUtil;

import org.luaj.vm2.utils.ResourceFinder;
import org.luaj.vm2.utils.StringReplaceUtils;

import java.io.File;

/**
 * HotReload
 */
public class HotReloadResourceFinder implements ResourceFinder {
    private static final String LUA_SUFFIX = ".lua";
    private static final char LUA_PATH_SEPARATOR = '.';
    private static final String PARENT_PATH = "..";


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
        String rootPath = FileUtil.getCacheDir() + File.separator + "LuaHotReload" + File.separator;
        String uiPath = rootPath + "LuaToolsUI" + File.separator + "src" ;
        String utilPath = rootPath + "LuaToolUtil" + File.separator + "src";
        File uiFile = new File(uiPath, name);
        if (uiFile.isFile()) {
            return uiFile.getAbsolutePath();
        }
        File utilFile = new File(utilPath, name);
        if (utilFile.isFile()) {
            return utilFile.getAbsolutePath();
        }
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
        return "";
    }

}
