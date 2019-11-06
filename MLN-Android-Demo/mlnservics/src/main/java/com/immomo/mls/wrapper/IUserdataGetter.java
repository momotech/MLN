package com.immomo.mls.wrapper;


import org.luaj.vm2.LuaUserdata;

/**
 * Created by Xiong.Fangyu on 2019/3/19
 */
public interface IUserdataGetter<L extends LuaUserdata, T> {

    T getJavaUserdata(L luserdata);
}
