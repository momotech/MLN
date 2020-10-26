/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

import com.immomo.mls.Environment;
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
import java.util.Set;

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
    private static final String NEW_UD_INIT = "_init";
    private static final String NEW_UD_REGISTER = "_register";
    private static final Map<Class, Class<? extends LuaUserdata>> udClassMap = new HashMap<>(20);

    private final AllStaticBridgeHolder allStaticBridgeHolder = new AllStaticBridgeHolder();
    private final List<StringEnumHolder> seHolders = new ArrayList<>(10);
    private final List<NumberEnumHolder> neHolders = new ArrayList<>(10);

    /**
     * 存储MLN独有的
     */
    private final List<SIHolder> mlnSiHolders = new ArrayList<>(10);

    /**
     * 存储共有的
     */
    private final List<SIHolder> allSiHolders = new ArrayList<>(10);

    private final HashMap<Class, String> luaClassNameMap = new HashMap<>();
    protected final AllUserdataHolder allUserdataHolder = new AllUserdataHolder();
    protected final AllUserdataHolder lvUserdataHolder = new AllUserdataHolder();
    private final List<NewUDHolder> newUDHolders = new ArrayList<>();
    private final List<NewStaticHolder> newStaticHolders = new ArrayList<>();
    private final List<String> emptyMethods = new ArrayList<>();

    private boolean preInstall = false;
    /**
     * 清除所有注册的东西
     */
    public void clearAll() {
        allStaticBridgeHolder.clear();
        seHolders.clear();
        neHolders.clear();
        mlnSiHolders.clear();
        allSiHolders.clear();

        udClassMap.clear();
        luaClassNameMap.clear();
        allUserdataHolder.clear();
        lvUserdataHolder.clear();
        newUDHolders.clear();
        newStaticHolders.clear();
        emptyMethods.clear();
    }

    /**
     * 是否有注册过luaview
     */
    public boolean isInit() {
        return lvUserdataHolder.index > 0 || allUserdataHolder.index > 0;
    }

    public boolean isPreInstall() {
        return preInstall;
    }

    /**
     * 全局增加空方法
     */
    public void registerEmptyMethods(String... methods) {
        emptyMethods.addAll(Arrays.asList(methods));
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

    protected static void checkClassMethods(Class clz, String[] methods, boolean ud) {
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
     * @see #registerUserdata(Class, boolean, boolean,String...)
     */
    public void registerUserdata(String luaClassName, boolean lazy, Class clz) throws RegisterError {
        registerUserdata(clz, lazy,false, luaClassName);
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
     * @param isMLN        是否是MLN独有的
     * @param luaClassName lua中类名
     */
    public void registerUserdata(Class clz, boolean lazy,boolean isMLN, String... luaClassName) throws RegisterError {
        final String wrapperName = clz.getName() + UD_CLASS_SUFFIX;
        try {
            Class<? extends LuaUserdata> udClz = (Class<? extends LuaUserdata>) Class.forName(wrapperName);
            Field f = udClz.getDeclaredField(METHODS_FIELD);
            String[] ms = (String[]) f.get(null);
            for (String s : luaClassName) {
                UDHolder h = new UDHolder(s, udClz, lazy,isMLN,ms);
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
        if (holder.isView) {
            lvUserdataHolder.add(holder);
        } else {
            SizeOfUtils.sizeof(holder.clz);
            allUserdataHolder.add(holder);
        }
    }

    /**
     * 注册高性能，新版userdata
     * 其中必须有两个native函数:
     *  static native void _init()
     *  static native void _register(long l)
     *
     * 写法可参照{@link com.immomo.mls.fun.ud.UDCCanvas}，且需要在c层注册文件
     * 建议使用Android Studio的模板生成java代码，实现完java层逻辑后，使用mlncgen.jar生成c层注册文件
     */
    public void registerNewUserdata(String lcn, Class<? extends LuaUserdata> clz) {
        NewUDHolder holder = new NewUDHolder(lcn, clz);
        holder.init();
        luaClassNameMap.put(clz, lcn);
        newUDHolders.add(holder);
    }

    /**
     * 注册高性能，新版userdata
     * 其中必须有两个native函数:
     *  static native void _init()
     *  static native void _register(long l)
     *
     * 写法可参照{@link com.immomo.mls.fun.ud.UDCCanvas}，且需要在c层注册文件
     * 建议使用Android Studio的模板生成java代码，实现完java层逻辑后，使用mlncgen.jar生成c层注册文件
     */
    public void registerNewUserdata(NewUDHolder holder) {
        holder.init();
        luaClassNameMap.put(holder.clz, holder.lcn);
        newUDHolders.add(holder);
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

    public static UDHolder newUDHolder(String lcn, Class<? extends LuaUserdata> clz, boolean lazy, boolean isView, String... methods) {
        return new UDHolder(lcn, clz, lazy, isView, methods);
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
        return newUDHolderWithLuaClass(lcn, clz, lazy, false);
    }

    public static UDHolder newUDHolderWithLuaClass(String lcn, Class clz, boolean lazy, boolean isView) {
        final String wrapperName = clz.getName() + UD_CLASS_SUFFIX;
        try {
            Class<? extends LuaUserdata> udClz = (Class<? extends LuaUserdata>) Class.forName(wrapperName);
            Field f = udClz.getDeclaredField(METHODS_FIELD);
            String[] ms = (String[]) f.get(null);
            udClassMap.put(clz, udClz);
            UDHolder h = new UDHolder(lcn, udClz, lazy, isView, ms);
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
        allStaticBridgeHolder.add(holder);
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
    /**
     * 注册高性能，新版static bridge
     * 其中必须有两个native函数:
     *  static native void _init()
     *  static native void _register(long l)
     *
     * 建议使用Android Studio的模板生成java代码，实现完java层逻辑后，使用mlncgen.jar生成c层注册文件
     */
    public void registerNewStaticBridge(String lcn, Class clz) {
        NewStaticHolder holder = new NewStaticHolder(lcn, clz);
        holder.init();
        luaClassNameMap.put(clz, lcn);
        newStaticHolders.add(holder);
    }

    /**
     * 注册高性能，新版static bridge
     * 其中必须有两个native函数:
     *  static native void _init()
     *  static native void _register(long l)
     *
     * 建议使用Android Studio的模板生成java代码，实现完java层逻辑后，使用mlncgen.jar生成c层注册文件
     */
    public void registerNewStaticBridge(NewStaticHolder holder) {
        holder.init();
        luaClassNameMap.put(holder.clz, holder.lcn);
        newStaticHolders.add(holder);
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
        registerSingleInstance(luaClassName, clz, false);
    }

    /**
     * 注册单例
     *
     * @param luaClassName lua通过这个名称获取单例
     * @param clz          java类
     * @param isMLN 是否是MLN独有的
     */
    public void registerSingleInstance(String luaClassName, Class clz,boolean isMLN) throws RegisterError {
        String realLuaClassName = "__" + luaClassName;
        registerUserdata(clz, false, isMLN,realLuaClassName);
        if(isMLN) {
            mlnSiHolders.add(new SIHolder(luaClassName, realLuaClassName));
        } else {
            allSiHolders.add(new SIHolder(luaClassName, realLuaClassName));
        }
    }

    /**
     * 注册单例，且使用高性能bridge写法
     * @param luaClassName lua通过这个名称获取单例
     */
    public void registerNewSingleInstance(String luaClassName, Class<? extends LuaUserdata> clz) throws RegisterError {
        String realKey = luaClassName.substring(2);
        registerNewUserdata(luaClassName, clz);
        allSiHolders.add(new SIHolder(realKey, luaClassName));
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
     * 若使用{@link #registerUserdata(String, boolean, Class)} 或 {@link #registerUserdata(Class, boolean,boolean, String...)}
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
        for (NewUDHolder h : newUDHolders) {
            h.register(g, luaClassNameMap);
        }
        for (NewStaticHolder h : newStaticHolders) {
            h.register(g, luaClassNameMap);
        }
        allUserdataHolder.install(g);
        if (installView)
            lvUserdataHolder.install(g);
        allStaticBridgeHolder.install(g);
        for (StringEnumHolder h : seHolders) {
            g.registerStringEnum(h.luaClassName, h.keys, h.values);
        }
        for (NumberEnumHolder h : neHolders) {
            g.registerNumberEnum(h.luaClassName, h.keys, h.values);
        }
        g.putLuaClassName(luaClassNameMap);
    }

    /**
     * 统计未使用的Bridge类
     * @param useBridge 使用过的bridge类名
     */
    public List<String> noUseBridge(Set<String> useBridge) {
        List<String> ret = new ArrayList<>();

        for (NewUDHolder h : newUDHolders) {
            if (!useBridge.contains(h.lcn)) {
                ret.add(h.clz.getName());
            }
        }
        for (NewStaticHolder h : newStaticHolders) {
            if (!useBridge.contains(h.lcn)) {
                ret.add(h.clz.getName());
            }
        }
        List<String> jcns = allUserdataHolder.jcns;
        int index = 0;
        for (String s : allUserdataHolder.lcns) {
            if (!useBridge.contains(s)) {
                ret.add(jcns.get(index));
            }
            index++;
        }

        jcns = lvUserdataHolder.jcns;
        index = 0;
        for (String s : lvUserdataHolder.lcns) {
            if (!useBridge.contains(s)) {
                ret.add(jcns.get(index));
            }
            index++;
        }

        jcns = allStaticBridgeHolder.jcns;
        index = 0;
        for (String s : allStaticBridgeHolder.lcns) {
            if (!useBridge.contains(s)) {
                ret.add(jcns.get(index));
            }
            index ++;
        }
        return ret;
    }

    /**
     * 提前初始化所有类信息
     */
    public synchronized void preInstall() {
        if (preInstall) return;

        try {
            allUserdataHolder.preInstall();
            lvUserdataHolder.preInstall();
            allStaticBridgeHolder.preInstall();
            if (!emptyMethods.isEmpty()) {
                Globals.preRegisterEmptyMethods(emptyMethods.toArray(new String[0]));
            }
            emptyMethods.clear();
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
    protected final class AllUserdataHolder {
        final int INIT = 50;
        final List<Class> classes = new ArrayList<>(INIT);
        final List<String> lcns = new ArrayList<>(INIT);
        final List<String> lpcns = new ArrayList<>(INIT);
        final List<String> jcns = new ArrayList<>(INIT);
        final List<String> methods = new ArrayList<>(INIT * 10);
        int[] mc = new int[INIT];
        boolean[] lazy = new boolean[INIT];
        int index = 0;

        void clear() {
            classes.clear();
            lcns.clear();
            lpcns.clear();
            jcns.clear();
            methods.clear();
            mc = new int[INIT];
            lazy = new boolean[INIT];
            index = 0;
        }

        public void add(UDHolder h) {
            lcns.add(h.luaClassName);
            classes.add(h.clz);
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
        }

        void preInstall() {
            mc = get(mc, index);
            String[] ams = methods.toArray(new String[0]);
            int use = 0;
            if (!classes.isEmpty())
                for (int i = 0; i < index; i ++) {
                    Class c = classes.get(i);
                    String parentName = Globals.findLuaParentClass(c, luaClassNameMap);
                    if (lcns.get(i).equals(parentName))
                        parentName = null;
                    lpcns.add(parentName);

                    String[] ms = new String[mc[i]];
                    System.arraycopy(ams, use, ms, 0, mc[i]);
                    Globals.preRegisterUserdata(jcns.get(i), ms);
                    use += mc[i];
                }
            else
                for (int i = 0; i < index; i ++) {
                    String[] ms = new String[mc[i]];
                    System.arraycopy(ams, use, ms, 0, mc[i]);
                    Globals.preRegisterUserdata(jcns.get(i), ms);
                    use += mc[i];
                }
            classes.clear();
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

    protected final class AllStaticBridgeHolder {
        final int INIT = 50;
        final List<Class> classes = new ArrayList<>(INIT);
        final List<String> lcns = new ArrayList<>(INIT);
        final List<String> lpcns = new ArrayList<>(INIT);
        final List<String> jcns = new ArrayList<>(INIT);
        final List<String> methods = new ArrayList<>(INIT * 10);
        int[] mc = new int[INIT];
        int index = 0;

        void clear() {
            classes.clear();
            lcns.clear();
            lpcns.clear();
            jcns.clear();
            methods.clear();
            mc = new int[INIT];
            index = 0;
        }

        public void add(SHolder h) {
            lcns.add(h.luaClassName);
            classes.add(h.clz);
            jcns.add(SignatureUtils.getClassName(h.clz));
            int m = h.methods != null ? h.methods.length : 0;
            mc = set(mc, index, m);
            index++;
            methods.addAll(Arrays.asList(h.methods));
            luaClassNameMap.put(h.clz, h.luaClassName);
        }

        void install(Globals g) {
            mc = get(mc, index);
            g.registerAllStaticClass(
                    lcns.toArray(new String[index]),
                    lpcns.toArray(new String[index]),
                    jcns.toArray(new String[index]));
        }

        void preInstall() {
            mc = get(mc, index);
            String[] ams = methods.toArray(new String[0]);
            int use = 0;
            if (!classes.isEmpty())
                for (int i = 0; i < index; i ++) {
                    Class c = classes.get(i);
                    String parentName = Globals.findLuaParentClass(c, luaClassNameMap);
                    if (lcns.get(i).equals(parentName))
                        parentName = null;
                    lpcns.add(parentName);

                    String[] ms = new String[mc[i]];
                    System.arraycopy(ams, use, ms, 0, mc[i]);
                    Globals.preRegisterStatic(jcns.get(i), ms);
                    use += mc[i];
                }
            else
                for (int i = 0; i < index; i ++) {
                    String[] ms = new String[mc[i]];
                    System.arraycopy(ams, use, ms, 0, mc[i]);
                    Globals.preRegisterStatic(jcns.get(i), ms);
                    use += mc[i];
                }
            classes.clear();
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

        private int[] get(int[] arr, int len) {
            if (arr.length == len)
                return arr;
            return Arrays.copyOf(arr, len);
        }
    }

    /**
     * 创建Globals后，将单例注册到虚拟机中，需要在同一个线程运行
     */
    public void createSingleInstance(Globals g,boolean isMLNInstall) {
        for (SIHolder h : allSiHolders) {
            g.createUserdataAndSet(h.luaKey, h.luaClassName);
        }
        if(isMLNInstall) {
            for (SIHolder h : mlnSiHolders) {
                g.createUserdataAndSet(h.luaKey, h.luaClassName);
            }
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
        public boolean needCheck = true;
        /**
         * 是否是view使用的
         */
        public boolean isView = false;

        private UDHolder(String lcn, Class<? extends LuaUserdata> clz, boolean lazy, String[] methods) {
            this(lcn, clz, lazy, UDView.class.isAssignableFrom(clz), methods);
        }

        private UDHolder(String lcn, Class<? extends LuaUserdata> clz, boolean lazy, boolean isView, String[] methods) {
            this.luaClassName = lcn;
            this.clz = clz;
            this.methods = methods;
            this.lazy = lazy;
            this.isView = isView;
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

    static class NewHolder {
        static final String UNSET = "@UNSET";
        final String lcn;
        final Method registerMethod;
        final Class clz;
        Method initMethod;
        String parent = UNSET;

        NewHolder(String lcn, Class clz) {
            this.lcn = lcn;
            this.clz = clz;
            try {
                initMethod = clz.getDeclaredMethod(NEW_UD_INIT);
                registerMethod = clz.getDeclaredMethod(NEW_UD_REGISTER, long.class, String.class);
                initMethod.setAccessible(true);
                registerMethod.setAccessible(true);
            } catch (Throwable t) {
                throw new RegisterError("register " + clz.getName() + " failed!", t);
            }
        }

        void init() {
            if (initMethod == null)
                return;
            try {
                initMethod.invoke(null);
                initMethod = null;
            } catch (Throwable t) {
                throw new RegisterError("init " + clz.getName() + " failed!", t);
            }
        }

        void register(Globals g, Map<Class, String> m) {
            if (parent == UNSET) {
                parent = Globals.findLuaParentClass(clz, m);
            }
            try {
                registerMethod.invoke(null, g.getL_State(), parent);
            } catch (Throwable e) {
                Environment.callbackError(e, g);
            }
        }
    }

    public static final class NewUDHolder extends NewHolder{
        public NewUDHolder(String lcn, Class<? extends LuaUserdata> clz) {
            super(lcn, clz);
        }
    }

    public static final class NewStaticHolder extends NewHolder{

        public NewStaticHolder(String lcn, Class clz) {
            super(lcn, clz);
        }
    }
}