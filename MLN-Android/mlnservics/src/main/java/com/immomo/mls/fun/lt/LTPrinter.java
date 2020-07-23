/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.DisposableIterator;

/**
 * Created by XiongFangyu on 2018/8/3.
 */
@LuaClass(isStatic = true)
public class LTPrinter {
    public static final String LUA_CLASS_NAME = "Printer";
    private static final String TAB = "    ";

    //<editor-fold desc="API">
    @LuaBridge
    public static void printTable(LuaValue table) {
        if (table.isNil()) {
            MLSAdapterContainer.getConsoleLoggerAdapter().d(LUA_CLASS_NAME, "null");
            return;
        }
        if (table.isTable()) {
            StringBuilder sb = new StringBuilder();
            appendTable((LuaTable) table, sb, 0);
            MLSAdapterContainer.getConsoleLoggerAdapter().d(LUA_CLASS_NAME, sb.toString());
        }
    }

    @LuaBridge
    public static void printObject(LuaValue v) {
        if (v == null || v.isNil()) {
//            MLSAdapterContainer.getConsoleLoggerAdapter().d(LUA_CLASS_NAME, "null");
            return;
        }
        if (v.isTable()) {
            printTable(v);
            return;
        }
        MLSAdapterContainer.getConsoleLoggerAdapter().d(LUA_CLASS_NAME, v.toString());
    }
    //</editor-fold>

    private static void appendTable(LuaTable table, StringBuilder sb, int tabCount) {
        DisposableIterator<LuaTable.KV> kvs = table.iterator();
        if (kvs != null) {
            while (kvs.hasNext()) {
                LuaTable.KV kv = kvs.next();
                appendTab(sb, tabCount);
                sb.append(kv.key.toJavaString()).append(":");
                if (kv.value.isTable()) {
                    sb.append("{\n");
                    appendTable((LuaTable) kv.value, sb, tabCount + 1);
                } else if (kv.value.isFunction()) {
                    sb.append("function");
                    kv.value.destroy();
                } else {
                    sb.append(kv.value.toJavaString());
                }
                sb.append(",\n");
            }
            kvs.dispose();
        }
        table.destroy();
    }

    private static void appendTab(StringBuilder sb, int tabCount) {
        for (int i = 0; i < tabCount; i++) {
            sb.append(TAB);
        }
    }
}