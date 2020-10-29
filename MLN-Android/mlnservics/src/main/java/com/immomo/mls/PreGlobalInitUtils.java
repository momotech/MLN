/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import android.os.Looper;
import android.os.SystemClock;

import androidx.annotation.Nullable;

import com.immomo.mls.adapter.MLSThreadAdapter;
import com.immomo.mls.global.LuaViewConfig;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.MainThreadExecutor;

import org.luaj.vm2.Globals;

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
        if (!MLSEngine.singleRegister.isPreInstall())
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
                try {
                    lock.lock();
                    preInitGlobals.addLast(globals);
                } finally {
                    lock.unlock();
                }
            }
        });
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