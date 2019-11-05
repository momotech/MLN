/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import androidx.annotation.NonNull;

import com.immomo.mlncore.MLNCore;

import org.luaj.vm2.utils.DisposableIterator;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.Arrays;
import java.util.Iterator;

/**
 * Created by Xiong.Fangyu on 2019/2/22
 * <p>
 * Lua table封装类
 * <p>
 * 使用完成及时调用{@link #destroy()}
 */
@LuaApiUsed
public class LuaTable extends NLuaValue implements Iterable {
    private static final Entrys EMPTY_ENTRYS = new Entrys(empty(), empty());

    /**
     * 由{@link Globals}继承
     */
    LuaTable(long stackIndex) {
        super(stackIndex);
        this.globals = (Globals) this;
    }

    /**
     * 由{@link #create(Globals)}创建
     */
    private LuaTable(Globals globals, long stackIndex) {
        super(globals, stackIndex);
    }

    /**
     * Called by native method.
     * see luajapi.c newLuaTable
     */
    @LuaApiUsed
    private LuaTable(long L_state, long stackIndex) {
        super(L_state, stackIndex);
    }

    /**
     * 创建table
     *
     * @param globals 虚拟机环境
     */
    public static LuaTable create(Globals globals) {
        globals.checkMainThread();
        return new LuaTable(globals, LuaCApi._createTable(globals.L_State));
    }

    //<editor-fold desc="get set">

    /**
     * table[index] = value
     */
    public void set(int index, LuaValue value) {
        if (!checkValid())
            return;
        int t = value.type();
        switch (t) {
            case LUA_TNUMBER:
                LuaCApi._setTableNumber(globals.L_State, nativeGlobalKey, index, value.toDouble());
                break;
            case LUA_TNIL:
                LuaCApi._setTableNil(globals.L_State, nativeGlobalKey, index);
                break;
            case LUA_TBOOLEAN:
                LuaCApi._setTableBoolean(globals.L_State, nativeGlobalKey, index, value.toBoolean());
                break;
            case LUA_TSTRING:
                LuaCApi._setTableString(globals.L_State, nativeGlobalKey, index, value.toJavaString());
                break;
            default:    //table function userdata thread
                if (value.notInGlobalTable()) {
                    LuaCApi._setTableChild(globals.L_State, nativeGlobalKey, index, value);
                } else {
                    LuaCApi._setTableChild(globals.L_State, nativeGlobalKey, index, value.nativeGlobalKey(), t);
                }
                break;
        }
    }

    /**
     * table[index] = num
     */
    public void set(int index, double num) {
        if (!checkValid())
            return;
        LuaCApi._setTableNumber(globals.L_State, nativeGlobalKey, index, num);
    }

    /**
     * table[index] = b
     */
    public void set(int index, boolean b) {
        if (!checkValid())
            return;
        LuaCApi._setTableBoolean(globals.L_State, nativeGlobalKey, index, b);
    }

    /**
     * table[index] = s
     */
    public void set(int index, String s) {
        if (!checkValid())
            return;
        LuaCApi._setTableString(globals.L_State, nativeGlobalKey, index, s);
    }

    /**
     * table.name = value
     */
    public void set(String name, LuaValue value) {
        if (!checkValid())
            return;
        int t = value.type();
        switch (t) {
            case LUA_TNUMBER:
                LuaCApi._setTableNumber(globals.L_State, nativeGlobalKey, name, value.toDouble());
                break;
            case LUA_TNIL:
                LuaCApi._setTableNil(globals.L_State, nativeGlobalKey, name);
                break;
            case LUA_TBOOLEAN:
                LuaCApi._setTableBoolean(globals.L_State, nativeGlobalKey, name, value.toBoolean());
                break;
            case LUA_TSTRING:
                LuaCApi._setTableString(globals.L_State, nativeGlobalKey, name, value.toJavaString());
                break;
            default:    //table function userdata thread
                if (value.notInGlobalTable()) {
                    LuaCApi._setTableChild(globals.L_State, nativeGlobalKey, name, value);
                } else {
                    LuaCApi._setTableChild(globals.L_State, nativeGlobalKey, name, value.nativeGlobalKey(), t);
                }
                if (this == globals)
                    value.destroy();
                break;
        }
    }

    /**
     * table.name = num
     */
    public void set(String name, double num) {
        if (!checkValid())
            return;
        LuaCApi._setTableNumber(globals.L_State, nativeGlobalKey, name, num);
    }

    /**
     * table.name = b
     */
    public void set(String name, boolean b) {
        if (!checkValid())
            return;
        LuaCApi._setTableBoolean(globals.L_State, nativeGlobalKey, name, b);
    }

    /**
     * table.name = s
     */
    public void set(String name, String s) {
        if (!checkValid())
            return;
        LuaCApi._setTableString(globals.L_State, nativeGlobalKey, name, s);
    }

    /**
     * 获取table[index]
     */
    public LuaValue get(int index) {
        if (!checkValid())
            return Nil();
        return (LuaValue) LuaCApi._getTableValue(globals.L_State, nativeGlobalKey, index);
    }

    /**
     * 获取table.name
     */
    public LuaValue get(String name) {
        if (!checkValid())
            return Nil();
        return (LuaValue) LuaCApi._getTableValue(globals.L_State, nativeGlobalKey, name);
    }
    //</editor-fold>

    /**
     * 清楚table的数组部分
     * @param from 从下标为from开始
     * @param to   下标为to结束，包含
     */
    public final void clearArray(int from, int to) {
        if (!checkValid())
            return;
        LuaCApi._clearTableArray(globals.L_State, nativeGlobalKey, from, to);
    }

    /**
     * 直接使用{@link #newEntry()}获取所有key value，并获取长度
     */
    @Deprecated
    public final int size() {
        return newEntry().length;
    }

    /**
     * 获取table的长度
     * table.getn(table)
     * 长度不一定是table的真实长度
     * @return 长度
     */
    public final int getn() {
        return LuaCApi._getTableSize(globals.L_State, nativeGlobalKey);
    }
    //<editor-fold desc="Traverse">

    /**
     * 遍历table，一次性将table中key value全部取出来，并放入{@link Entrys}中
     * 不会返回Null
     * @see Entrys
     */
    public final Entrys newEntry() {
        if (!checkValid())
            return EMPTY_ENTRYS;
        return (Entrys) LuaCApi._getTableEntry(globals.L_State, nativeGlobalKey);
    }

    /**
     * 开始遍历table，将不会取出所有元素，需要配合{@link #next()}使用
     * 注意：最后一定需要调用{@link #endTraverseTable()}
     * <p>
     * eg:
     * if (t.startTraverseTable()) {
     * try {
     * LuaValue[] next = t.next();
     * while (next != null) {
     * code...
     * next = t.next();
     * }
     * } finally {
     * t.endTraverseTable();
     * }
     * }
     *
     * @return 若当前表不存在，则返回false
     */
    public final boolean startTraverseTable() {
        if (!checkValid())
            return false;
        return LuaCApi._startTraverseTable(globals.L_State, nativeGlobalKey);
    }

    /**
     * 获取下一个key value对
     * 0为key，1为value
     *
     * @return 如果不存在，返回null
     */
    public final LuaValue[] next() {
        return LuaCApi._nextEntry(globals.L_State, this == globals);
    }

    /**
     * 结束遍历此table
     * 若{@link #startTraverseTable}返回true，此方法必须调用
     */
    public final void endTraverseTable() {
        LuaCApi._endTraverseTable(globals.L_State);
    }

    /**
     * 使用迭代器遍历此table，可能返回null
     * 迭代完成必须调用{@link DisposableIterator#dispose()}
     *
     * @return null or DisposableIterator
     * @see DisposableIterator
     */
    @Override
    public final DisposableIterator<KV> iterator() {
        if (!startTraverseTable())
            return null;
        return new DisposableIterator<KV>() {
            KV kv;

            @Override
            public void dispose() {
                endTraverseTable();
            }

            @Override
            public boolean hasNext() {
                LuaValue[] next = LuaTable.this.next();
                if (next == null) {
                    return false;
                }
                kv = new KV(next[0], next[1]);
                return true;
            }

            @Override
            public KV next() {
                return kv;
            }
        };
    }

    /**
     * 遍历使用，由native创建
     *
     * @see #newEntry()
     * @see LuaCApi#_getTableEntry
     */
    @LuaApiUsed
    public static final class Entrys implements Iterable<KV> {
        /**
         * 不为空，且长度和{@link #values}长度相同
         */
        @LuaApiUsed
        private final LuaValue[] keys;
        /**
         * 不为空，且长度和{@link #keys}长度相同
         */
        @LuaApiUsed
        private final LuaValue[] values;
        /**
         * 长度
         */
        private final int length;

        @LuaApiUsed
        private Entrys(LuaValue[] keys, LuaValue[] values) {
            this.keys = keys;
            this.values = values;
            length = this.keys.length;
        }

        public LuaValue[] keys() {
            return keys;
        }

        public LuaValue[] values() {
            return values;
        }

        public int length() {
            return length;
        }

        @Override
        public String toString() {
            return "keys:" + Arrays.toString(keys) + "\nvalues:" + Arrays.toString(values);
        }

        @NonNull
        @Override
        public Iterator<KV> iterator() {
            return new I(keys, values);
        }

        private static final class I implements Iterator<KV> {
            private final LuaValue[] keys;
            private final LuaValue[] values;
            private final int len;
            private int index;

            private I(LuaValue[] keys, LuaValue[] values) {
                this.keys = keys;
                this.values = values;
                len = keys.length;
                index = 0;
            }

            @Override
            public boolean hasNext() {
                return index < len;
            }

            @Override
            public KV next() {
                return new KV(keys[index], values[index++]);
            }
        }
    }

    /**
     * 保存table的键值对
     */
    public static final class KV {
        public final LuaValue key;
        public final LuaValue value;

        private KV(LuaValue key, LuaValue value) {
            this.key = key;
            this.value = value;
        }

        @Override
        public String toString() {
            return key + " : " + value;
        }
    }
    //</editor-fold>

    private boolean checkValid() {
        globals.checkMainThread();
        if (!destroyed && !globals.isDestroyed() && !notInGlobalTable() && checkStateByNative())
            return true;
        if (MLNCore.DEBUG)
            throwNotValid();
        return false;
    }

    private void throwNotValid() {
        throw new IllegalStateException(
                "table (" + nativeGlobalKey + ") is " + (destroyed ? "" : "not ") + "destroyed. " +
                        "global is " + (globals.isDestroyed() ? "destroyed" : "not destroyed"));
    }

    @Override
    public final int type() {
        return LUA_TTABLE;
    }

    @Override
    public final LuaTable toLuaTable() {
        return this;
    }

    @Override
    public String toJavaString() {
        if (destroyed || globals.isDestroyed() || !checkStateByNative())
            return "cannot find table by key: " + nativeGlobalKey;
        return newEntry().toString();
    }
}