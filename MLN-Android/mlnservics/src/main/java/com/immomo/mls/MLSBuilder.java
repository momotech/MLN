/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.os.SystemClock;

import com.immomo.mlncore.MLNCore;
import com.immomo.mls.adapter.ConsoleLoggerAdapter;
import com.immomo.mls.adapter.IFileCache;
import com.immomo.mls.adapter.MLSEmptyViewAdapter;
import com.immomo.mls.adapter.MLSGlobalEventAdapter;
import com.immomo.mls.adapter.MLSGlobalStateListener;
import com.immomo.mls.adapter.MLSHttpAdapter;
import com.immomo.mls.adapter.MLSLoadViewAdapter;
import com.immomo.mls.adapter.MLSQrCaptureAdapter;
import com.immomo.mls.adapter.MLSReloadButtonCreator;
import com.immomo.mls.adapter.MLSResourceFinderAdapter;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.adapter.OnRemovedUserdataAdapter;
import com.immomo.mls.adapter.PreinstallError;
import com.immomo.mls.adapter.ScriptReaderCreator;
import com.immomo.mls.adapter.ToastAdapter;
import com.immomo.mls.adapter.TypeFaceAdapter;
import com.immomo.mls.adapter.X64PathAdapter;
import com.immomo.mls.fun.ui.MLNSafeAreaAdapter;
import com.immomo.mls.global.LVConfig;
import com.immomo.mls.global.LuaViewConfig;
import com.immomo.mls.log.DefaultPrinter;
import com.immomo.mls.provider.ImageProvider;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.ILuaValueGetter;
import com.immomo.mls.wrapper.Register;
import com.immomo.mls.wrapper.Translator;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaConfigs;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.utils.MemoryMonitor;
import org.luaj.vm2.utils.ResourceFinder;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import androidx.annotation.NonNull;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class MLSBuilder {
    private final List<Register.UDHolder> udHolders;
    private final List<Register.SHolder> sHolders;
    private final List<Class> constantsClass;
    private final List<SIHolder> siHolders;
    private final List<CHolder> cHolders;
    private final List<Register.NewUDHolder> newUDHolders;
    private final List<Register.NewStaticHolder> newStaticHolders;
    private final Register register;
    private int preGlobalNum = 3;
    private boolean clearAll = false;
    private int delay = 0;

    public MLSBuilder(Register register) {
        this.register = register;
        udHolders = new ArrayList<>();
        sHolders = new ArrayList<>();
        constantsClass = new ArrayList<>();
        siHolders = new ArrayList<>();
        cHolders = new ArrayList<>();
        newUDHolders = new ArrayList<>();
        newStaticHolders = new ArrayList<>();
    }

    //<editor-fold desc="Adapter">
    public MLSBuilder setThreadAdapter(MLSThreadAdapter threadAdapter) {
        MLSAdapterContainer.setThreadAdapter(threadAdapter);
        return this;
    }

    public MLSBuilder setConsoleLoggerAdapter(ConsoleLoggerAdapter consoleLoggerAdapter) {
        MLSAdapterContainer.setConsoleLoggerAdapter(consoleLoggerAdapter);
        return this;
    }

    public MLSBuilder setHttpAdapter(MLSHttpAdapter httpAdapter) {
        MLSAdapterContainer.setHttpAdapter(httpAdapter);
        return this;
    }

    public MLSBuilder setQrCaptureAdapter(MLSQrCaptureAdapter qrCaptureAdapter) {
        MLSAdapterContainer.setQrCaptureAdapter(qrCaptureAdapter);
        return this;
    }

    public MLSBuilder setGlobalStateListener(MLSGlobalStateListener globalStateListener) {
        MLSAdapterContainer.setGlobalStateListener(globalStateListener);
        return this;
    }

    public MLSBuilder setToastAdapter(ToastAdapter toastAdapter) {
        MLSAdapterContainer.setToastAdapter(toastAdapter);
        return this;
    }

    public MLSBuilder setGlobalEventAdapter(MLSGlobalEventAdapter globalEventAdapter) {
        MLSAdapterContainer.setGlobalEventAdapter(globalEventAdapter);
        return this;
    }

    public MLSBuilder setEmptyViewAdapter(MLSEmptyViewAdapter emptyViewAdapter) {
        MLSAdapterContainer.setEmptyViewAdapter(emptyViewAdapter);
        return this;
    }

    public MLSBuilder setLoadViewAdapter(MLSLoadViewAdapter loadViewAdapter) {
        MLSAdapterContainer.setLoadViewAdapter(loadViewAdapter);
        return this;
    }

    public MLSBuilder setUncatchExceptionListener(Environment.UncatchExceptionListener listener) {
        Environment.uncatchExceptionListener = listener;
        return this;
    }

    public MLSBuilder setTypeFaceAdapter(TypeFaceAdapter typeFaceAdapter) {
        MLSAdapterContainer.setTypeFaceAdapter(typeFaceAdapter);
        return this;
    }

    public MLSBuilder setResourceFinderAdapter(MLSResourceFinderAdapter resourceFinderAdapter) {
        MLSAdapterContainer.setResourceFinderAdapter(resourceFinderAdapter);
        return this;
    }

    public MLSBuilder setScriptLoaderCreator(@NonNull ScriptReaderCreator creator) {
        MLSAdapterContainer.setScriptReaderCreator(creator);
        return this;
    }

    public MLSBuilder setImageProvider(ImageProvider imageProvider) {
        MLSAdapterContainer.setImageProvider(imageProvider);
        return this;
    }

    public MLSBuilder setOnRemovedUserdataAdapter(OnRemovedUserdataAdapter onRemovedUserdataAdapter) {
        MLSAdapterContainer.setOnRemovedUserdataAdapter(onRemovedUserdataAdapter);
        return this;
    }

    public MLSBuilder setReloadButtonCreator(MLSReloadButtonCreator creator) {
        MLSAdapterContainer.setReloadButtonCreator(creator);
        return this;
    }

    public MLSBuilder setPreinstallError(PreinstallError error) {
        MLSAdapterContainer.setPreinstallError(error);
        return this;
    }

    public MLSBuilder setFileCache(IFileCache iFileCache) {
        MLSAdapterContainer.setFileCache(iFileCache);
        return this;
    }

    public MLSBuilder setSafeAreaAdapter(MLNSafeAreaAdapter safeAreaAdapter) {
        MLSAdapterContainer.setSafeAreaAdapter(safeAreaAdapter);
        return this;
    }

    public MLSBuilder setX64PathAdapter(X64PathAdapter x64PathAdapter) {
        MLSAdapterContainer.setX64PathAdapter(x64PathAdapter);
        return this;
    }
    //</editor-fold>

    //<editor-fold desc="Register">
    public MLSBuilder clearAll() {
        udHolders.clear();
        newUDHolders.clear();
        newStaticHolders.clear();
        sHolders.clear();
        constantsClass.clear();
        siHolders.clear();
        cHolders.clear();
        clearAll = true;
        return this;
    }

    /**
     * 注册高性能，新bridge
     * 写法可参照{@link com.immomo.mls.fun.ud.UDCCanvas}，且需要在c层注册文件
     * 建议使用Android Studio的模板生成java代码，实现完java层逻辑后，使用mlncgen.jar生成c层注册文件
     */
    public MLSBuilder registerNewUD(Register.NewUDHolder... holders) {
        newUDHolders.addAll(Arrays.asList(holders));
        return this;
    }

    /**
     * 注册高性能bridge
     * @see Register#registerNewStaticBridge(Register.NewStaticHolder)
     */
    public MLSBuilder registerNewStaticBridge(Register.NewStaticHolder... holders) {
        newStaticHolders.addAll(Arrays.asList(holders));
        return this;
    }

    public MLSBuilder registerUD(Register.UDHolder... holder) {
        udHolders.addAll(Arrays.asList(holder));
        return this;
    }

    public MLSBuilder registerSC(Register.SHolder... holder) {
        sHolders.addAll(Arrays.asList(holder));
        return this;
    }

    public MLSBuilder registerConstants(Class... clz) {
        constantsClass.addAll(Arrays.asList(clz));
        return this;
    }

    public MLSBuilder registerSingleInsance(SIHolder... holder) {
        siHolders.addAll(Arrays.asList(holder));
        return this;
    }

    public MLSBuilder registerCovert(CHolder... holder) {
        cHolders.addAll(Arrays.asList(holder));
        return this;
    }

    public MLSBuilder registerEmptyMethods(String... methods) {
        register.registerEmptyMethods(methods);
        return this;
    }
    //</editor-fold>

    //<editor-fold desc="Setting">
    public MLSBuilder setDelay(int d) {
        this.delay = d;
        return this;
    }

    /**
     * 设置lua查找so的路径
     * 规则:
     * @see LuaConfigs#soPath
     */
    public MLSBuilder setGlobalSoPath(String path) {
        LuaConfigs.soPath = path;
        return this;
    }

    /**
     * 设置默认加载超时时长，默认20s
     * 若设置为0，表示不超时
     * @param timeout 单位ms
     */
    public MLSBuilder setDefaultLoadScriptTimeout(long timeout) {
        MLSConfigs.defaultLoadScriptTimeout = timeout;
        return this;
    }

    public MLSBuilder addGlobalResourceFinder(ResourceFinder rf) {
        MLSEngine.globalResourceFinder.add(rf);
        return this;
    }

    @Deprecated
    public MLSBuilder setUseStandardSyntax(boolean standardSyntax) {
        return this;
    }

    public MLSBuilder setLVConfig(LVConfig config) {
        LuaViewConfig.setLvConfig(config);
        return this;
    }

    public MLSBuilder setRefreshColor(int color) {
        MLSFlag.setRefreshColor(color);
        return this;
    }

    public MLSBuilder setRefreshScale(boolean refreshScale) {
        MLSFlag.setRefreshScale(refreshScale);
        return this;
    }

    public MLSBuilder setRefreshEndPx(int refreshEndPx) {
        MLSFlag.setRefreshEndPx(refreshEndPx);
        return this;
    }

    public MLSBuilder setPrinterMaxLines(int max) {
        DefaultPrinter.MAX_LINES = max;
        return this;
    }

    @Deprecated
    public MLSBuilder setDirectlyClipRadiu(boolean c) {
        return this;
    }

    public MLSBuilder setDefaultNotClip(boolean not) {
        MLSConfigs.defaultNotClip = not;
        return this;
    }

    public MLSBuilder setNoStateBarHeight(boolean noStateBarHeight) {
        MLSConfigs.noStateBarHeight = noStateBarHeight;
        return this;
    }

    public MLSBuilder setDefaultClickEventTimeLimit(long limit) {
        MLSConfigs.defaultClickEventTimeLimit = limit;
        return this;
    }

    /**
     * 是否使用内存映射读或写文件
     * 默认使用
     *
     * @param use
     */
    public MLSBuilder setUseMemoryMap(boolean use) {
        FileUtil.setUseMemoryMap(use);
        return this;
    }

    public MLSBuilder setOpenPreCreateGlobals(boolean open) {
        MLSConfigs.preCreateGlobals = open;
        return this;
    }

    public MLSBuilder setUninitTitleAndMessage(CharSequence title, CharSequence msg) {
        MLSConfigs.uninitTitle = title;
        MLSConfigs.uninitMsg = msg;
        return this;
    }

    /**
     * 0表示关闭，-1表示无限大
     * 默认1M
     *
     * @param max
     * @return
     */
    public MLSBuilder setMaxAutoPreloadByte(int max) {
        MLSConfigs.maxAutoPreloadByte = max;
        return this;
    }

    public MLSBuilder setMaxRecyclerPoolSize(int max) {
        max = Math.max(5, max);
        MLSConfigs.maxRecyclerPoolSize = max;
        return this;
    }

    public MLSBuilder setLazyFillCellData(boolean lazy) {
        MLSConfigs.lazyFillCellData = lazy;
        return this;
    }

    public MLSBuilder setDefaultNavBarHeight(float height) {
        MLSConfigs.defaultNavBarHeight = height;
        return this;
    }

    public MLSBuilder setViewPagerConfig(int config) {
        MLSConfigs.viewPagerConfig = config;
        return this;
    }

    /**
     * 设置加载脚本时重试次数，默认两次，
     */
    public MLSBuilder setMaxLoadScriptCount(int c) {
        if (c <= 1)
            c = 1;
        MLSConfigs.maxLoadCount = c;
        return this;
    }

    /**
     * 设置是否在java层读取脚本文件
     */
    @Deprecated
    public MLSBuilder setReadScriptFileInJava(boolean readScriptFileInJava) {
        return this;
    }

    /**
     * 是否开启加密
     * @see Globals#openSAES(boolean)
     * @param open false default
     */
    public MLSBuilder setOpenSAES(boolean open) {
        Globals.openSAES(open);
        return this;
    }

    /**
     * 设置lua gc回调java gc时间间隔
     * 若小于等于0，表示关闭回调
     * 值越大，越慢
     */
    public MLSBuilder setGcOffset(int offset) {
        Globals.setGcOffset(offset);
        return this;
    }

    /**
     * 设置gc间隔时间
     * @param ms 毫秒
     */
    public MLSBuilder setLuaGcOffset(long ms) {
        Globals.setLuaGcOffset(ms);
        return this;
    }

    /**
     * 设置需要销毁多少lua对象才执行gc
     */
    public MLSBuilder setNeedDestroyNumber(int n) {
        Globals.setNeedDestroyNumber(n);
        return this;
    }

    /**
     * 设置检查lua内存时间间隔
     * 小于等于0，关闭检查
     * 值越大，检查越慢
     * @param offset 单位ms
     */
    public MLSBuilder setMemoryMonitorOffset(int offset) {
        MemoryMonitor.setOffsetTime(offset);
        return this;
    }

    /**
     * 设置Lua DB文件存储路径
     * 默认Android数据库路径
     * @param path 路径必须存在
     */
    public MLSBuilder setDatabasePath(String path) {
        Globals.setDatabasePath(path);
        return this;
    }

    /**
     * 预先初始化global个数，默认3
     */
    public MLSBuilder setPreGlobals(int n) {
        preGlobalNum = n;
        return this;
    }

    /**
     * 设置userdata 缓存类型
     * @see com.immomo.mlncore.MLNCore#UserdataCacheType
     */
    public MLSBuilder setUserdataCacheType(byte type) {
        if (MLNCore.UserdataCacheType != MLNCore.TYPE_NONE
        && MLNCore.UserdataCacheType != MLNCore.TYPE_REMOVE
        && MLNCore.UserdataCacheType != MLNCore.TYPE_REMOVE_CACHE) {
            throw new IllegalArgumentException("type is invalid!");
        }
        MLNCore.UserdataCacheType = type;
        return this;
    }

    /**
     * 设置容器默认切割模式
     * @param clipChildren 默认是否切割子视图
     * @param clipToPadding 默认是否切割到padding
     */
    public MLSBuilder setDefaultClipState(boolean clipChildren, boolean clipToPadding, boolean forContainer) {
        MLSConfigs.defaultClipChildren = clipChildren;
        MLSConfigs.defaultClipToPadding = clipToPadding;
        MLSConfigs.defaultClipContainer = forContainer;
        return this;
    }

    /**
     * 设置是否默认蓝加载图片，默认true
     */
    public MLSBuilder setDefaultLazyLoadImage(boolean load) {
        MLSConfigs.defaultLazyLoadImage = load;
        return this;
    }
    //</editor-fold>

    //<editor-fold desc="May Delete">

    /**
     * 设置layout异常监听，可打日志检查
     */
    public MLSBuilder setOnLayoutException(MLSConfigs.OnLayoutException l) {
        MLSConfigs.onLayoutException = l;
        MLSConfigs.catchOnLayoutException = l != null;
        return this;
    }
    //</editor-fold>

    public void build(boolean inThread) {
        if (inThread) {
            realBuild();
            return;
        }
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new Runnable() {
            @Override
            public void run() {
                realBuild();
            }
        });
    }

    private void realBuild() {
        if (clearAll) {
            register.clearAll();
            Translator.clearAll();
            return;
        }
        long start = SystemClock.uptimeMillis();
        for (Register.UDHolder h : udHolders) {
            register.registerUserdata(h);
        }
        for (Register.NewUDHolder h : newUDHolders) {
            register.registerNewUserdata(h);
        }
        for (Register.NewStaticHolder h : newStaticHolders) {
            register.registerNewStaticBridge(h);
        }
        for (Register.SHolder h : sHolders) {
            register.registerStaticBridge(h);
        }
        for (Class c : constantsClass) {
            register.registerEnum(c);
        }
        for (SIHolder h : siHolders) {
            register.registerSingleInstance(h.luaClassName, h.clz,h.isMLN);
        }
        for (CHolder h : cHolders) {
            if (h.defaultL2J) {
                Translator.registerL2JAuto(h.clz);
            } else if (h.l2j != null){
                Translator.registerL2J(h.clz, h.l2j);
            }
            if (h.defaultJ2L) {
                Translator.registerJ2LAuto(h.clz);
            } else if (h.j2l != null) {
                Translator.registerJ2L(h.clz, h.j2l);
            }
        }
        Runnable task = new Runnable() {
            @Override
            public void run() {
                long ps = SystemClock.uptimeMillis();
                if (PreGlobalInitUtils.hasPreInitSize() == 0)
                    PreGlobalInitUtils.initFewGlobals(preGlobalNum);
                if (MLSEngine.DEBUG)
                    MLSAdapterContainer.getConsoleLoggerAdapter().d("MLSBuilder", "pre init globals cast: %d", (SystemClock.uptimeMillis() - ps));
            }
        };
        if (delay <= 0) {
            MainThreadExecutor.post(task);
        } else {
            MainThreadExecutor.postDelayed(this, task, delay);
        }
        if (MLSEngine.DEBUG)
            MLSAdapterContainer.getConsoleLoggerAdapter().d("MLSBuilder", "build cast: %d", (SystemClock.uptimeMillis() - start));
    }

    /**
     * 单例包裹类
     *
     * 每个虚拟机中只有一个实例，使用{@link #luaClassName}获取
     * 虚拟机销毁时，会调用相关类中__onLuaGc方法
     *
     * 和静态Bridge不同的是，单例有虚拟机状态，
     * 适用于需要获取状态的类中，或需要在虚拟机销毁时，释放资源的类中
     */
    public static class SIHolder {
        public String luaClassName;
        /**
         * 类中必须有{@link com.immomo.mls.annotation.LuaClass}注解
         */
        public Class clz;

        /**
         * 是否是MLN独有的
         */
        public boolean isMLN;

        public SIHolder(String lcn, Class clz) {
            luaClassName = lcn;
            this.clz = clz;
        }

        public SIHolder(String lcn, Class clz,boolean isMLN) {
            luaClassName = lcn;
            this.clz = clz;
            this.isMLN = isMLN;
        }
    }

    /**
     * 转换包裹类
     *
     * @see Translator#registerL2J(Class, IJavaObjectGetter)
     * @see Translator#registerJ2L(Class, ILuaValueGetter)
     * @see IJavaObjectGetter
     * @see ILuaValueGetter
     */
    public static class CHolder {
        Class clz;
        boolean defaultL2J = true;
        IJavaObjectGetter l2j;
        boolean defaultJ2L = true;
        ILuaValueGetter j2l;

        public CHolder(Class clz, IJavaObjectGetter l2j, ILuaValueGetter j2l) {
            this.clz = clz;
            this.j2l = j2l;
            this.l2j = l2j;
            defaultL2J = false;
            defaultJ2L = false;
        }

        public CHolder(Class clz) {
            this.clz = clz;
        }

        public CHolder(Class clz, IJavaObjectGetter l2j, boolean defaultJ2L) {
            this(clz, l2j, null);
            this.defaultJ2L = defaultJ2L;
        }

        public CHolder(Class clz, ILuaValueGetter j2l, boolean defaultL2J) {
            this(clz, null, j2l);
            this.defaultL2J = defaultL2J;
        }
    }
}