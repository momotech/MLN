/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.lt;

import android.content.Context;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.utils.LVCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by fanqiang on 2018/9/28.
 */
@LuaClass(name = "Vibrate", isSingleton = true)
public class SIVibrate {

    public static final String LUA_CLASS_NAME = "Vibrate";
    private Vibrator vibrator;

    private Globals globals;

    public SIVibrate(Globals globals, LuaValue[] init) {
        this.globals = globals;
        Context context = MLSEngine.getContext() == null ? getContext().getApplicationContext() : MLSEngine.getContext();
        try {
            vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        } catch (Exception ignored) {
        }
    }

    public void __onLuaGc() {
        try {
            if (vibrator != null && vibrator.hasVibrator()) vibrator.cancel();
        } catch (Exception ignored) {
        }

    }

    protected Context getContext() {
        return ((LuaViewManager) globals.getJavaUserdata()).context;
    }

    //<editor-fold desc="API">
    @LuaBridge
    public void vibrate(int style, float amplitude) {

    }

    @LuaBridge
    public void musicWithVibrate(String filePath, LVCallback callback) {

    }

    @LuaBridge
    public void i_popVibrate() {
        try {
            if (vibrator != null && vibrator.hasVibrator()) vibrator.vibrate(300);
        } catch (Exception ignored) {
        }
    }

    @LuaBridge
    public void i_normalVibrate() {
        try {

            if (vibrator != null && vibrator.hasVibrator()) vibrator.vibrate(1000);
        } catch (Exception ignored) {
        }
    }


    @LuaBridge
    public void i_peekVibrate() {
        try {

            if (vibrator != null && vibrator.hasVibrator()) vibrator.vibrate(3000);
        } catch (Exception ignored) {
        }
    }


    @LuaBridge
    public void i_trupleVibrate() {
        try {
            if (vibrator != null && vibrator.hasVibrator()) {
                long[] pattern = {0, 300, 200, 300, 200, 300};
                vibrator.vibrate(pattern, -1);
            }
        } catch (Exception ignored) {
        }

    }

    @LuaBridge
    public void i_vibrate(long timemills) {
        try {
            if (vibrator != null && vibrator.hasVibrator()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    // 震动强度必须为 1-255 的一个值
                    int amplitude = VibrationEffect.DEFAULT_AMPLITUDE;
                    VibrationEffect vibrationEffect = VibrationEffect.createOneShot(timemills, amplitude);
                    vibrator.vibrate(vibrationEffect);
                } else {
                    vibrator.vibrate(timemills);
                }
            }
        } catch (Exception ignored) {
        }
    }

    //</editor-fold>
}