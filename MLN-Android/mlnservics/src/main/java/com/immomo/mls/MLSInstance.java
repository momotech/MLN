/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.webkit.URLUtil;
import android.widget.ImageView;

import com.immomo.mls.adapter.MLSEmptyViewAdapter;
import com.immomo.mls.adapter.MLSGlobalEventAdapter;
import com.immomo.mls.adapter.MLSGlobalStateListener;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.adapter.ScriptReader;
import com.immomo.mls.fun.constants.StatusBarStyle;
import com.immomo.mls.fun.globals.LuaView;
import com.immomo.mls.fun.globals.UDLuaView;
import com.immomo.mls.global.ScriptLoader;
import com.immomo.mls.log.DefaultPrintStream;
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
import com.immomo.mls.wrapper.AssetsResourceFinder;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptBundleResourceFinder;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.PathResourceFinder;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

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
public class MLSInstance implements ScriptLoader.Callback, Callback, PrinterContainer {
    private static final String TAG = "MLSInstance";
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
    private int mBackgroundRes = R.drawable.mls_load_demo;

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
    private DefaultPrintStream STDOUT;
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
     * lua 容器
     */
    volatile LuaView mLuaView;
    /**
     * 设置到{@link Globals#setJavaUserdata}
     * 在bridge中通过Globals，能获取到上下文信息
     */
    private LuaViewManager luaViewManager;

    /****************************************************
     *
     * Hot Reload 相关虚拟机
     * 只在有HotReload时初始化
     *
     ****************************************************/
    private Globals hotReloadGlobals;
    private LuaView hotReloadLuaView;
    private LuaViewManager hotReloadLuaViewManager;
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

    public MLSInstance(@NonNull Context context) {
        this(context,  false);
    }

    public MLSInstance(@NonNull Context context, boolean isHotReloadPage) {
        AssertUtils.assertNullForce(context);
        mContext = context;
        createLuaViewManager();
        MLSGlobalEventAdapter adapter = MLSAdapterContainer.getGlobalEventAdapter();
        if (adapter != null) {
            debugButtonOpenListener = new DebugButtonOpenListener();
            adapter.addEventListener(Constants.KEY_DEBUG_BUTTON_EVENT, debugButtonOpenListener);
        }
        this.isHotReloadPage = isHotReloadPage;
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
        if (!MLSEngine.isInit()) {
            toggleEmptyViewShow(true);
            setEmptyViewContent(MLSConfigs.uninitTitle, MLSConfigs.uninitMsg);
            return;
        }
        if (isDebugUrl()) {
            initReloadButton();
        }
        showProgressView();
    }

    /**
     * 设置luaview 的url
     *
     * @param data
     */
    public void setData(InitData data) {
        if (!MLSEngine.isInit())
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
        scriptReader = MLSAdapterContainer.getScriptReaderCreator().newScriptLoader(url);
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
        if (!Globals.isInit() || !MLSEngine.isInit())
            return false;
        if (initData == null || TextUtils.isEmpty(initData.url) || scriptReader == null)
            return false;
        return true;
    }

    public void setScriptStateListener(ScriptStateListener scriptStateListener) {
        this.scriptStateListener = scriptStateListener;
    }

    private final HotReloadHelper.Callback callback = new HotReloadHelper.Callback() {
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
        }

        @Override
        public boolean reloadFinish() {
            return !hasState(STATE_HOT_RELOADING);
        }
    };

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
     * 页面显示时调用；若在多tab的Fragment中，应该在Fragment被切换出来时才调用
     */
    public void onResume() {
        if (mContext != null)
            DimenUtil.updateScale(mContext);
        addState(STATE_RESUME);
        if (mLuaView != null)
            mLuaView.onResume();
        if (MLSEngine.DEBUG)
            HotReloadHelper.addCallback(callback);
    }

    /**
     * 页面隐藏时调用；若在多tab的Fragment中，应该在Fragment被切换或进入别的页面或按下home键才调用
     */
    public void onPause() {
        removeState(STATE_RESUME);
        if (mLuaView != null)
            mLuaView.onPause();
        if (MLSEngine.DEBUG)
            HotReloadHelper.removeCallback(callback);
    }

    /**
     * 在activity的dispatchKeyEvent方法中调用
     */
    public void dispatchKeyEvent(KeyEvent event) {
        if (mLuaView != null)
            mLuaView.dispatchKeyEventSelf(event);
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
        if (MLSEngine.DEBUG)
            HotReloadHelper.removeCallback(callback);
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

    /**
     * call in main thread
     * 刷新，重新下载包，并渲染
     */
    public void reload(int type) {
        if (!MLSEngine.isInit())
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
            luaViewManager = new LuaViewManager(mContext);
            luaViewManager.instance = this;
            return;
        }
        luaViewManager.url = initData != null ? initData.url : null;
    }

    /**
     * 使用插件热更新时进入
     */
    private void reloadByHotReload(String url, int type, HashMap<String, String> params) {
        if (!MLSEngine.isInit())
            return;
        if (!renderFinish() && !isError())
            return;
        if (hasState(STATE_HOT_RELOADING))
            return;

        dismissKeyboard();
        addState(STATE_HOT_RELOADING);

        if (hotReloadLuaViewManager == null) {
            hotReloadLuaViewManager = new LuaViewManager(mContext);
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
        MLSEngine.singleRegister.createSingleInstance(globals);
        if (MLSEngine.DEBUG) {
            now = System.nanoTime() - now;
            LogUtil.d(String.format("create single instance cast : %.2fms", now / 1000000f));
        }
        if (initData == null) {
            if (toggleEmptyViewShow(true))
                setEmptyViewContent("非法链接", "点击重新加载");
            return null;
        }
        LuaView mLuaView = ((UDLuaView) globals.createUserdataAndSet(UDLuaView.LUA_SINGLE_NAME, UDLuaView.LUA_CLASS_NAME)).getView();
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
        if (STDOUT != null) {
            lvm.STDOUT = STDOUT;
            View v = (View) ((View) STDOUT.getPrinter()).getParent();
            v.bringToFront();

            if (MLSEngine.DEBUG) {
                MLSGlobalStateListener adapter = MLSAdapterContainer.getGlobalStateListener();
                if (adapter instanceof GlobalStateSDKListener) {
                    ((GlobalStateSDKListener) adapter).STDOUT = STDOUT;
                }
            }

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

            LuaViewManager tl = hotReloadLuaViewManager;
            hotReloadLuaViewManager = luaViewManager;
            luaViewManager = tl;
            hotReloadLuaViewManager = null;
        }
        if (isResume() && mLuaView != null) {
            /// 调用appear事件延后
            MainThreadExecutor.post(new Runnable() {
                @Override
                public void run() {
                    mLuaView.onResume();
                }
            });
        }
        removeState(STATE_HOT_RELOADING);
    }

    private Globals initGlobals(LuaViewManager luaViewManager) {
        Globals globals = PreGlobalInitUtils.take();
        if (globals == null) {
            globals = Globals.createLState(MLSEngine.isOpenDebugger());
            LuaViewManager.setupGlobals(globals);
        }
        globals.setJavaUserdata(luaViewManager);
        return globals;
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
                .withLoadType(loadType)
                .withCallback(MLSInstance.this)
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
        if (MLSEngine.DEBUG)
            return true;
        if (initData != null && initData.hasType(Constants.LT_FORCE_DEBUG))
            return true;
        return false;
    }

    private void initReloadButton() {
        if (debugButton == null) {
            debugButton = MLSAdapterContainer.getReloadButtonCreator().newGenerator(mContainer, this).generateReloadButton(isHotReloadPage);
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
            } catch (Throwable ignore) {}
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
                            LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
                            if (m != null && m.STDOUT != null) {
                                if (m.STDOUT instanceof DefaultPrintStream) {
                                    ((DefaultPrintStream) m.STDOUT).error(Environment.LUA_ERROR + em);
                                } else {
                                    m.STDOUT.printf("%s%s", Environment.LUA_ERROR, em);
                                    m.STDOUT.println();
                                }
                            }
                        }
                        if (toggleEmptyViewShow(true))
                            setEmptyViewContent("执行失败", "点击重新加载");
                    } else {
                        if (MLSEngine.DEBUG && code == COMPILE_FAILED)
                            HotReloadHelper.onError(em);
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
            onLuaScriptExecutedSuccess();
        }
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

//                if (scriptBundle.hasFlag(ScriptBundle.TYPE_ASSETS))
                g.addResourceFinder(new AssetsResourceFinder(mContext));
                if (scriptBundle.hasChildren()) {
                    g.addResourceFinder(new PathResourceFinder(scriptBundle.getBasePath()));
                    g.setResourceFinder(new ScriptBundleResourceFinder(scriptBundle));
                } else {
                    g.setResourceFinder(new PathResourceFinder(scriptBundle.getBasePath()));
                }

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
                ScriptLoader.loadScriptBundle(luaView.getUserdata(), scriptBundle, g, MLSInstance.this);
                if (MLSEngine.DEBUG)
                    HotReloadHelper.addCallback(callback);
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
                    getSTDPrinter().print(errorValue);
                    HotReloadHelper.onError(e.getMsg());

                    if (hasState(STATE_HOT_RELOADING)) {
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
        return STDOUT != null ? STDOUT.getPrinter() : null;
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
        if (p != null) {
            STDOUT = new DefaultPrintStream(p);
        }
        if (luaViewManager != null) {
            luaViewManager.STDOUT = STDOUT;
        }
    }
    //</editor-fold>

    private Object getTaskTag() {
        return TAG + hashCode();
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