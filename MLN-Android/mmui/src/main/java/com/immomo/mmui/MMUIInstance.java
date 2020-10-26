/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui;

import android.Manifest;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.webkit.URLUtil;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatDialog;
import androidx.core.app.ActivityCompat;

import com.immomo.mls.Constants;
import com.immomo.mls.DebugPrintStream;
import com.immomo.mls.HotReloadHelper;
import com.immomo.mls.InitData;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.MLSFlag;
import com.immomo.mls.OnActivityResultListener;
import com.immomo.mls.OnGlobalsCreateListener;
import com.immomo.mls.ScriptStateListener;
import com.immomo.mls.adapter.MLSEmptyViewAdapter;
import com.immomo.mls.adapter.MLSGlobalEventAdapter;
import com.immomo.mls.adapter.MLSGlobalStateListener;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.adapter.ScriptReader;
import com.immomo.mls.fun.constants.StatusBarStyle;
import com.immomo.mls.global.LuaViewConfig;
import com.immomo.mls.global.ScriptLoader;
import com.immomo.mls.log.DefaultPrintStream;
import com.immomo.mls.log.ErrorPrintStream;
import com.immomo.mls.log.ErrorType;
import com.immomo.mls.log.IPrinter;
import com.immomo.mls.log.PrinterContainer;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ClickEventLimiter;
import com.immomo.mls.utils.ERROR;
import com.immomo.mls.utils.GlobalStateSDKListener;
import com.immomo.mls.utils.GlobalStateUtils;
import com.immomo.mls.utils.LVCallback;
import com.immomo.mls.utils.LuaUrlUtils;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.utils.ParsedUrl;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.utils.UrlParams;
import com.immomo.mls.utils.loader.Callback;
import com.immomo.mls.utils.loader.LoadTypeUtils;
import com.immomo.mls.utils.loader.ScriptInfo;
import com.immomo.mls.weight.RefreshView;
import com.immomo.mls.weight.ScalpelFrameLayout;
import com.immomo.mls.wrapper.GlobalsContainer;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mmui.globals.LuaView;
import com.immomo.mmui.globals.UDLuaView;
import com.immomo.mmui.wraps.MMUIScriptReaderImpl;

import org.luaj.vm2.Globals;

import java.io.PrintStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Created by XiongFangyu on 2018/6/26.
 * <p>
 * LuaView 封装
 * 必须调用方法:
 *
 * @see #setContainer(ViewGroup)
 * @see #setData(InitData)
 * @see #isValid()
 * @see #onResume()
 * @see #onPause()
 * @see #onDestroy()
 */
public class MMUIInstance implements ScriptLoader.Callback, Callback, PrinterContainer,
        GlobalsContainer, HotReloadHelper.Callback {
    private static final String TAG = "MMUIInstance";
    /**
     * @see #mState
     */
    private static final short STATE_INIT = 0;
    private static final short STATE_SCRIPT_LOADED = 1;
    private static final short STATE_VIEW_CREATED = 1 << 1;
    private static final short STATE_SCRIPT_LOADING = 1 << 2;
    private static final short STATE_SCRIPT_PREPARED = 1 << 3;
    private static final short STATE_SCRIPT_COMPILED = 1 << 4;
    private static final short STATE_SCRIPT_EXECUTED = 1 << 5;
    private static final short STATE_RESUME = 1 << 6;
    private static final short STATE_ERROR = 1 << 7;
    private static final short STATE_DESTROY = 1 << 8;
    private static final short STATE_HOT_RELOADING = 1 << 9;

    private static final int DEFAULT_PROGRESS_ANIM_DURATION = 300;

    Context mContext;
    /**
     * 容器
     *
     * @see #setContainer(ViewGroup)
     */
    ViewGroup mContainer;
    /**
     * 加载脚本和编译脚本时的默认loading view
     *
     * @see #showProgressView()
     * @see #hideProgressView(boolean)
     * @see InitData#showLoadingView
     */
    private RefreshView refreshView;
    /**
     * 加载脚本和编译脚本时的默认loading backGround
     *
     * @see #showProgressBackground() ()
     * @see #hideProgressBackground() (boolean)
     * @see InitData#showLoadingBackground
     */
    private ImageView backGroundView;
    /**
     * 背景图res资源，默认：mls_load_demo
     */
    private int mBackgroundRes = com.immomo.mls.R.drawable.mls_load_demo;

    /**
     * 调试按钮
     *
     * @see #isDebugUrl()
     * @see #initReloadButton()
     */
    private View debugButton;
    /**
     * 3D视图，debug使用
     *
     */
    public ScalpelFrameLayout scalpelFrameLayout;
    /**
     * 调试用，普通输出
     * lua 中调用print()方法可在屏幕上输出
     */
    private DefaultPrintStream viewOut;
    /**
     * 调试用，普通输出+hotreload输出
     */
    private PrintStream STDOUT;
    /**
     * 是否手动关闭过printer
     */
    private boolean closePrinterOnce = false;
    /**
     * 读脚本工具
     */
    private ScriptReader scriptReader;
    /**
     * Lua 虚拟机
     */
    private volatile Globals globals;
    /**
     * globals创建完成回调
     */

    private OnGlobalsCreateListener onGlobalsCreateListener;

    private List<OnGlobalsCreateListener> onGlobalsCreateListeners;
    /**
     * lua 容器
     */
    volatile LuaView mLuaView;
    /**
     * 设置到{@link Globals#setJavaUserdata}
     * 在bridge中通过Globals，能获取到上下文信息
     */
    private MMUILuaViewManager luaViewManager;

    /****************************************************
     *
     * Hot Reload 相关虚拟机
     * 只在有HotReload时初始化
     *
     ****************************************************/
    private Globals hotReloadGlobals;
    private LuaView hotReloadLuaView;
    private MMUILuaViewManager hotReloadLuaViewManager;
    /**
     * 加载失败显示的视图
     *
     * @see #toggleEmptyViewShow(boolean)
     * @see #setEmptyViewContent(CharSequence, CharSequence)
     */
    private MLSEmptyViewAdapter.EmptyView emptyView;
    /**
     * 状态
     *
     * @see #isDestroy()
     * @see #isError()
     * @see #isResume()
     * @see #renderFinish()
     */
    private volatile short mState = STATE_INIT;
    /**
     * 初始化数据
     *
     * @see #setData(InitData)
     */
    private InitData initData;
    /**
     * 脚本加载执行监听
     */
    private ScriptStateListener scriptStateListener;

    /**
     * lua可获取的信息
     *
     * @see InitData#extras
     * @see #putExtras(HashMap)
     * @see LuaView#putExtras(Map)
     */
    private final HashMap extraData = new HashMap();
    /**
     * hot reload 时传入的参数
     *
     * @see #reload(int)
     */
    private HashMap reloadExtraData = null;
    /**
     * 点击事件限制
     * <p>
     * see UDView#canDoClick()
     */
    private ClickEventLimiter clickEventLimiter = new ClickEventLimiter();
    /**
     * debug开关监听
     */
    private DebugButtonOpenListener debugButtonOpenListener;
    /**
     * 是否是热重载页面
     */
    private final boolean isHotReloadPage;
    /**
     * 是否展示debug button
     */
    private  boolean showDebugButton;

    public MMUIInstance(@NonNull Context context) {
        this(context,  false, MLSEngine.DEBUG);
    }

    public MMUIInstance(@NonNull Context context, boolean isHotReloadPage, boolean showDebugButton) {
        AssertUtils.assertNullForce(context);
        mContext = context;
        createLuaViewManager();
        MLSGlobalEventAdapter adapter = MLSAdapterContainer.getGlobalEventAdapter();
        if (adapter != null) {
            debugButtonOpenListener = new DebugButtonOpenListener();
            adapter.addEventListener(Constants.KEY_DEBUG_BUTTON_EVENT, debugButtonOpenListener);
        }
        this.isHotReloadPage = isHotReloadPage;
        this.showDebugButton = showDebugButton;
        if (MLSEngine.DEBUG)
            initSerial(context);
    }

    public void setShowDebugButton(boolean isShowDebugButton) {
        this.showDebugButton = isShowDebugButton;
    }

    private void initSerial(Context context) {
        String serial = HotReloadHelper.getSerial();
        if (serial != null && !serial.equalsIgnoreCase("unknown")) {
            return;
        }
        String Serial;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
                    Serial = Build.getSerial();
                } else {
                    Serial = null;
                }
            } catch (Throwable ignore) {
                Serial = null;
            }
        } else {
            Serial = Build.SERIAL;
        }
        if (Serial == null || Serial.equalsIgnoreCase("unknown")) {
            Serial = MLSAdapterContainer.getFileCache().get("android_serial", "unknown");
        }
        HotReloadHelper.setSerial(Serial);
    }


    //<editor-fold desc="public method">
    //<editor-fold desc="must call method">

    /**
     * 设置容器装luaView
     *
     * @param container
     */
    public void setContainer(@NonNull ViewGroup container) {
        AssertUtils.assertNullForce(container);
        mContainer = container;
        if (!isInit()) {
            toggleEmptyViewShow(true);
            setEmptyViewContent(MLSConfigs.uninitTitle, MLSConfigs.uninitMsg);
            return;
        }
        if (isDebugUrl()) {
            initReloadButton();
        }
        showProgressView();
    }

    public void setScriptReader(ScriptReader scriptReader) {
        this.scriptReader = scriptReader;
    }

    /**
     * 设置luaview 的url
     *
     * @param data
     */
    public void setData(InitData data) {
        if (!isInit())
            return;
        AssertUtils.assertNullForce(data);
        if (data.extras != null) {
            extraData.putAll(data.extras);
        }
        initData = data;
        final String url = data.url;
        if (TextUtils.isEmpty(url))
            return;
        GlobalStateUtils.onStartLoadScript(url);
        ParsedUrl parsedUrl = new ParsedUrl(url);
        if (parsedUrl.getUrlType() == ParsedUrl.URL_TYPE_UNKNOWN) {
            return;
        }
        createLuaViewManager();
        if(scriptReader == null) {
            scriptReader = new MMUIScriptReaderImpl(initData.rootPath,initData.url);
        }
        if (!extraData.containsKey(Constants.KEY_URL)) {
            extraData.put(Constants.KEY_URL, url);
        }

        if (!extraData.containsKey(Constants.KEY_LUA_SOURCE)) {
            if (URLUtil.isNetworkUrl(url)) {
                extraData.put(Constants.KEY_LUA_SOURCE, url);
            } else {
                extraData.put(Constants.KEY_LUA_SOURCE, LuaUrlUtils.getUrlName(url));
            }
        }

        UrlParams params = parsedUrl.getUrlParams();
        initData.showLoadingView(initData.hasType(Constants.LT_SHOW_LOAD) && params.showLoading());

        int minSdkVersion = params.getMinSdkVersion();
        if (Constants.SDK_VERSION_INT <= minSdkVersion && minSdkVersion != -1 && MLSEngine.DEBUG)
            MLSAdapterContainer.getToastAdapter().toast("LUA SDK 版本过低，需要升级....");

        showProgressView();
        extraData.put(Constants.KEY_URL_PARAMS, params);
        if (mContext instanceof Activity) {
            Integer statusBarColor = params.getStatusBarColor();
            if (statusBarColor != null) {
                AndroidUtil.setStatusBarColor((Activity) mContext, statusBarColor);
            }

            Integer statusBarStyle = params.getStatusBarStyle();
            if (statusBarStyle != null) {
                switch (statusBarStyle) {
                    case StatusBarStyle.Default:
                        AndroidUtil.showLightStatusBar(false, (Activity) mContext);
                        break;
                    case StatusBarStyle.Light:
                        AndroidUtil.showLightStatusBar(true, (Activity) mContext);
                        break;
                }
            }
        }
        if (isDebugUrl()) {
            initReloadButton();
        }
        Runnable task = new Runnable() {
            @Override
            public void run() {
                if (isDestroy() || mContainer == null || mContext == null)
                    return;
                GlobalStateUtils.onStartLoadScript(url);
                loadScript(null, initData.loadType);
            }
        };
        if (initData.hasType(Constants.LT_NO_WINDOW_SIZE)) {
            MainThreadExecutor.post(task);
        } else {
            mContainer.post(task);
        }
    }

    /**
     * 判断url是否合法，若不合法，可关闭Activity
     *
     * @return
     */
    public boolean isValid() {
        if (!isInit())
            return false;
        if (initData == null || TextUtils.isEmpty(initData.url) || scriptReader == null)
            return false;
        return true;
    }

    /**
     * 页面显示时调用；若在多tab的Fragment中，应该在Fragment被切换出来时才调用
     */
    public void onResume() {
        if (mContext != null)
            DimenUtil.updateScale(mContext);
        addState(STATE_RESUME);
        if (mLuaView != null)
            mLuaView.onResume();
        if (MLSEngine.DEBUG)
            HotReloadHelper.addCallback(this);
    }

    /**
     * 页面隐藏时调用；若在多tab的Fragment中，应该在Fragment被切换或进入别的页面或按下home键才调用
     */
    public void onPause() {
        removeState(STATE_RESUME);
        if (mLuaView != null)
            mLuaView.onPause();
        if (MLSEngine.DEBUG)
            HotReloadHelper.removeCallback(this);
    }

    /**
     * 在activity的dispatchKeyEvent方法中调用
     * eg:
     *  if (argo.dispatchKeyEvent(event))
     *      return true;
     *  else
     *      return super.dispatchKeyEvent(event);
     */
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (mLuaView == null)
            return false;
        mLuaView.dispatchKeyEventSelf(event);
        return !mLuaView.getBackKeyEnabled();
    }

    /**
     * 在activity的dispatchKeyEvent方法中调用
     * 若返回true，表示在lua中处理
     */
    public boolean getBackKeyEnabled() {
        if (mLuaView != null)
            return mLuaView.getBackKeyEnabled();
        return true;
    }

    /**
     * activity onActivityResult 回调
     *
     * @return true 已处理
     */
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (luaViewManager == null)
            return false;

        OnActivityResultListener listener = luaViewManager.getOnActivityResultListener(requestCode);
        if (listener == null)
            return false;

        boolean delete = listener.onActivityResult(resultCode, data);
        if (delete)
            luaViewManager.removeOnActivityResultListeners(requestCode);

        return true;
    }

    /**
     * 销毁时调用
     */
    public void onDestroy() {
        if (MLSEngine.DEBUG){
            HotReloadHelper.removeCallback(this);
        }
        setState(STATE_DESTROY);
        if (mLuaView != null) {
            mLuaView.onDestroy();
        }
        if (globals != null) {
            globals.destroy();
        }
        if (hotReloadGlobals != null) {
            hotReloadGlobals.destroy();
        }
        MLSThreadAdapter adapter = MLSAdapterContainer.getThreadAdapter();
        if (scriptReader != null) {
            adapter.cancelTaskByTag(scriptReader.getTaskTag());
        }
        adapter.cancelTaskByTag(getTaskTag());
        MLSGlobalEventAdapter globalEventAdapter = MLSAdapterContainer.getGlobalEventAdapter();
        if (globalEventAdapter != null) {
            globalEventAdapter.removeEventListener(Constants.KEY_DEBUG_BUTTON_EVENT, debugButtonOpenListener);
        }
        MLSGlobalStateListener StateListener = MLSAdapterContainer.getGlobalStateListener();
        if (StateListener instanceof GlobalStateSDKListener) {
            ((GlobalStateSDKListener) StateListener).STDOUT = null;
        }
        scriptReader = null;
        initData = null;
        scriptStateListener = null;
        mLuaView = null;
        hotReloadLuaView = null;
        mContext = null;
        mContainer = null;
        luaViewManager = null;
        hotReloadLuaViewManager = null;
        extraData.clear();
    }
    //</editor-fold>
    public void setOnGlobalsCreateListener(OnGlobalsCreateListener l) {
        onGlobalsCreateListener = l;
    }

    public void addOnGlobalsCreateListener(OnGlobalsCreateListener l) {
        if(onGlobalsCreateListeners == null) {
            onGlobalsCreateListeners = new ArrayList<>();
        }
        onGlobalsCreateListeners.add(l);
    }

    public void setScriptStateListener(ScriptStateListener scriptStateListener) {
        this.scriptStateListener = scriptStateListener;
    }

    /**
     * call in main thread
     * 刷新，重新下载包，并渲染
     */
    public void reload(int type) {
        if (!isInit())
            return;
        if (!renderFinish() && !isError())
            return;
        GlobalStateUtils.onStartLoadScript(initData.url);
        setState(STATE_DESTROY);
        if (mLuaView != null) {
            removeLuaView(mLuaView);
            mLuaView.onDestroy();
        }
        if (globals != null) {
            globals.destroy();
        }
        luaViewManager = null;
        globals = null;
        mLuaView = null;
        setState(STATE_INIT);
        addState(STATE_RESUME);
        createLuaViewManager();
        showProgressView();
        reloadExtraData = null;
        loadScript(null, type);
    }

    /**
     * 增加参数
     *
     * @param extra
     * @see LuaView#putExtras(Map)
     */
    public void putExtras(HashMap extra) {
        extraData.putAll(extra);
        if (mLuaView != null) {
            mLuaView.putExtras(extraData);
        }
    }

    public HashMap getExtras() {
        return extraData;
    }

    public ClickEventLimiter getClickEventLimiter() {
        return clickEventLimiter;
    }

    public String getScriptVersion() {
        if (initData == null || scriptReader == null) {
            return "0";
        }
        return scriptReader.getScriptVersion();
    }

    public InitData getInitData() {
        return initData;
    }

    public @Nullable
    String getInitUrl() {
        return initData != null ? initData.url : null;
    }
    //</editor-fold>

    //<editor-fold desc="private method">
    private boolean isDestroy() {
        return (mState & STATE_DESTROY) == STATE_DESTROY;
    }

    private boolean isResume() {
        return (mState & STATE_RESUME) == STATE_RESUME;
    }

    private boolean isError() {
        return (mState & STATE_ERROR) == STATE_ERROR;
    }

    private boolean renderFinish() {
        return (mState & STATE_SCRIPT_EXECUTED) == STATE_SCRIPT_EXECUTED;
    }

    private void createLuaViewManager() {
        if (luaViewManager == null) {
            luaViewManager = new MMUILuaViewManager(mContext);
            luaViewManager.instance = this;
            return;
        }
        luaViewManager.url = initData != null ? initData.url : null;
    }

    private void dismissKeyboard() {
        if (mContext instanceof Activity) {
            View view = ((Activity) mContext).getCurrentFocus();
            if (view != null) {
                InputMethodManager inputMethodManager = (InputMethodManager) mContext.getSystemService(Activity.INPUT_METHOD_SERVICE);
                inputMethodManager.hideSoftInputFromWindow(view.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
            }
        }
    }

    /**
     * 使用插件热更新时进入
     */
    private void reloadByHotReload(String url, int type, HashMap<String, String> params) {
        if (!isInit())
            return;
        if (!renderFinish() && !isError())
            return;
        if (hasState(STATE_HOT_RELOADING))
            return;

        dismissKeyboard();
        addState(STATE_HOT_RELOADING);

        if (hotReloadLuaViewManager == null) {
            hotReloadLuaViewManager = new MMUILuaViewManager(mContext);
            hotReloadLuaViewManager.instance = this;
        }
        hotReloadLuaViewManager.url = url;
        reloadExtraData = params;
        loadScript(url, type);
    }

    private void removeLuaView(LuaView v) {
        if (scalpelFrameLayout != null) {
            scalpelFrameLayout.removeView(v);
        } else {
            mContainer.removeView(v);
        }
    }

    /**
     * call in main thread
     */
    private LuaView createLuaView(Globals globals) {
        if (isDestroy())
            return null;
        boolean inHotReload = hasState(STATE_HOT_RELOADING);
        LuaViewManager lvm = inHotReload ? hotReloadLuaViewManager : luaViewManager;
        if (lvm == null || lvm.context == null)
            return null;
        long now = System.nanoTime();
        MLSEngine.singleRegister.createSingleInstance(globals,false);
        MMUIEngine.singleRegister.createSingleInstance(globals,false);
        if (MLSEngine.DEBUG) {
            now = System.nanoTime() - now;
            LogUtil.d(String.format("create single instance cast : %.2fms", now / 1000000f));
        }
        if (initData == null) {
            if (toggleEmptyViewShow(true))
                setEmptyViewContent("非法链接", "点击重新加载");
            return null;
        }
        LuaView mLuaView;
        try {
            mLuaView = ((UDLuaView) globals.createUserdataAndSet(UDLuaView.LUA_SINGLE_NAME, UDLuaView.LUA_CLASS_NAME)).getView();
        } catch (RuntimeException e) {
            if (toggleEmptyViewShow(true))
                setEmptyViewContent("初始化出错", "点击重新加载");
            return null;
        }
        mLuaView.putExtras(extraData);
        if (reloadExtraData != null) {
            mLuaView.putExtras(reloadExtraData);
        }
        addState(STATE_VIEW_CREATED);
        ViewGroup.LayoutParams p = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        if (scalpelFrameLayout != null) {
            scalpelFrameLayout.addView(mLuaView, p);
        } else {
            mContainer.addView(mLuaView, p);
        }
        if (debugButton != null) {
            debugButton.bringToFront();
        }
        lvm.STDOUT = STDOUT;
        if (MLSEngine.DEBUG) {
            MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
            if (adapter instanceof GlobalStateSDKListener) {
                ((GlobalStateSDKListener) adapter).STDOUT = STDOUT;
            }
        }
        if (viewOut != null) {
            View v = (View) ((View) viewOut.getPrinter()).getParent();
            v.bringToFront();
        }
        return mLuaView;
    }

    /**
     * lua 脚本执行完成
     */
    private void onLuaScriptExecutedSuccess() {
        hideProgressView(true);
        toggleEmptyViewShow(false);
        if (scriptStateListener != null) {
            scriptStateListener.onSuccess();
        }
        /*
         * 执行成功需要将虚拟机切换，view切换，luaViewManager切换
         * 旧虚拟机需要reset，view需要remove并且destroy
         */
        if (hasState(STATE_HOT_RELOADING)) {
            dismissHotReloadLoading();
            final LuaView lv = hotReloadLuaView;
            hotReloadLuaView = mLuaView;
            mLuaView = lv;

            removeLuaView(hotReloadLuaView);
            hotReloadLuaView.onDestroy();
            hotReloadLuaView = null;

            final Globals tg = hotReloadGlobals;
            hotReloadGlobals = globals;
            globals = tg;

            hotReloadGlobals.destroy();
            hotReloadGlobals = null;

            MMUILuaViewManager tl = hotReloadLuaViewManager;
            hotReloadLuaViewManager = luaViewManager;
            luaViewManager = tl;
            hotReloadLuaViewManager = null;
        }
        if (isResume() && mLuaView != null) {
            mLuaView.onResume();
        }
        removeState(STATE_HOT_RELOADING);
    }

    private Globals initGlobals(LuaViewManager luaViewManager) {
        Globals globals = PreGlobalInitUtils.take();
        if (globals == null) {
            globals = Globals.createLState(MLSEngine.isOpenDebugger());
            PreGlobalInitUtils.setupGlobals(globals);
        }
        globals.setJavaUserdata(luaViewManager);

        if(onGlobalsCreateListener !=null) {
            onGlobalsCreateListener.onCreate(globals);
        }

        notifyOnGlobalCreateListener(globals);
        return globals;
    }


    private void notifyOnGlobalCreateListener(Globals globals) {
        if(onGlobalsCreateListeners ==null) {
            return;
        }
        for(OnGlobalsCreateListener onGlobalsCreateListener:onGlobalsCreateListeners) {
            onGlobalsCreateListener.onCreate(globals);
        }
    }

    private void loadScript(final String hru, final int loadType) {
        if (!isValid() || hasState(STATE_SCRIPT_LOADING) || isDestroy())
            return;
        addState(STATE_SCRIPT_LOADING);
        if (hasState(STATE_HOT_RELOADING)) {
            if (hotReloadGlobals == null) {
                hotReloadGlobals = initGlobals(hotReloadLuaViewManager);
            }
        } else if (globals == null) {
            globals = initGlobals(luaViewManager);
        }
        GlobalStateUtils.onGlobalPrepared(initData.url);

        ScriptInfo scriptInfo = new ScriptInfo(initData)
                .withContext(mContext)
                .withLoadType(loadType)
                .withCallback(MMUIInstance.this)
                .whitHotReloadUrl(hru);
        if (hasState(STATE_HOT_RELOADING)) {
            scriptInfo.withGlobals(hotReloadGlobals);
        } else {
            scriptInfo.withGlobals(globals);
        }
        closePrinterOnce = false;
        scriptReader.loadScriptImpl(scriptInfo);
    }

    /**
     * 判断是否是debug url
     * 样式：http://172.xxx/~UserName/xxxxxxx
     *
     * @return
     */
    private boolean isDebugUrl() {
        if (showDebugButton)
            return true;
        return initData != null && initData.hasType(Constants.LT_FORCE_DEBUG);
    }

    private void initReloadButton() {
        if (STDOUT == null)
            STDOUT = new DebugPrintStream(null);
        if (debugButton == null) {
            debugButton = MMUIEngine.reloadButtonCreator.newGenerator(mContainer, this).generateReloadButton(isHotReloadPage);
        }
        initScalpeLayout();
    }

    private void initScalpeLayout() {
        if (scalpelFrameLayout == null) {
            scalpelFrameLayout = new ScalpelFrameLayout(mContext);
            scalpelFrameLayout.setLayerInteractionEnabled(false);
            scalpelFrameLayout.setDrawViews(true);
            scalpelFrameLayout.setDrawViewNames(true);
            scalpelFrameLayout.setDrawIds(false);
            mContainer.addView(scalpelFrameLayout, 0, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            if (mLuaView != null) {
                mContainer.removeView(mLuaView);
                scalpelFrameLayout.addView(mLuaView);
            }
        }
    }

    private void showProgressView() {
        showProgressBackground();
        if (initData == null || !initData.hasType(Constants.LT_SHOW_LOAD))
            return;
        if (refreshView == null) {
            refreshView = new RefreshView(mContainer);
            refreshView.setRefreshOffsetY(MLSFlag.getRefreshEndPx());
            refreshView.setProgressColor(MLSFlag.getRefreshColor());
            refreshView.setProgressAnimDuration(DEFAULT_PROGRESS_ANIM_DURATION);
        }
        if (refreshView.getParent() == null) {
            refreshView.addProgressInContainer(mContainer);
        }
    }

    private void hideProgressView(boolean anim) {
        hideProgressBackground();
        if (refreshView != null) {
            refreshView.removeProgress(anim);
        }
    }

    private void showProgressBackground() {
        if (initData == null || !initData.hasType(Constants.LT_SHOW_LOAD_BG))
            return;

        MainThreadExecutor.cancelAllRunnable(getTaskTag());
        MainThreadExecutor.postDelayed(getTaskTag(), new Runnable() {
            @Override
            public void run() {
                if (isDestroy())
                    return;
                initBackGroundView();

                if (isNeedShowBackgroundCondition()) {
                    mContainer.addView(backGroundView);
                    refreshView.bringToFront();
                }

            }
        }, 120);
    }

    private boolean isNeedShowBackgroundCondition() {
        return backGroundView.getParent() == null && mContainer != null && refreshView != null && refreshView.getVisibility() == View.VISIBLE;
    }

    private void initBackGroundView() {
        if (backGroundView == null) {
            backGroundView = new ImageView(mContext);
            try {
                backGroundView.setImageResource(mBackgroundRes);
            } catch (Throwable ignore) {
            }
            backGroundView.setScaleType(ImageView.ScaleType.FIT_XY);
            backGroundView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }
    }

    private void hideProgressBackground() {
        if (backGroundView != null && backGroundView.getParent() instanceof ViewGroup) {
            ((ViewGroup) backGroundView.getParent()).removeView(backGroundView);
        }
        MainThreadExecutor.cancelAllRunnable(getTaskTag());
    }

    public void setBackgroundRes(@DrawableRes int mBackgroundRes) {
        this.mBackgroundRes = mBackgroundRes;
    }

    private void addState(short state) {
        mState |= state;
    }

    private boolean hasState(short mask) {
        return (mState & mask) == mask;
    }

    private void removeState(short state) {
        mState &= ~state;
    }

    private void setState(short state) {
        mState = state;
    }

    private boolean isInit() {
        if (!Globals.isInit() || !LuaViewConfig.isInit()
                || MLSEngine.singleRegister == null || !MLSEngine.singleRegister.isInit())
            return false;
        MLSEngine.singleRegister.preInstall();
        return MLSEngine.singleRegister.isPreInstall();
    }

    /**
     * 改变empty view的状态
     *
     * @param show
     */
    private boolean toggleEmptyViewShow(boolean show) {
        View v = null;
        if (emptyView == null) {
            if (!show || mContext == null || isDestroy())
                return false;
            MLSEmptyViewAdapter adapter = MLSAdapterContainer.getEmptyViewAdapter();
            if (adapter != null) {
                emptyView = adapter.createEmptyView(mContext);
                v = (View) emptyView;
                v.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
                v.setOnClickListener(reloadClickListener);
            }
        } else {
            v = (View) emptyView;
        }
        if (emptyView == null)
            return false;
        if (show) {
            if (v.getParent() == null) {
                mContainer.addView(v);
            }
            v.setVisibility(View.VISIBLE);
            setDebugBtnBring2Front();
        } else {
            v.setVisibility(View.GONE);
        }
        return true;
    }

    private void setEmptyViewContent(CharSequence title, CharSequence msg) {
        if (emptyView == null)
            return;
        emptyView.setTitle(title);
        emptyView.setMessage(msg);
    }

    public View.OnClickListener reloadClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            if (isDestroy())
                return;
            if (isError() || renderFinish()) {
                reload(LoadTypeUtils.add(LoadTypeUtils.remove(initData.loadType, Constants.LT_MAIN_THREAD), Constants.LT_FORCE_DOWNLOAD));
            } else if (MLSEngine.DEBUG) {
                MLSAdapterContainer.getToastAdapter().toast("别慌，等会按");
            }
        }
    };
    //</editor-fold>

    //<editor-fold desc="HotReloadHelper.Callback">

    private Dialog updatingDialog;
    private AtomicBoolean updating = new AtomicBoolean(false);
    @Override
    public void onUpdateFiles(String f) {
        if (mContext == null || updating.get())
            return;
        updating.set(true);
        MainThreadExecutor.post(new Runnable() {
            @Override
            public void run() {
                if (mContext == null || !updating.get())
                    return;
                if (updatingDialog == null) {
                    AppCompatDialog d = new AppCompatDialog(mContext);
                    d.setCanceledOnTouchOutside(false);
                    LinearLayout cv = new LinearLayout(mContext);
                    cv.setLayoutParams(new LinearLayout.LayoutParams(AndroidUtil.getScreenWidth(mContext) - 50, LinearLayout.LayoutParams.WRAP_CONTENT));
                    cv.setOrientation(LinearLayout.VERTICAL);
                    cv.setGravity(Gravity.CENTER);
                    cv.setPadding(20,20,20,20);
                    LayoutInflater.from(mContext).inflate(com.immomo.mls.R.layout.luasdk_loading_diloag, cv);
                    TextView tv = new TextView(mContext);
                    tv.setTextSize(20);
                    tv.setGravity(Gravity.CENTER);
                    tv.setText("正在更新脚本，请稍后...");
                    LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(-2, -2);
                    p.setMargins(0, 20, 0, 0);
                    cv.addView(tv, p);
                    d.setContentView(cv);
                    updatingDialog = d;
                }
                updatingDialog.show();
            }
        });
    }

    private void dismissHotReloadLoading() {
        updating.set(false);
        if (updatingDialog != null && updatingDialog.isShowing())
            updatingDialog.dismiss();
    }

    @Override
    public void onReload(final String path, final HashMap<String, String> params, int state) {
        if (globals.isDestroyed()) {
            if (luaViewManager != null)
                HotReloadHelper.removeCallback(this);
            return;
        }

        if (!MainThreadExecutor.isMainThread()) {
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    reloadByHotReload(path, LoadTypeUtils.add(initData.loadType, Constants.LT_MAIN_THREAD), params);
                }
            });
        } else {
            reloadByHotReload(path, LoadTypeUtils.add(initData.loadType, Constants.LT_MAIN_THREAD), params);
        }
        MainThreadExecutor.postDelayed(getTaskTag(), new Runnable() {
            @Override
            public void run() {
                dismissHotReloadLoading();
            }
        }, 100);
    }

    @Override
    public boolean reloadFinish() {
        return !hasState(STATE_HOT_RELOADING);
    }

    @Override
    public void onDisconnected(final int type, final String error) {
        if (globals.isDebugOpened())
            return;
        MainThreadExecutor.post(new Runnable() {
            @Override
            public void run() {
                MLSAdapterContainer.getToastAdapter().toast(
                        String.format("断开与HotReload插件的%s连接，error: %s",
                                (type == HotReloadHelper.NET_CONNECTION ? "wifi, 检查是否与电脑在同一个网络环境下" : "usb"),
                                error));
            }
        });
    }
    //</editor-fold>

    //<editor-fold desc="ScriptLoader.Callback">

    /**
     * 最后阶段，执行回调
     * 成功的话，在主线程回调，失败可能在其他线程
     *
     * @param code 结果
     */
    @Override
    public void onScriptExecuted(final int code, final @Nullable String em) {
        removeState(STATE_SCRIPT_LOADING);
        if (code != SUCCESS) {
            LogUtil.e(null, em);
            addState(STATE_ERROR);
            if (scriptStateListener != null) {
                scriptStateListener.onFailed(ScriptStateListener.Reason.EXCUTE_FAILED);
            }
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    addState(STATE_SCRIPT_EXECUTED);
                    hideProgressView(true);
                    if (!hasState(STATE_HOT_RELOADING)) {
                        if (MLSEngine.DEBUG) {
                            MLSAdapterContainer.getToastAdapter().toast(em, 1);
                            if (STDOUT != null)
                                ((ErrorPrintStream) STDOUT).error(ErrorType.ERROR.getErrorPrefix() + em);
                        }
                        if (toggleEmptyViewShow(true))
                            setEmptyViewContent("打开页面失败", "点击重新加载");
                    } else {
                        dismissHotReloadLoading();
                        if (MLSEngine.DEBUG && code == COMPILE_FAILED && STDOUT != null) {
                            ((ErrorPrintStream) STDOUT).error(em);
                        }
                        if (hotReloadLuaView != null) {
                            removeLuaView(hotReloadLuaView);
                            hotReloadLuaView = null;
                        }
                        hotReloadGlobals.destroy();
                        hotReloadGlobals = null;
                        hotReloadLuaView = null;
                        hotReloadLuaViewManager = null;
                        removeState(STATE_HOT_RELOADING);
                    }
                }
            });
        } else {
            addState(STATE_SCRIPT_EXECUTED);
            /// 调用appear事件延后
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    onLuaScriptExecutedSuccess();
                }
            });
        }
        if (initData != null)
            GlobalStateUtils.onScriptExecuted(initData.url, code == SUCCESS);
    }
    //</editor-fold>

    //<editor-fold desc="Callback">

    /**
     * 脚本加载成功回调
     *
     * @param scriptBundle
     */
    @Override
    public void onScriptLoadSuccess(final ScriptBundle scriptBundle) {
        addState(STATE_SCRIPT_PREPARED);
        addState(STATE_SCRIPT_LOADED);
        if (isDestroy())
            return;
        Runnable task = new Runnable() {
            @Override
            public void run() {
                if (isDestroy())
                    return;
                toggleEmptyViewShow(false);
                Globals g = hasState(STATE_HOT_RELOADING) ? hotReloadGlobals : globals;
                LuaView luaView = createLuaView(g);
                if (luaView == null)
                    return;
                if (scriptBundle.getParams() != null)
                    luaView.putExtras(scriptBundle.getParams());

                g.setBasePath(scriptBundle.getBasePath(), false);

                final LuaViewManager lvm;
                if (hasState(STATE_HOT_RELOADING)) {
                    lvm = hotReloadLuaViewManager;
                    hotReloadLuaView = luaView;
                } else {
                    lvm = luaViewManager;
                    mLuaView = luaView;
                }

                lvm.scriptVersion = getScriptVersion();
                lvm.baseFilePath = scriptBundle.getBasePath();
                GlobalStateUtils.onScriptLoaded(initData.url, scriptBundle);
                ScriptLoader.loadScriptBundle(scriptBundle, g, MMUIInstance.this);
                if (MLSEngine.DEBUG) {
                    HotReloadHelper.addCallback(MMUIInstance.this);
                }
            }
        };
        if (MainThreadExecutor.isMainThread()) {
            task.run();
        } else {
            MainThreadExecutor.post(task);
        }
    }

    /**
     * 加载失败回调
     */
    @Override
    public void onScriptLoadFailed(final ScriptLoadException e) {
        if (globals == null || globals.isDestroyed() || e.getCode() == ERROR.GLOBALS_DESTROY.getCode())
            return;
        addState(STATE_ERROR);
        removeState(STATE_SCRIPT_LOADING);
        if (scriptStateListener != null) {
            scriptStateListener.onFailed(ScriptStateListener.Reason.LOAD_FAILED);
        }
        GlobalStateUtils.onScriptLoadFailed(initData.url, e);

        Runnable task = new Runnable() {
            @Override
            public void run() {
                hideProgressView(true);
                if (!hasState(STATE_HOT_RELOADING) && toggleEmptyViewShow(true)) {
                    String title = e.getCode() == -7 ? "请求超时" : "加载失败";
                    setEmptyViewContent(title, "点击重新加载");
                }

                if (MLSEngine.DEBUG) {
                    String errorValue = String.format("脚本加载失败，code: %d, \n\n msg: %s, \n\n cause: %s, \n\n 详细信息检查日志，tag: %s", e.getCode(), e.getMsg(), e.getCause(), TAG);
                    MLSAdapterContainer.getConsoleLoggerAdapter().e(TAG, e, errorValue);
                    if (STDOUT != null) {
                        ((ErrorPrintStream) STDOUT).error(e.getMsg());
                    }

                    if (hasState(STATE_HOT_RELOADING)) {
                        dismissHotReloadLoading();
                        hotReloadGlobals.destroy();
                        hotReloadGlobals = null;
                        hotReloadLuaViewManager = null;
                        hotReloadLuaView = null;
                        removeState(STATE_HOT_RELOADING);
                    } else {
                        MLSAdapterContainer.getToastAdapter().toast(errorValue);
                    }
                }
            }
        };
        if (MainThreadExecutor.isMainThread()) {
            task.run();
        } else {
            MainThreadExecutor.post(task);
        }
    }
    //</editor-fold>

    //<editor-fold desc="PrinterContainer">
    @Override
    public IPrinter getSTDPrinter() {
        return viewOut != null ? viewOut.getPrinter() : null;
    }

    @Override
    public boolean isShowPrinter() {
        IPrinter printer = getSTDPrinter();
        if (printer == null)
            return false;
        View pv = (View) printer;
        View pvParent = ((View) (pv.getParent()));
        return pvParent.getVisibility() == View.VISIBLE;
    }

    @Override
    public boolean hasClosePrinter() {
        return closePrinterOnce;
    }

    @Override
    public void showPrinter(boolean show) {
        IPrinter printer = getSTDPrinter();
        if (printer == null)
            return;
        View pv = (View) printer;
        View pvParent = ((View) (pv.getParent()));
        if (show) {
            pvParent.setVisibility(View.VISIBLE);
            pvParent.bringToFront();
        } else {
            pvParent.setVisibility(View.INVISIBLE);
            closePrinterOnce = true;
        }
    }

    @Override
    public void onSTDPrinterCreated(IPrinter p) {
        viewOut = new DefaultPrintStream(p);
        if (STDOUT == null)
            STDOUT = new DebugPrintStream(viewOut);
        else
            ((DebugPrintStream) STDOUT).inner = viewOut;
        if (luaViewManager != null) {
            luaViewManager.STDOUT = STDOUT;
        }
    }
    //</editor-fold>

    private Object getTaskTag() {
        return TAG + hashCode();
    }

    @Override
    public Globals getGlobals() {
        return globals;
    }

    /**
     * 监听设置debug 开关
     */
    private class DebugButtonOpenListener implements LVCallback {

        @Override
        public boolean call(@Nullable Object... params) {
            if (isDestroy() || mContainer == null)
                return true;
            if (params == null || params.length == 0 || !(params[0] instanceof Map))
                return true;
            Map data = (Map) params[0];
            try {
                boolean open = Boolean.parseBoolean(data.get(Constants.KEY_DEBUG_BUTTON_PARAMS).toString());
                if (open) {
                    initReloadButton();
                    setDebugBtnBring2Front();
                } else if (debugButton != null) {
                    debugButton.setVisibility(View.GONE);
                }
            } catch (Throwable ignore) {
            }
            return true;
        }

        @Override
        public void destroy() {

        }
    }

    private void setDebugBtnBring2Front() {
        if (debugButton != null && MLSEngine.DEBUG) {
            debugButton.setVisibility(View.VISIBLE);
            debugButton.bringToFront();
        }
    }

    @Override
    public String toString() {
        return initData != null ? initData.toString() : "NoneInitInstance";
    }
}