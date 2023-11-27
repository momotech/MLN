/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper.callback;

import com.immomo.mls.wrapper.Translator;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019/3/21
 */
class Utils {

    static void check(LuaFunction luaFunction) {
        if (luaFunction == null || luaFunction.isDestroyed()) {
            throw new IllegalStateException("lua function is destroyed.");
        }
    }

    static LuaValue[] invoke(LuaFunction luaFunction, Object... params) {
        final int len = params == null ? 0 : params.length;
        if (len == 0) {
            return luaFunction.invoke(null);
        }
        if (params.getClass() == LuaValue[].class) {
            return luaFunction.invoke((LuaValue[]) params);
        }
        LuaValue[] p = new LuaValue[len];
        Globals globals = luaFunction.getGlobals();
        Translator t = Translator.fromGlobals(globals);
        for (int i = 0; i < len; i++) {
            Object pn = params[i];
            if (pn == null) {
                p[i] = LuaValue.Nil();
                continue;
            }
            if (pn instanceof LuaValue) {
                p[i] = (LuaValue) pn;
                continue;
            }
            if (Translator.isPrimitiveLuaData(pn)) {
                p[i] = Translator.translatePrimitiveToLua(pn);
                continue;
            }
            if (t != null)
                p[i] = t.translateJavaToLua(globals, params[i]);
        }
        return luaFunction.invoke(p);
    }
}