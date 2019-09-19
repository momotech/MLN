/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import com.immomo.mls.utils.convert.ConvertUtils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.DisposableIterator;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;

/**
 * Json 处理
 *
 * @author song
 * @date 15/9/6
 */
public class JsonUtil {

    /**
     * convert a lua table to data string
     *
     * @param table
     * @return
     */
    public static String toStringPlain(LuaTable table) {
        JSONObject obj = toJSONObject(table);
        return obj.toString();
    }

    public static JSONObject toJSONObject(LuaTable table) {
        JSONObject obj = new JSONObject();
        if (table != null) {
            DisposableIterator<LuaTable.KV> iterator = table.iterator();
            if (iterator != null) {
                try {
                    while (iterator.hasNext()) {
                        LuaTable.KV kv = iterator.next();
                        String key = kv.key.toJavaString();
                        LuaValue value = kv.value;
                        if (value instanceof LuaTable) {
                            obj.put(key, toJSONObject((LuaTable) value));
                        } else {
                            obj.put(key, ConvertUtils.toNativeValue(value));
                        }
                    }
                } catch (Throwable t) {
                    LogUtil.e("[LuaView Error-toJSONObject]-Json Parse Failed, Reason: Invalid Format!", t);
                }
                iterator.dispose();
            }
            table.destroy();
        }
        return obj;
    }

    /**
     * 将JSONObject转成LuaTable
     *
     * @param obj
     * @return
     */
    public static LuaValue toLuaTable(Globals g, JSONObject obj) {
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
        return table;
    }

    /**
     * 判断是否可以转成json
     *
     * @param jsonString
     * @return
     */
    public static boolean isJson(String jsonString) {
        try {
            new JSONObject(jsonString);
        } catch (JSONException ex) {
            try {
                new JSONArray(jsonString);
            } catch (JSONException ex1) {
                LogUtil.e("[LuaView Error-isJson]-Json Parse Failed, Reason: Invalid Format!", ex1);
                return false;
            }
        }
        return true;
    }

    /**
     * 将JSONObject转成LuaTable
     *
     * @param obj
     * @return
     */
    public static LuaValue toLuaTable(Globals g, JSONArray obj) {
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
        return table;
    }

    public static Map<String, Object> toMap(JSONObject jo) {
        Iterator<String> keys = jo.keys();
        Map<String, Object> ret = new HashMap<>();
        while (keys.hasNext()) {
            String k = keys.next();
            Object v = jo.opt(k);
            if (v == null)
                continue;
            ret.put(k, convertJson(v));
        }
        return ret;
    }

    private static Object convertJson(@NonNull Object v) {
        if (v instanceof JSONObject) {
            return toMap((JSONObject) v);
        }
        if (v instanceof JSONArray) {
            return toList((JSONArray) v);
        }
        return v;
    }

    public static List toList(JSONArray ja) {
        List ret = new ArrayList();
        for (int i = 0, l = ja.length(); i < l; i++) {
            Object v = ja.opt(i);
            if (v == null)
                continue;
            ret.add(convertJson(v));
        }
        return ret;
    }

    public static JSONObject toJson(Map map) {
        JSONObject obj = new JSONObject();
        if (map != null) {
            Iterator iterator = map.keySet().iterator();
            String keyStr;
            Object key;
            Object value;
            while (iterator.hasNext()) {
                key = iterator.next();
                keyStr = key.toString();
                try {
                    value = map.get(key);
                    if (value instanceof Map) {
                        obj.put(keyStr, toJson((Map) value));
                    } else if (value instanceof List) {
                        obj.put(keyStr, toJsonArray((List) value));
                    } else {
                        obj.put(keyStr, value);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    LogUtil.e("[LuaView Error-toJson]-Json Parse Failed, Reason: Invalid Format!", e);
                }
            }
        }
        return obj;
    }

    public static JSONArray toJsonArray(List list) {
        JSONArray array = new JSONArray();
        if (list != null) {
            for (Object value :
                    list) {
                if (value instanceof Map) {
                    array.put(toJson((Map) value));
                } else if (value instanceof List) {
                    array.put(toJsonArray((List) value));
                } else {
                    array.put(value);
                }
            }
        }
        return array;
    }
}