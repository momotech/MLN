package com.mln.demo.common;


import com.immomo.mls.util.LogUtil;

import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2019-07-01
 */
@LuaApiUsed
public class JavaClassTest {

    public int aInt;

    public float aFloat;

    public static void init() {
        LogUtil.d("init");
    }

    public static int getInt() {
        return 1;
    }

    public static void doSomeThing(String s) {
        LogUtil.i(s);
    }
}
