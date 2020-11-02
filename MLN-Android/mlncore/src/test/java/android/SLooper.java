/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package android;

/**
 * Created by Xiong.Fangyu on 2019-06-24
 */
public class SLooper {

    static final ThreadLocal<SLooper> sThreadLocal = new ThreadLocal<SLooper>();
    private static SLooper sMainLooper;

    private Thread mThread;
    SMessageQueue mQueue;

    private SLooper() {
        mQueue = new SMessageQueue();
        mThread = Thread.currentThread();
    }

    public static SLooper myLooper() {
        return sThreadLocal.get();
    }

    public static SLooper getMainLooper() {
        synchronized (SLooper.class) {
            return sMainLooper;
        }
    }

    public static void prepareMainLooper() {
        prepare();
        synchronized (SLooper.class) {
            if (sMainLooper != null) {
                throw new IllegalStateException("The main Looper has already been prepared.");
            }
            sMainLooper = myLooper();
        }
    }

    public static void prepare() {
        if (sThreadLocal.get() != null) {
            throw new RuntimeException("Only one Looper may be created per thread");
        }
        sThreadLocal.set(new SLooper());
    }

    public static void loop() {
        final SLooper me = myLooper();
        if (me == null) {
            throw new RuntimeException("No Looper; Looper.prepare() wasn't called on this thread.");
        }
        final SMessageQueue queue = me.mQueue;

        while (true) {
            SMessage msg = queue.next(); // might block
            if (msg == null) {
                return;
            }
            msg.target.dispatchMessage(msg);
        }
    }

    public void quit() {
        mQueue.quit(false);
    }

    public void quitSafely() {
        mQueue.quit(true);
    }
}