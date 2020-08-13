/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.util.LogUtil;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.utils.BindingConvertUtils;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Created by MLN Template
 * 注册方法：
 * new Register.NewStaticHolder(LTCDataBinding.LUA_CLASS_NAME, LTCDataBinding.class)
 */
@LuaApiUsed
public class LTCDataBinding {
    /**
     * Lua类名
     */
    public static final String LUA_CLASS_NAME = "DataBinding";

    /**
     * 初始化方法
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     *
     * @param l 虚拟机C层地址
     * @see Globals#getL_State()
     */
    public static native void _register(long l);
    //</editor-fold>

    private static class Callback implements IPropertyCallback {
        DataBindingCallback callback = null;
        private final long L;
        private final long fun;
        private final Globals globals;
        private final String key;

        private Callback(Globals g, long fun, String key) {
            this.L = g.getL_State();
            this.fun = fun;
            this.globals = g;
            this.key = key;
        }

        @Override
        public void callBack(Object old, Object news) {
            if (DataBinding.isLog) {
                Log.d(DataBinding.TAG, "callBack" + key);
            }

            if (callback == null) {
                callback = new DataBindingCallback(L, fun);
            }

            if (old == null && news == null) {
                callback.fastInvoke(0, 0);
                return;
            }

            if (old != null) {
                switch (isSameTypeParams(old, news)) {
                    case 1:
                        callback.fastInvoke((Boolean) news, (Boolean) old);
                        break;
                    case 2:
                        callback.fastInvoke(((Number) news).doubleValue(), ((Number) old).doubleValue());
                        break;
                    case 3:
                        callback.fastInvoke((Character) news, (Character) old);
                        break;
                    case 4:
                        callback.fastInvoke((String) news, (String) old);
                        break;
                    case 5:
                        callback.fastInvoke(news != null ? BindingConvertUtils.toTable(globals, (Map) news).nativeGlobalKey() : 0,
                                BindingConvertUtils.toTable(globals, (Map) old).nativeGlobalKey());
                        break;
                    case 6:
                        callback.fastInvoke(news != null ? BindingConvertUtils.toTable(globals, (List) news).nativeGlobalKey() : 0,
                                BindingConvertUtils.toTable(globals, (Map) old).nativeGlobalKey());
                        break;
                    case 7:
                        callback.fastInvoke(news != null ? BindingConvertUtils.toTable(globals, (List) news).nativeGlobalKey() : 0,
                                BindingConvertUtils.toTable(globals, (List) old).nativeGlobalKey());
                        break;
                    case 8:
                        callback.fastInvoke(news != null ? BindingConvertUtils.toTable(globals, (Map) news).nativeGlobalKey() : 0,
                                BindingConvertUtils.toTable(globals, (List) old).nativeGlobalKey());
                        break;
                    default:
                        callback.invoke(LuaValue.varargsOf(BindingConvertUtils.toLuaValue(globals,news), BindingConvertUtils.toLuaValue(globals,old)));
                        break;
                }
            } else {// if news != null and old == null
                switch (isSameTypeParams(news, old)) {
                    case 4:
                        callback.fastInvoke((String) news, (String) old);
                        break;
                    case 5:
                    case 6:
                        callback.fastInvoke(BindingConvertUtils.toTable(globals, (Map) news).nativeGlobalKey(),
                                0);
                        break;
                    case 7:
                    case 8:
                        callback.fastInvoke(BindingConvertUtils.toTable(globals, (List) news).nativeGlobalKey(),
                                0);
                        break;
                    default:
                        callback.invoke(LuaValue.varargsOf(BindingConvertUtils.toLuaValue(globals,news)));
                        break;
                }
            }
        }

        /**
         * 1: boolean
         * 2: number
         * 3: char
         * 4: string
         * 5: map map
         * 6: map list
         * 7: list list
         * 8: list map
         */
        private int isSameTypeParams(@NonNull Object a, Object b) {
            if (a instanceof Boolean) {
                if (b == null)
                    return -1;
                if (b instanceof Boolean)
                    return 1;
                return -1;
            }
            if (a instanceof Number) {
                if (b == null)
                    return -1;
                if (b instanceof Number)
                    return 2;
                return -1;
            }
            if (a instanceof Character) {
                if (b == null)
                    return -1;
                if (b instanceof Character)
                    return 3;
                return -1;
            }
            if (a instanceof String) {
                if (b == null || b instanceof String)
                    return 4;
                return -1;
            }
            if (a instanceof Map) {
                if (b == null || b instanceof Map)
                    return 5;
                if (b instanceof List)
                    return 6;
                return -1;
            }
            if (a instanceof List) {
                if (b == null || b instanceof List)
                    return 7;
                if (b instanceof Map)
                    return 8;
            }
            return -1;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            Callback callback = (Callback) o;
            return L == callback.L &&
                    fun == callback.fun;
        }

        @Override
        public int hashCode() {
            return Objects.hash(L, fun);
        }
    }
    //<editor-fold desc="Bridge API">

    /**
     * todo 去重
     * 1、key和fun都相同，存储的时候去重
     * 2、key不同，fun相同，回调的时候去重
     */
    @LuaApiUsed
    static String watch(final long L, String key, final long fun) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "watch---" + key + "---" + fun);
        }
        final Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.watch(globals, key, new Callback(globals, fun, key));
    }

    /**
     * 通过key更改值
     *
     * @param L
     * @param key
     * @param value
     */
    @LuaApiUsed
    static void update(final long L, String key, LuaValue value) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"update---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.update(globals, key, BindingConvertUtils.toNativeValue(value));
    }

    /**
     * 通过key，获取值
     *
     * @param L
     * @param key
     * @return
     */
    @LuaApiUsed
    static LuaValue get(final long L, String key) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"get---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        return BindingConvertUtils.toLuaValue(globals, DataBinding.get(globals, key));
    }


    /**
     * 数组插入数据
     *
     * @param L
     * @param key
     * @param index
     * @param luaValue
     */
    @LuaApiUsed
    static void insert(final long L, String key, int index, LuaValue luaValue) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"insert---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.insert(globals, key, index, BindingConvertUtils.toNativeValue(luaValue));
    }


    /**
     * 数组移除数据
     *
     * @param L
     * @param key
     * @param index
     */
    @LuaApiUsed
    static void remove(final long L, String key, int index) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"remove---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.remove(globals, key, index);
    }


    /**
     * 绑定listView
     *
     * @param L
     * @param key
     * @param view
     */
    @LuaApiUsed
    static void bindListView(final long L, String key, UDView view) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"bindListView---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.bindListView(globals, key, view);
    }


    /**
     * 获取section的数量
     *
     * @param L
     * @param key
     * @return
     */
    @LuaApiUsed
    static int getSectionCount(final long L, String key) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"getSectionCount---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.getSectionCount(globals, key);
    }


    /**
     * 通过section获取row的数量
     *
     * @param L
     * @param key
     * @param section
     * @return
     */
    @LuaApiUsed
    static int getRowCount(final long L, String key, int section) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"getRowCount---" + key + "section---" + section);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.getRowCount(globals, key, section - 1);
    }


    /**
     * 绑定cell
     *
     * @param L
     * @param key
     * @param section
     * @param row
     * @param luaTable
     */
    @LuaApiUsed
    static void bindCell(final long L, String key, int section, int row, LuaTable luaTable) {
        Globals globals = Globals.getGlobalsByLState(L);
        List<String> bindProperties = BindingConvertUtils.toFastObservableList(luaTable);
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"bindCell---" + key + "section---" + section + "row---" +row + "properties" + bindProperties.toString());
        }
        DataBinding.bindCell(globals, key, section, row, bindProperties);
    }


    /**
     * mock 数据
     *
     * @param L
     * @param key
     * @param luaTable
     */
    @LuaApiUsed
    static void mock(final long L, String key, LuaTable luaTable) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"mock---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.mock(globals, key, BindingConvertUtils.toFastObservableMap(luaTable));
    }


    /**
     * mock 数组数据（）
     *
     * @param L
     * @param key
     * @param luaTable
     * @param callBack
     */
    @LuaApiUsed
    static void mockArray(final long L, String key, LuaTable luaTable, LuaTable callBack) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"mockArray---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.mockArray(globals, key, BindingConvertUtils.toFastObservableList(luaTable), BindingConvertUtils.toFastObservableMap(callBack));
    }


    @LuaApiUsed
    static int arraySize(final long L, String key) {
        if(DataBinding.isLog) {
            Log.d(DataBinding.TAG,"arraySize---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.arraySize(globals, key);
    }


    @LuaApiUsed
    static void removeObserver(final long L, String key) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "removeObserver---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.removeObserver(globals, key);
    }


    //</editor-fold>

    /**
     * 获取上下文，一般情况，此上下文为Activity
     *
     * @param globals 虚拟机，可通过构造函数存储
     */
    protected static Context getContext(@NonNull Globals globals) {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }
}