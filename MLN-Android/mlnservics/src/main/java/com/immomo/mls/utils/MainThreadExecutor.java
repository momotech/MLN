/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public class MainThreadExecutor {

    private static volatile Handler handler;

    public static boolean isMainThread() {
        return Looper.myLooper() == Looper.getMainLooper();
    }

    public static boolean isMainThread(Thread t) {
        return Looper.getMainLooper().getThread() == t;
    }

    /**
     * 使用全局Main Thread handler来post一直Runnable
     *
     * @param runnable
     */
    public static void post(Runnable runnable) {
        if (runnable == null) {
            throw new IllegalArgumentException("runnable is null");
        }
        getHandler().post(runnable);
    }


    public static void post(Object tag, Runnable runnable) {
        if (tag instanceof Number || tag instanceof CharSequence) {
            tag = tag.toString().intern();
        }

        Message message = Message.obtain(getHandler(), runnable);
        message.obj = tag;
        getHandler().sendMessage(message);
    }

    public static void postAtFrontOfQueue(Runnable runnable) {
        if (runnable == null) {
            throw new IllegalArgumentException("runnable is null");
        }
        getHandler().postAtFrontOfQueue(runnable);
    }

    public static void postDelayed(Object tag, Runnable runnable, long delayMill) {
        if (tag == null) {
            throw new IllegalArgumentException("tag is null");
        }
        if (runnable == null) {
            throw new IllegalArgumentException("runnable is null");
        }
        if (delayMill <= 0) {
            throw new IllegalArgumentException("delayMill <= 0");
        }

        if (tag instanceof Number || tag instanceof CharSequence) {
            tag = tag.toString().intern();
        }

        Message message = Message.obtain(getHandler(), runnable);
        message.obj = tag;

        getHandler().sendMessageDelayed(message, delayMill);
    }

    public static void cancelSpecificRunnable(Object tag, Runnable runnable) {
        if (tag == null) {
            throw new IllegalArgumentException("tag is null");
        }
        if (runnable == null) {
            throw new IllegalArgumentException("runnable is null");
        }

        if (tag instanceof Number || tag instanceof CharSequence) {
            tag = tag.toString().intern();
        }

        getHandler().removeCallbacks(runnable, tag);
    }

    public static void cancelAllRunnable(Object tag) {
        if (tag == null) {
            throw new IllegalArgumentException("tag is null");
        }

        if (tag instanceof Number || tag instanceof CharSequence) {
            tag = tag.toString().intern();
        }

        getHandler().removeCallbacksAndMessages(tag);
    }

    private static Handler getHandler() {
        if (handler == null) {
            synchronized (MainThreadExecutor.class) {
                if (handler == null) {
                    handler = new Handler(Looper.getMainLooper());
                }
            }
        }
        return handler;
    }
}