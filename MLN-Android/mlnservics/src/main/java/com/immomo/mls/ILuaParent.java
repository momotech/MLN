package com.immomo.mls;

/**
 * Created by Xiong.Fangyu on 2021/1/14
 */
public interface ILuaParent {
    void add(String url, ILuaLifeCycle child);
    void remove(String url);
    void setHotReloadImediately(boolean im);
}
