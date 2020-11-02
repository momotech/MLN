/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.utils;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mls.wrapper.Translator;
import com.immomo.mmui.databinding.DataBinding;
import com.immomo.mmui.databinding.bean.MMUIColor;
import com.immomo.mmui.databinding.bean.ObservableField;
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
import org.luaj.vm2.utils.DisposableIterator;

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
            ObservableMap observableMap = (ObservableMap) value;
            LuaTable cache = observableMap.getFieldCache(globals);
            if (cache != null) {
                if (DataBinding.isLog) {
                    Log.d(DataBinding.TAG, "from cache");
                }
                return cache;
            }

            LuaTable luaTable = toTable(globals, (ObservableMap) value);
            return luaTable;
        }

        if (value instanceof ObservableList) {
            ObservableList observableList = (ObservableList) value;
            LuaTable cache = observableList.getFieldCache(globals);
            if (cache != null) {
                if (DataBinding.isLog) {
                    Log.d(DataBinding.TAG, "from cache");
                }
                return cache;
            }
            LuaTable luaTable = toTable(globals, (ObservableList) value);
            return luaTable;
        }

        if (value instanceof ObservableField) {
            ObservableField observableField = (ObservableField) value;
            LuaTable cache = observableField.getFieldCache(globals);
            if (cache != null) {
                if (DataBinding.isLog) {
                    Log.d(DataBinding.TAG, "from cache");
                }
                return cache;
            }
            LuaTable luaTable = toTable(globals, (ObservableMap) ((ObservableField) value).getFields());
            return luaTable;
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
    private static @NonNull
    LuaTable toTable(@NonNull Globals g, @NonNull ObservableMap<Object, Object> map) {
        LuaTable ret = LuaTable.create(g);
        LuaTable metatalbe = LuaTable.create(g);
        metatalbe.set(COLLECTION_TYPE,MAP_TYPE);
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
        map.addFieldCache(ret);
        return ret;
    }


    /**
     * list转table
     *
     * @param g
     * @param list
     * @return
     */
    private static @NonNull
    LuaTable toTable(@NonNull Globals g, @NonNull ObservableList list) {
        LuaTable ret = LuaTable.create(g);
        LuaTable metatalbe = LuaTable.create(g);
        metatalbe.set(COLLECTION_TYPE,ARRAY_TYPE);
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
        list.addFieldCache(ret);
        return ret;
    }

    /**
     * @param value
     * @return
     */
    public static @Nullable
    Object toNativeValue(@Nullable LuaValue value,boolean isMock) {
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
            case LuaValue.LUA_TTABLE: //当luaTable 为空时，根据元表中"collectionType"进行判断array为2,map为1
                LuaTable luaTable = value.toLuaTable();
                if (luaTable.isEmpty()) {
                    LuaTable metatable = luaTable.getMetatable();
                    if(metatable !=null) {
                        LuaValue collectionType = metatable.get(COLLECTION_TYPE);
                        return collectionType instanceof LuaNumber && collectionType.toInt() == ARRAY_TYPE ? new ObservableList<>() : new ObservableMap<>();
                    } else {
                        throw new RuntimeException("empty table must user array or map");
                    }
                } else {
                    return luaTable.getn() > 0 ? toFastObservableList(luaTable,isMock) : toFastObservableMap(luaTable,isMock);
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
    ObservableList toFastObservableList(LuaTable table,boolean isMock) {
        ObservableList ret = new ObservableList();
        if (table != null) {
            DisposableIterator<LuaTable.KV> iterator = table.iterator();
            if (iterator != null) {
                while (iterator.hasNext()) {
                    LuaTable.KV kv = iterator.next();
                    ret.add(toNativeValue(kv.value,isMock));
                }
                iterator.dispose();
            }
        }
        return ret;
    }


    public static @NonNull
    ObservableMap toFastObservableMap(LuaTable table,boolean isMock) {
        ObservableMap ret = new ObservableMap();
        if (table != null) {
            DisposableIterator<LuaTable.KV> iterator = table.iterator();
            if (iterator != null) {
                while (iterator.hasNext()) {
                    LuaTable.KV kv = iterator.next();
                    String key = kv.key.toJavaString();
                    if(isMock) {
                        ret.mock(key, toNativeValue(kv.value,true));
                    } else {
                        ret.put(key, toNativeValue(kv.value,false));
                    }
                }
                iterator.dispose();
            }
        }
        return ret;
    }

}