package com.immomo.mls.wrapper;

import com.immomo.mls.LuaToolUtilInfo;

import java.util.List;

/**
 * File寻找工具类路径
 */
public class FileLuaToolUtilResourceFinder extends BaseLuaToolUtilResourceFinder {
    /**
     * 传入依赖包路径以及所需依赖moudleName
     */
    public FileLuaToolUtilResourceFinder(List<LuaToolUtilInfo> luaToolUtilInfos,List<LuaToolUtilInfo> anotherInfos) {
        infoList = luaToolUtilInfos;
        anotherList = anotherInfos;
    }

}
