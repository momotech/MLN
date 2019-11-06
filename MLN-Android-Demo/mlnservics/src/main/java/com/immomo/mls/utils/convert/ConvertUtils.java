package com.immomo.mls.utils.convert;

import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.wrapper.Translator;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Created by XiongFangyu on 2018/7/26.
 * <p>
 * 数据类型转换工具
 *
 * @see #toNativeValue(LuaValue)
 * @see #toLuaValue(Globals, Object)
 * @see #toMap(LuaTable)
 */
public class ConvertUtils {

    public static @Nullable
    Object toNativeValue(@Nullable LuaValue value) {
        if (value == null || value.isNil())
            return null;
        if (value instanceof UDView)
            return value;
        switch (value.type()) {
            case LuaValue.LUA_TBOOLEAN:
                return value.toBoolean();
            case LuaValue.LUA_TSTRING:
                return value.toJavaString();
            case LuaValue.LUA_TNUMBER:
                double v = value.toDouble();
                if (v == (int) v)
                    return (int) v;
                if (v == (long) v)
                    return (long) v;
                return v;
            case LuaValue.LUA_TTABLE:
                return toMap(value.toLuaTable());
            case LuaValue.LUA_TUSERDATA:
            case LuaValue.LUA_TLIGHTUSERDATA:
                LuaUserdata ud = value.toUserdata();
                Object jud = ud.getJavaUserdata();
                return Translator.translateLuaToJava(ud, jud != null ? jud.getClass() : null);
        }
        return value;
    }

    public static @NonNull
    Map toMap(@NonNull LuaTable luaTable) {
        Map ret = new HashMap();
        LuaTable.Entrys entrys = luaTable.newEntry();
        LuaValue[] keys = entrys.keys();
        LuaValue[] values = entrys.values();
        int len = keys.length;
        for (int i = 0; i < len; i++) {
            ret.put(ConvertUtils.toNativeValue(keys[i]), ConvertUtils.toNativeValue(values[i]));
        }
        luaTable.destroy();
        return ret;
    }

    public static @NonNull
    List toList(@NonNull LuaTable table) {
        List ret = new ArrayList();
        LuaTable.Entrys entrys = table.newEntry();
        LuaValue[] values = entrys.values();
        for (int i = 0, l = values.length; i < l; i++) {
            ret.add(ConvertUtils.toNativeValue(values[i]));
        }
        table.destroy();
        return ret;
    }


    public static @NonNull
    LuaTable toTable(@NonNull Globals g, @NonNull Map<String, Object> map) {
        LuaTable ret = LuaTable.create(g);
        Set<Map.Entry<String, Object>> entrys = map.entrySet();
        for (Map.Entry<String, Object> e : entrys) {
            String i = e.getKey();
            Object v = e.getValue();
            if (v == null)
                ret.set(i, LuaValue.Nil());
            else if (v instanceof Number)
                ret.set(i, ((Number) v).doubleValue());
            else if (v instanceof String)
                ret.set(i, v.toString());
            else if (v instanceof Boolean)
                ret.set(i, ((Boolean) v));
            else if (v instanceof Map)
                ret.set(i, toTable(g, (Map) v));
            else if (v instanceof List)
                ret.set(i, toTable(g, (List) v));
            else
                ret.set(i, toLuaValue(g, v));
        }
        return ret;
    }

    public static @NonNull
    LuaTable toTable(@NonNull Globals g, @NonNull List list) {
        LuaTable ret = LuaTable.create(g);
        for (int i = 0, l = list.size(); i < l; i++) {
            Object v = list.get(i);
            if (v == null)
                ret.set(i, LuaValue.Nil());
            else if (v instanceof Number)
                ret.set(i, ((Number) v).doubleValue());
            else if (v instanceof String)
                ret.set(i, v.toString());
            else if (v instanceof Boolean)
                ret.set(i, ((Boolean) v));
            else if (v instanceof Map)
                ret.set(i, toTable(g, (Map) v));
            else if (v instanceof List)
                ret.set(i, toTable(g, (List) v));
            else
                ret.set(i, toLuaValue(g, v));
        }
        return ret;
    }

    public static LuaValue toLuaValue(@NonNull Globals globals, Object value) {
        LuaValue ret = Translator.isPrimitiveLuaData(value) ? Translator.translatePrimitiveToLua(value) : null;
        if (ret == null)
            ret = Translator.translateJavaToLua(globals, value);
        return ret;
    }
}
