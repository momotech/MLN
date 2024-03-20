package com.immomo.mmui.databinding.interfaces;

/**
 * 所有lua动态改变的回调，回调给原生
 * Created by wang.yang on 2021/1/22.
 */
public interface ILuaCallback {
    void callback(String key, Object value);
}
