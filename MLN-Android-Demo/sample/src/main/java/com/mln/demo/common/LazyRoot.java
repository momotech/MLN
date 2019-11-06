package com.mln.demo.common;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.util.LogUtil;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-06-03
 */
@LuaClass
public class LazyRoot {

    public LazyRoot(Globals g, LuaValue[] init) {}

    @LuaBridge
    public void a() {
        LogUtil.d("root a called");
    }

    @LuaBridge
    public void b() {

    }
}
