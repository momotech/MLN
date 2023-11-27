package com.immomo.mls;

import java.io.File;
import java.util.Objects;

/**
 * 工程依赖工具包基本信息包装类
 */
public class LuaToolUtilInfo {
    /**
     * 工具包本地路径
     */
   private File localFile;
    /**
     * 工具包命名
     */
   private String luaToolModelName;

    public LuaToolUtilInfo(File localFile, String luaToolModelName) {
        this.localFile = localFile;
        this.luaToolModelName = luaToolModelName;
    }

    public File getLocalFile() {
        return localFile;
    }

    public void setLocalFile(File localFile) {
        this.localFile = localFile;
    }

    public String getLuaToolModelName() {
        return luaToolModelName;
    }

    public void setLuaToolModelName(String luaToolModelName) {
        this.luaToolModelName = luaToolModelName;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        LuaToolUtilInfo info = (LuaToolUtilInfo) o;
        return Objects.equals(localFile, info.localFile) && Objects.equals(luaToolModelName, info.luaToolModelName);
    }

    @Override
    public int hashCode() {
        return Objects.hash(localFile, luaToolModelName);
    }
}
