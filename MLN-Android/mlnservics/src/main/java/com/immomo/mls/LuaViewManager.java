/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.content.Context;
import android.os.Looper;
import android.os.SystemClock;
import android.util.SparseArray;

import com.immomo.mls.cache.LuaCache;
import com.immomo.mls.log.DefaultPrintStream;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.MainThreadExecutor;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.IGlobalsUserdata;

import java.io.PrintStream;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Created by Xiong.Fangyu on 2019/3/11
 */
public class LuaViewManager implements IGlobalsUserdata{

    public Context context;
    public MLSInstance instance;
    public PrintStream STDOUT;
    public String scriptVersion;
    public String baseFilePath;
    public final LuaCache luaCache;
    public String url;
    private SparseArray<OnActivityResultListener> onActivityResultListeners;
    /**
     * 虚拟机全局圆角配置
     */
    private boolean defaltCornerClip = false ;//全局默认属性：false

    public LuaViewManager(Context c) {
        context = c;
        luaCache = new LuaCache();
    }

    public void putOnActivityResultListener(int code, OnActivityResultListener l) {
        if (onActivityResultListeners == null) {
            onActivityResultListeners = new SparseArray<>();
        }
        onActivityResultListeners.put(code, l);
    }

    public OnActivityResultListener getOnActivityResultListener(int code) {
        return onActivityResultListeners != null ? onActivityResultListeners.get(code) : null;
    }

    public void removeOnActivityResultListeners(int c) {
        if (onActivityResultListeners != null)
            onActivityResultListeners.remove(c);
    }

    @Override
    public void onGlobalsDestroy(Globals g) {
        if (g.isIsolate()) return;
        context = null;
        instance = null;
        STDOUT = null;
        luaCache.clear();
        if (onActivityResultListeners != null)
            onActivityResultListeners.clear();
    }

    @Override
    public void l(long L, String tag, String log) {
        Globals g = Globals.getGlobalsByLState(L);
        LuaViewManager v = g != null ? (LuaViewManager) g.getJavaUserdata() : null;
        PrintStream out = v != null ? v.STDOUT : null;
        if (out != null) {
            out.print(log);
            out.println();
        }
        LogUtil.d(tag, log);
    }

    @Override
    public void e(long L, String tag, String log) {
        Globals g = Globals.getGlobalsByLState(L);
        LuaViewManager v = g != null ? (LuaViewManager) g.getJavaUserdata() : null;
        PrintStream out = v != null ? v.STDOUT : null;
        if (out instanceof DefaultPrintStream) {
            ((DefaultPrintStream) out).error(log);
        } else if (out != null) {
            out.print(log);
            out.println();
        }
        LogUtil.d(tag, log);
    }

    public void showPrinterIfNot() {
        if (instance != null && !instance.isShowPrinter() && !instance.hasClosePrinter()) {
            instance.showPrinter(true);
        }
    }

    public boolean getDefaltCornerClip() {
        return defaltCornerClip;
    }

    public void setDefaltCornerClip(boolean defaltCornerClip) {
        this.defaltCornerClip = defaltCornerClip;
    }

    /**
     * setup global values
     *
     * @param globals
     */
    public static Globals setupGlobals(final Globals globals) {
        if (globals == null)
            return null;
        if (Looper.myLooper() == Looper.getMainLooper()) {
            realSetupGlobals(globals);
        } else {
            final Lock lock = new ReentrantLock();
            final Condition condition = lock.newCondition();
            MainThreadExecutor.post(new LockRunnable(lock, condition) {
                @Override
                public void realRun() {
                    realSetupGlobals(globals);
                }
            });
            try {
                lock.lock();
                condition.await();
            } catch (InterruptedException ignore) {
            } finally {
                lock.unlock();
            }
        }
        return globals;
    }

    private static void realSetupGlobals(Globals globals) {
        long t = SystemClock.uptimeMillis();
        MLSEngine.singleRegister.install(globals);
        t = SystemClock.uptimeMillis() - t;
        if (MLSEngine.DEBUG) {
            MLSAdapterContainer.getConsoleLoggerAdapter().d("LuaViewManager", "init cast: " + t);
        }
        NativeBridge.registerNativeBridge(globals);
    }

    private abstract static class LockRunnable implements Runnable {
        final Lock lock;
        final Condition condition;
        LockRunnable(Lock lock, Condition condition) {
            this.lock = lock;
            this.condition = condition;
        }
        @Override
        public void run() {
            try {
                lock.lock();
                realRun();
                condition.signal();
            } finally {
                lock.unlock();
            }
        }

        protected abstract void realRun();
    }
}