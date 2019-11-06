package com.mln.demo.common;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-06-03
 */
@LuaClass
public class LazyChild2 extends NonlazyChild {
    public LazyChild2(Globals g, LuaValue[] init) {
        super(g, init);
    }

    @LuaBridge
    public void e() {}
}
