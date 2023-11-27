package com.immomo.mls.adapter;

import android.util.Pair;

import com.immomo.mls.LuaToolUtilInfo;

import java.io.File;
import java.util.List;

/**
 *
 * 查找依赖工具类
 */
public interface LuaToolFinder {
    /**
     *
     * @param file 工程入口文件地址
     * @return  返回值第一个为正常依赖包信息  返回值第二个为兜底包信息
     *
     */
    Pair<List<LuaToolUtilInfo>, List<LuaToolUtilInfo>> getLuaToolFile(File file);
}
