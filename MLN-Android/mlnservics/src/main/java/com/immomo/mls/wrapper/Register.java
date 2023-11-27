/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

import androidx.annotation.NonNull;

import com.immomo.mls.Environment;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.utils.ReplaceArrayList;

import org.luaj.vm2.Globals;
import org.luaj.vm2.JavaUserdata;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;
import org.luaj.vm2.utils.SignatureUtils;
import org.luaj.vm2.utils.SizeOfUtils;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import kotlin.collections.CollectionsKt;

/**
 * Created by Xiong.Fangyu on 2019/3/18
 * <p>
 * lua userdata或bridge注册器
 * 提前注册并提取，在创建{@link Globals}后调用{@link #install(Globals)}将提前注册的库放入虚拟机中
 * <p>
 * 可提前初始化lua中需要的java库
 */
public class Register {
    public static boolean SupportEmptyMethod = true;
    private static final String UD_CLASS_SUFFIX = "_udwrapper";
    private static final String SB_CLASS_SUFFIX = "_sbwrapper";
    private static final String METHODS_FIELD = "methods";
    private static final String NEW_UD_INIT = "_init";
    private static final String NEW_UD_REGISTER = "_register";
    private static final Map<Class, Class<? extends LuaUserdata>> udClassMap = new HashMap<>(20);

    public static enum CheckType {
        /**
         * 啥也不检查
         */
        Close,
        /**
         * 检查构造函数
         */
        Constructor,
        /**
         * 检查注册函数
         */
        Methods,
        /**
         * 都检查
         */
        All
    }

    private static CheckType checkType = CheckType.Methods;

    /**
     * 设置debug过程中注册检查范围
     *
     * @see CheckType
     */
    public static void setRegisterCheckType(CheckType t) {
        checkType = t;
    }

    /**
     * Class -> Lua Class Name
     * 用来查找某个类的父类
     */
    private static final HashMap<Class, String> luaClassNameMap = new HashMap<>();
    /**
     * 普通静态bridge
     */
    private final AllStaticBridgeHolder allStaticBridgeHolder = new AllStaticBridgeHolder();
    /**
     * 枚举class缓存，用来判断是否重复枚举
     */
    private final ReplaceArrayList<Class> enumClasses = new ReplaceArrayList<>(10);
    /**
     * 字符串枚举
     */
    private final List<StringEnumHolder> seHolders = new ArrayList<>(10);
    /**
     * 数字型枚举
     */
    private final List<NumberEnumHolder> neHolders = new ArrayList<>(10);
    /**
     * 存储单例类型
     */
    private final List<SIHolder> allSiHolders = new ArrayList<>(10);
    /**
     * 未标记为View类型的普通bridge
     */
    protected final AllUserdataHolder allUserdataHolder = new AllUserdataHolder();
    /**
     * 标记为View类型的普通Bridge
     */
    protected final AllUserdataHolder lvUserdataHolder = new AllUserdataHolder();
    /**
     * 新版本bridge，走C注册
     */
    private final ReplaceArrayList<NewUDHolder> newUDHolders = new ReplaceArrayList<>();
    /**
     * 新版本静态bridge，走C注册
     */
    private final ReplaceArrayList<NewStaticHolder> newStaticHolders = new ReplaceArrayList<>();
    /**
     * 允许重复注册
     */
    private boolean allowDuplicateRegister = true;

    private final HashSet<String> allSiHolderKeys = new HashSet<>(10);//包含__的名字

    private volatile boolean preInstall = false;

    public void setAllowDuplicateRegister(boolean allowDuplicateRegister) {
        this.allowDuplicateRegister = allowDuplicateRegister;
    }

    /**
     * 清除所有注册的东西
     */
    public synchronized void clearAll() {
        preInstall = false;
        allStaticBridgeHolder.clear();
        seHolders.clear();
        neHolders.clear();
        allSiHolders.clear();
        allSiHolderKeys.clear();
        udClassMap.clear();
        luaClassNameMap.clear();
        allUserdataHolder.clear();
        lvUserdataHolder.clear();
        newUDHolders.clear();
        newStaticHolders.clear();
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

    public int udCount() {
        return lvUserdataHolder.index + allUserdataHolder.index;
    }

    //<editor-fold desc="check">
    private static int checkUD(Class clz, String methodName) {
        return checkClassMethod(clz, methodName, LuaValue[].class);
    }

    private static int checkSC(Class clz, String methodName) {
        return checkClassMethod(clz, methodName, long.class, LuaValue[].class);
    }

    private static int checkClassMethod(Class clz, String mn, Class... pc) {
        Method m = null;
        try {
            m = clz.getMethod(mn, pc);
        } catch (NoSuchMethodException ignore) {
        }
        if (m == null) {
            try {
                m = clz.getDeclaredMethod(mn, pc);
            } catch (NoSuchMethodException ignore) {
            }
        }
        if (m == null) return 0;
        if (m.getAnnotation(LuaApiUsed.class) == null) {
            clz = clz.getSuperclass();
            if (LuaUserdata.class == clz || JavaUserdata.class == clz) {
                return -1;
            }
            return checkClassMethod(clz, mn, pc);
        }
        return 1;
    }

    protected static void checkClassMethods(Class clz, String[] methods, boolean ud) {
        if (checkType == CheckType.Close)
            return;
        if (clz.getAnnotation(LuaApiUsed.class) == null) {
            throw new ProGuardError("Throw in debug! " + clz.getName() + "上没有@LuaApiUsed注解！");
        }

        if (ud && (checkType == CheckType.All || checkType == CheckType.Constructor)) {
            try {
                Constructor c = clz.getDeclaredConstructor(long.class, LuaValue[].class);
                if (c.getAnnotation(LuaApiUsed.class) == null) {
                    throw new ProGuardError("Throw in debug! " + clz.getName() + "(long, LuaValue[])构造方法没有@LuaApiUsed注解！");
                }
            } catch (NoSuchMethodException ignore) {
//                throw new ProGuardError("Throw in debug! " + clz.getName() + " 没有(long, LuaValue[])构造方法！", e);
            }
        }
        if (methods == null || methods.length == 0
                || (checkType == CheckType.Constructor))
            return;

        String name = clz.getSimpleName();
        try {
            int check;
            for (String mn : methods) {
                if (ud) {
                    check = checkUD(clz, mn);
                    if (SupportEmptyMethod && check == -1
                            || (!SupportEmptyMethod && check != 1))
                        throw new Exception("Throw in debug! " + name + "." + mn + "方法没有@LuaApiUsed注解!");
                } else {
                    check = checkSC(clz, mn);
                    if (SupportEmptyMethod && check == -1
                            || (!SupportEmptyMethod && check != 1))
                        throw new Exception("Throw in debug! " + name + "." + mn + "方法没有@LuaApiUsed注解!");
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
    public synchronized void registerUserdata(Class clz, boolean lazy, String... luaClassName) throws RegisterError {
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
    public synchronized void registerUserdata(UDHolder holder) {
        if (MLSEngine.DEBUG && holder.needCheck)
            checkClassMethods(holder.clz, holder.methods, true);
        preInstall = false;
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
     * static native void _init()
     * static native void _register(long l)
     * <p>
     * 写法可参照{@link com.immomo.mls.fun.ud.UDCCanvas}，且需要在c层注册文件
     * 建议使用Android Studio的模板生成java代码，实现完java层逻辑后，使用mlncgen.jar生成c层注册文件
     */
    public synchronized void registerNewUserdata(String lcn, Class<? extends LuaUserdata> clz) {
        NewUDHolder holder = new NewUDHolder(lcn, clz);
        registerNewUserdata(holder);
    }

    /**
     * 注册高性能，新版userdata
     * 其中必须有两个native函数:
     * static native void _init()
     * static native void _register(long l)
     * <p>
     * 写法可参照{@link com.immomo.mls.fun.ud.UDCCanvas}，且需要在c层注册文件
     * 建议使用Android Studio的模板生成java代码，实现完java层逻辑后，使用mlncgen.jar生成c层注册文件
     */
    public synchronized void registerNewUserdata(NewUDHolder holder) {
        if (!allowDuplicateRegister && newUDHolders.replace(holder, holder)) {
            return;
        }
        preInstall = false;
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
     *
     * @param lcn  lua类名
     * @param clz  java中类名，必须继承自{@link LuaUserdata}
     * @param lazy 是否是懒注册
     */
    public static UDHolder newUDHolderAuto(String lcn, Class<? extends LuaUserdata> clz, boolean lazy) {
        Method[] methods = clz.getDeclaredMethods();
        List<String> msl = new ArrayList<>(methods.length);
        for (Method m : methods) {
            if (((m.getModifiers() & Modifier.STATIC) != Modifier.STATIC)
                    && m.getAnnotation(LuaApiUsed.class) != null
                    && checkUD(clz, m.getName()) == 1) {
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
    public synchronized void registerStaticBridge(String luaClassName, Class clz) {
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
    public synchronized void registerStaticBridge(SHolder holder) {
        if (MLSEngine.DEBUG && holder.needCheck)
            checkClassMethods(holder.clz, holder.methods, false);
        preInstall = false;
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
     *
     * @param lcn lua类名
     * @param clz java类
     */
    public static SHolder newSHolderAuto(String lcn, Class clz) {
        Method[] methods = clz.getDeclaredMethods();
        List<String> lms = new ArrayList<>(methods.length);
        for (Method m : methods) {
            if (((m.getModifiers() & Modifier.STATIC) == Modifier.STATIC)
                    && m.getAnnotation(LuaApiUsed.class) != null
                    && checkSC(clz, m.getName()) == 1) {
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
     * static native void _init()
     * static native void _register(long l)
     * <p>
     * 建议使用Android Studio的模板生成java代码，实现完java层逻辑后，使用mlncgen.jar生成c层注册文件
     */
    public synchronized void registerNewStaticBridge(String lcn, Class clz) {
        NewStaticHolder holder = new NewStaticHolder(lcn, clz);
        registerNewStaticBridge(holder);
    }

    /**
     * 注册高性能，新版static bridge
     * 其中必须有两个native函数:
     * static native void _init()
     * static native void _register(long l)
     * <p>
     * 建议使用Android Studio的模板生成java代码，实现完java层逻辑后，使用mlncgen.jar生成c层注册文件
     */
    public synchronized void registerNewStaticBridge(NewStaticHolder holder) {
        if (!allowDuplicateRegister && newStaticHolders.replace(holder, holder))
            return;
        preInstall = false;
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
    public synchronized void registerSingleInstance(String luaClassName, Class clz) throws RegisterError {
        String realLuaClassName = "__" + luaClassName;
        registerUserdata(clz, false, realLuaClassName);
        allSiHolders.add(new SIHolder(luaClassName, realLuaClassName));
        allSiHolderKeys.add(realLuaClassName);
    }

    /**
     * 注册单例，且使用高性能bridge写法
     *
     * @param luaClassName lua通过这个名称获取单例
     */
    public synchronized void registerNewSingleInstance(String luaClassName, Class<? extends LuaUserdata> clz) throws RegisterError {
        String realKey = luaClassName.substring(2);
        registerNewUserdata(luaClassName, clz);
        allSiHolders.add(new SIHolder(realKey, luaClassName));
        allSiHolderKeys.add(realKey);
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
    public synchronized void registerEnum(Class clz) {
        if (!allowDuplicateRegister && enumClasses.replace(clz, clz))
            return;

        ConstantClass cc = (ConstantClass) clz.getAnnotation(ConstantClass.class);
        if (cc == null) {
            throw new RegisterError("register enum failed! class must have a ConstantClass annotation. Class:" + clz.getName());
        }
        enumClasses.add(clz);
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
    public synchronized void registerEnum(String luaClassName, String[] keys, String[] values) {
        seHolders.add(new StringEnumHolder(luaClassName, keys, values));
    }

    /**
     * 注册数字型枚举
     */
    public synchronized void registerEnum(String luaClassName, String[] keys, double[] values) {
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
    public synchronized void install(Globals g, boolean installView) {
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
        installEnum(g);
        g.putLuaClassName(luaClassNameMap);
    }

    public void installEnum(Globals g) {
        for (StringEnumHolder h : seHolders) {
            g.registerStringEnum(h.luaClassName, h.keys, h.values);
        }
        for (NumberEnumHolder h : neHolders) {
            g.registerNumberEnum(h.luaClassName, h.keys, h.values);
        }
    }

    /**
     * 所有bridge名称
     * key有：userdata、static、enum、singleInstance
     *
     * @param luaVisible lua开发是否能看到，一般，名称由__开头，不可见
     */
    public Map<String, Set<String>> dumpBridge(boolean luaVisible) {
        Map<String, Set<String>> ret = new HashMap<>();

        Set<String> values = new HashSet<>();
        ret.put("userdata", values);
        for (NewUDHolder h : newUDHolders) {
            if (luaVisible) {
                if (h.lcn.charAt(0) != '_')
                    values.add(h.lcn);
            } else {
                values.add(h.lcn);
            }
        }
        for (String l : allUserdataHolder.lcns) {
            if (luaVisible) {
                if (l.charAt(0) != '_')
                    values.add(l);
            } else {
                values.add(l);
            }
        }
        for (String l : lvUserdataHolder.lcns) {
            if (luaVisible) {
                if (l.charAt(0) != '_')
                    values.add(l);
            } else {
                values.add(l);
            }
        }

        values = new HashSet<>();
        ret.put("static", values);
        for (NewStaticHolder h : newStaticHolders) {
            if (luaVisible) {
                if (h.lcn.charAt(0) != '_')
                    values.add(h.lcn);
            } else {
                values.add(h.lcn);
            }
        }
        for (String l : allStaticBridgeHolder.lcns) {
            if (luaVisible) {
                if (l.charAt(0) != '_')
                    values.add(l);
            } else {
                values.add(l);
            }
        }

        values = new HashSet<>();
        ret.put("enum", values);
        for (NumberEnumHolder h : neHolders) {
            values.add(h.luaClassName);
        }
        for (StringEnumHolder h : seHolders) {
            values.add(h.luaClassName);
        }

        values = new HashSet<>();
        ret.put("singleInstance", values);
        for (SIHolder h : allSiHolders) {
            values.add(h.luaKey);
        }

        return ret;
    }

    /**
     * 统计未使用的Bridge类
     *
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
            index++;
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
        } catch (Throwable t) {
            if (MLSAdapterContainer.getPreinstallError() != null) {
                MLSAdapterContainer.getPreinstallError().onError(t);
            }
            return;
        }
        preInstall = true;
    }

    //<editor-fold desc="统一注册类">
    protected abstract class AllHolder<T extends BridgeHolder> {
        final int INIT = 50;
        final List<Class> classes = new ArrayList<>(INIT);
        final List<String> lcns = new ArrayList<>(INIT);
        final List<String> lpcns = new ArrayList<>(INIT);
        final List<String> jcns = new ArrayList<>(INIT);
        final List<String> methods = new ArrayList<>(INIT * 10);
        int[] mc = new int[INIT];
        int index = 0;

        void add(T h) {
            if (!allowDuplicateRegister) {
                int oldLuaClassIndex = lcns.indexOf(h.luaClassName);
                /// 防止重复注册
                if (oldLuaClassIndex >= 0 && classes.indexOf(h.clz) == oldLuaClassIndex)
                    return;
            }
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
            install(g, lcns.toArray(new String[index]),
                    lpcns.toArray(new String[index]),
                    jcns.toArray(new String[index]));
        }

        protected abstract void install(Globals g, String[] lcns, String[] lpcns, String[] jcns);

        void preInstall() {
            mc = get(mc, index);
            String[] ams = methods.toArray(new String[0]);
            int use = 0;
            if (!classes.isEmpty())
                for (int i = 0; i < index; i++) {
                    Class c = classes.get(i);
                    String parentName = Globals.findLuaParentClass(c, luaClassNameMap);
                    if (lcns.get(i).equals(parentName))
                        parentName = null;
                    lpcns.add(parentName);

                    String[] ms = new String[mc[i]];
                    System.arraycopy(ams, use, ms, 0, mc[i]);
                    int type = 0;
                    if (allSiHolderKeys.contains(lcns.get(i))) {
                        type = 1;
                    }
                    preInstall(jcns.get(i), lcns.get(i), parentName, type, ms);
                    use += mc[i];
                }
            else
                for (int i = 0; i < index; i++) {
                    String[] ms = new String[mc[i]];
                    System.arraycopy(ams, use, ms, 0, mc[i]);
                    preInstall(jcns.get(i), lcns.get(i), null, 0, ms);
                    use += mc[i];
                }
            classes.clear();
        }

        protected abstract void preInstall(String jcn, String luaClassName, String parentName, int type, String[] ms);

        void clear() {
            classes.clear();
            lcns.clear();
            lpcns.clear();
            jcns.clear();
            methods.clear();
            mc = new int[INIT];
            index = 0;
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

        protected boolean[] set(boolean[] arr, int index, boolean value) {
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

        protected boolean[] get(boolean[] arr, int len) {
            if (arr.length == len)
                return arr;
            return Arrays.copyOf(arr, len);
        }
    }

    /**
     * 将所有userdata放到一起同时注册
     */
    protected final class AllUserdataHolder extends AllHolder<UDHolder> {
        boolean[] lazy = new boolean[INIT];

        void clear() {
            super.clear();
            lazy = new boolean[INIT];
        }

        public void add(UDHolder h) {
            super.add(h);
            lazy = set(lazy, index, h.lazy);
        }

        void install(Globals g) {
            lazy = get(lazy, index);
            super.install(g);
        }

        @Override
        protected void install(Globals g, String[] lcns, String[] lpcns, String[] jcns) {
            g.registerAllUserdata(lcns, lpcns, jcns, lazy);
        }

        @Override
        protected void preInstall(String jcn, String luaClassName, String parentName, int type, String[] ms) {
            Globals.preRegisterUserdata(jcn, luaClassName, parentName, type, ms);
        }
    }

    protected final class AllStaticBridgeHolder extends AllHolder<SHolder> {

        @Override
        protected void install(Globals g, String[] lcns, String[] lpcns, String[] jcns) {
            g.registerAllStaticClass(lcns, lpcns, jcns);
        }

        /**
         * @param type 0 普通userdata 1 单例 2 静态
         */
        @Override
        protected void preInstall(String jcn, String luaClassName, String parentName, int type, String[] ms) {
            Globals.preRegisterStatic(jcn, luaClassName, parentName, ms);
        }
    }
    //</editor-fold>

    /**
     * 创建Globals后，将单例注册到虚拟机中，需要在同一个线程运行
     */
    public void createSingleInstance(Globals g) {
        for (SIHolder h : allSiHolders) {
            g.createUserdataAndSet(h.luaKey, h.luaClassName);
        }
    }

    static abstract class BridgeHolder {
        /**
         * lua中类名
         */
        public @NonNull
        final String luaClassName;
        /**
         * java类
         */
        public @NonNull
        final Class clz;
        /**
         * 所有方法名
         */
        public final String[] methods;
        /**
         * 是否要检查LuaApiUsed注解
         */
        public boolean needCheck = true;

        protected BridgeHolder(@NonNull String luaClassName, @NonNull Class clz, String[] methods) {
            this.luaClassName = luaClassName;
            this.clz = clz;
            this.methods = methods;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            BridgeHolder that = (BridgeHolder) o;
            return luaClassName.equals(that.luaClassName) && clz.equals(that.clz);
        }

        @Override
        public int hashCode() {
            return Objects.hash(luaClassName, clz);
        }
    }

    /**
     * userdata 包裹类
     */
    public static final class UDHolder extends BridgeHolder {
        /**
         * 是否懒注册
         */
        public boolean lazy = false;
        /**
         * 是否是view使用的
         */
        public boolean isView = false;

        private UDHolder(String lcn, Class<? extends LuaUserdata> clz, boolean lazy, String[] methods) {
            this(lcn, clz, lazy, UDView.class.isAssignableFrom(clz), methods);
        }

        private UDHolder(String lcn, Class<? extends LuaUserdata> clz, boolean lazy, boolean isView, String[] methods) {
            super(lcn, clz, methods);
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
    public static final class SHolder extends BridgeHolder {

        protected SHolder(@NonNull String luaClassName, @NonNull Class clz, String[] methods) {
            super(luaClassName, clz, methods);
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

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            NewHolder newHolder = (NewHolder) o;
            return lcn.equals(newHolder.lcn) &&
                    clz.equals(newHolder.clz);
        }

        @Override
        public int hashCode() {
            return Objects.hash(lcn, clz);
        }
    }

    public static final class NewUDHolder extends NewHolder {
        public NewUDHolder(String lcn, Class<? extends LuaUserdata> clz) {
            super(lcn, clz);
        }
    }

    public static final class NewStaticHolder extends NewHolder {

        public NewStaticHolder(String lcn, Class clz) {
            super(lcn, clz);
        }
    }
}