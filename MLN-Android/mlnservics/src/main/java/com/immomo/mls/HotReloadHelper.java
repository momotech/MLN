/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.text.TextUtils;

import androidx.annotation.IntDef;

import com.immomo.luanative.hotreload.HotReloadServer;
import com.immomo.luanative.hotreload.IHotReloadServer;
import com.immomo.luanative.hotreload.iHotReloadListener;
import com.immomo.mls.global.LuaViewConfig;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.IOUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.MainThreadExecutor;
import com.immomo.mls.wrapper.GlobalsContainer;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.StringReplaceUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.lang.annotation.Retention;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static java.lang.annotation.RetentionPolicy.SOURCE;

/**
 * Created by Xiong.Fangyu on 2019-07-16
 */
public class HotReloadHelper {
    private static final String TAG = "HotReloadHelper";
    /**
     * 网络连接类型为USB连接.
     */
    public static final int USB_CONNECTION = IHotReloadServer.USB_CONNECTION;

    /**
     * 网咯连接类型为NET连接.
     */
    public static final int NET_CONNECTION = IHotReloadServer.NET_CONNECTION;

    public static final int STATE_NORMAL = 0;
    public static final int STATE_PROJECT = 1;
    public static final int STATE_FORCE = 2;
    public static final int STATE_SDK = 3;

    private static final int DEBUG_LENGTH = 5;
    private static final int RELEASE_LENGTH = 7;

    @Retention(SOURCE)
    @IntDef({STATE_NORMAL, STATE_PROJECT, STATE_FORCE, STATE_SDK})
    public @interface STATE {
    }

    private static final int CS_N = 0;
    private static final int CS_Connect = 1;
    private static final int CS_Connecting = 2;
    private static final int CS_Disconnect = 3;

    public static final int DEFAULT_USB_PORT = 8176;

    private static final List<Callback> callbacks = new ArrayList<>();

    private static HotReloadImpl hotReload;

    private static int usbPort = DEFAULT_USB_PORT;
    private static String wifiIp = null;
    private static int wifiPort = 0;

    private static int connectType = 0;
    private static int connectState = CS_N;

    private static final String pattern = "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}:\\d+$";
    private static Pattern P;

    private static ConnectListener connectListener;

    public static void setSerial(String serial) {
        HotReloadServer.getInstance().setSerial(serial);
    }

    public static String getSerial() {
        return HotReloadServer.getInstance().getSerial();
    }

    private static File getHotReloadPath() {
        File f = new File(FileUtil.getCacheDir(), "LuaHotReload");
        if (!f.exists()) {
            f.mkdirs();
        }
        return f;
    }

    public static HashMap<String, String> parseParams(String p) {
        if (TextUtils.isEmpty(p)) return null;

        HashMap<String, String> ret = new HashMap<>();
        String[] kvs = p.split("&");
        for (String kv : kvs) {
            if (kv.length() <= 1)
                continue;
            String[] kva = kv.split("=", 2);
            if (kva.length != 2)
                continue;
            String k = kva[0];
            String v = kva[1];
            if (TextUtils.isEmpty(k) || TextUtils.isEmpty(v))
                continue;
            ret.put(k, v);
        }

        if (ret.isEmpty()) return null;
        return ret;
    }

    private static Pattern errorPattern;

    public static String parseErrorString(String s) {
        if (TextUtils.isEmpty(s)) return s;

        if (errorPattern == null) {
            errorPattern = Pattern.compile("(\".*\")]");
        }

        Matcher m = errorPattern.matcher(s);
        int index = 0;
        int start;
        final StringBuilder sb = new StringBuilder();
        while (m.find(index)) {
            start = m.start();
            sb.append(s.substring(index, start));
            String g = m.group();

            sb.append(StringReplaceUtils.replaceAllChar(g.substring(0, g.length() - 2), '.', File.separatorChar)).append(".lua\"]");
            index = m.end();
        }
        sb.append(s.substring(index));
        return sb.toString();
    }

    public static void onError(String er) {
        HotReloadServer.getInstance().error(parseErrorString(er));
    }

    public static void log(String l) {
        HotReloadServer.getInstance().log(l);
    }

    private static final class HotReloadImpl implements iHotReloadListener {

        private final ExecutorService threads = new ThreadPoolExecutor(2, 3, 1, TimeUnit.MINUTES, new LinkedBlockingQueue<Runnable>());
        private final ExecutorService reloadThread = new ThreadPoolExecutor(1, 1, 1, TimeUnit.MINUTES, new LinkedBlockingQueue<Runnable>());
        private final AtomicInteger changeFiles = new AtomicInteger(0);

        private static final int PRE_RELOAD = 1;
        private static final int WAIT_FILE = 1 << 1;
        private static final int RELOADING = 1 << 2;
        private static final int FILE_CHANGE_WHEN_RELOADING = 1 << 3;
        private static final int RELOAD_AGAIN = 1 << 4;
        private final AtomicInteger reloadState = new AtomicInteger(0);

        @Override
        public void onReload(final String entryFilePath, final String relativeEntryFilePath, final String params) {
            if (relativeEntryFilePath == null)
                return;

            if (relativeEntryFilePath.indexOf('/') > 0) {
                onError("Entry File必须设置在src根目录下!");
                return;
            }
            LogUtil.d(TAG, "onReload", entryFilePath, relativeEntryFilePath, params);
            int st = reloadState.get();
            if (st != 0 && st != RELOAD_AGAIN) {
                reloadState.set(reloadState.get() | RELOAD_AGAIN);
                return;
            }
            reloadState.set(PRE_RELOAD);

            reloadThread.submit(new Runnable() {
                @Override
                public void run() {
                    reloadState.set(WAIT_FILE);
                    try {
                        Thread.sleep(50);
                    } catch (InterruptedException ignore) {
                    }
                    while (changeFiles.get() > 0) ;
                    reloadState.set(RELOADING);
                    HashMap<String, String> p = parseParams(params);
                    Collection<Callback> cs = new ArrayList<>(callbacks);
                    File file = new File(getHotReloadPath(), relativeEntryFilePath);
                    try {
                        for (Callback cb : cs) {
                            cb.onReload(file.getAbsolutePath(), p, STATE_NORMAL);
                            do {
                                Thread.sleep(100);
                            } while (!cb.reloadFinish());
                        }
                    } catch (Throwable ignore) {
                    }
                    int state = reloadState.get();
                    reloadState.set(PRE_RELOAD);
                    if ((state & FILE_CHANGE_WHEN_RELOADING) == FILE_CHANGE_WHEN_RELOADING && (state & RELOAD_AGAIN) == RELOAD_AGAIN) {
                        reloadThread.submit(this);
                    } else {
                        reloadState.set(0);
                    }
                }
            });
        }

        private void waitReloading() {
            int state;
            while (((state = reloadState.get()) & RELOADING) == RELOADING
                    && (state & FILE_CHANGE_WHEN_RELOADING) != FILE_CHANGE_WHEN_RELOADING
                    && (state & PRE_RELOAD) != PRE_RELOAD) {
                reloadState.set(reloadState.get() | FILE_CHANGE_WHEN_RELOADING);
            }
        }

        @Override
        public void onFileCreate(final String filePath, final String relativeFilePath, final InputStream is) {
            LogUtil.d(TAG, "onFileCreate", filePath, relativeFilePath);
            changeFiles.incrementAndGet();
            threads.submit(new Runnable() {
                @Override
                public void run() {
                    waitReloading();
                    File f = new File(getHotReloadPath(), relativeFilePath);
                    File parent = f.getParentFile();
                    if (!parent.isDirectory()) {
                        parent.mkdirs();
                    }
                    boolean exists = true;
                    if (!f.exists()) {
                        exists = false;
                        try {
                            exists = f.createNewFile();
                        } catch (IOException ignore) {
                        }
                    }
                    if (!exists) {
                        changeFiles.decrementAndGet();
                        return;
                    }
                    FileUtil.save(f, is);
                    IOUtil.closeQuietly(is);

                    changeFiles.decrementAndGet();
                }
            });
        }

        @Override
        public void onFileUpdate(final String filePath, final String relativeFilePath, final InputStream is) {
            LogUtil.d(TAG, "onFileUpdate", filePath, relativeFilePath);
            changeFiles.incrementAndGet();
            threads.submit(new Runnable() {
                @Override
                public void run() {
                    waitReloading();

                    File f = new File(getHotReloadPath(), relativeFilePath);
                    for (Callback cb : callbacks) {
                        cb.onUpdateFiles(f.getAbsolutePath());
                    }
                    File parent = f.getParentFile();
                    if (!parent.isDirectory()) {
                        parent.mkdirs();
                    }
                    boolean exists = true;
                    if (!f.exists()) {
                        exists = false;
                        try {
                            exists = f.createNewFile();
                        } catch (IOException ignore) {
                        }
                    }
                    if (!exists) {
                        changeFiles.decrementAndGet();
                        return;
                    }

                    FileUtil.clearFile(f);
                    FileUtil.save(f, is);
                    IOUtil.closeQuietly(is);

                    changeFiles.decrementAndGet();
                }
            });
        }

        @Override
        public void onFileRename(final String filePath, final String relativeFilePath, String newFilePath, final String relativeNewFilePath) {
            LogUtil.d(TAG, "onFileRename", filePath, relativeFilePath, newFilePath, relativeNewFilePath);
            changeFiles.incrementAndGet();
            threads.submit(new Runnable() {
                @Override
                public void run() {
                    waitReloading();

                    File f = new File(getHotReloadPath(), relativeFilePath);
                    if (f.exists()) {
                        f.renameTo(new File(getHotReloadPath(), relativeNewFilePath));
                    }

                    changeFiles.decrementAndGet();
                }
            });
        }

        @Override
        public void onFileMove(final String filePath, final String relativeFilePath, String newFilePath, final String relativeNewFilePath) {
            LogUtil.d(TAG, "onFileMove", filePath, relativeFilePath, newFilePath, relativeNewFilePath);
            changeFiles.incrementAndGet();
            threads.submit(new Runnable() {
                @Override
                public void run() {
                    waitReloading();

                    File f = new File(getHotReloadPath(), relativeFilePath);
                    if (f.exists()) {
                        f.renameTo(new File(getHotReloadPath(), relativeNewFilePath));
                    }

                    changeFiles.decrementAndGet();
                }
            });
        }

        @Override
        public void onFileDelete(final String filePath, final String relativeFilePath) {
            LogUtil.d(TAG, "onFileDelete", filePath, relativeFilePath);
            changeFiles.incrementAndGet();
            threads.submit(new Runnable() {
                @Override
                public void run() {
                    waitReloading();

                    File f = new File(getHotReloadPath(), relativeFilePath);
                    if (f.exists()) {
                        f.delete();
                    }

                    changeFiles.decrementAndGet();
                }
            });
        }

        @Override
        public void onConnected(int type, String ip, int port) {
            LogUtil.d(TAG, "onConnected", type, ip, port);
            toast("连接HotReload插件成功，连接方式: " + (type == NET_CONNECTION ? "wifi" : "usb"));
            connectState = CS_Connecting;
            connectType |= type;
            if (connectListener != null)
                connectListener.onConnected(!callbacks.isEmpty());
//            for (Map.Entry<String, Callback> e : callbacks.entrySet()) {
//                e.getValue().onConnectStateChange(true, type, null);
//            }
        }

        @Override
        public void disconnecte(int type, String ip, int port, String error) {
            LogUtil.d(TAG, "disconnecte", type, ip, port, error);
            connectState = CS_Disconnect;
            connectType &= ~type;
            HotReloadServer.getInstance().stop();
        }

        @Override
        public void onGencoveragereport() {
            final Globals g = getGlobals();
            if (g != null) {
                g.post(new Runnable() {
                    @Override
                    public void run() {
                        if (g.isDestroyed())
                            return;
                        if (!MLSEngine.isInit()) {
                            MLSAdapterContainer.getToastAdapter().toast("未初始化");
                            return;
                        }
                        int c = NativeBridge.callGencoveragereport(g);
                        if (c != Globals.LUA_OK) {
                            MLSAdapterContainer.getToastAdapter().toast("callGencoveragereport failed, code: " + c);
                        }
                    }
                });
            }
        }

        @Override
        public void onIpChanged(String ip) {
            LuaViewConfig.setDebugIp(ip);
        }

        private Globals getGlobals() {
            for (Callback c : callbacks) {
                if (c instanceof GlobalsContainer)
                    return ((GlobalsContainer) c).getGlobals();
            }
            return null;
        }
    }

    private static void toast(final String s) {
        MainThreadExecutor.post(new Runnable() {
            @Override
            public void run() {
                MLSAdapterContainer.getToastAdapter().toast(s, 1);
            }
        });
    }

    public static int getUsbPort() {
        return usbPort;
    }

    public static String getWifiIp() {
        return wifiIp;
    }

    public static int getWifiPort() {
        return wifiPort;
    }

    public static void addCallback(Callback c) {
        if (!MLSEngine.DEBUG) return;
        if (!callbacks.contains(c))
            callbacks.add(c);
        connect(true);
    }

    public static void removeCallback(Callback cb) {
        if (!MLSEngine.DEBUG) return;
        callbacks.remove(cb);
    }

    public static void setUseUSB(int port) {
        if (!MLSEngine.DEBUG) return;
        if (usbPort == port && hasConnect(true)) {
            if (connectListener != null)
                connectListener.onConnected(!callbacks.isEmpty());
            return;
        }
        usbPort = port;
        HotReloadServer.getInstance().setupUSB(port);
    }

    public static void setUseWifi(String ip, int port) {
        if (!MLSEngine.DEBUG) return;
        MLSEngine.setDebugIp(ip);
        if (ip.equals(wifiIp) && port == wifiPort && hasConnect(false)) {
            if (connectListener != null)
                connectListener.onConnected(!callbacks.isEmpty());
            return;
        }
        wifiIp = ip;
        wifiPort = port;
        stop();
        connect(false);
    }

    public static boolean setUseWifi(String ip_port) {
        if (TextUtils.isEmpty(ip_port)) return false;

        String[] s = ip_port.split(":");
        try {
            int port = Integer.parseInt(s[1]);
            setUseWifi(s[0], port);
            return true;
        } catch (Throwable e) {
            LogUtil.e(e, "error set port");
        }
        return false;
    }

    public static boolean isIPPortString(String s) {
        if (P == null)
            P = Pattern.compile(pattern);
        Matcher m = P.matcher(s);
        return m.matches();
    }

    public static void setConnectListener(ConnectListener connectListener) {
        HotReloadHelper.connectListener = connectListener;
    }

    public static boolean isConnecting() {
        return connectState == CS_Connecting;
    }

    public static boolean hasConnect(boolean usb) {
        int type = usb ? HotReloadServer.USB_CONNECTION : HotReloadServer.NET_CONNECTION;
        return (connectType & type) == type;
    }

    private static void stop() {
        connectState = CS_Disconnect;
        HotReloadServer.getInstance().stop();
    }

    private static void connect(boolean useUSB) {
        if (connectState == CS_Connect || connectState == CS_Connecting) {
            /// 正在连接相同类型的链接时，return
            if (hasConnect(useUSB)) return;
        }
        if (hotReload == null) {
            hotReload = new HotReloadImpl();
            HotReloadServer.getInstance().setListener(hotReload);
        }
        connectState = CS_Connect;
        if (useUSB) {
            HotReloadServer.getInstance().start();
        } else {
            HotReloadServer.getInstance().startNetClient(wifiIp, wifiPort);
        }
    }

    public static interface Callback {

        void onUpdateFiles(String f);

        void onReload(String path, HashMap<String, String> params, @STATE int state);

        boolean reloadFinish();

        void onDisconnected(int type, String error);
    }

    public static interface ConnectListener {
        void onConnected(boolean hasCallback);

        void onDisConnected();
    }
}