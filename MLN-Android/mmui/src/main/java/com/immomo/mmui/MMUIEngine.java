/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.ILoadLibAdapter;
import com.immomo.mls.adapter.impl.LoadLibAdapterImpl;
import com.immomo.mls.fun.constants.BreakMode;
import com.immomo.mls.fun.constants.ContentMode;
import com.immomo.mls.fun.constants.DrawStyle;
import com.immomo.mls.fun.constants.EditTextViewInputMode;
import com.immomo.mls.fun.constants.FileInfo;
import com.immomo.mls.fun.constants.FillType;
import com.immomo.mls.fun.constants.FontStyle;
import com.immomo.mls.fun.constants.GradientType;
import com.immomo.mls.fun.constants.NavigatorAnimType;
import com.immomo.mls.fun.constants.NetworkState;
import com.immomo.mls.fun.constants.RectCorner;
import com.immomo.mls.fun.constants.ResultType;
import com.immomo.mls.fun.constants.ReturnType;
import com.immomo.mls.fun.constants.SafeAreaConstants;
import com.immomo.mls.fun.constants.ScrollDirection;
import com.immomo.mls.fun.constants.StatusBarStyle;
import com.immomo.mls.fun.constants.StyleImageAlign;
import com.immomo.mls.fun.constants.TextAlign;
import com.immomo.mls.fun.constants.UnderlineStyle;
import com.immomo.mls.fun.java.Alert;
import com.immomo.mls.fun.java.Event;
import com.immomo.mls.fun.java.JToast;
import com.immomo.mls.fun.java.LuaDialog;
import com.immomo.mls.fun.lt.LTFile;
import com.immomo.mls.fun.lt.LTPreferenceUtils;
import com.immomo.mls.fun.lt.SClipboard;
import com.immomo.mls.fun.lt.SIApplication;
import com.immomo.mls.fun.lt.SICornerRadiusManager;
import com.immomo.mls.fun.lt.SIEventCenter;
import com.immomo.mls.fun.lt.SIGlobalEvent;
import com.immomo.mls.fun.lt.SILoading;
import com.immomo.mls.fun.lt.SINetworkReachability;
import com.immomo.mls.fun.lt.SISystem;
import com.immomo.mls.fun.lt.SITimeManager;
import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.Timer;
import com.immomo.mls.fun.ud.UDArray;
import com.immomo.mls.fun.ud.UDCanvas;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.fun.ud.UDPaint;
import com.immomo.mls.fun.ud.UDPath;
import com.immomo.mls.fun.ud.net.CachePolicy;
import com.immomo.mls.fun.ud.net.EncType;
import com.immomo.mls.fun.ud.net.ErrorKey;
import com.immomo.mls.fun.ud.net.ResponseKey;
import com.immomo.mls.fun.ud.net.UDHttp;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.wrapper.IJavaObjectGetter;
import com.immomo.mls.wrapper.ILuaValueGetter;
import com.immomo.mls.wrapper.Register;
import com.immomo.mls.wrapper.Translator;
import com.immomo.mmui.constants.CrossAxis;
import com.immomo.mmui.constants.FlexConstants;
import com.immomo.mmui.constants.MainAxis;
import com.immomo.mmui.constants.PositionType;
import com.immomo.mmui.constants.Wrap;
import com.immomo.mmui.databinding.LTCDataBinding;
import com.immomo.mmui.databinding.annotation.WatchContext;
import com.immomo.mmui.gesture.DispatchDelay;
import com.immomo.mmui.globals.UDLuaView;
import com.immomo.mmui.sbridge.ArgoUI;
import com.immomo.mmui.sbridge.LTStringUtil;
import com.immomo.mmui.ud.SIPageLink;
import com.immomo.mmui.ud.UDColor;
import com.immomo.mmui.ud.UDEditText;
import com.immomo.mmui.ud.UDHStack;
import com.immomo.mmui.ud.UDImageButton;
import com.immomo.mmui.ud.UDImageView;
import com.immomo.mmui.ud.UDLabel;
import com.immomo.mmui.ud.UDNodeGroup;
import com.immomo.mmui.ud.UDPoint;
import com.immomo.mmui.ud.UDSafeAreaRect;
import com.immomo.mmui.ud.UDScrollView;
import com.immomo.mmui.ud.UDSize;
import com.immomo.mmui.ud.UDSpacer;
import com.immomo.mmui.ud.UDStyleString;
import com.immomo.mmui.ud.UDSwitch;
import com.immomo.mmui.ud.UDVStack;
import com.immomo.mmui.ud.UDView;
import com.immomo.mmui.ud.anim.InteractiveBehavior;
import com.immomo.mmui.ud.anim.InteractiveDirection;
import com.immomo.mmui.ud.anim.InteractiveType;
import com.immomo.mmui.ud.anim.TouchType;
import com.immomo.mmui.ud.anim.UDAnimation;
import com.immomo.mmui.ud.anim.UDAnimatorSet;
import com.immomo.mmui.ud.anim.UDBaseAnimation;
import com.immomo.mmui.ud.constants.AnimProperty;
import com.immomo.mmui.ud.constants.Timing;
import com.immomo.mmui.ud.recycler.UDBaseRecyclerAdapter;
import com.immomo.mmui.ud.recycler.UDBaseRecyclerLayout;
import com.immomo.mmui.ud.recycler.UDCollectionAdapter;
import com.immomo.mmui.ud.recycler.UDCollectionLayout;
import com.immomo.mmui.ud.recycler.UDListAdapter;
import com.immomo.mmui.ud.recycler.UDRecyclerView;
import com.immomo.mmui.ud.recycler.UDWaterFallAdapter;
import com.immomo.mmui.ud.recycler.UDWaterFallLayout;

import org.luaj.vm2.Globals;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Xiong.Fangyu on 2020-05-27
 */
public class MMUIEngine {

    public static final String ANIMATOR_LIB = "libanimator";
    public static final String DATABIND_LIB = "mmuibridge";
    public static final String YOGA_LIB = "yoga";

    private static final Map<String, Boolean> otherLibs;
    private static boolean init = false;

    private static volatile int modiCount = 0;

    static {
        otherLibs = new HashMap<>(1);
        otherLibs.put(ANIMATOR_LIB, false);
        otherLibs.put(DATABIND_LIB, false);
        otherLibs.put(YOGA_LIB, false);
    }

    /// 单独实例，和luaview不冲突
    public static MMUIRegister singleRegister;
    public static Translator singleTranslator;

    static MMUIReloadButtonCreator reloadButtonCreator = new MMUIReloadButtonCreatorImpl();

    public static void init() {
        init(LoadLibAdapterImpl.getInstance());
    }

    public static void init(ILoadLibAdapter loader) {
        if (!MLSEngine.isInit())
            throw new Error("init mls engine first!");
        if (init)
            return;
        if (singleRegister == null) {
            synchronized (MMUIEngine.class) {
                if (singleRegister == null) {
                    singleRegister = new MMUIRegister();
                    singleTranslator = new Translator();
                } else {
                    init = true;
                }
            }
        } else {
            init = true;
        }
        if (init)
            return;

        initOtherLibs(loader);

        registerMMUI(MMUI);
        registerMMUI(TOOLS);
        registerMMUIEnum(ENUMS);
        registerStaticClass(STATICS);
        registerCovert(COVERT);
        registerSingleInstance(SINGLE_INSTANCE);
        registerNewSingleInstance(NEW_SINGLE_INSTANCE);
        registerNewStaticClass(NEW_STATIC);
        registerNewUserdata(NEW_UD);
        com.immomo.mls.PreGlobalInitUtils.setOnSetupGlobalsListener(new com.immomo.mls.PreGlobalInitUtils.OnSetupGlobalsListener() {
            @Override
            public void onSetup(Globals g) {
                g.registerArgoLib();
            }
        });
        MLSEngine.singleRegister.registerNewStaticBridge(ArgoUI.LUA_CLASS_NAME, ArgoUI.class);

        init = true;
    }

    //<editor-fold desc="Bridges">
    private static Register.UDHolder[] MMUI = new Register.UDHolder[]{
            Register.newUDHolder(UDSwitch.LUA_CLASS_NAME, UDSwitch.class, false, UDSwitch.methods),
//            Register.newUDHolder(UDCanvasView.LUA_CLASS_NAME, UDCanvasView.class, false, UDCanvasView.methods),
    };

    private static Register.UDHolder[] TOOLS = new Register.UDHolder[]{
            Register.newUDHolder(UDPath.LUA_CLASS_NAME, UDPath.class, false, UDPath.methods),
            Register.newUDHolder(UDPaint.LUA_CLASS_NAME, UDPaint.class, false, UDPaint.methods),
            Register.newUDHolder(UDCanvas.LUA_CLASS_NAME, UDCanvas.class, false, UDCanvas.methods),

            Register.newUDHolderWithLuaClass(UDHttp.LUA_CLASS_NAME, UDHttp.class, false),
            Register.newUDHolderWithLuaClass(Timer.LUA_CLASS_NAME, Timer.class, false),
            Register.newUDHolderWithLuaClass(JToast.LUA_CLASS_NAME, JToast.class, false),
            Register.newUDHolderWithLuaClass(Event.LUA_CLASS_NAME, Event.class, false),
            Register.newUDHolderWithLuaClass(Alert.LUA_CLASS_NAME, Alert.class, false),
            Register.newUDHolderWithLuaClass(LuaDialog.LUA_CLASS_NAME, LuaDialog.class, false),
    };

    private static Class[] ENUMS = new Class[]{
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
            NavigatorAnimType.class,
            NetworkState.class,
            RectCorner.class,
            ScrollDirection.class,
            EncType.class,
            ResultType.class,
            GradientType.class,
            StatusBarStyle.class,
            FileInfo.class,
            DrawStyle.class,
            FillType.class,
            StyleImageAlign.class,
            SafeAreaConstants.class,

            PositionType.class,
            MainAxis.class,
            CrossAxis.class,
            Wrap.class,
            FlexConstants.class,
            AnimProperty.class,
            Timing.class,
            InteractiveDirection.class,
            InteractiveType.class,
            TouchType.class,
            WatchContext.class,
            DispatchDelay.class
    };

    private static Register.SHolder[] STATICS = new Register.SHolder[]{
            /// 第一种，类中含有LuaClass注解
            Register.newSHolderWithLuaClass(LTPreferenceUtils.LUA_CLASS_NAME, LTPreferenceUtils.class),
            Register.newSHolderWithLuaClass(LTFile.LUA_CLASS_NAME, LTFile.class),
    };

    private static CHolder[] COVERT = new CHolder[]{
            new CHolder(UDColor.class, UDColor.J, null),
            new CHolder(Point.class, UDPoint.L, true),
            new CHolder(Size.class, UDSize.L, true),
            new CHolder(Map.class, UDMap.J, UDMap.G),
            new CHolder(List.class, UDArray.G, true),
    };

    private static SIHolder[] SINGLE_INSTANCE = new SIHolder[]{
            new SIHolder(SISystem.KEY, SISystem.class),
            new SIHolder(SITimeManager.KEY, SITimeManager.class),
            new SIHolder(SClipboard.KEY, SClipboard.class),
            new SIHolder(SIGlobalEvent.LUA_CLASS_NAME, SIGlobalEvent.class),
            new SIHolder(SIApplication.LUA_CLASS_NAME, SIApplication.class),
            new SIHolder(SIEventCenter.LUA_CLASS_NAME, SIEventCenter.class),
            new SIHolder(SINetworkReachability.LUA_CLASS_NAME, SINetworkReachability.class),
            new SIHolder(SILoading.LUA_CLASS_NAME, SILoading.class),
            new SIHolder(SICornerRadiusManager.LUA_CLASS_NAME, SICornerRadiusManager.class),
    };

    /**
     * 注册高性能bridge单例
     */
    private static SIHolder[] NEW_SINGLE_INSTANCE = new SIHolder[]{
            new SIHolder(SIPageLink.LUA_CLASS_NAME, SIPageLink.class)
    };

    private static Register.NewStaticHolder[] NEW_STATIC = new Register.NewStaticHolder[]{
            new Register.NewStaticHolder(LTCDataBinding.LUA_CLASS_NAME, LTCDataBinding.class),
            new Register.NewStaticHolder(LTStringUtil.LUA_CLASS_NAME, LTStringUtil.class),
            new Register.NewStaticHolder(ArgoUI.LUA_CLASS_NAME, ArgoUI.class),
    };

    private static Register.NewUDHolder[] NEW_UD = new Register.NewUDHolder[]{
            new Register.NewUDHolder(UDPoint.LUA_CLASS_NAME, UDPoint.class),
            new Register.NewUDHolder(UDSize.LUA_CLASS_NAME, UDSize.class),
            new Register.NewUDHolder(UDArray.LUA_CLASS_NAME, UDArray.class),
            new Register.NewUDHolder(UDMap.LUA_CLASS_NAME, UDMap.class),

            new Register.NewUDHolder(InteractiveBehavior.LUA_CLASS_NAME, InteractiveBehavior.class),
            new Register.NewUDHolder(UDView.LUA_CLASS_NAME, UDView.class),
            new Register.NewUDHolder(UDNodeGroup.LUA_CLASS_NAME, UDNodeGroup.class),
            new Register.NewUDHolder(UDHStack.LUA_CLASS_NAME, UDHStack.class),
            new Register.NewUDHolder(UDVStack.LUA_CLASS_NAME, UDVStack.class),
            new Register.NewUDHolder(UDSpacer.LUA_CLASS_NAME, UDSpacer.class),
            new Register.NewUDHolder(UDLuaView.LUA_CLASS_NAME, UDLuaView.class),
            new Register.NewUDHolder(UDColor.LUA_CLASS_NAME, UDColor.class),
            new Register.NewUDHolder(UDLabel.LUA_CLASS_NAME, UDLabel.class),
            new Register.NewUDHolder(UDStyleString.LUA_CLASS_NAME, UDStyleString.class),
            new Register.NewUDHolder(UDEditText.LUA_CLASS_NAME, UDEditText.class),
            new Register.NewUDHolder(UDImageView.LUA_CLASS_NAME, UDImageView.class),
            new Register.NewUDHolder(UDImageButton.LUA_CLASS_NAME, UDImageButton.class),
            new Register.NewUDHolder(UDRecyclerView.LUA_META_NAME, UDRecyclerView.class),
            new Register.NewUDHolder(UDScrollView.LUA_CLASS_NAME, UDScrollView.class),

            new Register.NewUDHolder(UDBaseRecyclerAdapter.LUA_CLASS_NAME, UDBaseRecyclerAdapter.class),
            new Register.NewUDHolder(UDListAdapter.LUA_CLASS_NAME, UDListAdapter.class),
            new Register.NewUDHolder(UDCollectionAdapter.LUA_CLASS_NAME, UDCollectionAdapter.class),
            new Register.NewUDHolder(UDWaterFallAdapter.LUA_CLASS_NAME, UDWaterFallAdapter.class),
            new Register.NewUDHolder(UDBaseRecyclerLayout.LUA_CLASS_NAME, UDBaseRecyclerLayout.class),
            new Register.NewUDHolder(UDCollectionLayout.LUA_CLASS_NAME, UDCollectionLayout.class),
            new Register.NewUDHolder(UDWaterFallLayout.LUA_CLASS_NAME, UDWaterFallLayout.class),

            new Register.NewUDHolder(UDSafeAreaRect.LUA_CLASS_NAME, UDSafeAreaRect.class),
            new Register.NewUDHolder(UDBaseAnimation.LUA_CLASS_NAME, UDBaseAnimation.class),
            new Register.NewUDHolder(UDAnimation.LUA_CLASS_NAME, UDAnimation.class),
            new Register.NewUDHolder(UDAnimatorSet.LUA_CLASS_NAME, UDAnimatorSet.class),
    };
    //</editor-fold>

    /**
     * 初始化非核心库
     */
    private static void initOtherLibs(ILoadLibAdapter libAdapter) {
        Map<String, Boolean> temp = new HashMap<>(otherLibs);
        for (Map.Entry<String, Boolean> e : temp.entrySet()) {
            if (!e.getValue()) {
                otherLibs.put(e.getKey(), libAdapter.load(e.getKey()));
            }
        }
        if (MLSEngine.DEBUG) {
            LogUtil.d("mmui engine load libs:", otherLibs);
        }
    }

    public static boolean isLibInit(String libName) {
        Boolean init = otherLibs.get(libName);
        return init != null && init;
    }

    public static void registerMMUI(Register.UDHolder... mmuiHolders) {
        modiCount ++;
        for (Register.UDHolder h : mmuiHolders) {
            singleRegister.registerUserdata(h);
        }
        modiCount --;
    }

    public static void registerMMUIEnum(Class... mmuiHolders) {
        modiCount ++;
        for (Class h : mmuiHolders) {
            singleRegister.registerEnum(h);
        }
        modiCount --;
    }

    public static void registerStaticClass(Register.SHolder... siHolders) {
        modiCount ++;
        for (Register.SHolder siHolder : siHolders) {
            singleRegister.registerStaticBridge(siHolder);
        }
        modiCount --;
    }

    private static void registerNewStaticClass(Register.NewStaticHolder... newStaticHolders) {
        modiCount ++;
        for (Register.NewStaticHolder newStaticHolder : newStaticHolders) {
            singleRegister.registerNewStaticBridge(newStaticHolder);
        }
        modiCount --;
    }

    private static void registerNewUserdata(Register.NewUDHolder... udHolders) {
        modiCount ++;
        for (Register.NewUDHolder h : udHolders) {
            singleRegister.registerNewUserdata(h);
        }
        modiCount --;
    }

    public static void registerSingleInstance(SIHolder... siHolders) {
        modiCount ++;
        for (SIHolder siHolder : siHolders) {
            singleRegister.registerSingleInstance(siHolder.luaClassName, siHolder.clz);
        }
        modiCount --;
    }

    public static void registerNewSingleInstance(SIHolder... holders) {
        modiCount ++;
        for (SIHolder h : holders) {
            singleRegister.registerNewSingleInstance(h.luaClassName, h.clz);
        }
        modiCount --;
    }

    public static void registerCovert(CHolder... cHolders) {
        for (CHolder h : cHolders) {
            if (h.defaultL2J) {
                singleTranslator.registerL2JAuto(h.clz);
            } else if (h.l2j != null) {
                singleTranslator.registerL2J(h.clz, h.l2j);
            }
            if (h.defaultJ2L) {
                singleTranslator.registerJ2LAuto(h.clz);
            } else if (h.j2l != null) {
                singleTranslator.registerJ2L(h.clz, h.j2l);
            }
        }
    }

    public static void setReloadButtonCreator(MMUIReloadButtonCreator reloadButtonCreator) {
        MMUIEngine.reloadButtonCreator = reloadButtonCreator;
    }

    public static void preInit(final int num) {
        if (modiCount > 0)
            return;
        MainThreadExecutor.post(new Runnable() {
            @Override
            public void run() {
                if (modiCount > 0)
                    return;
                if (PreGlobalInitUtils.hasPreInitSize() == 0)
                    PreGlobalInitUtils.initFewGlobals(num);
            }
        });
    }


    /**
     * 单例包裹类
     * <p>
     * 每个虚拟机中只有一个实例，使用{@link #luaClassName}获取
     * 虚拟机销毁时，会调用相关类中__onLuaGc方法
     * <p>
     * 和静态Bridge不同的是，单例有虚拟机状态，
     * 适用于需要获取状态的类中，或需要在虚拟机销毁时，释放资源的类中
     */
    public static class SIHolder {
        public String luaClassName;
        /**
         * 类中必须有{@link com.immomo.mls.annotation.LuaClass}注解
         */
        public Class clz;

        public SIHolder(String lcn, Class clz) {
            luaClassName = lcn;
            this.clz = clz;
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
        boolean defaultL2J;
        IJavaObjectGetter l2j;
        boolean defaultJ2L;
        ILuaValueGetter j2l;

        public CHolder(Class clz) {
            this.clz = clz;
            defaultL2J = true;
            defaultJ2L = true;
        }

        public CHolder(Class clz, IJavaObjectGetter l2j, boolean defaultJ2L) {
            this.clz = clz;
            this.defaultJ2L = defaultJ2L;
            this.l2j = l2j;
            defaultL2J = false;
        }

        public CHolder(Class clz, ILuaValueGetter j2l, boolean defaultL2J) {
            this.clz = clz;
            this.defaultL2J = defaultL2J;
            this.j2l = j2l;
            defaultJ2L = false;
        }

        public CHolder(Class clz, IJavaObjectGetter l2j, ILuaValueGetter j2l) {
            this.clz = clz;
            this.j2l = j2l;
            this.l2j = l2j;
            defaultL2J = false;
            defaultJ2L = false;
        }
    }

}