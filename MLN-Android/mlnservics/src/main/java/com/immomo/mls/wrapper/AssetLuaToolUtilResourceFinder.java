package com.immomo.mls.wrapper;

import com.immomo.mls.LuaToolUtilInfo;

import java.util.List;

/**
 * 资产目录寻找工具类路径
 */
public class AssetLuaToolUtilResourceFinder extends BaseLuaToolUtilResourceFinder {


    /**
     * 传入兜底包路径以及所需依赖moudleName
     */
    public AssetLuaToolUtilResourceFinder(List<LuaToolUtilInfo> luaToolUtilInfos,List<LuaToolUtilInfo> anotherInfos) {
        infoList = luaToolUtilInfos;
        anotherList = anotherInfos;
    }

}
