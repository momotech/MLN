package com.mln.demo.common;

import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.ud.net.UDHttp;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-06-11
 */
@LuaClass
public class TestLazyHttp extends UDHttp {
    public TestLazyHttp(Globals globals, LuaValue[] init) {
        super(globals, init);
    }
}
