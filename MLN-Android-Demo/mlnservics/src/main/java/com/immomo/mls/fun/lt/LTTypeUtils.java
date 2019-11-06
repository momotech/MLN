package com.immomo.mls.fun.lt;

import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDMap;

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
    @LuaApiUsed
    public static LuaValue[] isMap(long L, LuaValue[] o) {
        return o.length == 1 && o[0] instanceof UDMap ? LuaValue.rTrue() : LuaValue.rFalse();
    }

    @LuaApiUsed
    public static LuaValue[] isArray(long L, LuaValue[] o) {
        return o.length == 1 && o[0] instanceof UDArray ? LuaValue.rTrue() : LuaValue.rFalse();
    }
    //</editor-fold>
}
