package com.immomo.mls.fun.java;

import android.widget.Toast;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by XiongFangyu on 2018/8/9.
 */
@LuaClass
public class JToast {
    public static final String LUA_CLASS_NAME = "Toast";

    public JToast(Globals globals, LuaValue[] init) {
        String msg = "";

        if (init[0].isString())
            msg = init[0].toJavaString();

        int d = Toast.LENGTH_SHORT;
        if (init.length > 1) {
            d = init[1].toInt();
        }
        MLSAdapterContainer.getToastAdapter().toast(msg, d);
    }
}
