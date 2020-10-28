/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils.convert;

import com.immomo.mls.fun.IUserdataHolder;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.wrapper.Translator;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.DisposableIterator;

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
 * table更智能的转换：{@link SmartTableConvert}
 *
 * @see #toNativeValue(LuaValue)
 * @see #toLuaValue(Globals, Object)
 * @see #toMap(LuaTable)
 */
public class ConvertUtils {
    /**
     * 这里table全部转换成map
     *
     * 特殊转换可使用
     * @see #toMap(LuaTable)
     * @see #toArrayList(LuaTable)
     * @see #toArrayListSafe(LuaTable)
     * @see #toList(LuaTable)
     * @see SmartTableConvert#toList(LuaTable)
     * @see SmartTableConvert#toMap(LuaTable)
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
                return toMap(value.toLuaTable());
            case LuaValue.LUA_TUSERDATA:
            case LuaValue.LUA_TLIGHTUSERDATA:
                LuaUserdata ud = value.toUserdata();
                Object jud = ud.getJavaUserdata();
                return Translator.translateLuaToJava(ud, jud != null ? jud.getClass() : null);
        }
        return value;
    }

    /**
     * 默认转换方法，遇到table全部转换成map
     */
    public static @NonNull
    Map toMap(@NonNull LuaTable luaTable) {
        Map ret = new HashMap();
        if (!luaTable.startTraverseTable()) {
            return ret;
        }
        LuaValue[] next;
        while ((next = luaTable.next()) != null) {
            ret.put(ConvertUtils.toNativeValue(next[0]), ConvertUtils.toNativeValue(next[1]));
        }
        luaTable.endTraverseTable();
        luaTable.destroy();
        return ret;
    }

    /**
     * 将table转成list，table中全部数据(包括array部分和hash部分)都会放入list中，顺序可能改变
     * table内的table将转换成map
     * @see #toArrayList(LuaTable)
     * @see #toArrayListSafe(LuaTable)
     * 更智能的转换
     * @see SmartTableConvert#toList(LuaTable)
     * @see SmartTableConvert#toMap(LuaTable)
     */
    public static @NonNull
    List toList(@NonNull LuaTable table) {
        List ret = new ArrayList();
        if (!table.startTraverseTable()) {
            return ret;
        }
        LuaValue[] next;
        while ((next = table.next()) != null) {
            ret.add(ConvertUtils.toNativeValue(next[1]));
        }
        table.endTraverseTable();
        table.destroy();
        return ret;
    }

    /**
     * 只将table中的数组部分转成list，顺序不变，但数据可能丢失
     * 数据丢失情况：1、hash部分全部丢失，及key-value部分
     *              2、array部分nil后所有数据丢失，比如{1,2,3,nil,5,6}，nil后的5、6丢失
     * table内的table将转换成map
     * @see #toArrayListSafe(LuaTable)
     * @see #toList(LuaTable)
     * 更智能的转换
     * @see SmartTableConvert#toList(LuaTable)
     * @see SmartTableConvert#toMap(LuaTable)
     */
    public static @NonNull
    List toArrayList(@NonNull LuaTable table) {
        List ret = new ArrayList();
        int n = table.getn();
        for (int i = 1; i <= n; i ++) {
            ret.add(ConvertUtils.toNativeValue(table.get(i)));
        }
        table.destroy();

        return ret;
    }

    /**
     * 只将table中的数组部分转成list，顺序不变，但hash部分数据丢失
     * table内的table将转换成map
     * @see #toList(LuaTable)
     * @see #toArrayList(LuaTable)
     * 更智能的转换
     * @see SmartTableConvert#toList(LuaTable)
     * @see SmartTableConvert#toMap(LuaTable)
     */
    public static @NonNull
    List toArrayListSafe(@NonNull LuaTable table) {
        if (!table.startTraverseTable())
            return new ArrayList();
        Object[] arr = new Object[10];
        int arrMax = 0;
        LuaValue[] next;
        while ((next = table.next()) != null) {
            LuaValue key = next[0];
            if (!key.isInt())
                continue;
            int index = key.toInt();
            if (index < 0)
                continue;
            LuaValue value = next[1];
            Object[] ret = ArrayUtils.set(arr, ConvertUtils.toNativeValue(value), index - 1);
            if (ret != arr) {
                arrMax = index;
                arr = ret;
            } else {
                arrMax = Math.max(index, arrMax);
            }
        }
        table.endTraverseTable();
        table.destroy();

        return ArrayUtils.toList(arr, arrMax);
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
        if (ret == null && value instanceof IUserdataHolder) {
            return ((IUserdataHolder) value).getUserdata();
        }
        if (ret == null)
            ret = Translator.translateJavaToLua(globals, value);
        return ret;
    }
}