/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.globals;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.Constants;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.fun.constants.StatusBarStyle;
import com.immomo.mls.fun.constants.StatusMode;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.receiver.ConnectionStateChangeBroadcastReceiver;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.keyboard.MMUIKeyboardUtil;
import com.immomo.mmui.ud.UDColor;
import com.immomo.mmui.ud.UDNodeGroup;
import com.immomo.mmui.ud.UDSafeAreaRect;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.HashSet;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed
public class UDLuaView extends UDNodeGroup<LuaView> implements ConnectionStateChangeBroadcastReceiver.OnConnectionChangeListener, MMUIKeyboardUtil.OnKeyboardShowingListener {
    public static final String LUA_CLASS_NAME = "__WINDOW";
    public static final String LUA_SINGLE_NAME = "window";

    private LuaFunction viewAppearCallback;
    private LuaFunction viewDisappearCallback;
    private LuaFunction sizeChangedCallback;
    private LuaFunction destroyCallback;
    private LuaFunction keyBoardHeightChangeCallback;
    private LuaFunction keyboardShowingCallback;

    private LuaFunction backKeyPressedCallback;

    private UDMap extraData;
    private int statusTextStyle = -1;
    private int mStatusMode = -1;//默认非全屏
    private DefaultSafeAreaManager safeAreaManager;

    private HashSet<UDView> keyboardViewCache;//缓存键盘弹起后，上移的view。（配合keyboardManager.lua的方法。）
    private boolean isKeyboardShowing;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDLuaView(long L) {
        super(L);
    }

    @Override
    protected LuaView newView(LuaValue[] init) {
        return new LuaView(getContext(), this);
    }

    //<editor-fold desc="native method">
    /**
     * 初始化方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>
    //<editor-fold desc="API">

    @LuaApiUsed
    public String getLuaVersion() {
        return getLuaViewManager().scriptVersion;
    }

    @LuaApiUsed
    public void viewAppear(LuaFunction p) {
        viewAppearCallback = p;
    }

    @LuaApiUsed
    public void viewDisappear(LuaFunction p) {
        viewDisappearCallback = p;
    }

    @LuaApiUsed
    public void backKeyPressed(LuaFunction p) {
        backKeyPressedCallback = p;
    }

    boolean backKeyEnabled = true;

    @LuaApiUsed
    public boolean isBackKeyEnabled() {
        return backKeyEnabled;
    }

    @LuaApiUsed
    public void setBackKeyEnabled(boolean backKeyEnabled) {
        this.backKeyEnabled = backKeyEnabled;
    }

    @LuaApiUsed
    public void keyBoardHeightChange(LuaFunction p) {
        keyBoardHeightChangeCallback = p;
        final LuaView view = getView();
        if (view != null) {
            if (keyboardShowingCallback != null
                    && keyBoardHeightChangeCallback != null) {
                view.setKeyboardChangeListener();
            } else {
                view.removeKeyboardChangeListener();
            }
        }
    }

    @LuaApiUsed
    public void sizeChanged(LuaFunction p) {
        sizeChangedCallback = p;
    }

    @LuaApiUsed
    public void keyboardShowing(LuaFunction p) {
        keyboardShowingCallback = p;
        final LuaView view = getView();
        if (view != null) {
            if (keyboardShowingCallback != null
                    && keyBoardHeightChangeCallback != null) {
                view.setKeyboardChangeListener();
            } else {
                view.removeKeyboardChangeListener();
            }
        }
    }

    @LuaApiUsed
    public UDMap getExtra() {
        return extraData;
    }

    @LuaApiUsed
    public String getLuaSource() {
        if (extraData != null && extraData.getMap() != null) {
            Object luaSource = extraData.getMap().get(Constants.KEY_LUA_SOURCE);
            if (luaSource instanceof String) {
                return (String) luaSource;
            }
        }
        return null;
    }

    @LuaApiUsed
    public void onDestroy(LuaFunction p) {
        destroyCallback = p;
    }

    @Deprecated
    @LuaApiUsed
    public void setPageColor(UDColor color) {
        Activity a = getActivity();
        if (a == null)
            return;
        int c = color.getColor();
        AndroidUtil.setStatusBarColor(a, c);
        setBgColor(c);
    }

    @LuaApiUsed
    public void setStatusBarStyle(int style) {
        Activity a = getActivity();
        if (a == null || style == statusTextStyle) {
            return;
        }

        switch (style) {
            case StatusBarStyle.Default:
                statusTextStyle = style;
                AndroidUtil.showLightStatusBar(false, a);
                break;

            case StatusBarStyle.Light:
                statusTextStyle = style;
                AndroidUtil.showLightStatusBar(true, a);
                break;
        }
    }

    @CGenerate(alias = "getStatusBarStyle")
    @LuaApiUsed
    public int nGetStatusBarStyle() {
        return statusTextStyle;
    }

    @LuaApiUsed
    public void setStatusBarMode(int statusMode) {
        Activity a = getActivity();
        if (a == null)
            return;
        mStatusMode = statusMode;
        switch (statusMode) {
            case StatusMode.NON_FULLSCREEN:
                AndroidUtil.switchFullscreen(a, false);
                break;
            case StatusMode.FULLSCREEN:
                AndroidUtil.switchFullscreen(a, true);
                break;
            case StatusMode.TRANSLUCENT:
                AndroidUtil.switchFullscreen(a, false);
                AndroidUtil.setTranslucent(a);
                break;
        }
    }

    @LuaApiUsed
    public int getStatusBarMode() {
        Activity a = getActivity();
        if (mStatusMode == -1) {
            if (a == null) {
                return mStatusMode;
            }
            boolean isTranslucent = AndroidUtil.isLayoutStable(a);
            boolean isFullScreen = AndroidUtil.isFullScreen(a);
            return isFullScreen ? StatusMode.FULLSCREEN :
                    isTranslucent ? (StatusMode.FULLSCREEN) : (StatusMode.NON_FULLSCREEN);
        }
        return mStatusMode;
    }

    @LuaApiUsed
    public void setStatusBarColor(UDColor color) {
        Activity a = getActivity();
        if (a == null)
            return;
        AndroidUtil.setStatusColor(a, color.getColor());
    }

    @LuaApiUsed
    public UDColor getStatusBarColor() {
        Activity a = getActivity();
        if (a == null) {
            return null;
        }
        return new UDColor(getGlobals(), AndroidUtil.getStatusColor(a));
    }

    @LuaApiUsed
    public float statusBarHeight() {
        return DimenUtil.pxToDpi(AndroidUtil.getStatusBarHeight(getContext()));
    }

    @LuaApiUsed
    public float navBarHeight() {
        return MLSConfigs.defaultNavBarHeight;
    }

    @LuaApiUsed
    public float tabBarHeight() {
        return 0;
    }

    @LuaApiUsed
    public float homeHeight() {
        return 0;
    }

    @LuaApiUsed
    public float homeBarHeight() {
        return DimenUtil.pxToDpi(AndroidUtil.getNavigationBarHeight(getContext()));
    }

    @LuaApiUsed
    public void safeArea() {
        safeArea(DefaultSafeAreaManager.CLOSE);
    }

    @LuaApiUsed
    public void safeArea(int safeArea) {
        getSafeArea().safeArea(safeArea, this);
    }

    @LuaApiUsed
    public float safeAreaInsetsTop() {
        return getSafeArea().getSafeAreaInsetsTop();
    }

    @LuaApiUsed
    public float safeAreaInsetsBottom() {
        return getSafeArea().getSafeAreaInsetsBottom();
    }

    @LuaApiUsed
    public float safeAreaInsetsLeft() {
        return getSafeArea().getSafeAreaInsetsLeft();
    }

    @LuaApiUsed
    public float safeAreaInsetsRight() {
        return getSafeArea().getSafeAreaInsetsRight();
    }

    @LuaApiUsed
    public void safeAreaAdapter(UDSafeAreaRect v) {
        if (v != null) {
            getSafeArea().setSafeAreaAdapter(v, this);
        }
    }

    private DefaultSafeAreaManager getSafeArea() {
        if (safeAreaManager == null) {
            safeAreaManager = new DefaultSafeAreaManager(getContext());
        }
        return safeAreaManager;
    }

    @Override
    public void padding(double t, double r, double b, double l) {
        super.padding(t, r, b, l);
        if (safeAreaManager != null) {
            safeAreaManager.updataArea(this);
        }
    }

    @LuaApiUsed
    public void cachePushView(UDView bindView) {
        if (keyboardViewCache == null) {
            keyboardViewCache = new HashSet<>();
        }
        keyboardViewCache.add(bindView);
    }

    @LuaApiUsed
    public void clearPushView() {
        if (keyboardViewCache != null) {
            keyboardViewCache.clear();
            keyboardViewCache = null;
        }
    }

    /**
     * Android端，私有APi
     */
    @LuaApiUsed
    public void sizeChangeEnable(boolean enable) {
        getView().sizeChangeEnable(enable);
    }
    //</editor-fold>

    private Activity getActivity() {
        Context c = getContext();
        if (c instanceof Activity) {
            return (Activity) c;
        }
        return null;
    }

    public void putExtras(Map extras) {
        if (extraData == null) {
            extraData = new UDMap(globals, extras);
            extraData.onJavaRef();
        } else {
            extraData.getMap().putAll(extras);
        }
    }

    public void callbackAppear() {
        if (viewAppearCallback != null) {
            viewAppearCallback.fastInvoke();
        }
    }

    public void callbackDisappear() {
        if (viewDisappearCallback != null) {
            viewDisappearCallback.fastInvoke();
        }
    }

    public void callBackKeyPressed() {
        if (backKeyPressedCallback != null)
            backKeyPressedCallback.fastInvoke();
    }

    public boolean callSizeChanged(int w, int h) {
        if (safeAreaManager != null) {//切换全屏/非全屏/屏幕尺寸改变时，重新计算安全区域
            safeAreaManager.updataArea(this);
        }
        if (sizeChangedCallback == null)
            return false;
        sizeChangedCallback.fastInvoke(DimenUtil.pxToDpi(w), DimenUtil.pxToDpi(h));
        return true;
    }

    public void callDestroy() {
        if (destroyCallback != null) {
            destroyCallback.fastInvoke();
        }

        if (keyboardViewCache != null) {//销毁键盘弹出，缓存的View
            keyboardViewCache.clear();
            keyboardViewCache = null;
        }
    }

    @Override
    public int getWidth() {
        final View view = getView();
        if (view != null) {
            int pw = super.getWidth();
            if (pw > 0)
                return pw;
            int mw = view.getMeasuredWidth();
            if (mw > 0)
                return mw;
            if (view.getParent() instanceof ViewGroup) {
                return ((ViewGroup) view.getParent()).getMeasuredWidth();
            }
            return mw;
        }
        return 0;
    }

    @Override
    public int getHeight() {
        final View view = getView();
        if (view != null) {
            int pw = super.getHeight();
            if (pw > 0)
                return pw;
            int mw = view.getMeasuredHeight();
            if (mw > 0)
                return mw;
            if (view.getParent() instanceof ViewGroup) {
                return ((ViewGroup) view.getParent()).getMeasuredHeight();
            }
            return mw;
        }
        return 0;
    }

    @Override
    public void onConnectionClosed() {

    }

    @Override
    public void onMobileConnected() {

    }

    @Override
    public void onWifiConnected() {

    }

    public boolean isKeyboardShowing() {
        return isKeyboardShowing;
    }

    public HashSet<UDView> getKeyboardViewCache() {
        return keyboardViewCache;
    }

    @Override
    public void onKeyboardShowing(boolean isShowing, int keyboardHeight) {
        isKeyboardShowing = isShowing;
        if (keyboardShowingCallback != null)
            keyboardShowingCallback.invoke(varargsOf(isShowing ? True() : False(), LuaNumber.valueOf(isShowing ? DimenUtil.pxToDpi(keyboardHeight) : 0)));
    }

    @Override
    public void onKeyboardChange(int oldHeight, int newHeight) {
        if (keyBoardHeightChangeCallback != null) {
            keyBoardHeightChangeCallback.fastInvoke(DimenUtil.pxToDpi(oldHeight), DimenUtil.pxToDpi(newHeight));
        }
    }
}