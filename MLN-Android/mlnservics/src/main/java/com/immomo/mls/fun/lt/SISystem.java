/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.view.Window;
import android.view.WindowManager;

import com.immomo.mls.Constants;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.constants.NetworkState;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.receiver.ConnectionStateChangeBroadcastReceiver;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.NetworkUtil;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.wrapper.callback.IVoidCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;

import androidx.annotation.Nullable;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
@LuaClass
public class SISystem implements ConnectionStateChangeBroadcastReceiver.OnConnectionChangeListener {
    public static final String KEY = "System";

    protected Globals globals;
    protected Context context;
    private LuaFunction networkStateCallback;
    private final Object tag;

    public SISystem(Globals globals, LuaValue[] init) {
        this.globals = globals;
        context = ((LuaViewManager) globals.getJavaUserdata()).context;
        tag = new Object();
    }

    public void __onLuaGc() {
        MainThreadExecutor.cancelAllRunnable(getTag());
        NetworkUtil.unregisterConnectionChangeListener(getContext(), this);
        globals = null;
        context = null;
        if (networkStateCallback != null) {
            networkStateCallback.destroy();
        }
        networkStateCallback = null;
    }

    protected Context getContext() {
        return context;
    }

    //<editor-fold desc="API">
    @LuaBridge
    public boolean iOS() {
        return false;
    }

    @LuaBridge
    public boolean Android() {
        return true;
    }

    @LuaBridge
    public String SDKVersion() {
        return Constants.SDK_VERSION;
    }

    @LuaBridge
    public int SDKVersionInt() {
        return Constants.SDK_VERSION_INT;
    }

    @LuaBridge
    public String OSVersion() {
        return AndroidUtil.getOsVersion();
    }

    @LuaBridge
    public int OSVersionInt() {
        return AndroidUtil.getSdkVersionInt();
    }

    @LuaBridge(alias = "deviceInfo")
    public String platform() {
        return AndroidUtil.getOsModel();
    }

    @LuaBridge
    public float scale() {
        return AndroidUtil.getDensity(getContext());
    }

    @LuaBridge
    public LuaTable device() {
        LuaTable table = LuaTable.create(globals);
        table.set("device", AndroidUtil.getDevice());
        table.set("brand", AndroidUtil.getBrand());
        table.set("product", AndroidUtil.getProduct());
        table.set("manufacturer", AndroidUtil.getManufacturer());

        //screen size
        int[] screenSize = AndroidUtil.getWindowSizeInDp(getContext());
        table.set("window_width", screenSize[0]);
        table.set("window_height", screenSize[1]);

        //action bar height
        int actionBarHeight = AndroidUtil.getActionBarHeightInDp(getContext());
        table.set("nav_height", actionBarHeight);
        int bottomNavHeight = AndroidUtil.getNavigationBarHeightInDp(getContext());
        table.set("bottom_nav_height", bottomNavHeight);
        int statusBarHeight = AndroidUtil.getStatusBarHeightInDp(getContext());
        table.set("status_bar_height", statusBarHeight);
        return table;
    }

    @LuaBridge
    public Size screenSize() {
        return new Size((int) DimenUtil.pxToDpi(AndroidUtil.getScreenWidth(getContext())),
                (int) DimenUtil.pxToDpi(AndroidUtil.getScreenHeight(getContext())));
    }

    @LuaBridge
    public int navBarHeight() {
        if (getContext() != null) {
            return AndroidUtil.getNavigationBarHeightInDp(getContext());
        }
        return 0;
    }

    @LuaBridge
    public int stateBarHeight() {
        if (MLSConfigs.noStateBarHeight)
            return 0;
        if (getContext() != null) {
            return AndroidUtil.getStatusBarHeightInDp(getContext());
        }
        return 0;
    }

    @LuaBridge
    public int homeIndicatorHeight() {
        return 0;
    }

    @LuaBridge
    public int tabBarHeight() {
        return 0;
    }

    @LuaBridge
    public int networkState() {
        NetworkUtil.NetworkType type = NetworkUtil.getCurrentType(getContext());
        switch (type) {
            case NETWORK_2G:
            case NETWORK_3G:
            case NETWORK_4G:
                return NetworkState.CELLULAR;
            case NETWORK_WIFI:
                return NetworkState.WIFI;
            default:
                return NetworkState.NO_NETWORK;
        }
    }

    @LuaBridge
    public boolean asyncDoInMain(final IVoidCallback fun) {
        return globals.post(new Runnable() {
            @Override
            public void run() {
                fun.callback();
            }
        });
    }

    @LuaBridge
    public void setOnNetworkStateChange(LuaFunction callback) {
        if (networkStateCallback != null)
            networkStateCallback.destroy();
        networkStateCallback = callback;
        NetworkUtil.registerConnectionChangeListener(getContext(), this);
    }

    @LuaBridge
    public void setTimeOut(final IVoidCallback task, float delay) {
        globals.postDelayed(new Runnable() {
            @Override
            public void run() {
                task.callback();
            }
        }, (long) (delay * 1000));
    }

    @LuaBridge
    public int AppVersion() {
        return AndroidUtil.getLocalVersion(getContext());
    }

    /**
     * only for android debug
     *
     * @return
     */
    @LuaBridge
    public long nanoTime() {
        return System.nanoTime();
    }

    @LuaBridge
    public void switchFullscreen(boolean full) {
        Context c = getContext();
        if (c instanceof Activity) {
            AndroidUtil.switchFullscreen((Activity) c, full);
        }
    }

    @LuaBridge
    public void hideStatusBar() {
        switchFullscreen(true);
    }

    @LuaBridge
    public void showStatusBar() {
        switchFullscreen(false);
    }
    //</editor-fold>

    private Object getTag() {
        return tag;
    }

    //<editor-fold desc="OnConnectionChangeListener">
    @Override
    public void onConnectionClosed() {
        if (networkStateCallback != null)
            networkStateCallback.invoke(LuaValue.rNumber(NetworkState.NO_NETWORK));
    }

    @Override
    public void onMobileConnected() {
        if (networkStateCallback != null) {
            networkStateCallback.invoke(LuaValue.rNumber(NetworkState.CELLULAR));
        }
    }

    @Override
    public void onWifiConnected() {
        if (networkStateCallback != null) {
            networkStateCallback.invoke(LuaValue.rNumber(NetworkState.WIFI));
        }
    }
    //</editor-fold>

    /**
     * @param brightness     0 - 255 之间
     * @param saveBrightness 退出此页面后，亮度是否保存设置，可以为空，默认 false
     */
    @LuaBridge
    public void changeBright(int brightness, @Nullable Boolean saveBrightness) {

        Context context = getContext();
        if (!(context instanceof Activity))
            return;

        Window window = ((Activity) context).getWindow();
        WindowManager.LayoutParams lp = window.getAttributes();

        if (lp == null)
            return;

        if (brightness <= 1)
            brightness = 1;

        if (brightness >= 255)
            brightness = 255;

        lp.screenBrightness = brightness / 255f;
        window.setAttributes(lp);

        if (saveBrightness != null && saveBrightness)
            saveBrightness(context, brightness);
    }

    @LuaBridge
    public int getBright() {

        int systemBrightness = 0;
        try {
            systemBrightness = Settings.System.getInt(getContext().getContentResolver(), Settings.System.SCREEN_BRIGHTNESS);
        } catch (Exception e) {
            e.printStackTrace();
        }

        Context context = getContext();
        if (!(context instanceof Activity))
            return systemBrightness;

        Window window = ((Activity) context).getWindow();
        WindowManager.LayoutParams lp = window.getAttributes();

        if (lp == null)
            return systemBrightness;

        if (lp.screenBrightness < 0)
            return systemBrightness;

        int finalBright = Math.abs((int) (lp.screenBrightness * 255f));

        if (finalBright >= 255)
            finalBright = 255;

        if (finalBright <= 1)
            finalBright = 1;

        return finalBright;
    }

    /**
     * 保存亮度设置状态，退出app也能保持设置状态
     */
    private void saveBrightness(Context context, int brightness) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Settings.System.canWrite(context))
                writeScreenBright2Settings(context, brightness);
            else
                startModifySettingPermission(context);
        } else
            writeScreenBright2Settings(context, brightness);

    }

    private void writeScreenBright2Settings(Context context, int brightness) {
        ContentResolver resolver = context.getContentResolver();
        Uri uri = android.provider.Settings.System.getUriFor(Settings.System.SCREEN_BRIGHTNESS);
        android.provider.Settings.System.putInt(resolver, Settings.System.SCREEN_BRIGHTNESS, brightness);
        resolver.notifyChange(uri, null);
    }

    private void startModifySettingPermission(Context context) {
        Intent intent = new Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS);
        intent.setData(Uri.parse("package:" + context.getPackageName()));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }


}