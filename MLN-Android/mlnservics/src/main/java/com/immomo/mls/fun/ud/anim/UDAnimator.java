/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim;

import android.animation.Animator;
import android.animation.ValueAnimator;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.utils.LVCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

@LuaClass
public class UDAnimator implements ValueAnimator.AnimatorUpdateListener, Animator.AnimatorListener {
    public static final String LUA_CLASS_NAME = "Animator";

    private final ValueAnimator mAnimator;

    private LVCallback
            startCallback,
            stopCallback,
            cancelCallback,
            repeatCallback,
            updateCallback;

    public UDAnimator(Globals globals, LuaValue[] varargs) {
        mAnimator = new ValueAnimator();
        init();
    }

    public UDAnimator(ValueAnimator animator) {
        mAnimator = animator;
        init();
    }

    private void init() {
        mAnimator.addUpdateListener(this);
        mAnimator.setInterpolator(Utils.linear);
        mAnimator.addListener(this);
        mAnimator.setFloatValues(0, 1);
    }

    //<editor-fold desc="API">
    @LuaBridge
    public void setRepeat(@RepeatType.RepeatMode int type, int count) {

        switch (type) {
            case RepeatType.NONE:
                count = 0;
                break;

            case RepeatType.REVERSE:
                count = 2 * count - 1;
                break;

            case RepeatType.FROM_START:
                if (count >= 1)
                    count = count - 1;
                break;
        }

        mAnimator.setRepeatCount(count);
        mAnimator.setRepeatMode(type);
    }

    @LuaBridge
    public void setDuration(float duration) {
        mAnimator.setDuration((long) (duration * 1000));
    }

    @LuaBridge
    public void setDelay(float delay) {
        mAnimator.setStartDelay((long) (delay * 1000));
    }

    @LuaBridge
    public void start() {
        mAnimator.start();
    }

    @LuaBridge
    public void stop() {
        mAnimator.end();
    }

    @LuaBridge
    public void cancel() {
        mAnimator.cancel();
    }

    @LuaBridge
    public void setStartCallback(LVCallback startCallback) {
        if (this.startCallback != null)
            this.startCallback.destroy();
        this.startCallback = startCallback;
    }

    @LuaBridge
    public void setStopCallback(LVCallback endCallback) {
        if (this.stopCallback != null)
            this.stopCallback.destroy();
        this.stopCallback = endCallback;
    }

    @LuaBridge
    public void setCancelCallback(LVCallback cancelCallback) {
        if (this.cancelCallback != null)
            this.cancelCallback.destroy();
        this.cancelCallback = cancelCallback;
    }

    @LuaBridge
    public void setRepeatCallback(LVCallback repeatCallback) {
        if (this.repeatCallback != null)
            this.repeatCallback.destroy();
        this.repeatCallback = repeatCallback;
    }

    @LuaBridge
    public void setOnAnimationUpdateCallback(LVCallback updateCallback) {
        if (this.updateCallback != null)
            this.updateCallback.destroy();
        this.updateCallback = updateCallback;
    }

    @LuaBridge
    public boolean isRunning() {
        return mAnimator.isRunning();
    }

    @LuaBridge
    public UDAnimator clone() {
        Animator animator = new ValueAnimator();
        ((ValueAnimator) animator).setRepeatCount(mAnimator.getRepeatCount());
        ((ValueAnimator) animator).setRepeatMode(mAnimator.getRepeatMode());
        animator.setDuration(mAnimator.getDuration());
        animator.setStartDelay(mAnimator.getStartDelay());
        return new UDAnimator((ValueAnimator) animator);
    }

    //</editor-fold>

    //<editor-fold desc="AnimatorUpdateListener">
    @Override
    public void onAnimationUpdate(ValueAnimator animation) {

        float value = (float) animation.getAnimatedValue();

        if (updateCallback != null) {
            updateCallback.call(value);
        }
    }
    //</editor-fold>

    //<editor-fold desc="AnimatorListener">
    @Override
    public void onAnimationStart(Animator animation) {
        if (startCallback != null)
            startCallback.call();
    }

    /**
     * 动画结束，isCancel标记动画是否完整执行,回调true
     *
     * @param animation
     */
    @Override
    public void onAnimationEnd(Animator animation) {
        if (stopCallback != null)
            stopCallback.call();

    }

    @Override
    public void onAnimationCancel(Animator animation) {
        if (cancelCallback != null)
            cancelCallback.call();
    }

    @Override
    public void onAnimationRepeat(Animator animation) {
        if (repeatCallback != null)
            repeatCallback.call();
    }
    //</editor-fold>

    public void __onLuaGc() {
        if (startCallback != null)
            startCallback.destroy();
        if (stopCallback != null)
            stopCallback.destroy();
        if (cancelCallback != null)
            cancelCallback.destroy();
        if (repeatCallback != null)
            repeatCallback.destroy();

        startCallback = null;
        stopCallback = null;
        cancelCallback = null;
        repeatCallback = null;
        mAnimator.cancel();
    }
}