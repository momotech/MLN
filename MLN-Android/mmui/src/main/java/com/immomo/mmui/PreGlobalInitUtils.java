/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui;

import android.os.Looper;

import androidx.annotation.Nullable;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.NativeBridge;
import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.global.LuaViewConfig;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.MainThreadExecutor;

import org.luaj.vm2.Globals;
import org.luaj.vm2.exception.InvokeError;
import org.luaj.vm2.exception.UndumpError;

import java.io.File;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Created by Xiong.Fangyu on 2019-08-08
 *
 * 提前初始化一些Globals以供使用
 */
public class PreGlobalInitUtils {
    public static final String SCRIPT_VERSION = "packet/v1_0/";

    private static final String[] PreloadScriptName = {
            "BindMeta",
            "KeyboardManager",
            "PageView",
            "Navigator",
            "style",
            "TabSegment",
            "ViewPager",
            "ViewPagerAdapter"
    };

    private final static Deque<Globals> preInitGlobals = new ArrayDeque<>(10);

    private final static Lock lock = new ReentrantLock(true);

    private static int preInitSize = 0;

    /**
     * Call in Main Thread
     */
    public static @Nullable Globals take() {
        AssertUtils.assetTrue(MainThreadExecutor.isMainThread());
        try {
            lock.lock();
            Globals g = preInitGlobals.pollFirst();
            preInit();
            return g;
        } finally {
            lock.unlock();
        }
    }

    /**
     * Call in Main Thread
     * 提前初始化num个虚拟机
     */
    public static void initFewGlobals(int num) {
        AssertUtils.assetTrue(MainThreadExecutor.isMainThread());
        if (num > 10) num = 10;
        preInitSize += num;

        if (!MLSEngine.isInit() || !Globals.isInit())
            return;
        MLSEngine.singleRegister.preInstall();
        MMUIEngine.singleRegister.preInstall();
        if (!MLSEngine.singleRegister.isPreInstall() || !MMUIEngine.singleRegister.isPreInstall())
            return;
        while (num -- > 0) {
            preInit();
        }
    }

    /**
     * 已初始化个数
     */
    public static int hasPreInitSize() {
        return preInitSize;
    }

    private static void preInit() {
        if (preInitGlobals.size() == 10)
            return;
        final Globals globals = Globals.createLState(LuaViewConfig.isOpenDebugger());
        MLSAdapterContainer.getThreadAdapter().execute(MLSThreadAdapter.Priority.HIGH, new Runnable() {
            @Override
            public void run() {
                setupGlobals(globals);
                preloadScriptsSimple(globals);
                try {
                    lock.lock();
                    preInitGlobals.addLast(globals);
                } finally {
                    lock.unlock();
                }
            }
        });
    }

    private static void preloadScriptsSimple(Globals g) {
        for (String script : PreloadScriptName) {
            try {
                g.require(SCRIPT_VERSION + script);
            } catch (InvokeError e) {
                if (MLSEngine.DEBUG)
                    LogUtil.e(e, "require script " + script + " from assets failed!");
            }
        }
    }

    private static void preloadScripts(Globals g) {
        String cache = FileUtil.getCacheDir().getAbsolutePath() + File.separatorChar;
        for (String script : PreloadScriptName) {
            script = SCRIPT_VERSION + script;
            String path = cache + script + ".lua";
            if (!FileUtil.exists(path)) {
                path = null;
            }
            if (path != null) {
                try {
                    g.preloadFile(script, path);
                    continue;
                } catch (UndumpError e) {
                    if (MLSEngine.DEBUG)
                        LogUtil.e(e, "preload script " + script + " from path " + path + " failed!");
                }
            }

            path = script + ".lua";
            try {
                String savePath = cache + path;
                int dumpRet = g.preloadAssetsAndSave(script, path, savePath);
                if (dumpRet != 0 && MLSEngine.DEBUG) {
                    LogUtil.e("dump " + script + " to " + savePath + " failed, error code: " + dumpRet);
                }
            } catch (UndumpError e) {
                if (MLSEngine.DEBUG)
                    LogUtil.e(e, "preload script " + script + " from assets failed!");
            }
        }
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
        MLSEngine.singleRegister.install(globals, false);
        MMUIEngine.singleRegister.install(globals);
        if (MLSEngine.isInit())
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