/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

import org.luaj.vm2.Globals;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Xiong.Fangyu on 2019-05-17
 */
public class MemoryMonitor {
    private static int OFFSET = 0;

    private static T globalMonitor;
    private final static Map<Globals, T> luaVmMonitors = new HashMap<>();

    private static final String[] SIZE = {
            "B", "KB", "MB", "GB"
    };

    /**
     * 设置间隔时长
     * 若<=0 ，表示关闭
     * @param offset 单位ms
     */
    public static void setOffsetTime(int offset) {
        OFFSET = offset;
        if (offset <= 0) {
            terminalGlobalMemoryMonitoer();
            stopAllCheckLuaVmMemory();
        }
    }

    /**
     * 获取内存字符串，只保留一位小数
     * eg: 1.1KB or 3.5MB
     * @param size 内存使用量，单位Byte
     * @return eg: 1.1KB or 3.5MB
     */
    public static String getMemorySizeString(long size) {
        long temp = size;
        long pre = temp;
        int times = 0;
        final int max = SIZE.length;
        while ((temp = temp >>> 10) > 0) {
            if (++times < max)
                pre = temp;
            else
                times --;
        }
        temp = size - (pre << (10 * times));
        float ret = pre + (temp / (float)(1 << (10 * times)));
        return String.format("%.2f%s", ret, SIZE[times]);
    }

    /**
     * 检查所有虚拟机内存消耗
     * 一般情况下，此线程会一直运行，直到调用{@link #terminalGlobalMemoryMonitoer()}
     */
    public synchronized static void startCheckGlobalMemory(GlobalMemoryListener listener) {
        if (OFFSET <= 0) return;
        if (globalMonitor == null) {
            globalMonitor = new T();
            globalMonitor.start();
        }
        globalMonitor.setGlobalMemoryListener(listener);
    }

    /**
     * 停止检查所有虚拟机内存消耗
     * 不会终止检查线程，线程将处于wait状态
     */
    public synchronized static void stopCheckGlobalMemory() {
        if (globalMonitor == null) return;
        globalMonitor.setGlobalMemoryListener(null);
    }

    /**
     * 停止检查线程
     */
    public synchronized static void terminalGlobalMemoryMonitoer() {
        if (globalMonitor == null) return;
        globalMonitor.running = false;
        globalMonitor.setGlobalMemoryListener(null);
        globalMonitor = null;
    }

    /**
     * 检查单个虚拟机内存消耗
     */
    public synchronized static void startCheckLuaVmMemory(Globals globals, LuaVmMemoryListener listener) {
//        if (globals.isDestroyed()) return;
//        T t = luaVmMonitors.get(globals);
//        if (t == null) {
//            t = new T(globals);
//            t.start();
//            luaVmMonitors.put(globals, t);
//        }
//        t.luaVmMemoryListener = listener;
    }

    /**
     * 停止检查单个虚拟机内存消耗
     */
    public synchronized static void stopCheckLuaVmMemory(Globals globals) {
        T t = luaVmMonitors.remove(globals);
        if (t != null) {
            t.luaVmMemoryListener = null;
            t.interrupt();
        }
    }

    /**
     * 关闭所有检查
     */
    public synchronized static void stopAllCheckLuaVmMemory() {
//        for (Map.Entry<Globals, T> e : luaVmMonitors.entrySet()) {
//            T t = e.getValue();
//            t.luaVmMemoryListener = null;
//            t.interrupt();
//        }
//        luaVmMonitors.clear();
    }

    private static final class T extends Thread {
        private final Globals globals;

        private LuaVmMemoryListener luaVmMemoryListener;

        private volatile GlobalMemoryListener globalMemoryListener;

        private boolean running = true;

        T(Globals g) {
            super("LuaVmMemMonitor-" + g.getL_State());
            this.globals = g;
        }

        T() {
            super("LuaVmMemMonitor");
            globals = null;
        }

        public synchronized void setGlobalMemoryListener(GlobalMemoryListener globalMemoryListener) {
            this.globalMemoryListener = globalMemoryListener;
            notify();
        }

        @Override
        public void run() {
            if (OFFSET <= 0) return;
            if (globals != null) {
//                runForGlobals();
            } else {
                runForAll();
            }
        }

        private void runForGlobals() {
            while (true) {
                synchronized (T.class) {
                    try {
                        T.class.wait();
                    } catch (Throwable t) {
                        synchronized(MemoryMonitor.class) {
                            luaVmMonitors.remove(globals);
                        }
                    }
                }
                if (luaVmMemoryListener == null) {
                    synchronized(MemoryMonitor.class) {
                        luaVmMonitors.remove(globals);
                    }
                    return;
                }
                synchronized (globals) {
                    if (globals.isDestroyed()) {
                        synchronized(MemoryMonitor.class) {
                            luaVmMonitors.remove(globals);
                        }
                        return;
                    }
                    long size = globals.getLVMMemUse();
                    luaVmMemoryListener.onMemory(globals, size);
                }
            }
        }

        private void runForAll() {
            while (running) {
                synchronized (this) {
                    while (globalMemoryListener == null && OFFSET > 0 && running) {
                        try {
                            wait();
                        } catch (Throwable ignore) {}
                    }
                    try {
                        sleep(OFFSET);
                    } catch (Throwable ignore) { }
                    globalMemoryListener.onInfo(Globals.getAllLVMMemUse());
                }
            }
        }
    }

    /**
     * 单个虚拟机内存检测
     */
    public interface LuaVmMemoryListener {
        /**
         * 回调特殊虚拟机使用内存量
         * Called in other Thread
         * @param g     目标虚拟机
         * @param size  内存总量，单位Byte
         */
        void onMemory(Globals g, long size);
    }

    /**
     * 所有正在运行中的虚拟机内存检测
     */
    public interface GlobalMemoryListener {
        /**
         * 回调所有虚拟机使用内存量
         * Called in other Thread
         * @param memSize  内存总量，单位Byte
         */
        void onInfo(long memSize);
    }
}