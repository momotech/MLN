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
import org.luaj.vm2.utils.SignatureUtils;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
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

    private boolean inTraverse = false;

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
        if (!checkValidForGetSet())
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
        if (!checkValidForGetSet())
            return;
        LuaCApi._setTableNumber(globals.L_State, nativeGlobalKey, name, num);
    }

    /**
     * table.name = b
     */
    public void set(String name, boolean b) {
        if (!checkValidForGetSet())
            return;
        LuaCApi._setTableBoolean(globals.L_State, nativeGlobalKey, name, b);
    }

    /**
     * table.name = s
     */
    public void set(String name, String s) {
        if (!checkValidForGetSet())
            return;
        LuaCApi._setTableString(globals.L_State, nativeGlobalKey, name, s);
    }

    /**
     * table[index] = function(...) method.invoke(...) end
     * @param clz 类，必须含有{@link LuaApiUsed}注解
     * @param method 方法，必须含有{@link LuaApiUsed}注解，方法模型：static LuaValue[] xxx(LuaValue[])
     */
    public void set(int index, Class<?> clz, Method method) {
        if (!checkValid())
            return;
        if ((method.getModifiers() & Modifier.STATIC) != Modifier.STATIC)
            throw new IllegalArgumentException("method must be static");
        if (method.getAnnotation(LuaApiUsed.class) == null || clz.getAnnotation(LuaApiUsed.class) == null)
            throw new IllegalArgumentException("class and method must have @LuaApiUsed annotation");
        String methodSig = SignatureUtils.getMethodSignature(method);
        if (!SignatureUtils.isValidStaticMethodSignature(methodSig))
            throw new IllegalArgumentException("method invalid, must like LuaValue[] " + method.getName() + "(long,LuaValue[])");

        String clzSig = SignatureUtils.getClassName(clz);
        LuaCApi._setTableMethod(globals.L_State, nativeGlobalKey, index, clzSig, method.getName());
    }

    /**
     * table.k = function(...) method.invoke(...) end
     * @param clz 类，必须含有{@link LuaApiUsed}注解
     * @param method 方法，必须含有{@link LuaApiUsed}注解，方法模型：static LuaValue[] xxx(LuaValue[])
     */
    public void set(String k, Class<?> clz, Method method) {
        if (!checkValidForGetSet())
            return;
        if ((method.getModifiers() & Modifier.STATIC) != Modifier.STATIC)
            throw new IllegalArgumentException("method must be static");
        if (method.getAnnotation(LuaApiUsed.class) == null || clz.getAnnotation(LuaApiUsed.class) == null)
            throw new IllegalArgumentException("class and method must have @LuaApiUsed annotation");
        String methodSig = SignatureUtils.getMethodSignature(method);
        if (!SignatureUtils.isValidStaticMethodSignature(methodSig))
            throw new IllegalArgumentException("method invalid, must like LuaValue[] " + method.getName() + "(long,LuaValue[])");

        String clzSig = SignatureUtils.getClassName(clz);
        LuaCApi._setTableMethod(globals.L_State, nativeGlobalKey, k, clzSig, method.getName());
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
        if (!checkValidForGetSet())
            return Nil();
        return (LuaValue) LuaCApi._getTableValue(globals.L_State, nativeGlobalKey, name);
    }
    //</editor-fold>

//<editor-fold desc="other">

    @Override
    public final LuaTable setMetatalbe(LuaTable t) {
        if (!checkValid())
            return null;
        if (t == null) {
            long ret = LuaCApi._setMetatable(globals.L_State, nativeGlobalKey, 0);
            if (ret != 0)
                return new LuaTable(globals, ret);
            return null;
        }
        t.checkValid();
        long ret = LuaCApi._setMetatable(globals.L_State, nativeGlobalKey, t.nativeGlobalKey);
        if (ret != 0)
            return new LuaTable(globals, ret);
        return null;
    }


    @Override
    public LuaTable getMetatable() {
        if (!checkValid())
            return null;
        long ret = LuaCApi._getMetatable(globals.L_State,nativeGlobalKey);

        if (ret != 0)
            return new LuaTable(globals, ret);

        return null;
    }


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
     * 根据index清除table
     * @param index 下标
     */
    public final void remove(int index) {
        if (!checkValid())
            return;
        LuaCApi._removeTableIndex(globals.L_State,nativeGlobalKey,index);
    }

    /**
     * 清除全部数据
     */
    public final void clear() {
        if (!checkValid())
            return;
        LuaCApi._clearTable(globals.L_State,nativeGlobalKey);
    }

    /**
     * 直接使用{@link #newEntry()}获取所有key value，并获取长度
     * 若table有hash部分，推荐通过{@link #iterator()}取出数据后计算长度
     * 若想读取array部分长度，使用{@link #getn()}
     */
    @Deprecated
    public final int size() {
        return newEntry().length;
    }

    /**
     * 判断table是否为空，只要table中数组部分或hash部分不为空，返回true
     */
    public final boolean isEmpty() {
        if (!checkValid())
            return true;
        return LuaCApi._isEmpty(globals.L_State, nativeGlobalKey);
    }

    /**
     * 获取table数组部分的长度 = table.getn(table)
     * 若数组部分中间有nil，则长度不是真实长度
     * eg: {1,2,nil,4,5} 长度为2
     * @return 长度
     */
    public final int getn() {
        if (!checkValid())
            return -1;
        return LuaCApi._getTableSize(globals.L_State, nativeGlobalKey);
    }
//</editor-fold>

    //<editor-fold desc="Traverse">

    /**
     * 遍历table，一次性将table中key value全部取出来，并放入{@link Entrys}中
     * 不会返回Null
     * @see Entrys
     * Deprecated 性能很低
     * use {@link #iterator()}
     */
    @Deprecated
    public final Entrys newEntry() {
        if (!checkValidForGetSet())
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
        if (!checkValidForGetSet())
            return false;
        inTraverse = LuaCApi._startTraverseTable(globals.L_State, nativeGlobalKey);
        return inTraverse;
    }

    /**
     * 获取下一个key value对
     * 0为key，1为value
     *
     * @return 如果不存在，返回null
     */
    public final LuaValue[] next() {
        if (inTraverse)
            return LuaCApi._nextEntry(globals.L_State, this == globals);
        return null;
    }

    /**
     * 结束遍历此table
     * 若{@link #startTraverseTable}返回true，此方法必须调用
     */
    public final void endTraverseTable() {
        if (inTraverse) {
            LuaCApi._endTraverseTable(globals.L_State);
            inTraverse = false;
        }
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
                    endTraverseTable();
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

    private boolean checkValidForGetSet() {
        globals.checkMainThread();
        if (!isDestroyed() && nativeGlobalKey != 0)
            return true;
        if (MLNCore.DEBUG)
            throwNotValid();
        return false;
    }

    private boolean checkValid() {
        globals.checkMainThread();
        if (!isDestroyed() && !notInGlobalTable())
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
        if (isDestroyed())
            return "table(" + nativeGlobalKey + ") is destroyed!";
        return newEntry().toString();
    }

    @Override
    public boolean isDestroyed() {
        return globals.isDestroyed() || !checkStateByNative();
    }
}