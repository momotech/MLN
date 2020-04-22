package com.immomo.mls.adapter;

/**
 * Created by Xiong.Fangyu on 2020-01-16
 */
public interface IFileCache {

    void save(String key, String value);

    String get(String key, String defaultValue);

}
