/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDMap;

import com.immomo.mls.fun.ud.view.UDTabLayout;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by XiongFangyu on 2018/9/19.
 */
@LuaApiUsed
public class LTTypeUtils {
    public static final String LUA_CLASS_NAME = "TypeUtils";
    public static final String[] methods = {
            "isMap", "isArray"
    };

    //<editor-fold desc="API">
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(LuaValue.class)
            }, returns = @LuaApiUsed.Type(LTTypeUtils.class))
    })
    public static LuaValue[] isMap(long L, LuaValue[] o) {
        return o.length == 1 && o[0] instanceof UDMap ? LuaValue.rTrue() : LuaValue.rFalse();
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(LuaValue.class)
            }, returns = @LuaApiUsed.Type(LTTypeUtils.class))
    })
    public static LuaValue[] isArray(long L, LuaValue[] o) {
        return o.length == 1 && o[0] instanceof UDArray ? LuaValue.rTrue() : LuaValue.rFalse();
    }
    //</editor-fold>
}