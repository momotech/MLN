package com.immomo.mls.wrapper;

import android.text.TextUtils;

import com.immomo.mls.LuaToolUtilInfo;

import org.luaj.vm2.utils.ResourceFinder;
import org.luaj.vm2.utils.StringReplaceUtils;

import java.io.File;
import java.util.List;

/**
 * 寻找工具类路径
 */
public class BaseLuaToolUtilResourceFinder implements ResourceFinder {
    private static final String LUA_SUFFIX = ".lua";
    private static final char LUA_PATH_SEPARATOR = '.';
    private static final String PARENT_PATH = "..";
    private static final String SRC_SEPARATOR = "src/";
    private static final String LUA_UI = "LuaToolsUI";
    private static final String LUA_UTIL = "LuaToolUtil";


    protected List<LuaToolUtilInfo> infoList;
    protected List<LuaToolUtilInfo> anotherList;
    private String errorMsg;


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
        errorMsg = "";
        if (infoList != null) {
            for (LuaToolUtilInfo info : infoList) {
                if (name.startsWith(LUA_UI) || name.startsWith(LUA_UTIL)) {
                    if (!name.startsWith(info.getLuaToolModelName())) {
                        continue;
                    }
                }
                if (name.startsWith(info.getLuaToolModelName())) {
                    name = name.substring(name.lastIndexOf(SRC_SEPARATOR) + 4);
                }
                File f = new File(info.getLocalFile(), name);
                if (f.isFile()) {
                    errorMsg = "";
                    return f.getAbsolutePath();
                }
                if (TextUtils.isEmpty(errorMsg)) {
                    errorMsg = f.getAbsolutePath() + "路径不存在 ";
                }else {
                    errorMsg = errorMsg + "同时" +  f.getAbsolutePath() + "路径也不存在 ";
                }
            }
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
        String message = "";
        if (!TextUtils.isEmpty(errorMsg)) {
            StringBuilder sb = new StringBuilder();
            if (infoList != null) {
                for (LuaToolUtilInfo info : infoList) {
                    int size = 0;
                    String name = info.getLuaToolModelName();
                    File localFile = info.getLocalFile();
                    if (localFile != null && localFile.exists()) {
                        int count = 0;
                        File[] files = localFile.listFiles();
                        if (files != null) {
                            for (File file1:files){
                                if (file1.isFile() && file1.getName().endsWith(".lua")) {
                                    count++;
                                }
                            }
                            size = count;
                        }else {
                            size = -1;
                        }
                    }else {
                        size = -2;
                    }
                    sb.append(" currentListSizeIs ");
                    sb.append(infoList.size());
                    sb.append(" anotherListSizeIs ");
                    sb.append(anotherList != null?anotherList.size():"anotherListIsNull ");
                    sb.append(" moduleNameIs ");
                    sb.append(name);
                    sb.append(" localFileSizeIs ");
                    sb.append(size);
                }
            }
            message = errorMsg + sb.toString();
        }
        return message ;
    }

}
