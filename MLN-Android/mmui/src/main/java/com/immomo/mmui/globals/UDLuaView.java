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
import com.immomo.mmui.keyboard.MMUIKeyboardUtil;
import com.immomo.mmui.ud.UDColor;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.receiver.ConnectionStateChangeBroadcastReceiver;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.ud.UDNodeGroup;
import com.immomo.mmui.ud.UDSafeAreaRect;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
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

    public static final String[] methods = {
            "getLuaVersion",
            "viewAppear",
            "viewDisappear",
            "backKeyPressed",
            "sizeChanged",
            "keyboardShowing",
            "getExtra",
            "getLuaSource",
            "onDestory",
            "onDestroy",
            "setPageColor",
            "setStatusBarStyle",
            "getStatusBarStyle",
            "stateBarHeight",
            "statusBarHeight",
            "navBarHeight",
            "tabBarHeight",
            "homeHeight",
            "homeBarHeight",
            "canEndEditing",
            "sizeChangeEnable",
            "backKeyEnabled",
            "safeArea",
            "safeAreaInsetsTop",
            "safeAreaInsetsBottom",
            "safeAreaInsetsLeft",
            "safeAreaInsetsRight",
            "safeAreaAdapter",
            "keyBoardHeightChange",
            "cachePushView",
            "clearPushView",
            "statusBarMode",
            "statusBarColor",
    };

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

    @LuaApiUsed
    protected UDLuaView(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected LuaView newView(LuaValue[] init) {
        return new LuaView(getContext(), this);
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] getLuaVersion(LuaValue[] p) {
        return rString(getLuaViewManager().scriptVersion);
    }

    @LuaApiUsed
    public LuaValue[] viewAppear(LuaValue[] p) {
        viewAppearCallback = p[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] viewDisappear(LuaValue[] p) {
        viewDisappearCallback = p[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] backKeyPressed(LuaValue[] p) {
        backKeyPressedCallback = p[0].toLuaFunction();
        return null;
    }

    boolean backKeyEnabled = true;

    /**
     * 是否屏蔽返回键操作
     */
    @LuaApiUsed
    public LuaValue[] backKeyEnabled(LuaValue[] values) {
        if (values.length >= 1 && values[0].isBoolean()) {
            backKeyEnabled = values[0].toBoolean();
            return null;
        }
        return varargsOf(LuaBoolean.valueOf(backKeyEnabled));
    }

    @LuaApiUsed
    public LuaValue[] keyBoardHeightChange(LuaValue[] p) {
        if (p.length>0){
            keyBoardHeightChangeCallback = p[0].isFunction() ? p[0].toLuaFunction() : null;
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
        return null;
    }

    @LuaApiUsed
    public LuaValue[] sizeChanged(LuaValue[] p) {
        sizeChangedCallback = p[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] keyboardShowing(LuaValue[] p) {
        if (p.length > 0) {
            keyboardShowingCallback = p[0].isFunction() ? p[0].toLuaFunction() : null;
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
        return null;
    }

    @LuaApiUsed
    public LuaValue[] getExtra(LuaValue[] p) {
        if (extraData == null)
            return rNil();
        return varargsOf(extraData);
    }

    @LuaApiUsed
    public LuaValue[] getLuaSource(LuaValue[] p) {
        if (extraData != null && extraData.getMap() != null) {
            Object luaSource = extraData.getMap().get(Constants.KEY_LUA_SOURCE);
            if (luaSource instanceof String) {
                return rString((String) luaSource);
            }
        }
        return rNil();
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] onDestory(LuaValue[] p) {
        destroyCallback = p[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] onDestroy(LuaValue[] p) {
        destroyCallback = p[0].toLuaFunction();
        return null;
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] setPageColor(LuaValue[] p) {
        Activity a = getActivity();
        if (a == null)
            return null;
        int c = ((UDColor) p[0]).getColor();
        AndroidUtil.setStatusBarColor(a, c);
        setBgColor(c);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] setStatusBarStyle(LuaValue[] p) {
        int style = p[0].toInt();

        Activity a = getActivity();
        if (a == null || style == statusTextStyle) {
            return null;
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
        return null;
    }

    @LuaApiUsed
    public LuaValue[] getStatusBarStyle(LuaValue[] p) {
        return rNumber(statusTextStyle);
    }

    @LuaApiUsed
    public LuaValue[] statusBarMode(LuaValue[] v) {
        Activity a = getActivity();
        if (v.length > 0) {
            int statusMode = v[0].toInt();
            if (a == null) {
                return null;
            }
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
            return null;
        }

        if(mStatusMode == -1) {
            if (a == null) {
                return rNumber(mStatusMode);
            }
            boolean isTranslucent = AndroidUtil.isLayoutStable(a);
            boolean isFullScreen = AndroidUtil.isFullScreen(a);
            return isFullScreen ? rNumber(StatusMode.FULLSCREEN) :
                isTranslucent ? rNumber(StatusMode.FULLSCREEN) : rNumber(StatusMode.NON_FULLSCREEN);
        }
        return rNumber(mStatusMode);
    }

    @LuaApiUsed
    public LuaValue[] statusBarColor(LuaValue[] v) {
        Activity a = getActivity();

        if (v.length > 0) {
            if (a == null) {
                return null;
            }
            UDColor color = (UDColor) v[0].toUserdata();
            AndroidUtil.setStatusColor(a, color.getColor());
            return null;
        }

        if (a == null) {
            return rNil();
        }
        return varargsOf(new UDColor(getGlobals(), AndroidUtil.getStatusColor(a)));
    }

    @Deprecated
    @LuaApiUsed
    public LuaValue[] stateBarHeight(LuaValue[] p) {
        return rNumber(0);
    }

    @LuaApiUsed
    public LuaValue[] statusBarHeight(LuaValue[] p) {
        return rNumber(DimenUtil.pxToDpi(AndroidUtil.getStatusBarHeight(getContext())));
    }

    @LuaApiUsed
    public LuaValue[] navBarHeight(LuaValue[] p) {
        return rNumber(MLSConfigs.defaultNavBarHeight);
    }

    @LuaApiUsed
    public LuaValue[] tabBarHeight(LuaValue[] p) {
        return rNumber(0);
    }

    @LuaApiUsed
    public LuaValue[] homeHeight(LuaValue[] p) {
        return rNumber(0);
    }

    @LuaApiUsed
    public LuaValue[] homeBarHeight(LuaValue[] p) {
        return rNumber(DimenUtil.pxToDpi(AndroidUtil.getNavigationBarHeight(getContext())));
    }

    @LuaApiUsed
    public LuaValue[] safeArea(LuaValue[] v) {
        int safeArea = v.length > 0 ? v[0].toInt() : DefaultSafeAreaManager.CLOSE;

        getSafeArea().safeArea(safeArea, this);
        return null;
    }

    @LuaApiUsed
    public LuaValue[] safeAreaInsetsTop(LuaValue[] v) {
        return getSafeArea().safeAreaInsetsTop();
    }

    @LuaApiUsed
    public LuaValue[] safeAreaInsetsBottom(LuaValue[] v) {
        return getSafeArea().safeAreaInsetsBottom();
    }

    @LuaApiUsed
    public LuaValue[] safeAreaInsetsLeft(LuaValue[] v) {
        return getSafeArea().safeAreaInsetsLeft();
    }

    @LuaApiUsed
    public LuaValue[] safeAreaInsetsRight(LuaValue[] v) {
        return getSafeArea().safeAreaInsetsRight();
    }

    @LuaApiUsed
    public LuaValue[] safeAreaAdapter(LuaValue[] v) {
        UDSafeAreaRect safeAreaAdapter = v.length > 0 ? (UDSafeAreaRect) v[0].toUserdata() : null;
        if (safeAreaAdapter != null) {
            getSafeArea().setSafeAreaAdapter(safeAreaAdapter,this);
        }
        return null;
    }

    private DefaultSafeAreaManager getSafeArea() {
        if (safeAreaManager == null) {
            safeAreaManager = new DefaultSafeAreaManager(getContext());
        }
        return safeAreaManager;
    }

    @Override
    public LuaValue[] padding(LuaValue[] p) {
        LuaValue[] result = super.padding(p);
        if (safeAreaManager != null) {
            safeAreaManager.updataArea(this);
        }
        return result;
    }

    //    @LuaApiUsed
//    public LuaValue[] canEndEditing(LuaValue[] p) {
//        return null;
//    }

    @LuaApiUsed
    public LuaValue[] cachePushView(LuaValue[] var) {
        if (var.length > 0 && !var[0].isNil()) {
            UDView bindView = (UDView) var[0].toUserdata();
            if(keyboardViewCache == null) {
                keyboardViewCache = new HashSet<>();
            }
            keyboardViewCache.add(bindView);
        }

        return null;
    }

    @LuaApiUsed
    public LuaValue[] clearPushView(LuaValue[] var){
        if(keyboardViewCache!=null){
            keyboardViewCache.clear();
            keyboardViewCache = null;
        }
        return null;
    }
    /**
     * Android端，私有APi
     */
    @LuaApiUsed
    public LuaValue[] sizeChangeEnable(LuaValue[] p) {
        if (p.length != 0 && p[0].isBoolean()) {
            getView().sizeChangeEnable(p[0].toBoolean());
        }
        return null;
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
            viewAppearCallback.invoke(null);
        }
    }

    public void callbackDisappear() {
        if (viewDisappearCallback != null) {
            viewDisappearCallback.invoke(null);
        }
    }

    public void callBackKeyPressed() {
        if (backKeyPressedCallback != null)
            backKeyPressedCallback.invoke(null);
    }

    public boolean callSizeChanged(int w, int h) {
        if (safeAreaManager != null) {//切换全屏/非全屏/屏幕尺寸改变时，重新计算安全区域
            safeAreaManager.updataArea(this);
        }
        if (sizeChangedCallback == null)
            return false;
        sizeChangedCallback.invoke(varargsOf(
                LuaNumber.valueOf(DimenUtil.pxToDpi(w)),
                LuaNumber.valueOf(DimenUtil.pxToDpi(h))));
        return true;
    }

    public void callDestroy() {
        if (destroyCallback != null) {
            destroyCallback.invoke(null);
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

    public boolean getBackKeyEnabled() {
        return backKeyEnabled;
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
        if(keyBoardHeightChangeCallback != null) {

            keyBoardHeightChangeCallback.invoke(varargsOf(LuaNumber.valueOf(DimenUtil.pxToDpi(oldHeight)), LuaNumber.valueOf(DimenUtil.pxToDpi(newHeight))));
        }
    }
}