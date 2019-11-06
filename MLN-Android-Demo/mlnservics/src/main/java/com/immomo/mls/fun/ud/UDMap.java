package com.immomo.mls.fun.ud;

import androidx.collection.ArrayMap;

import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.ILuaValueGetter;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/7/31.
 * <p>
 * native存储native对象，lua get时转换成lua对象
 */
@LuaApiUsed
public class UDMap extends LuaUserdata {
    public static final String LUA_CLASS_NAME = "Map";
    public static final String[] methods = new String[]{
            "put",
            "putAll",
            "remove",
            "removeAll",
            "get",
            "size",
            "allKeys",
            "removeObjects",
    };
    private final Map map;

    public static final ILuaValueGetter<UDMap, Map> G = new ILuaValueGetter<UDMap, Map>() {
        @Override
        public UDMap newInstance(Globals g, Map obj) {
            return new UDMap(g, obj);
        }
    };

    public static final IJavaObjectGetter<LuaValue, Map> J = new IJavaObjectGetter<LuaValue, Map>() {
        @Override
        public Map getJavaObject(LuaValue lv) {
            if (lv.isTable())
                return ConvertUtils.toMap((LuaTable) lv);

            return ((UDMap) lv).getMap();
        }
    };

    @LuaApiUsed
    protected UDMap(long L, LuaValue[] v) {
        super(L, v);
        int init = 10;
        if (v != null && v.length >= 1) {
            if (v[0].isNumber()) {
                init = v[0].toInt();
            }
        }
        map = new HashMap(init);
        javaUserdata = map;
    }

    public UDMap(Globals g, Object jud) {
        super(g, jud);
        if (jud == null) {
            map = new ArrayMap(0);
        } else {
            map = (Map) jud;
        }
        javaUserdata = map;
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] put(LuaValue[] var) {
        LuaValue key = var[0], value = var[1];
        map.put(ConvertUtils.toNativeValue(key), ConvertUtils.toNativeValue(value));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] putAll(LuaValue[] var) {
        UDMap map = (UDMap) var[0];
        this.map.putAll(map.map);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] remove(LuaValue[] var) {
        LuaValue key = var[0];
        map.remove(ConvertUtils.toNativeValue(key));
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeAll(LuaValue[] v) {
        map.clear();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] get(LuaValue[] var) {
        LuaValue key = var[0];
        LuaValue ret = ConvertUtils.toLuaValue(getGlobals(), map.get(ConvertUtils.toNativeValue(key)));
        return varargsOf(ret);
    }

    @LuaApiUsed
    public LuaValue[] size(LuaValue[] v) {
        return varargsOf(LuaNumber.valueOf(map.size()));
    }

    @LuaApiUsed
    public LuaValue[] allKeys(LuaValue[] v) {
        return varargsOf(new UDArray(getGlobals(), map.keySet()));
    }

    @LuaApiUsed
    public LuaValue[] removeObjects(LuaValue[] v) {
        UDArray array = v.length > 0 ? (UDArray) v[0].toUserdata() : null;
        List list = array != null ? array.getArray() : null;
        if (list != null) {
            for (Object key :
                    list) {
                map.remove(key);
            }
        }
        return null;
    }
    //</editor-fold>

    @LuaApiUsed
    @Override
    public String toString() {
        return map.toString();
    }
    //</editor-fold>

    public Map getMap() {
        return map;
    }
}
