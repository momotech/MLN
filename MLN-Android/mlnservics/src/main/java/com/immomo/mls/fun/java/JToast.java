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
        String msg = init[0].toJavaString();
        int d = Toast.LENGTH_SHORT;
        if (init.length > 1) {
            d = init[1].toInt();
        }
        MLSAdapterContainer.getToastAdapter().toast(msg, d);
    }
}