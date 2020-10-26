/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.content.ComponentCallbacks2;
import android.content.Context;

import androidx.annotation.NonNull;

import com.immomo.mlncore.MLNCore;
import com.immomo.mls.adapter.ILoadLibAdapter;
import com.immomo.mls.adapter.OnRemovedUserdataAdapter;
import com.immomo.mls.adapter.impl.LoadLibAdapterImpl;
import com.immomo.mls.fun.constants.BreakMode;
import com.immomo.mls.fun.constants.ContentMode;
import com.immomo.mls.fun.constants.CrossAxisAlignType;
import com.immomo.mls.fun.constants.DrawStyle;
import com.immomo.mls.fun.constants.EditTextViewInputMode;
import com.immomo.mls.fun.constants.FileInfo;
import com.immomo.mls.fun.constants.FillType;
import com.immomo.mls.fun.constants.FontStyle;
import com.immomo.mls.fun.constants.GradientType;
import com.immomo.mls.fun.constants.GravityConstants;
import com.immomo.mls.fun.constants.LinearType;
import com.immomo.mls.fun.constants.MainAxisAlignType;
import com.immomo.mls.fun.constants.MeasurementType;
import com.immomo.mls.fun.constants.MotionEvent;
import com.immomo.mls.fun.constants.NavigatorAnimType;
import com.immomo.mls.fun.constants.NetworkState;
import com.immomo.mls.fun.constants.RectCorner;
import com.immomo.mls.fun.constants.ResultType;
import com.immomo.mls.fun.constants.ReturnType;
import com.immomo.mls.fun.constants.SafeAreaConstants;
import com.immomo.mls.fun.constants.ScrollDirection;
import com.immomo.mls.fun.constants.StatusBarStyle;
import com.immomo.mls.fun.constants.StatusMode;
import com.immomo.mls.fun.constants.StyleImageAlign;
import com.immomo.mls.fun.constants.TabSegmentAlignment;
import com.immomo.mls.fun.constants.TextAlign;
import com.immomo.mls.fun.constants.UnderlineStyle;
import com.immomo.mls.fun.constants.WrapType;
import com.immomo.mls.fun.globals.UDLuaView;
import com.immomo.mls.fun.java.Alert;
import com.immomo.mls.fun.java.Event;
import com.immomo.mls.fun.java.JToast;
import com.immomo.mls.fun.java.LuaDialog;
import com.immomo.mls.fun.lt.LTFile;
import com.immomo.mls.fun.lt.LTPreferenceUtils;
import com.immomo.mls.fun.lt.LTPrinter;
import com.immomo.mls.fun.lt.LTStringUtil;
import com.immomo.mls.fun.lt.LTTypeUtils;
import com.immomo.mls.fun.lt.SClipboard;
import com.immomo.mls.fun.lt.SIApplication;
import com.immomo.mls.fun.lt.SICornerRadiusManager;
import com.immomo.mls.fun.lt.SIEventCenter;
import com.immomo.mls.fun.lt.SIGlobalEvent;
import com.immomo.mls.fun.lt.SILoading;
import com.immomo.mls.fun.lt.SINavigator;
import com.immomo.mls.fun.lt.SINetworkReachability;
import com.immomo.mls.fun.lt.SISystem;
import com.immomo.mls.fun.lt.SITimeManager;
import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.other.Rect;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.Timer;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDCanvas;
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.fun.ud.UDPaint;
import com.immomo.mls.fun.ud.UDPath;
import com.immomo.mls.fun.ud.UDPoint;
import com.immomo.mls.fun.ud.UDRect;
import com.immomo.mls.fun.ud.UDSafeAreaRect;
import com.immomo.mls.fun.ud.UDSize;
import com.immomo.mls.fun.ud.UDStyleString;
import com.immomo.mls.fun.ud.UDWindowManager;
import com.immomo.mls.fun.ud.anim.InterpolatorType;
import com.immomo.mls.fun.ud.anim.RepeatType;
import com.immomo.mls.fun.ud.anim.UDAnimator;
import com.immomo.mls.fun.ud.anim.ValueType;
import com.immomo.mls.fun.ud.anim.canvasanim.AnimationValueType;
import com.immomo.mls.fun.ud.anim.canvasanim.UDAlphaAnimation;
import com.immomo.mls.fun.ud.anim.canvasanim.UDAnimationSet;
import com.immomo.mls.fun.ud.anim.canvasanim.UDBaseAnimation;
import com.immomo.mls.fun.ud.anim.canvasanim.UDRotateAnimation;
import com.immomo.mls.fun.ud.anim.canvasanim.UDScaleAnimation;
import com.immomo.mls.fun.ud.anim.canvasanim.UDTranslateAnimation;
import com.immomo.mls.fun.ud.net.CachePolicy;
import com.immomo.mls.fun.ud.net.EncType;
import com.immomo.mls.fun.ud.net.ErrorKey;
import com.immomo.mls.fun.ud.net.ResponseKey;
import com.immomo.mls.fun.ud.net.UDHttp;
import com.immomo.mls.fun.ud.view.UDBaseHVStack;
import com.immomo.mls.fun.ud.view.UDBaseStack;
import com.immomo.mls.fun.ud.view.UDCanvasView;
import com.immomo.mls.fun.ud.view.UDEditText;
import com.immomo.mls.fun.ud.view.UDHStack;
import com.immomo.mls.fun.ud.view.UDImageButton;
import com.immomo.mls.fun.ud.view.UDImageView;
import com.immomo.mls.fun.ud.view.UDLabel;
import com.immomo.mls.fun.ud.view.UDLinearLayout;
import com.immomo.mls.fun.ud.view.UDRelativeLayout;
import com.immomo.mls.fun.ud.view.UDScrollView;
import com.immomo.mls.fun.ud.view.UDSpacer;
import com.immomo.mls.fun.ud.view.UDSwitch;
import com.immomo.mls.fun.ud.view.UDTabLayout;
import com.immomo.mls.fun.ud.view.UDVStack;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.ud.view.UDViewGroup;
import com.immomo.mls.fun.ud.view.UDViewPager;
import com.immomo.mls.fun.ud.view.UDZStack;
import com.immomo.mls.fun.ud.view.recycler.UDBaseNeedHeightAdapter;
import com.immomo.mls.fun.ud.view.recycler.UDBaseRecyclerAdapter;
import com.immomo.mls.fun.ud.view.recycler.UDBaseRecyclerLayout;
import com.immomo.mls.fun.ud.view.recycler.UDCollectionAdapter;
import com.immomo.mls.fun.ud.view.recycler.UDCollectionAutoFitAdapter;
import com.immomo.mls.fun.ud.view.recycler.UDCollectionLayout;
import com.immomo.mls.fun.ud.view.recycler.UDListAdapter;
import com.immomo.mls.fun.ud.view.recycler.UDListAutoFitAdapter;
import com.immomo.mls.fun.ud.view.recycler.UDRecyclerView;
import com.immomo.mls.fun.ud.view.recycler.UDWaterFallAdapter;
import com.immomo.mls.fun.ud.view.recycler.UDWaterFallLayout;
import com.immomo.mls.fun.ud.view.viewpager.UDViewPagerAdapter;
import com.immomo.mls.global.LVConfig;
import com.immomo.mls.global.LuaViewConfig;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.wrapper.AssetsResourceFinder;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.ILuaValueGetter;
import com.immomo.mls.wrapper.Register;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.utils.IGlobalsUserdata;
import org.luaj.vm2.utils.MemoryMonitor;
import org.luaj.vm2.utils.ResourceFinder;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class MLSEngine {
    /**
     * 必须初始化的库
     */
    private static final String[] coreLibs = {
            "luajapi",
            "mlnbridge",
    };

    public static final String BC_Lib = "mlnbc";
    public static final String BLUR_LIB = "lblur";

    private static final Map<String, Boolean> otherLibs;

    static {
        otherLibs = new HashMap<>(3);
//        otherLibs.put(BC_Lib, false);
        otherLibs.put(BLUR_LIB, false);
    }

    private static boolean init = false;

    private static Context context;
    public static boolean DEBUG;

    public static Register singleRegister;

    final static List<ResourceFinder> globalResourceFinder = new ArrayList<>();

    private static volatile IGlobalsUserdata globalsUserdata;
    public static IGlobalsUserdata getGlobalUD() {
        if (globalsUserdata == null) {
            synchronized (MLSEngine.class) {
                if (globalsUserdata == null) {
                    globalsUserdata = new LuaViewManager(context);
                }
            }
        }
        return globalsUserdata;
    }

    public static String getGlobalPath() {
        return LuaViewConfig.getLvConfig().getGlobalResourceDir();
    }

    public static List<ResourceFinder> getGlobalResourceFinder() {
        return globalResourceFinder;
    }

    /**
     * 设置是否显示debug按钮（左上角lua图标按钮）
     *
     * @param open
     */
    public static void setOpenDebugInfo(boolean open) {
        MLSConfigs.openDebug = open;
    }

    /**
     * @return
     * @see #setOpenDebugInfo(boolean)
     */
    public static boolean isOpenDebugInfo() {
        return MLSConfigs.openDebug;
    }

    /**
     * 是否初始化成功
     */
    public static boolean isInit() {
        return LuaViewConfig.isInit() && singleRegister != null && singleRegister.isInit();
    }

    private static MemoryListener memoryListener;

    /**
     * 初始化核心库
     */
    public static void initCoreLibs(ILoadLibAdapter loadLibAdapter) {
        boolean init = true;
        for (String s : coreLibs) {
            init = loadLibAdapter.load(s) && init;
        }
        MLSEngine.init = init;
    }

    /**
     * 初始化非核心库
     */
    public static void initOtherLibs(ILoadLibAdapter libAdapter) {
        Map<String, Boolean> temp = new HashMap<>(otherLibs);
        for (Map.Entry<String, Boolean> e : temp.entrySet()) {
            if (!e.getValue()) {
                otherLibs.put(e.getKey(), libAdapter.load(e.getKey()));
            }
        }
        if (MLSEngine.DEBUG) {
            LogUtil.d("lua engine load libs:", otherLibs);
        }
    }

    public static boolean isLibInit(String libName) {
        Boolean init = otherLibs.get(libName);
        return init != null && init;
    }

    public static MLSBuilder init(Context context, final boolean debug) {
        return init(context, LoadLibAdapterImpl.getInstance(), debug);
    }

    public static MLSBuilder init(Context context, @NonNull ILoadLibAdapter adapter, final boolean debug) {
        if (!init) {
            DEBUG = debug;
            initCoreLibs(adapter);
        }
        if (!init)
            return null;
        boolean firstInit = false;
        if (singleRegister == null) {
            synchronized (MLSEngine.class) {
                if (singleRegister == null) {
                    singleRegister = new Register();
                    firstInit = true;
                }
            }
        }
        if (firstInit) {
            initOtherLibs(adapter);
            MLNCore.setCallback(new MLNCore.Callback() {
                @Override
                public void onNativeCreateGlobals(Globals g, boolean isStatic) {
                    if (isStatic) {
                        g.setJavaUserdata(MLSEngine.getGlobalUD());
                        g.setBasePath(MLSEngine.getGlobalPath(), false);
                        g.setResourceFinders(MLSEngine.getGlobalResourceFinder());
                    }
                    singleRegister.install(g, false);
                    if (init)
                        NativeBridge.registerNativeBridge(g);
                }

                @Override
                public boolean hookLuaError(Throwable t, Globals g) {
                    return Environment.hook(t, g);
                }

                @Override
                public void luaGcCast(Globals g, long ms) {
                    if (debug)
                        LogUtil.e("Lua Gc cast:", ms);
                }

                @Override
                public LuaUserdata onNullGet(long id, @NonNull LuaUserdata cache) {
                    OnRemovedUserdataAdapter adapter = MLSAdapterContainer.getOnRemovedUserdataAdapter();
                    if (adapter != null)
                        return adapter.onNullGet(id, cache);
                    return cache;
                }
            });
            MLSEngine.context = context;
            DEBUG = debug;
            MLNCore.DEBUG = debug;
            FileUtil.DEBUG = debug;
            Environment.DEBUG = debug;
            DimenUtil.init(context);
            if (!Globals.isInit())
                throw new RuntimeException("luac library is not loaded! call Globals.isInit()");

            File dbpath = context.getDatabasePath("a").getParentFile();
            if (!dbpath.exists()) {
                if (dbpath.mkdirs()) {
                    Globals.setDatabasePath(dbpath.getAbsolutePath());
                }
            } else {
                Globals.setDatabasePath(dbpath.getAbsolutePath());
            }
            if (debug) {
                if (memoryListener == null) {
                    memoryListener = new MemoryListener();
                    MemoryMonitor.startCheckGlobalMemory(memoryListener);
                }
            }
            globalResourceFinder.add(new AssetsResourceFinder(context));
            Globals.setAssetManagerForNative(context.getAssets());
            return newBuilder();
        }
        return new MLSBuilder(singleRegister);
    }

    public static Context getContext() {
        return context;
    }

    private static MLSBuilder newBuilder() {
        return new MLSBuilder(singleRegister)
                .registerUD(registerLuaView())
                .registerUD(registerTools())
                .registerCovert(registerCovert())
                .registerSingleInsance(registerSingleInstance())
                .registerSC(registerStaticClass())
                .registerConstants(registerConstants())
                .registerNewUD(registerNewUD())
                ;
    }

    public static void setLVConfig(@NonNull LVConfig config) {
        if (config.isValid()) {
            LuaViewConfig.setLvConfig(config);
        }
    }

    /**
     * 是否开启lua断点调试
     */
    public static void setOpenDebugger(boolean open) {
        LuaViewConfig.setOpenDebugger(open);
    }

    /**
     * 是否开启lua断点调试
     */
    public static boolean isOpenDebugger() {
        return LuaViewConfig.isOpenDebugger();
    }

    /**
     * 设置断点调试ip
     */
    public static void setDebugIp(String ip) {
        LuaViewConfig.setDebugIp(ip);
    }

    /**
     * 获取断点ip
     */
    public static String getDebugIp() {
        return LuaViewConfig.getDebugIp();
    }

    /**
     * 设置断点port
     */
    public static void setDebugPort(int port) {
        LuaViewConfig.setPort(port);
    }

    /**
     * 获取断点port
     */
    public static int getDebugPort() {
        return LuaViewConfig.getPort();
    }

    /// view类型放到这里
    public static Register.UDHolder[] registerLuaView() {
        return new Register.UDHolder[] {
                Register.newUDHolder(UDView.LUA_CLASS_NAME, UDView.class, false, UDView.methods),
                Register.newUDHolder(UDViewGroup.LUA_CLASS_NAME[0], UDViewGroup.class, false, UDViewGroup.methods),
                Register.newUDHolder(UDViewGroup.LUA_CLASS_NAME[1], UDViewGroup.class, false, UDViewGroup.methods),
                Register.newUDHolder(UDLuaView.LUA_CLASS_NAME, UDLuaView.class, false, UDLuaView.methods),
                Register.newUDHolder(UDLinearLayout.LUA_CLASS_NAME, UDLinearLayout.class, false),
                Register.newUDHolder(UDRelativeLayout.LUA_CLASS_NAME, UDRelativeLayout.class, false, UDRelativeLayout.methods),
                Register.newUDHolder(UDLabel.LUA_CLASS_NAME, UDLabel.class, false, UDLabel.methods),
                Register.newUDHolder(UDEditText.LUA_CLASS_NAME, UDEditText.class, false, UDEditText.methods),
                Register.newUDHolder(UDImageView.LUA_CLASS_NAME, UDImageView.class, false, UDImageView.methods),
                Register.newUDHolder(UDImageButton.LUA_CLASS_NAME, UDImageButton.class, false, UDImageButton.methods),
                Register.newUDHolder(UDScrollView.LUA_CLASS_NAME, UDScrollView.class, false, UDScrollView.methods),
                Register.newUDHolder(UDBaseRecyclerAdapter.LUA_CLASS_NAME, UDBaseRecyclerAdapter.class, false, true, UDBaseRecyclerAdapter.methods),
                Register.newUDHolder(UDBaseNeedHeightAdapter.LUA_CLASS_NAME, UDBaseNeedHeightAdapter.class, false, true, UDBaseNeedHeightAdapter.methods),
                Register.newUDHolder(UDBaseRecyclerLayout.LUA_CLASS_NAME, UDBaseRecyclerLayout.class, false, true, UDBaseRecyclerLayout.methods),
                Register.newUDHolder(UDRecyclerView.LUA_CLASS_NAME[0], UDRecyclerView.class, false, UDRecyclerView.methods),
                Register.newUDHolder(UDRecyclerView.LUA_CLASS_NAME[1], UDRecyclerView.class, false, UDRecyclerView.methods),
                Register.newUDHolder(UDRecyclerView.LUA_CLASS_NAME[2], UDRecyclerView.class, false, UDRecyclerView.methods),
                Register.newUDHolder(UDViewPager.LUA_CLASS_NAME, UDViewPager.class, false, UDViewPager.methods),
                Register.newUDHolder(UDTabLayout.LUA_CLASS_NAME, UDTabLayout.class, false, UDTabLayout.methods),
                Register.newUDHolder(UDSwitch.LUA_CLASS_NAME, UDSwitch.class, false, UDSwitch.methods),
                Register.newUDHolder(UDCanvasView.LUA_CLASS_NAME, UDCanvasView.class, false, UDCanvasView.methods),
                Register.newUDHolder(UDBaseStack.LUA_CLASS_NAME, UDBaseStack.class, false, UDBaseStack.methods),
                Register.newUDHolder(UDBaseHVStack.LUA_CLASS_NAME, UDBaseHVStack.class, false, UDBaseHVStack.methods),
                Register.newUDHolder(UDVStack.LUA_CLASS_NAME, UDVStack.class, false, UDVStack.methods),
                Register.newUDHolder(UDHStack.LUA_CLASS_NAME, UDHStack.class, false, UDHStack.methods),
                Register.newUDHolder(UDZStack.LUA_CLASS_NAME, UDZStack.class, false, UDZStack.methods),
                Register.newUDHolder(UDSpacer.LUA_CLASS_NAME, UDSpacer.class, false, UDSpacer.methods),

                Register.newUDHolder(UDListAdapter.LUA_CLASS_NAME, UDListAdapter.class, false, true, UDListAdapter.methods),
                Register.newUDHolder(UDListAutoFitAdapter.LUA_CLASS_NAME, UDListAutoFitAdapter.class, false, true),
                Register.newUDHolder(UDCollectionAdapter.LUA_CLASS_NAME, UDCollectionAdapter.class, false, true, UDCollectionAdapter.methods),
                Register.newUDHolder(UDCollectionAutoFitAdapter.LUA_CLASS_NAME, UDCollectionAutoFitAdapter.class, false, true, UDCollectionAutoFitAdapter.methods),
                Register.newUDHolder(UDCollectionLayout.LUA_CLASS_NAME, UDCollectionLayout.class, false,true, UDCollectionLayout.methods),
                Register.newUDHolder(UDWaterFallAdapter.LUA_CLASS_NAME, UDWaterFallAdapter.class, false, true, UDWaterFallAdapter.methods),
                Register.newUDHolder(UDWaterFallLayout.LUA_CLASS_NAME, UDWaterFallLayout.class, false, true, UDWaterFallLayout.methods),
                Register.newUDHolder(UDViewPagerAdapter.LUA_CLASS_NAME,UDViewPagerAdapter.class, false, true, UDViewPagerAdapter.methods),

                Register.newUDHolder(UDStyleString.LUA_CLASS_NAME, UDStyleString.class, false, true, UDStyleString.methods),
                Register.newUDHolder(UDColor.LUA_CLASS_NAME, UDColor.class, false, true, UDColor.methods),
        };
    }

    /// 非view类型放到这里
    public static Register.UDHolder[] registerTools() {
        return new Register.UDHolder[] {
                /// 两种方式生成udholder
                /// 第一种，类继承自LuaUserdata时，使用这种方式
                Register.newUDHolder(UDSize.LUA_CLASS_NAME, UDSize.class, false, UDSize.methods),
                Register.newUDHolder(UDPoint.LUA_CLASS_NAME, UDPoint.class, false, UDPoint.methods),
                Register.newUDHolder(UDRect.LUA_CLASS_NAME, UDRect.class, false, UDRect.methods),
                Register.newUDHolder(UDWindowManager.LUA_CLASS_NAME, UDWindowManager.class, false,true, UDWindowManager.methods),

                Register.newUDHolder(UDPath.LUA_CLASS_NAME, UDPath.class, false, UDPath.methods),
                Register.newUDHolder(UDPaint.LUA_CLASS_NAME, UDPaint.class, false, UDPaint.methods),
                Register.newUDHolder(UDCanvas.LUA_CLASS_NAME, UDCanvas.class, false, UDCanvas.methods),
                Register.newUDHolder(UDSafeAreaRect.LUA_CLASS_NAME, UDSafeAreaRect.class, false, UDSafeAreaRect.methods),

                /// 第二种，普通类，含有LuaClass注解的
                Register.newUDHolderWithLuaClass(UDHttp.LUA_CLASS_NAME, UDHttp.class, false),
                Register.newUDHolderWithLuaClass(UDAnimator.LUA_CLASS_NAME, UDAnimator.class, false),
                Register.newUDHolderWithLuaClass(Timer.LUA_CLASS_NAME, Timer.class, false),
                Register.newUDHolderWithLuaClass(JToast.LUA_CLASS_NAME, JToast.class, false),
                Register.newUDHolderWithLuaClass(Event.LUA_CLASS_NAME, Event.class,false),
                Register.newUDHolderWithLuaClass(Alert.LUA_CLASS_NAME, Alert.class,false),
                Register.newUDHolderWithLuaClass(LuaDialog.LUA_CLASS_NAME, LuaDialog.class,false,true),

                /// Canvas Animations
                Register.newUDHolderWithLuaClass(UDBaseAnimation.LUA_CLASS_NAME, UDBaseAnimation.class, false),
                Register.newUDHolderWithLuaClass(UDAlphaAnimation.LUA_CLASS_NAME, UDAlphaAnimation.class, false),
                Register.newUDHolderWithLuaClass(UDRotateAnimation.LUA_CLASS_NAME, UDRotateAnimation.class, false),
                Register.newUDHolderWithLuaClass(UDScaleAnimation.LUA_CLASS_NAME, UDScaleAnimation.class, false),
                Register.newUDHolderWithLuaClass(UDTranslateAnimation.LUA_CLASS_NAME, UDTranslateAnimation.class, false),
                Register.newUDHolderWithLuaClass(UDAnimationSet.LUA_CLASS_NAME, UDAnimationSet.class, false),
                /// end
        };
    }

    public static Register.NewUDHolder[] registerNewUD() {
        return new Register.NewUDHolder[] {
                new Register.NewUDHolder(UDArray.LUA_CLASS_NAME, UDArray.class),
                new Register.NewUDHolder(UDMap.LUA_CLASS_NAME, UDMap.class)
        };
    }

    public static MLSBuilder.CHolder[] registerCovert() {
        return new MLSBuilder.CHolder[]{
                new MLSBuilder.CHolder(Size.class, UDSize.G, true),
                new MLSBuilder.CHolder(Point.class, UDPoint.G, true),
                new MLSBuilder.CHolder(Rect.class, UDRect.G, true),
                new MLSBuilder.CHolder(UDColor.class, UDColor.J, null),
                new MLSBuilder.CHolder(Map.class, UDMap.J, UDMap.G),
                new MLSBuilder.CHolder(List.class, UDArray.G, true),

                new MLSBuilder.CHolder(UDAnimator.class),
                /// Canvas Animations
                new MLSBuilder.CHolder(UDBaseAnimation.class, (ILuaValueGetter) null, true),
                new MLSBuilder.CHolder(UDAlphaAnimation.class, (IJavaObjectGetter) null, true),
                new MLSBuilder.CHolder(UDRotateAnimation.class, (IJavaObjectGetter) null, true),
                new MLSBuilder.CHolder(UDScaleAnimation.class, (IJavaObjectGetter) null, true),
                new MLSBuilder.CHolder(UDTranslateAnimation.class, (IJavaObjectGetter) null, true),
                new MLSBuilder.CHolder(UDAnimationSet.class, (IJavaObjectGetter) null, true),
                /// end
        };
    }

    public static MLSBuilder.SIHolder[] registerSingleInstance() {
        return new MLSBuilder.SIHolder[]{
                new MLSBuilder.SIHolder(SISystem.KEY, SISystem.class),
                new MLSBuilder.SIHolder(SITimeManager.KEY, SITimeManager.class),
                new MLSBuilder.SIHolder(SClipboard.KEY, SClipboard.class),
                new MLSBuilder.SIHolder(SIGlobalEvent.LUA_CLASS_NAME, SIGlobalEvent.class),
                new MLSBuilder.SIHolder(SIApplication.LUA_CLASS_NAME, SIApplication.class),
                new MLSBuilder.SIHolder(SIEventCenter.LUA_CLASS_NAME, SIEventCenter.class),
                new MLSBuilder.SIHolder(SINetworkReachability.LUA_CLASS_NAME, SINetworkReachability.class),
                new MLSBuilder.SIHolder(SILoading.LUA_CLASS_NAME, SILoading.class),
                new MLSBuilder.SIHolder(SINavigator.LUA_CLASS_NAME, SINavigator.class,true),
                new MLSBuilder.SIHolder(SICornerRadiusManager.LUA_CLASS_NAME, SICornerRadiusManager.class),
        };
    }

    public static Register.SHolder[] registerStaticClass() {
        return new Register.SHolder[]{
                /// 第一种，类中含有LuaClass注解
                Register.newSHolderWithLuaClass(LTPrinter.LUA_CLASS_NAME, LTPrinter.class),
                Register.newSHolderWithLuaClass(LTPreferenceUtils.LUA_CLASS_NAME, LTPreferenceUtils.class),
                Register.newSHolderWithLuaClass(LTFile.LUA_CLASS_NAME, LTFile.class),
                Register.newSHolderWithLuaClass(LTStringUtil.LUA_CLASS_NAME, LTStringUtil.class),
                /// 第二种，类中不含有LuaClass注解
                Register.newSHolder(LTTypeUtils.LUA_CLASS_NAME, LTTypeUtils.class, LTTypeUtils.methods),
        };
    }

    public static Class[] registerConstants() {
        return new Class[]{
                FontStyle.class,
                TextAlign.class,
                BreakMode.class,
                EditTextViewInputMode.class,
                ReturnType.class,
                ContentMode.class,
                UnderlineStyle.class,
                CachePolicy.class,
                ErrorKey.class,
                ResponseKey.class,
                InterpolatorType.class,
                ValueType.class,
                RepeatType.class,
                NavigatorAnimType.class,
                NetworkState.class,
                RectCorner.class,
                ScrollDirection.class,
                EncType.class,
                ResultType.class,
                GravityConstants.class,
                LinearType.class,
                MeasurementType.class,
                GradientType.class,
                TabSegmentAlignment.class,
                StatusBarStyle.class,
                StatusMode.class,
                AnimationValueType.class,
                FileInfo.class,
                DrawStyle.class,
                FillType.class,
                StyleImageAlign.class,
                MotionEvent.class,
                SafeAreaConstants.class,
                MainAxisAlignType.class,
                CrossAxisAlignType.class,
                WrapType.class,
        };
    }

    /**
     * 低内存时动态释放lua资源
     */
    public static void onTrimMemory(int level) {
        switch (level) {
            case ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW:
            case ComponentCallbacks2.TRIM_MEMORY_BACKGROUND:
                Globals.tryFullGc(1);
                break;
            case ComponentCallbacks2.TRIM_MEMORY_MODERATE:
                Globals.tryFullGc(2);
                break;
            case ComponentCallbacks2.TRIM_MEMORY_RUNNING_CRITICAL:
            case ComponentCallbacks2.TRIM_MEMORY_COMPLETE:
                Globals.tryFullGc(-2);
                break;
        }
    }
}