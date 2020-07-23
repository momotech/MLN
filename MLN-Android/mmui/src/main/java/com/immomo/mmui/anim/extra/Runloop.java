/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.extra;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.os.Message;


import androidx.annotation.NonNull;

import com.immomo.mmui.anim.Animator;

public class Runloop {

    private static final int MSG_RUN_LOOP = 1;
    private Handler mHandler;
    private boolean isLoopStart = false;
    private static final long I = 1000 / 60;

    private static class SingleTonHolder {
        private static final Runloop _INSTANCE = new Runloop();
    }


    @SuppressLint("HandlerLeak")
    private Runloop() {
        mHandler = new Handler() {
            @Override
            public void handleMessage(@NonNull Message msg) {
                if (msg.what == MSG_RUN_LOOP) {
                    if (isLoopStart) {
                        long timeMillis = System.currentTimeMillis();
                        nativeRunLoop(timeMillis);
                        long execTimeMillis = System.currentTimeMillis() - timeMillis;
                        if (timeMillis >= I) {
                            mHandler.sendEmptyMessageDelayed(MSG_RUN_LOOP, 0);
                        } else {
                            mHandler.sendEmptyMessageDelayed(MSG_RUN_LOOP, I - execTimeMillis);
                        }
                    }
                } else {
                    isLoopStart = false;
                }

            }
        };
    }

    private void startInnerLoop() {
        if (!isLoopStart) {
            isLoopStart = true;
            mHandler.sendEmptyMessageDelayed(MSG_RUN_LOOP, I);
        }
    }

    private static Runloop getShareLoop() {
        return SingleTonHolder._INSTANCE;
    }

    public static void startLoop() {
        Runloop.getShareLoop().startInnerLoop();
    }

    public static void stopLoop() {
        Runloop.getShareLoop().isLoopStart = false;

        Animator.getInstance().nativeAnimatorRelease();

    }

    public static long currentTime() {
        return System.currentTimeMillis();
    }

    public native void nativeRunLoop(long currentTime);

}