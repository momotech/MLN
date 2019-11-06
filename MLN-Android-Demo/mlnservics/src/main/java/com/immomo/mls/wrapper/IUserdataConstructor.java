package com.immomo.mls.wrapper;


import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;

/**
 * Created by Xiong.Fangyu on 2019/3/19
 */
public interface IUserdataConstructor<L extends LuaUserdata, O> {

    L newInstance(Globals g, O obj);
}
