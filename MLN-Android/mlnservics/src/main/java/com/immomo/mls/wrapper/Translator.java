/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.base.ud.lv.ILView;
import com.immomo.mls.utils.LVCallback;
import com.immomo.mls.utils.SimpleLVCallback;
import com.immomo.mls.wrapper.callback.DefaultBoolCallback;
import com.immomo.mls.wrapper.callback.DefaultIntCallback;
import com.immomo.mls.wrapper.callback.DefaultStringCallback;
import com.immomo.mls.wrapper.callback.DefaultVoidCallback;
import com.immomo.mls.wrapper.callback.IBoolCallback;
import com.immomo.mls.wrapper.callback.IIntCallback;
import com.immomo.mls.wrapper.callback.IStringCallback;
import com.immomo.mls.wrapper.callback.IVoidCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaString;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;

import java.lang.reflect.Constructor;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Xiong.Fangyu on 2019/3/15
 *
 * java 和lua userdata类型转换
 *
 * 注册转换方法：
 *  @see #registerJ2LAuto(Class)
 *  @see #registerJ2LAuto(Class, Class)
 *  @see #registerJ2L(Class, ILuaValueGetter)
 *
 *  @see #registerL2JAuto(Class)
 *  @see #registerL2J(Class, IJavaObjectGetter)
 */
public class Translator {
    private final Map<Class, ILuaValueGetter> javaToLuaMap = new HashMap<>(20);
    private final Map<Class, IJavaObjectGetter> luaToJavaMap = new HashMap<>(20);

    public static Translator fromGlobals(Globals g) {
        LuaViewManager lm = (LuaViewManager) g.getJavaUserdata();
        return lm != null ? lm.translator : null;
    }

    public Translator() {
        luaToJavaMap.put(IVoidCallback.class, DefaultVoidCallback.G);
        luaToJavaMap.put(IIntCallback.class, DefaultIntCallback.G);
        luaToJavaMap.put(IBoolCallback.class, DefaultBoolCallback.G);
        luaToJavaMap.put(IStringCallback.class, DefaultStringCallback.G);
        luaToJavaMap.put(LVCallback.class, SimpleLVCallback.G);
    }

    /**
     * 清除所有注册的转换逻辑
     */
    public void clearAll() {
        javaToLuaMap.clear();
        luaToJavaMap.clear();
        luaToJavaMap.put(IVoidCallback.class, DefaultVoidCallback.G);
        luaToJavaMap.put(IIntCallback.class, DefaultIntCallback.G);
        luaToJavaMap.put(IBoolCallback.class, DefaultBoolCallback.G);
        luaToJavaMap.put(IStringCallback.class, DefaultStringCallback.G);
        luaToJavaMap.put(LVCallback.class, SimpleLVCallback.G);
    }

    //<editor-fold desc="translate methods">

    /**
     * 将Lua数据转成java数据类型
     * @param lv    lua原始数据 non null non nil
     * @param clz   java接收类型的类对象
     * @param <T>   java接收类型
     * @return nullable
     */
    public <T> T translateLuaToJava(LuaValue lv, Class<T> clz) {
        if (LuaValue.class.isAssignableFrom(clz))
            return (T) lv;
        IJavaObjectGetter getter = luaToJavaMap.get(clz);
        if (getter == null) {
            if (Map.class.isAssignableFrom(clz)) {
                getter = luaToJavaMap.get(Map.class);
            } else if (List.class.isAssignableFrom(clz)) {
                getter = luaToJavaMap.get(List.class);
            }
        }
        if (getter != null)
            return (T) getter.getJavaObject(lv);
        if (lv.isUserdata()) {
            Object u = lv.toUserdata().getJavaUserdata();
            if (clz.isInstance(u)) return (T) u;
        }
        return null;
    }

    /**
     * 将java数据类型转成Lua数据类型
     * @param g 虚拟机
     * @param o java原始数据
     * @return non null
     */
    public LuaValue translateJavaToLua(Globals g, Object o) {
        if (o == null)
            return LuaValue.Nil();
        if (o instanceof LuaValue)
            return (LuaValue) o;
        if (o instanceof ILView) {
            return ((ILView) o).getUserdata();
        }

        ILuaValueGetter con = javaToLuaMap.get(o.getClass());
        if (con == null) {
            if (o instanceof Map) {
                con = javaToLuaMap.get(Map.class);
            } else if (o instanceof List) {
                con = javaToLuaMap.get(List.class);
            }
        }
        if (con != null) {
            LuaValue v = con.newInstance(g, o);
            if (v == null)
                throw new NullPointerException();
            return v;
        }
        return LuaValue.Nil();
    }

    /**
     * 将java数据类型转成Lua数据类型
     * @param g 虚拟机
     * @param o java原始数据
     * @param c java数据类型
     * @return non null
     */
    public LuaValue translateJavaToLua(Globals g, Object o, Class c) {
        if (o == null)
            return LuaValue.Nil();
        if (o instanceof LuaValue)
            return (LuaValue) o;
        if (o instanceof ILView) {
            return ((ILView) o).getUserdata();
        }

        ILuaValueGetter con = javaToLuaMap.get(c);
        if (con != null) {
            LuaValue v = con.newInstance(g, o);
            if (v == null)
                throw new NullPointerException();
            return v;
        }
        return LuaValue.Nil();
    }

    /**
     * 检查java类型是否是lua基本数据类型
     * 支持 java的基本数据类型和String类型
     * @param o nonnull
     */
    public static boolean isPrimitiveLuaData(Object o) {
        return o instanceof Boolean
                || o instanceof Number
                || o instanceof Character
                || o instanceof String;
    }

    /**
     * 基本数据类型转换
     * 支持 java的基本数据类型和String类型
     * @param o non null
     * @return nullable
     * @see #isPrimitiveLuaData
     */
    public static LuaValue translatePrimitiveToLua(Object o) {
        Class clz = o.getClass();
        if (clz == Boolean.class) {
            return ((boolean) o) ? LuaValue.True() : LuaValue.False();
        }
        if (Number.class.isAssignableFrom(clz)) {
            return LuaNumber.valueOf(((Number)o).doubleValue());
        }
        if (clz == Character.class) {
            return LuaNumber.valueOf((Character) o);
        }
        if (clz == String.class) {
            return LuaString.valueOf(o.toString());
        }
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="register java to lua object">

    /**
     * 注册java对象转换成lua对象的转换方式
     * 为此类创建默认构建lua对象的方式{@link DefaultGetter}
     *
     * 此对象必须在{@link Register}中注册过
     *
     * @see #registerJ2LAuto(Class, Class)
     * @see #registerJ2L(Class, ILuaValueGetter)
     */
    public synchronized void registerJ2LAuto(Class clz) {
        registerJ2LAuto(clz, Register.getUDClass(clz));
    }

    /**
     * 注册java对象转换成lua对象的转换方式
     * 为此类创建默认构建lua对象的方式{@link DefaultGetter}
     *
     * @see #registerJ2L(Class, ILuaValueGetter)
     */
    public void registerJ2LAuto(Class clz, Class<? extends LuaUserdata> udClz) {
        registerJ2L(clz, new DefaultGetter(udClz));
    }

    /**
     * 注册java对象转换成lua对象的转换方式
     * @param clz java类
     * @param con LuaUserdata生成方式
     */
    public synchronized void registerJ2L(Class clz, ILuaValueGetter con) {
        javaToLuaMap.put(clz, con);
    }
    //</editor-fold>

    //<editor-fold desc="register lua to java object">

    /**
     * 注册lua对象转换成java对象的转换方式
     *
     * 为clz创建默认转换对象{@link DefaultUserdataGetter}
     *
     * @see #registerL2J(Class, IJavaObjectGetter)
     */
    public synchronized void registerL2JAuto(Class clz) {
        registerL2J(clz, new DefaultUserdataGetter());
    }

    /**
     * 注册lua对象转换成java对象的转换方式
     * @param clz    java类
     * @param getter 从LuaUserdata转换成java对象的转换方式
     */
    public synchronized void registerL2J(Class clz, IJavaObjectGetter getter) {
        luaToJavaMap.put(clz, getter);
    }
    //</editor-fold>

    /**
     * 默认构造器，使用反射
     */
    private static final class DefaultGetter implements ILuaValueGetter<LuaUserdata, Object> {
        Constructor<? extends LuaUserdata> con;

        DefaultGetter(Class<? extends LuaUserdata> udClz) {
            try {
                con = udClz.getConstructor(Globals.class, Object.class);
            } catch (Throwable e) {
                e.printStackTrace();
            }
        }

        @Override
        public LuaUserdata newInstance(Globals g, Object obj) {
            try {
                return con.newInstance(g, obj);
            } catch (Throwable e) {
                throw new RuntimeException(e);
            }
        }
    }

    /**
     * 使用{@link LuaUserdata#getJavaUserdata()}方式直接获取
     */
    private static final class DefaultUserdataGetter implements IJavaObjectGetter<LuaUserdata, Object> {

        @Override
        public Object getJavaObject(LuaUserdata lv) {
            Object ret = lv.getJavaUserdata();
            lv.destroy();
            return ret;
        }
    }
}