package com.immomo.mls.wrapper;

import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019/3/19
 *
 * lua数据类型转换成java数据类型接口
 */
public interface IJavaObjectGetter<L extends LuaValue, T> {
    /**
     * 通过lua数据类型转成java数据类型
     * @param lv lua原始数据
     * @return nullable
     */
    T getJavaObject(L lv);
}
