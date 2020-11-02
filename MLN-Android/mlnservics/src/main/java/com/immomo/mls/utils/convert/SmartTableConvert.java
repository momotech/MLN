/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.utils.convert;

import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Xiong.Fangyu on 2020/10/15
 * table自动转换成map和list
 *
 * 当table中有数组部分时，且符合lua规定的数组形式，则按照数组处理，输出List
 * 否则按照map处理
 */
public class SmartTableConvert {

    private SmartTableConvert() {}

    public static Map<String, Object> toMap(LuaTable t) {
        Map<String, Object> ret = new HashMap<>();
        if (!t.startTraverseTable()) {
            return ret;
        }
        LuaValue[] next;
        while ((next = t.next()) != null) {
            String k = next[0].toJavaString();
            LuaValue v = next[1];
            if (v.isTable()) {
                LuaTable vt = v.toLuaTable();
                if (vt.getn() > 0) {
                    ret.put(k, toList(vt));
                } else if (!vt.isEmpty()) {
                    ret.put(k, toMap(vt));
                } else {
                    v.destroy();
                }
                continue;
            }
            ret.put(k, ConvertUtils.toNativeValue(v));
        }
        t.endTraverseTable();
        t.destroy();
        return ret;
    }

    public static List<Object> toList(LuaTable t) {
        List<Object> ret = new ArrayList();
        int n = t.getn();
        for (int i = 1; i <= n; i ++) {
            LuaValue v = t.get(i);
            if (v.isTable()) {
                LuaTable vt = v.toLuaTable();
                if (vt.getn() > 0) {
                    ret.add(toList(vt));
                } else if (!vt.isEmpty()) {
                    ret.add(toMap(vt));
                } else {
                    v.destroy();
                }
                continue;
            }
            ret.add(ConvertUtils.toNativeValue(v));
        }
        t.destroy();
        return ret;
    }
}
