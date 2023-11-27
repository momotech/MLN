/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.java;

import android.widget.Toast;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by XiongFangyu on 2018/8/9.
 */
@LuaClass
public class JToast {
    public static final String LUA_CLASS_NAME = "Toast";
    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type( value = String.class),
            })
    })
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