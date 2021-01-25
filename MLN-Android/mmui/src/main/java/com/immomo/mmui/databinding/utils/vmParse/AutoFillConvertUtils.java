package com.immomo.mmui.databinding.utils.vmParse;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.wrapper.Translator;
import com.immomo.mmui.databinding.bean.MMUIColor;
import com.immomo.mmui.databinding.bean.ObservableField;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;
import com.immomo.mmui.ud.UDColor;
import com.immomo.mmui.ud.UDView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.DisposableIterator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Description: DataBinding java 和 lua 数据结构转化规则； 转换规则和以前的DataBinding有区别，因此重写
 * Author: wang.yang
 * Date: 2020-08-24 14:52
 */
public class AutoFillConvertUtils {

    private static final String COLLECTION_TYPE = "collectionType";
    private static final int ARRAY_TYPE = 2;
    private static final int MAP_TYPE = 1;

    /**
     * LTDataBinding.get()返回的数据转换
     * 与普通数据返回有区别
     * 1.Map,List返回LuaTable
     * 2.CustomColor返回UDColor
     * 3.剩余按之前规则处理
     *
     * @param globals
     * @param value
     * @return
     */
    public static LuaValue toLuaValue(@NonNull Globals globals, Object value) {
        //基本数据转换
        if (value instanceof Boolean) {
            return ((boolean) value) ? LuaValue.True() : LuaValue.False();
        }

        if (value instanceof Number) {
            return LuaNumber.valueOf(((Number) value).doubleValue());
        }

        if (value instanceof Character) {
            return LuaNumber.valueOf((Character) value);
        }

        if (value instanceof String) {
            return LuaString.valueOf(value.toString());
        }

        if (value instanceof MMUIColor) {
            return new UDColor(globals, (MMUIColor) value);
        }

        if (value instanceof ObservableMap) {
            //noinspection unchecked
            return toTable(globals, (ObservableMap) value);
        }

        if (value instanceof ObservableList) {
            return toTable(globals, (ObservableList) value);
        }

        if (value instanceof ObservableField) {
            return toTable(globals, (ObservableMap) ((ObservableField) value).getFields());
        }

        return ConvertUtils.toLuaValue(globals, value);
    }


    /**
     * Map转table
     *
     * @param g
     * @param map
     * @return
     */
    public static @NonNull
    LuaTable toTable(@NonNull Globals g, @NonNull ObservableMap<Object, Object> map) {
        LuaTable ret = LuaTable.create(g);
        LuaTable metatalbe = LuaTable.create(g);
        metatalbe.set(COLLECTION_TYPE, MAP_TYPE);
        ret.setMetatalbe(metatalbe);
        Set<Map.Entry<Object, Object>> entrys = map.entrySet();
        for (Map.Entry<Object, Object> e : entrys) {
            Object v = e.getValue();
            Object i = e.getKey();
            if (i instanceof Integer) {
                if (v == null)
                    ret.set((Integer) i, LuaValue.Nil());
                else if (v instanceof Number)
                    ret.set((Integer) i, ((Number) v).doubleValue());
                else if (v instanceof String)
                    ret.set((Integer) i, v.toString());
                else if (v instanceof Boolean)
                    ret.set((Integer) i, ((Boolean) v));
                else if (v instanceof Map)
                    ret.set((Integer) i, toTable(g, (ObservableMap) v));
                else if (v instanceof List)
                    ret.set((Integer) i, toTable(g, (ObservableList) v));
                else
                    ret.set((Integer) i, toLuaValue(g, v));
            }
            if (i instanceof String) {
                if (v == null)
                    ret.set((String) i, LuaValue.Nil());
                else if (v instanceof Number)
                    ret.set((String) i, ((Number) v).doubleValue());
                else if (v instanceof String)
                    ret.set((String) i, v.toString());
                else if (v instanceof Boolean)
                    ret.set((String) i, ((Boolean) v));
                else if (v instanceof Map)
                    ret.set((String) i, toTable(g, (ObservableMap) v));
                else if (v instanceof List)
                    ret.set((String) i, toTable(g, (ObservableList) v));
                else
                    ret.set((String) i, toLuaValue(g, v));
            }
        }
        return ret;
    }


    /**
     * list转table
     *
     * @param g
     * @param list
     * @return
     */
    public static @NonNull
    LuaTable toTable(@NonNull Globals g, @NonNull ObservableList list) {
        LuaTable ret = LuaTable.create(g);
        LuaTable metatalbe = LuaTable.create(g);
        metatalbe.set(COLLECTION_TYPE, ARRAY_TYPE);
        ret.setMetatalbe(metatalbe);
        for (int i = 0, l = list.size(); i < l; i++) {
            Object v = list.get(i);
            if (v == null)
                ret.set(i + 1, LuaValue.Nil());
            else if (v instanceof Number)
                ret.set(i + 1, ((Number) v).doubleValue());
            else if (v instanceof String)
                ret.set(i + 1, v.toString());
            else if (v instanceof Boolean)
                ret.set(i + 1, ((Boolean) v));
            else if (v instanceof Map)
                ret.set(i + 1, toTable(g, (ObservableMap) v));
            else if (v instanceof List)
                ret.set(i + 1, toTable(g, (ObservableList) v));
            else
                ret.set(i + 1, toLuaValue(g, v));
        }
        return ret;
    }

    /**
     * @param value
     * @return
     */
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
                LuaTable luaTable = value.toLuaTable();
                if (luaTable.isEmpty()) {
                    LuaTable metatable = luaTable.getMetatable();
                    if (metatable != null) {
                        LuaValue collectionType = metatable.get(COLLECTION_TYPE);
                        return collectionType.isNumber() && collectionType.toInt() == ARRAY_TYPE ? new ArrayList<>() : new HashMap<>();
                    } else {
                        throw new RuntimeException("empty table must user array or map");
                    }
                } else {
                    return luaTable.getn() > 0 ? toList(luaTable) : toMap(luaTable);
                }
            case LuaValue.LUA_TUSERDATA:
            case LuaValue.LUA_TLIGHTUSERDATA:
                LuaUserdata ud = value.toUserdata();
                Object jud = ud.getJavaUserdata();
                return Translator.translateLuaToJava(ud, jud != null ? jud.getClass() : null);
        }
        return value;
    }

    public static @NonNull
    List<Object> toList(LuaTable table) {
        ArrayList ret = new ArrayList();
        if (table != null) {
            DisposableIterator<LuaTable.KV> iterator = table.iterator();
            if (iterator != null) {
                while (iterator.hasNext()) {
                    LuaTable.KV kv = iterator.next();
                    ret.add(toNativeValue(kv.value));
                }
                iterator.dispose();
            }
        }
        return ret;
    }

    public static @NonNull
    Map<String, Object> toMap(LuaTable table) {
        HashMap ret = new HashMap();
        if (table != null) {
            DisposableIterator<LuaTable.KV> iterator = table.iterator();
            if (iterator != null) {
                while (iterator.hasNext()) {
                    LuaTable.KV kv = iterator.next();
                    String key = kv.key.toJavaString();
                    ret.put(key, toNativeValue(kv.value));
                }
                iterator.dispose();
            }
        }
        return ret;
    }

    /**
     * @param value map给数据ObservableMap/ObservableList 赋值
     * @return
     */
    public static @Nullable
    Object toNativeValue(@Nullable Object value) {
        if (value instanceof Map) {
            return toFastObservableMap((Map) value);
        } else if (value instanceof List) {
            return toFastObservableList((List) value);
        } else {
            return value;
        }
    }

    public static @NonNull
    ObservableMap toFastObservableMap(Map<Object, Object> map) {
        ObservableMap ret = new ObservableMap();
        if (map != null) {
            for (Map.Entry<Object, Object> entry : map.entrySet()) {
                ret.put(entry.getKey(), toNativeValue(entry.getValue()));
            }
        }
        return ret;
    }

    public static @NonNull
    ObservableList toFastObservableList(List list) {
        ObservableList ret = new ObservableList();
        if (list != null) {
            for (Object value : list) {
                ret.add(toNativeValue(value));
            }
        }
        return ret;
    }

    /**
     * 将jsonString字符串转成LuaTable
     *
     * @return
     */
    public static LuaValue toLuaTable(Globals g, String jsonString) {
        LuaValue table = null;
        try {
            Object json = new JSONTokener(jsonString).nextValue();
            if (json instanceof JSONObject) {
                JSONObject jsonObject = (JSONObject) json;
                table = toLuaTable(g, jsonObject);
            } else if (json instanceof JSONArray) {
                JSONArray jsonArray = (JSONArray) json;
                table = toLuaTable(g, jsonArray);
            }
        } catch (JSONException e) {
            LogUtil.e("[LuaView Error-isJson]-Json Parse Failed, Reason: Invalid Format!", e);
            e.printStackTrace();
            return null;
        }
        return table;
    }

    /**
     * 将JSONObject转成LuaTable
     *
     * @param obj
     * @return
     */
    private static LuaValue toLuaTable(Globals g, JSONObject obj) {
        LuaTable table = LuaTable.create(g);
        Iterator<String> iter = obj.keys();
        while (iter.hasNext()) {
            String key = iter.next();
            Object value = obj.opt(key);
            if (value instanceof JSONObject) {
                table.set(key, toLuaTable(g, (JSONObject) value));
            } else if (value instanceof JSONArray) {
                table.set(key, toLuaTable(g, (JSONArray) value));
            } else {
                table.set(key, ConvertUtils.toLuaValue(g, value));
            }
        }
        LuaTable metatalbe = LuaTable.create(g);
        metatalbe.set(COLLECTION_TYPE, MAP_TYPE);
        table.setMetatalbe(metatalbe);
        return table;
    }

    /**
     * 将JSONObject转成LuaTable
     *
     * @param obj
     * @return
     */
    private static LuaValue toLuaTable(Globals g, JSONArray obj) {
        LuaTable table = LuaTable.create(g);
        final int len = obj.length();
        for (int i = 0; i < len; i++) {
            int key = i + 1;
            Object value = obj.opt(i);
            if (value instanceof JSONObject) {
                table.set(key, toLuaTable(g, (JSONObject) value));
            } else if (value instanceof JSONArray) {
                table.set(key, toLuaTable(g, (JSONArray) value));
            } else {
                table.set(key, ConvertUtils.toLuaValue(g, value));
            }
        }
        LuaTable metatalbe = LuaTable.create(g);
        metatalbe.set(COLLECTION_TYPE, ARRAY_TYPE);
        table.setMetatalbe(metatalbe);
        return table;
    }
}
