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
import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.functions.Function1;

@LuaClass
public class UDAnimator extends ValueAnimator implements ValueAnimator.AnimatorUpdateListener, Animator.AnimatorListener {
    public static final String LUA_CLASS_NAME = "Animator";

    private LVCallback
            startCallback,
            stopCallback,
            cancelCallback,
            repeatCallback,
            updateCallback;

    public UDAnimator() {
        init();
    }

    private void init() {
        this.addUpdateListener(this);
        this.setInterpolator(Utils.linear);
        this.addListener(this);
        this.setFloatValues(0, 1);
    }

    //<editor-fold desc="API">
    @LuaBridge
    public void setRepeat(@RepeatType.RepeatMode int type, int count) {
        if (RepeatType.NONE == type) {
            count = 0;
        }
        if (count < 0)
            count = INFINITE;
        this.setRepeatCount(count);
        this.setRepeatMode(type);
    }

    @LuaBridge
    public void setDuration(float duration) {
        this.setDuration((long) (duration * 1000));
    }

    @LuaBridge
    public void setDelay(float delay) {
        this.setStartDelay((long) (delay * 1000));
    }

    @LuaBridge
    public void start() {
        if (super.isRunning()) {
            return;
        }
        super.start();
    }

    @LuaBridge
    public void stop() {
        if (!isStarted())
            return;
        this.end();
    }

    @LuaBridge
    public void cancel() {
        super.cancel();
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Function0.class, typeArgs = {Unit.class})})
    })
    public void setStartCallback(LVCallback startCallback) {
        if (this.startCallback != null)
            this.startCallback.destroy();
        this.startCallback = startCallback;
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Function0.class, typeArgs = {Unit.class})})
    })
    public void setStopCallback(LVCallback endCallback) {
        if (this.stopCallback != null)
            this.stopCallback.destroy();
        this.stopCallback = endCallback;
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Function0.class, typeArgs = {Unit.class})})
    })
    public void setCancelCallback(LVCallback cancelCallback) {
        if (this.cancelCallback != null)
            this.cancelCallback.destroy();
        this.cancelCallback = cancelCallback;
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Function0.class, typeArgs = {Unit.class})})
    })
    public void setRepeatCallback(LVCallback repeatCallback) {
        if (this.repeatCallback != null)
            this.repeatCallback.destroy();
        this.repeatCallback = repeatCallback;
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Function1.class, typeArgs = {Float.class, Unit.class})})
    })
    public void setOnAnimationUpdateCallback(LVCallback updateCallback) {
        if (this.updateCallback != null)
            this.updateCallback.destroy();
        this.updateCallback = updateCallback;
    }

    @LuaBridge
    public boolean isRunning() {
        return super.isRunning();
    }

    @LuaBridge
    public UDAnimator clone() {
        UDAnimator animator = new UDAnimator();
        animator.setRepeatCount(this.getRepeatCount());
        animator.setRepeatMode(this.getRepeatMode());
        animator.setDuration(this.getDuration());
        animator.setStartDelay(this.getStartDelay());
        return animator;
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
        this.cancel();
    }
}