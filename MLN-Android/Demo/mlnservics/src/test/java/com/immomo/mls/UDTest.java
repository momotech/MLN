package com.immomo.mls;

import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-06-20
 */
public class UDTest extends LuaUserdata {

    protected UDTest(long L, LuaValue[] v) {
        super(L, v);
    }

    public LuaValue[] test(LuaValue[] v) {
        Log.i("in java test");
        return null;
    }
}
