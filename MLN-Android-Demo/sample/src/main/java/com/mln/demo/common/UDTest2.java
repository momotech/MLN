package com.mln.demo.common;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.util.LogUtil;

/**
 * Created by Xiong.Fangyu on 2019/4/15
 */
@LuaClass
public class UDTest2 {

//    public UDTest2(Globals g, LuaValue[] i) {
//        LogUtil.e("2 test!!!!!");
//    }

//    public UDTest2(Globals g) {}

//    public UDTest2(LuaValue[] v) {}

//    public UDTest2() {}

    @LuaBridge
    public void t() {
        LogUtil.e("tttttt");

    }
}
