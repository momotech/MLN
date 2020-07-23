/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.utils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.wrapper.Translator;
import com.immomo.mmui.databinding.bean.MMUIColor;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;
import com.immomo.mmui.ud.UDColor;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Description: DataBinding java 和 lua 数据结构转化规则
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-05-13 14:52
 */
public class BindingConvertUtils {
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

        if (value instanceof Map) {
            return toTable(globals, (Map) value);
        }

        if (value instanceof List) {
            return toTable(globals, (List) value);
        }

        if (value instanceof MMUIColor) {
            return new UDColor(globals, (MMUIColor) value);
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
    LuaTable toTable(@NonNull Globals g, @NonNull Map<Object, Object> map) {
        LuaTable ret = LuaTable.create(g);
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
                    ret.set((Integer) i, toTable(g, (Map) v));
                else if (v instanceof List)
                    ret.set((Integer) i, toTable(g, (List) v));
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
                    ret.set((String) i, toTable(g, (Map) v));
                else if (v instanceof List)
                    ret.set((String) i, toTable(g, (List) v));
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
    LuaTable toTable(@NonNull Globals g, @NonNull List list) {
        LuaTable ret = LuaTable.create(g);
        for (int i = 0, l = list.size(); i < l; i++) {
            Object v = list.get(i);
            if (v == null)
                ret.set(i+1, LuaValue.Nil());
            else if (v instanceof Number)
                ret.set(i+1, ((Number) v).doubleValue());
            else if (v instanceof String)
                ret.set(i+1, v.toString());
            else if (v instanceof Boolean)
                ret.set(i+1, ((Boolean) v));
            else if (v instanceof Map)
                ret.set(i+1, toTable(g, (Map) v));
            else if (v instanceof List)
                ret.set(i+1, toTable(g, (List) v));
            else
                ret.set(i+1, toLuaValue(g, v));
        }
        return ret;
    }


    /**
     * LuaTable 转 ObservableMap
     *
     * @param luaTable
     * @return
     */
    public static @NonNull
    ObservableMap toObservableMap(@NonNull LuaTable luaTable) {
        ObservableMap ret = new ObservableMap();
        LuaTable.Entrys entrys = luaTable.newEntry();
        LuaValue[] keys = entrys.keys();
        LuaValue[] values = entrys.values();
        int len = keys.length;
        for (int i = 0; i < len; i++) {
            ret.put(toNativeValue(keys[i]), toNativeValue(values[i]));
        }
        luaTable.destroy();
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
                if(isList(value.toLuaTable())) {
                    return toObservableList(value.toLuaTable());
                }
                return toObservableMap(value.toLuaTable());
            case LuaValue.LUA_TUSERDATA:
            case LuaValue.LUA_TLIGHTUSERDATA:
                LuaUserdata ud = value.toUserdata();
                Object jud = ud.getJavaUserdata();
                return Translator.translateLuaToJava(ud, jud != null ? jud.getClass() : null);
        }
        return value;
    }


    /**
     * 判断luaTable 是否是List
     * @param luaTable
     * @return
     */
    public static boolean isList(LuaTable luaTable) {
        LuaTable.Entrys entrys = luaTable.newEntry();
        LuaValue[] keys = entrys.keys();
        if(keys.length>0 && keys[0].isNumber()) {
            return true;
        }
        return false;
    }


    /**
     * 转ObservableList
     * @param table
     * @return
     */
    public static @NonNull
    ObservableList toObservableList(@NonNull LuaTable table) {
        ObservableList ret = new ObservableList();
        LuaTable.Entrys entrys = table.newEntry();
        LuaValue[] keys = entrys.keys();
        LuaValue[] values = entrys.values();
        for (int i = 0, l = values.length; i < l; i++) {
            if(keys[i].toInt() == i+1) {
                ret.add(toNativeValue(values[i]));
            } else{
                break;
            }
        }
        table.destroy();
        return ret;
    }

}