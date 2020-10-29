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
public class SHandler {

    public interface Callback {
        public boolean handleMessage(SMessage msg);
    }

    Callback mCallback;

    SLooper mLooper;

    private SMessageQueue mQueue;

    public SHandler() {
        this((Callback) null);
    }

    public SHandler(SLooper looper) {
        mLooper = looper;
    }

    public SHandler(Callback callback) {
        SLooper looper = SLooper.myLooper();
        if (looper == null)
            throw new RuntimeException(
                "Can't create handler inside thread " + Thread.currentThread()
                        + " that has not called Looper.prepare()");
        mLooper = looper;
        mQueue = looper.mQueue;
        mCallback = callback;
    }

    public void dispatchMessage(SMessage msg) {
        if (msg.callback != null) {
            msg.callback.run();
        } else {
            if (mCallback != null) {
                if (mCallback.handleMessage(msg)) {
                    return;
                }
            }
            handleMessage(msg);
        }
    }

    public void handleMessage(SMessage msg) {
    }

    public final boolean post(Runnable r)
    {
        return  sendMessageDelayed(getPostMessage(r), 0);
    }

    public final boolean sendMessageDelayed(SMessage msg, long delayMillis)
    {
        if (delayMillis < 0) {
            delayMillis = 0;
        }
        return sendMessageAtTime(msg, System.currentTimeMillis() + delayMillis);
    }

    public boolean sendMessageAtTime(SMessage msg, long uptimeMillis) {
        SMessageQueue queue = mQueue;
        if (queue == null) {
            return false;
        }
        return enqueueMessage(queue, msg, uptimeMillis);
    }

    private boolean enqueueMessage(SMessageQueue queue, SMessage msg, long uptimeMillis) {
        msg.target = this;
        return queue.enqueueMessage(msg, uptimeMillis);
    }

    private static SMessage getPostMessage(Runnable r) {
        SMessage m = SMessage.obtain();
        m.callback = r;
        return m;
    }
}