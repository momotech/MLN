package com.mln.demo.common;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.other.Point;
import com.immomo.mls.util.LogUtil;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2019-07-11
 */
@LuaClass(isStatic = true)
public class GlobalRefTest {

    private static Point p = new Point(0,0);

    @LuaBridge
    static Point getPoint() {
        LogUtil.d(Globals.globalObjectSize());
        return p;
    }
}
