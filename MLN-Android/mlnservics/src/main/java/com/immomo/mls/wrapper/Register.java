/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.ud.view.UDView;

import org.luaj.vm2.Globals;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;
import org.luaj.vm2.utils.SignatureUtils;
import org.luaj.vm2.utils.SizeOfUtils;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Xiong.Fangyu on 2019/3/18
 * <p>
 * lua userdata或bridge注册器
 * 提前注册并提取，在创建{@link Globals}后调用{@link #install(Globals)}将提前注册的库放入虚拟机中
 * <p>
 * 可提前初始化lua中需要的java库
 */
public class Register {
    private static final String UD_CLASS_SUFFIX = "_udwrapper";
    private static final String SB_CLASS_SUFFIX = "_sbwrapper";
    private static final String METHODS_FIELD = "methods";
    private static final Map<Class, Class<? extends LuaUserdata>> udClassMap = new HashMap<>(20);

    private final List<SHolder> sHolders = new ArrayList<>(20);
    private final List<StringEnumHolder> seHolders = new ArrayList<>(10);
    private final List<NumberEnumHolder> neHolders = new ArrayList<>(10);
    private final List<SIHolder> siHolders = new ArrayList<>(10);

    private final HashMap<Class, String> luaClassNameMap = new HashMap<>();
    private final AllUserdataHolder allUserdataHolder = new AllUserdataHolder();
    private final AllUserdataHolder lvUserdataHolder = new AllUserdataHolder();

    private boolean preInstall = false;
    /**
     * 清除所有注册的东西
     */
    public void clearAll() {
        sHolders.clear();
        seHolders.clear();
        neHolders.clear();
        siHolders.clear();
        udClassMap.clear();
        luaClassNameMap.clear();
        allUserdataHolder.clear();
        lvUserdataHolder.clear();
    }

    /**
     * 是否有注册过luaview
     */
    public boolean isInit() {
        return lvUserdataHolder.index > 0;
    }

    public boolean isPreInstall() {
        return preInstall;
    }

    //<editor-fold desc="check">
    private static boolean checkUD(Class clz, String methodName) {
        return checkClassMethod(clz, methodName, LuaValue[].class);
    }

    private static boolean checkSC(Class clz, String methodName) {
        return checkClassMethod(clz, methodName, long.class, LuaValue[].class);
    }

    private static boolean checkClassMethod(Class clz, String mn, Class... pc) {
        Method m = null;
        try {
            m = clz.getMethod(mn, pc);
        } catch (NoSuchMethodException ignore) {
        }
        if (m == null) {
            try {
                m = clz.getDeclaredMethod(mn, pc);
            }  catch (NoSuchMethodException ignore) {
            }
        }
        if (m == null) return false;
        if (m.getAnnotation(LuaApiUsed.class) == null) {
            clz = clz.getSuperclass();
            if (LuaUserdata.class == clz || JavaUserdata.class == clz) {
                return false;
            }
            return checkClassMethod(clz, mn, pc);
        }
        return true;
    }

    private static void checkClassMethods(Class clz, String[] methods, boolean ud) {
        String name = clz.getSimpleName();
        if (clz.getAnnotation(LuaApiUsed.class) == null) {
            throw new ProGuardError("Throw in debug! No @LuaApiUsed in class " + clz.getName());
        }
        if (methods == null || methods.length == 0)
            return;

        try {
            for (String mn : methods) {
                if (ud) {
                    if (!checkUD(clz, mn)) {
                        throw new Exception(name + "." + mn + " has no LuaApiUsed annotation!");
                    }
                } else {
                    if (!checkSC(clz, mn)) {
                        throw new Exception(name + "." + mn + " has no LuaApiUsed annotation!");
                    }
                }
            }
        } catch (Exception e) {
            throw new ProGuardError("Throw in debug! " + e.getMessage());
        }
    }
    //</editor-fold>

    //<editor-fold desc="userdata">

    /**
     * 注册userdata
     * <p>
     * 必须有此构造方法
     * public Name(Globals g, LuaValue[] init) {}
     * <p>
     * 在lua中，只有一个名称对应相关类
     * 类中必须含有{@link com.immomo.mls.annotation.LuaClass} 和 {@link com.immomo.mls.annotation.LuaBridge}注解
     * 编译器将通过lprocess库生成相关代码
     *
     * @see #registerUserdata(Class, boolean, String...)
     */
    public void registerUserdata(String luaClassName, boolean lazy, Class clz) throws RegisterError {
        registerUserdata(clz, lazy, luaClassName);
    }

    /**
     * 注册userdata
     * <p>
     * 必须有此构造方法
     * public Name(Globals g, LuaValue[] init) {}
     * <p>
     * 可有多个名称对应同一个java class
     * 类中必须含有{@link com.immomo.mls.annotation.LuaClass} 和 {@link com.immomo.mls.annotation.LuaBridge}注解
     * 编译器将通过lprocess库生成相关代码
     *
     * @param clz          相关类
     * @param lazy         是否懒注册
     * @param luaClassName lua中类名
     */
    public void registerUserdata(Class clz, boolean lazy, String... luaClassName) throws RegisterError {
        final String wrapperName = clz.getName() + UD_CLASS_SUFFIX;
        try {
            Class<? extends LuaUserdata> udClz = (Class<? extends LuaUserdata>) Class.forName(wrapperName);
            Field f = udClz.getDeclaredField(METHODS_FIELD);
            String[] ms = (String[]) f.get(null);
            for (String s : luaClassName) {
                UDHolder h = new UDHolder(s, udClz, lazy, ms);
                h.needCheck = false;
                registerUserdata(h);
            }
            udClassMap.put(clz, udClz);
        } catch (Throwable e) {
            throw new RegisterError(e);
        }
    }

    /**
     * 注册userdata，其中信息由{@link UDHolder}包裹
     *
     * @see #newUDHolder(String, Class, boolean, String...)
     */
    public void registerUserdata(UDHolder holder) {
        if (MLSEngine.DEBUG && holder.needCheck)
            checkClassMethods(holder.clz, holder.methods, true);
        if (UDView.class.isAssignableFrom(holder.clz)) {
            lvUserdataHolder.add(holder);
        } else {
            SizeOfUtils.sizeof(holder.clz);
            allUserdataHolder.add(holder);
        }
    }

    /**
     * 创建包裹userdata信息的对象
     *
     * @param lcn     lua类名
     * @param clz     java中类名，必须继承自{@link LuaUserdata}
     * @param lazy    是否是懒注册
     * @param methods 类中所有方法
     */
    public static UDHolder newUDHolder(String lcn, Class<? extends LuaUserdata> clz, boolean lazy, String... methods) {
        return new UDHolder(lcn, clz, lazy, methods);
    }

    /**
     * 创建包裹userdata信息的对象
     * 注意：未按要求写的接口，不会增加到lua接口中
     * @param lcn   lua类名
     * @param clz   java中类名，必须继承自{@link LuaUserdata}
     * @param lazy  是否是懒注册
     */
    public static UDHolder newUDHolderAuto(String lcn, Class<? extends LuaUserdata> clz, boolean lazy) {
        Method[] methods = clz.getDeclaredMethods();
        List<String> msl = new ArrayList<>(methods.length);
        for (Method m : methods) {
            if (((m.getModifiers() & Modifier.STATIC) != Modifier.STATIC)
                    && m.getAnnotation(LuaApiUsed.class) != null
                    && checkUD(clz, m.getName())) {
                msl.add(m.getName());
            }
        }
        UDHolder h = new UDHolder(lcn, clz, lazy, msl.toArray(new String[0]));
        h.needCheck = false;
        return h;
    }

    /**
     * 创建包裹userdata信息的对象
     * <p>
     * 必须有此构造方法
     * public Name(Globals g, LuaValue[] init) {}
     * <p>
     *
     * @param lcn  lua类名
     * @param clz  java类
     * @param lazy 是否懒注册
     */
    public static UDHolder newUDHolderWithLuaClass(String lcn, Class clz, boolean lazy) {
        final String wrapperName = clz.getName() + UD_CLASS_SUFFIX;
        try {
            Class<? extends LuaUserdata> udClz = (Class<? extends LuaUserdata>) Class.forName(wrapperName);
            Field f = udClz.getDeclaredField(METHODS_FIELD);
            String[] ms = (String[]) f.get(null);
            udClassMap.put(clz, udClz);
            UDHolder h = new UDHolder(lcn, udClz, lazy, ms);
            h.needCheck = false;
            return h;
        } catch (Throwable e) {
            throw new RegisterError(e);
        }
    }
    //</editor-fold>

    //<editor-fold desc="Static bridge">

    /**
     * 注册静态bridge
     * class中必须含有{@link com.immomo.mls.annotation.LuaClass} 和 {@link com.immomo.mls.annotation.LuaBridge}注解
     * 编译器将通过lprocess库生成相关代码
     */
    public void registerStaticBridge(String luaClassName, Class clz) {
        final String wrapperName = clz.getName() + SB_CLASS_SUFFIX;
        try {
            Class sclz = Class.forName(wrapperName);
            Field f = sclz.getDeclaredField(METHODS_FIELD);
            String[] ms = (String[]) f.get(null);
            registerStaticBridge(new SHolder(luaClassName, sclz, ms));
        } catch (Throwable e) {
            throw new RegisterError(e);
        }
    }

    /**
     * 注册静态bridge，其中信息由{@link SHolder}包裹
     *
     * @see #newSHolder(String, Class, String...)
     */
    public void registerStaticBridge(SHolder holder) {
        if (MLSEngine.DEBUG && holder.needCheck)
            checkClassMethods(holder.clz, holder.methods, false);
        sHolders.add(holder);
    }

    /**
     * 创建包裹静态bridge信息的对象
     *
     * @param lcn     lua类名
     * @param clz     java类
     * @param methods 所有方法，必须是静态方法
     */
    public static SHolder newSHolder(String lcn, Class clz, String... methods) {
        return new SHolder(lcn, clz, methods);
    }

    /**
     * 创建包裹静态bridge信息的对象
     * 注意：未按要求写的接口，不会增加到lua接口中
     * @param lcn   lua类名
     * @param clz   java类
     */
    public static SHolder newSHolderAuto(String lcn, Class clz) {
        Method[] methods = clz.getDeclaredMethods();
        List<String> lms = new ArrayList<>(methods.length);
        for (Method m : methods) {
            if (((m.getModifiers() & Modifier.STATIC) == Modifier.STATIC)
                    && m.getAnnotation(LuaApiUsed.class) != null
                    && checkSC(clz, m.getName())) {
                lms.add(m.getName());
            }
        }
        SHolder h = new SHolder(lcn, clz, lms.toArray(new String[0]));
        h.needCheck = false;
        return h;
    }

    /**
     * 创建包裹静态bridge信息的对象
     * class中必须含有{@link com.immomo.mls.annotation.LuaClass} 和 {@link com.immomo.mls.annotation.LuaBridge}注解
     *
     * @param lcn lua类名
     * @param clz java类
     */
    public static SHolder newSHolderWithLuaClass(String lcn, Class clz) {
        final String wrapperName = clz.getName() + SB_CLASS_SUFFIX;
        try {
            Class sclz = Class.forName(wrapperName);
            Field f = sclz.getDeclaredField(METHODS_FIELD);
            String[] ms = (String[]) f.get(null);
            SHolder s = new SHolder(lcn, sclz, ms);
            s.needCheck = false;
            return s;
        } catch (Throwable e) {
            throw new RegisterError(e);
        }
    }
    //</editor-fold>

    //<editor-fold desc="Cache Static Bridge (Single instance userdata)">

    /**
     * 注册单例
     *
     * @param luaClassName lua通过这个名称获取单例
     * @param clz          java类
     */
    public void registerSingleInstance(String luaClassName, Class clz) throws RegisterError {
        String realLuaClassName = "__" + luaClassName;
        registerUserdata(clz, false, realLuaClassName);
        registerSingleInstance(new SIHolder(luaClassName, realLuaClassName));
    }

    /**
     * 注册单例
     *
     * @param holder userdata包裹信息
     * @param key    lua通过这个名称获取单例
     */
    public void registerSingleInstance(UDHolder holder, String key) {
        registerUserdata(holder);
        registerSingleInstance(new SIHolder(key, holder.luaClassName));
    }

    /**
     * 注册单例
     *
     * @param h 单例包裹信息
     * @see #newSingleInstanceHolder(String, String)
     */
    public void registerSingleInstance(SIHolder h) {
        siHolders.add(h);
    }

    /**
     * 生成单例包裹信息
     *
     * @param luaKey       lua通过这个名称获取单例
     * @param luaClassName 已注册的lua类名
     * @return 包裹信息
     */
    public static SIHolder newSingleInstanceHolder(String luaKey, String luaClassName) {
        return new SIHolder(luaKey, luaClassName);
    }

    //</editor-fold>

    //<editor-fold desc="Enum">

    /**
     * 注册枚举
     * 枚举class必须有 {@link ConstantClass}注解
     * 常量必须是数字类型，或String类型，且由 {@link Constant}注解
     */
    public void registerEnum(Class clz) {
        ConstantClass cc = (ConstantClass) clz.getAnnotation(ConstantClass.class);
        if (cc == null) {
            throw new RegisterError("register enum failed! class must have a ConstantClass annotation. Class:" + clz.getName());
        }
        Field[] fields = clz.getDeclaredFields();
        final int len = fields == null ? 0 : fields.length;
        if (len == 0)
            return;
        String alias = cc.alias();
        final String lcn = isEmpty(alias) ? clz.getSimpleName() : alias;
        String[] keys = new String[len];
        int nullValue = 0;
        Class c = fields[0].getType();
        if (c.isPrimitive()) {
            double[] values = new double[len];
            try {
                for (int i = 0; i < len; i++) {
                    Field f = fields[i];
                    Constant ca = f.getAnnotation(Constant.class);
                    if (ca == null) {
                        nullValue++;
                        continue;
                    }
                    values[i - nullValue] = ((Number) f.get(null)).doubleValue();
                    alias = ca.alias();
                    keys[i - nullValue] = isEmpty(alias) ? f.getName() : alias;
                }
            } catch (Throwable e) {
                throw new RegisterError("register enum error in " + clz.getName(), e);
            }
            if (nullValue != 0) {
                if (len - nullValue <= 0)
                    return;
                String[] ks = new String[len - nullValue];
                double[] vs = new double[len - nullValue];
                System.arraycopy(keys, 0, ks, 0, ks.length);
                System.arraycopy(values, 0, vs, 0, vs.length);
                keys = ks;
                values = vs;
            }
            registerEnum(lcn, keys, values);
            return;
        } else if (c.equals(String.class)) {
            String[] values = new String[len];
            try {
                for (int i = 0; i < len; i++) {
                    Field f = fields[i];
                    Constant ca = f.getAnnotation(Constant.class);
                    if (ca == null) {
                        nullValue++;
                        continue;
                    }
                    values[i - nullValue] = (String) f.get(null);
                    alias = ca.alias();
                    keys[i - nullValue] = isEmpty(alias) ? f.getName() : alias;
                }
            } catch (Throwable e) {
                throw new RegisterError("register enum error in " + clz.getName(), e);
            }
            if (nullValue != 0) {
                if (len - nullValue <= 0)
                    return;
                String[] ks = new String[len - nullValue];
                String[] vs = new String[len - nullValue];
                System.arraycopy(keys, 0, ks, 0, ks.length);
                System.arraycopy(values, 0, vs, 0, vs.length);
                keys = ks;
                values = vs;
            }
            registerEnum(lcn, keys, values);
            return;
        }
        throw new RegisterError("constant type must be number type or String, Class: " + clz.getName() + " field[0] class: " + c.getName());
    }

    private static boolean isEmpty(String s) {
        return s == null || s.length() == 0;
    }

    /**
     * 注册字符串型枚举
     */
    public void registerEnum(String luaClassName, String[] keys, String[] values) {
        seHolders.add(new StringEnumHolder(luaClassName, keys, values));
    }

    /**
     * 注册数字型枚举
     */
    public void registerEnum(String luaClassName, String[] keys, double[] values) {
        neHolders.add(new NumberEnumHolder(luaClassName, keys, values));
    }
    //</editor-fold>

    /**
     * 若使用{@link #registerUserdata(String, boolean, Class)} 或 {@link #registerUserdata(Class, boolean, String...)}
     * 注册userdata，则会将普通类与ud类对应，放入{@link #udClassMap}中
     * 获取对应ud类
     *
     * @param clz 普通类
     * @return nullable
     * @see Translator#registerJ2LAuto
     */
    public static Class<? extends LuaUserdata> getUDClass(Class clz) {
        return udClassMap.get(clz);
    }

    /**
     * 创建Globals后，将提前注册的库注册进虚拟机中
     * 默认注册view
     *
     * @param g 虚拟机
     */
    public void install(Globals g) {
        install(g, true);
    }

    /**
     * 创建Globals后，将提前注册的库注册进虚拟机中
     *
     * @param g           虚拟机
     * @param installView 是否注册View
     */
    public void install(Globals g, boolean installView) {
        allUserdataHolder.install(g);
        if (installView)
            lvUserdataHolder.install(g);
        for (SHolder h : sHolders) {
            g.registerStaticBridgeSimple(h.luaClassName, h.clz);
        }
        for (StringEnumHolder h : seHolders) {
            g.registerStringEnum(h.luaClassName, h.keys, h.values);
        }
        for (NumberEnumHolder h : neHolders) {
            g.registerNumberEnum(h.luaClassName, h.keys, h.values);
        }
    }

    /**
     * 提前初始化所有类信息
     */
    public void preInstall() {
        if (preInstall) return;

        try {
            allUserdataHolder.preInstall();
            lvUserdataHolder.preInstall();
            for (SHolder h : sHolders) {
                Globals.preRegisterStatic(h.clz, h.methods);
            }
        } catch (Throwable t) {
            if (MLSAdapterContainer.getPreinstallError() != null) {
                MLSAdapterContainer.getPreinstallError().onError(t);
            }
            return;
        }
        preInstall = true;
    }

    /**
     * 将所有userdata放到一起同时注册
     */
    private final class AllUserdataHolder {
        final int INIT = 50;
        final List<String> lcns = new ArrayList<>(INIT);
        final List<String> lpcns = new ArrayList<>(INIT);
        final List<String> jcns = new ArrayList<>(INIT);
        final List<String> methods = new ArrayList<>(INIT * 10);
        int[] mc = new int[INIT];
        boolean[] lazy = new boolean[INIT];
        int index = 0;

        void clear() {
            lcns.clear();
            lpcns.clear();
            jcns.clear();
            methods.clear();
            mc = new int[INIT];
            lazy = new boolean[INIT];
            index = 0;
        }

        void add(UDHolder h) {
            lcns.add(h.luaClassName);
            String parentName = Globals.findLuaParentClass(h.clz, luaClassNameMap);
            if (h.luaClassName.equals(parentName))
                parentName = null;
            lpcns.add(parentName);
            jcns.add(SignatureUtils.getClassName(h.clz));
            int m = h.methods != null ? h.methods.length : 0;
            mc = set(mc, index, m);
            lazy = set(lazy, index, h.lazy);
            index++;
            methods.addAll(Arrays.asList(h.methods));
            luaClassNameMap.put(h.clz, h.luaClassName);
        }

        void install(Globals g) {
            mc = get(mc, index);
            lazy = get(lazy, index);
            g.registerAllUserdata(
                    lcns.toArray(new String[index]),
                    lpcns.toArray(new String[index]),
                    jcns.toArray(new String[index]),
                    lazy);
            g.putLuaClassName(luaClassNameMap);
        }

        void preInstall() {
            mc = get(mc, index);
            String[] ams = methods.toArray(new String[0]);
            int use = 0;
            for (int i = 0; i < index; i ++) {
                String[] ms = new String[mc[i]];
                System.arraycopy(ams, use, ms, 0, mc[i]);
                Globals.preRegisterUserdata(jcns.get(i), ms);
                use += mc[i];
            }
        }

        private int[] set(int[] arr, int index, int value) {
            if (arr.length > index) {
                arr[index] = value;
                return arr;
            }
            int[] ret = Arrays.copyOf(arr, arr.length + 10);
            ret[index] = value;
            return ret;
        }

        private boolean[] set(boolean[] arr, int index, boolean value) {
            if (arr.length > index) {
                arr[index] = value;
                return arr;
            }
            boolean[] ret = Arrays.copyOf(arr, arr.length + 10);
            ret[index] = value;
            return ret;
        }

        private int[] get(int[] arr, int len) {
            if (arr.length == len)
                return arr;
            return Arrays.copyOf(arr, len);
        }

        private boolean[] get(boolean[] arr, int len) {
            if (arr.length == len)
                return arr;
            return Arrays.copyOf(arr, len);
        }
    }

    /**
     * 创建Globals后，将单例注册到虚拟机中，需要在同一个线程运行
     */
    public void createSingleInstance(Globals g) {
        for (SIHolder h : siHolders) {
            g.createUserdataAndSet(h.luaKey, h.luaClassName);
        }
    }

    /**
     * userdata 包裹类
     */
    public static final class UDHolder {
        /**
         * lua中类名
         */
        public String luaClassName;
        /**
         * java类，必须继承自{@link LuaUserdata}
         */
        public Class<? extends LuaUserdata> clz;
        /**
         * 所有方法名
         */
        public String[] methods;
        /**
         * 是否懒注册
         */
        public boolean lazy = false;
        /**
         * 是否要检查LuaApiUsed注解
         */
        private boolean needCheck = true;

        private UDHolder(String lcn, Class<? extends LuaUserdata> clz, boolean lazy, String[] methods) {
            this.luaClassName = lcn;
            this.clz = clz;
            this.methods = methods;
            this.lazy = lazy;
        }
    }

    /**
     * ud 的单例
     */
    public static final class SIHolder {
        /**
         * lua通过此名称获取单例
         */
        public final String luaKey;
        /**
         * 已注册的lua类名
         */
        public final String luaClassName;

        private SIHolder(String luaKey, String luaClassName) {
            this.luaKey = luaKey;
            this.luaClassName = luaClassName;
        }
    }

    /**
     * Static bridge 包裹类
     */
    public static final class SHolder {
        /**
         * lua中类名
         */
        public String luaClassName;
        /**
         * java类
         */
        public Class clz;
        /**
         * 所有方法，必须是static
         */
        public String[] methods;
        /**
         * 是否要检查LuaApiUsed注解
         */
        private boolean needCheck = true;

        private SHolder(String lcn, Class clz, String[] methods) {
            this.luaClassName = lcn;
            this.clz = clz;
            this.methods = methods;
        }
    }

    /**
     * 枚举包裹类
     */
    public static class EnumHolder {
        /**
         * lua中类名
         */
        public String luaClassName;
        /**
         * 键
         */
        public String[] keys;

        EnumHolder(String luaClassName, String[] keys) {
            this.luaClassName = luaClassName;
            this.keys = keys;
        }
    }

    private static final class StringEnumHolder extends EnumHolder {
        private String[] values;

        StringEnumHolder(String luaClassName, String[] keys, String[] values) {
            super(luaClassName, keys);
            this.values = values;
        }
    }

    private static final class NumberEnumHolder extends EnumHolder {
        private double[] values;

        NumberEnumHolder(String luaClassName, String[] keys, double[] values) {
            super(luaClassName, keys);
            this.values = values;
        }
    }
}