/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.globals;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.Constants;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.fun.constants.StatusBarStyle;
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ud.UDMap;
import com.immomo.mls.fun.ud.UDSafeAreaRect;
import com.immomo.mls.fun.ud.view.UDViewGroup;
import com.immomo.mls.fun.ui.DefaultSafeAreaManager;
import com.immomo.mls.receiver.ConnectionStateChangeBroadcastReceiver;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.KeyboardUtil;

import org.luaj.vm2.LuaBoolean;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@LuaApiUsed
public class UDLuaView extends UDViewGroup<LuaView> implements ConnectionStateChangeBroadcastReceiver.OnConnectionChangeListener, KeyboardUtil.OnKeyboardShowingListener {
    public static final String LUA_CLASS_NAME = "__WINDOW";
    public static final String LUA_SINGLE_NAME = "window";

    public static final String[] methods = {
            "getLuaVersion",
            "viewAppear",
            "viewDisappear",
            "backKeyPressed",
            "sizeChanged",
            "keyboardShowing",
            "removeKeyboardCallback",
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
            "i_keyBoardFrameChangeCallback",
    };

    private LuaFunction viewAppearCallback;
    private LuaFunction viewDisappearCallback;
    private LuaFunction sizeChangedCallback;
    private LuaFunction destroyCallback;
    private List<LuaFunction> keyboardShowingCallbacks;

    private LuaFunction backKeyPressedCallback;

    private UDMap extraData;
    private int statusTextStyle = -1;
    private DefaultSafeAreaManager safeAreaManager;

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

    // ios 私有方法，安卓空实现
    @LuaApiUsed
    public LuaValue[] i_keyBoardFrameChangeCallback(LuaValue[] p) {

        return null;
    }

    @LuaApiUsed
    public LuaValue[] sizeChanged(LuaValue[] p) {
        sizeChangedCallback = p[0].toLuaFunction();
        return null;
    }

    @LuaApiUsed
    public LuaValue[] keyboardShowing(LuaValue[] p) {
        LuaFunction fun = p[0].isFunction() ? p[0].toLuaFunction() : null;
        if (keyboardShowingCallbacks == null) {
            keyboardShowingCallbacks = new ArrayList<>();
        }
        if (fun != null && !keyboardShowingCallbacks.contains(fun)) {
            keyboardShowingCallbacks.add(fun);
        }
        final LuaView view = getView();
        if (view != null) {
            if (keyboardShowingCallbacks.size() > 0) {
                view.setKeyboardChangeListener();
            } else {
                view.removeKeyboardChangeListener();
            }
        }
        return null;
    }

    @LuaApiUsed
    public LuaValue[] removeKeyboardCallback(LuaValue[] p) {
        if (keyboardShowingCallbacks != null) {
            keyboardShowingCallbacks.remove(p[0].toLuaFunction());
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
    }

    @Override
    public int getWidth() {
        final View view = getView();
        if (view != null) {
            ViewGroup.LayoutParams params = view.getLayoutParams();
            if (params != null) {
                int pw = params.width;
                if (pw >= 0)
                    return pw;
                int mw = view.getMeasuredWidth();
                if (mw > 0)
                    return mw;
                if (pw == MATCH_PARENT) {
                    if (view.getParent() instanceof ViewGroup) {
                        return ((ViewGroup) view.getParent()).getMeasuredWidth();
                    }
                }
                return mw;
            }
        }
        return 0;
    }

    @Override
    public int getHeight() {
        int h = getViewHeight();
//        Context c = getContext();
//        if (c instanceof Activity) {
//            int sh = AndroidUtil.getScreenHeight(c);
//            if (h == sh && !AndroidUtil.isFullScreen((Activity) c)) {
//                h -= AndroidUtil.getStatusBarHeight(c);
//            }
//        }
        return h;
    }

    public boolean getBackKeyEnabled() {
        return backKeyEnabled;
    }

    private int getViewHeight() {
        final View view = getView();
        if (view != null) {
            ViewGroup.LayoutParams params = view.getLayoutParams();
            if (params != null) {
                int ph = params.height;
                if (ph >= 0)
                    return ph;
                int mh = view.getMeasuredHeight();
                if (mh > 0)
                    return mh;
                if (ph == MATCH_PARENT) {
                    if (view.getParent() instanceof ViewGroup) {
                        return ((ViewGroup) view.getParent()).getMeasuredHeight();
                    }
                }
                return mh;
            }
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

    @Override
    public void onKeyboardShowing(boolean isShowing, int keyboardHeight) {
        if (keyboardShowingCallbacks == null) return;

        for (LuaFunction fun :
                keyboardShowingCallbacks) {
            if (fun != null)
                fun.invoke(varargsOf(isShowing ? True() : False(), LuaNumber.valueOf(isShowing ? DimenUtil.pxToDpi(keyboardHeight) : 0)));
        }
    }
}