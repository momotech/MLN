/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package com.mln.demo.weex.utils;


import com.taobao.weex.devtools.common.LogUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

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
