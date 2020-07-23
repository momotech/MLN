/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

import android.util.Log;

import org.luaj.vm2.LuaConfigs;

import androidx.collection.LongSparseArray;

/**
 * Created by Xiong.Fangyu on 2019/2/27
 * <p>
 * called by native
 * <p>
 * lua的print函数或错误日志，都将通过{@link #log}方法打印
 */
@LuaApiUsed
public final class NativeLog {
    private static final String TAG = "LuaLog";

    private static  LongSparseArray<StringBuilder> logBuilder = new LongSparseArray<>();
    private static  LongSparseArray<ILog> logs = new LongSparseArray<>();
    private static ILog logImpl;

    private static StringBuilder get(long L) {
        StringBuilder sb = logBuilder.get(L);
        if (sb == null) {
            sb = new StringBuilder();
            logBuilder.put(L, sb);
        }
        return sb;
    }

    public static void release(long L) {
        logBuilder.remove(L);
        logs.remove(L);
    }

    /**
     * 注册对应虚拟机的日志实现
     * @see org.luaj.vm2.Globals#setJavaUserdata
     */
    public static void register(long L, ILog log) {
        logs.put(L, log);
    }

    /**
     * 设置全局日志实现
     */
    public static void setLogImpl(ILog impl) {
        logImpl = impl;
    }

    /**
     * called by native
     * see jlog.c
     */
    @LuaApiUsed
    private static void log(long L, int type, String s) {
        switch (type) {
            case 1:     //log
                get(L).append(s);
                break;
            case -1:    //flush
                l(L);
                break;
            case 2:     //Error log
                le(L, s);
                break;
        }
    }

    private static void l(long L) {
        String log = get(L).toString();
        get(L).setLength(0);
        if (LuaConfigs.openLogLevel >= LuaConfigs.LOG_ALL) {
            ILog logImpl = logs.get(L);
            if (logImpl != null) {
                logImpl.l(L, TAG, log);
            } else {
                Log.d(TAG, log);
            }
            if (NativeLog.logImpl != null) {
                NativeLog.logImpl.l(L, TAG, log);
            }
        }
    }

    private static void le(long L, String s) {
        if (LuaConfigs.openLogLevel >= LuaConfigs.LOG_ERR) {
            ILog logImpl = logs.get(L);
            if (logImpl != null) {
                logImpl.e(L, TAG, s);
            } else {
                Log.e(TAG, s);
            }
            if (NativeLog.logImpl != null) {
                NativeLog.logImpl.e(L, TAG, s);
            }
        }
    }
}