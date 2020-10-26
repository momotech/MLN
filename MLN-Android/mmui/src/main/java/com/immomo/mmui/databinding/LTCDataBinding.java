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
import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.databinding.bean.ObservableList;
import com.immomo.mmui.databinding.bean.ObservableMap;
import com.immomo.mmui.databinding.filter.ArgoContextFilter;
import com.immomo.mmui.databinding.filter.IWatchKeyFilter;
import com.immomo.mmui.databinding.interfaces.IPropertyCallback;
import com.immomo.mmui.databinding.utils.BindingConvertUtils;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.List;
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
     * 反射调用
     *
     * @see com.immomo.mls.wrapper.Register.NewStaticHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     *
     * @see com.immomo.mls.wrapper.Register.NewStaticHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>
    //<editor-fold desc="Bridge API">

    /**
     * 监听更改值的行为
     *
     * @param L
     * @param key
     * @param fun
     * @return
     */
    @CGenerate(params = "G0F")
    @LuaApiUsed
    static String watch(final long L, String key, final long fun) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "watchAction---" + key + "---" + fun);
        }
        final Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.watch(globals, key, new ArgoContextFilter(WatchContext.ArgoWatch_native), new Callback(globals, fun, key));
    }


    /**
     * 监听更改值的行为（带有过滤器）
     *
     * @param L
     * @param key
     * @param filterFun
     * @param fun
     * @return
     */
    @CGenerate(params = "G0FF")
    @LuaApiUsed
    static String watch(final long L, String key, final long filterFun, final long fun) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "watch---" + key + "---" + fun);
        }
        final Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.watch(globals, key, new FilterCallBack(globals, filterFun), new Callback(globals, fun, key));
    }


    /**
     * 监听值改变
     *
     * 1、key和fun都相同，存储的时候去重
     * 2、key不同，fun相同，回调的时候去重
     */
    @CGenerate(params = "G0F")
    @LuaApiUsed
    static String watchValue(final long L, String key, final long fun) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "watchValue---" + key + "---" + fun);
        }
        final Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.watchValue(globals, key, new ArgoContextFilter(WatchContext.ArgoWatch_native), new Callback(globals, fun, key));
    }


    /**
     * 监听值改变 （带有过滤器）
     * @param L
     * @param key
     * @param filterFun
     * @param callBackFun
     * @return
     */
    @CGenerate(params = "G0FF")
    @LuaApiUsed
    static String watchValue(final long L, String key, final long filterFun, final long callBackFun) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "watchValue---" + key + "---");
        }
        final Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.watchValue(globals, key, new FilterCallBack(globals, filterFun), new Callback(globals, callBackFun, key));
    }


    /**
     * 监听更改值的行为
     *
     * @param L
     * @param key
     * @param fun
     * @return
     */
    @CGenerate(params = "G0F")
    @LuaApiUsed
    static String watchValueAll(final long L, String key, final long fun) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "watchValueAll---" + key + "---" + fun);
        }
        final Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.watchValue(globals, key, null, new Callback(globals, fun, key));
    }


    /**
     * 通过key更改值
     *
     * @param L
     * @param key
     * @param value
     */
    @CGenerate(params = "G")
    @LuaApiUsed
    static void update(final long L, String key, LuaValue value) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "update---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.update(globals, key, BindingConvertUtils.toNativeValue(value, false));
    }

    /**
     * 通过key，获取值
     *
     * @param L
     * @param key
     * @return
     */
    @CGenerate(params = "G")
    @LuaApiUsed
    static LuaValue get(final long L, String key) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "get---" + key);
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
    @CGenerate(params = "G")
    @LuaApiUsed
    static void insert(final long L, String key, int index, LuaValue luaValue) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "insert---" + "index---" + index + "key---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.insert(globals, key, index, BindingConvertUtils.toNativeValue(luaValue, false));
    }


    /**
     * 数组移除数据
     *
     * @param L
     * @param key
     * @param index
     */
    @CGenerate(params = "G")
    @LuaApiUsed
    static void remove(final long L, String key, int index) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "remove---" + key + "index---" + index);
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
    @CGenerate(params = "G")
    @LuaApiUsed
    static void bindListView(final long L, String key, UDView view) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "bindListView---" + key);
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
    @CGenerate(params = "G")
    @LuaApiUsed
    static int getSectionCount(final long L, String key) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "getSectionCount---" + key);
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
    @CGenerate(params = "G")
    @LuaApiUsed
    static int getRowCount(final long L, String key, int section) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "getRowCount---" + key + "section---" + section);
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
    @CGenerate(params = "G")
    @LuaApiUsed
    static void bindCell(final long L, String key, int section, int row, LuaTable luaTable) {
        Globals globals = Globals.getGlobalsByLState(L);
        List<String> bindProperties = BindingConvertUtils.toFastObservableList(luaTable, true);
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "bindCell---" + key + "section---" + section + "row---" + row + "properties" + bindProperties.toString());
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
    @CGenerate(params = "G")
    @LuaApiUsed
    static void mock(final long L, String key, LuaTable luaTable) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "mock---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.mock(globals, key, BindingConvertUtils.toFastObservableMap(luaTable, true));
    }


    /**
     * mock 数组数据（）
     *
     * @param L
     * @param key
     * @param luaTable
     * @param callBack
     */
    @CGenerate(params = "G")
    @LuaApiUsed
    static void mockArray(final long L, String key, LuaTable luaTable, LuaTable callBack) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "mockArray---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.mockArray(globals, key, BindingConvertUtils.toFastObservableList(luaTable, true), BindingConvertUtils.toFastObservableMap(callBack, true));
    }


    @CGenerate(params = "G")
    @LuaApiUsed
    static int arraySize(final long L, String key) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "arraySize---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        return DataBinding.arraySize(globals, key);
    }


    @CGenerate(params = "G")
    @LuaApiUsed
    static void removeObserver(final long L, String key) {
        if (DataBinding.isLog) {
            Log.d(DataBinding.TAG, "removeObserver---" + key);
        }
        Globals globals = Globals.getGlobalsByLState(L);
        DataBinding.removeObserver(globals, key);
    }


    //</editor-fold>

    private static class Callback implements IPropertyCallback {
        LuaFunction callback = null;
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
                callback = new LuaFunction(L, fun);
            }

            // 与ios统一 只回传news
            if (old == null && news == null) {
                callback.fastInvoke();
                return;
            }


            switch (isSameTypeParams(news, old)) {
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
                    callback.fastInvoke((String) news, null);
                    break;
                case 5:
                case 6:
                    callback.fastInvoke(BindingConvertUtils.toLuaValue(globals, news), LuaValue.Nil());
                    break;

                default:
                    callback.invoke(LuaValue.varargsOf(BindingConvertUtils.toLuaValue(globals, news)));
                    break;
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
            if (a instanceof ObservableMap) {
                return 5;
            }
            if (a instanceof ObservableList) {
                return 6;
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


    public static class FilterCallBack implements IWatchKeyFilter {
        LuaFunction callback = null;
        private final long L;
        private final long fun;
        private final Globals globals;

        public FilterCallBack(Globals g, long fun) {
            this.L = g.getL_State();
            this.fun = fun;
            this.globals = g;
        }

        @Override
        public boolean call(int argoWatchContext, String key, Object newer) {
            if (callback == null) {
                callback = new LuaFunction(L, fun);
            }
            LuaValue[] result = callback.invoke(LuaValue.varargsOf(LuaNumber.valueOf(argoWatchContext), BindingConvertUtils.toLuaValue(globals, newer)));
            return result[0].toBoolean();
        }
    }


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