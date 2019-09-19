/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim.canvasanim;

import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.Interpolator;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.ud.anim.RepeatType;
import com.immomo.mls.fun.ud.anim.Utils;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.utils.LVCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-05-27
 */
@LuaClass(abstractClass = true)
public abstract class UDBaseAnimation implements Animation.AnimationListener {
    public static final String LUA_CLASS_NAME = "__CanvasAnimation";

    protected Globals globals;

    protected @RepeatType.RepeatMode
    int repeatMode;

    protected int repeatCount = 0;

    protected boolean autoBack = false;

    protected int duration;

    protected int delay;

    protected Interpolator interpolator;

    protected LVCallback startCallback;
    protected LVCallback endCallback;
    protected LVCallback repeatCallback;

    protected Animation animation;

    public UDBaseAnimation(Globals g, LuaValue[] init) {
        globals = g;
    }

    public void __onLuaGc() {
        if (startCallback != null)
            startCallback.destroy();
        if (endCallback != null)
            endCallback.destroy();
        if (repeatCallback != null)
            repeatCallback.destroy();
        startCallback = null;
        endCallback = null;
        repeatCallback = null;
    }

    //<editor-fold desc="Api">

    @LuaBridge
    public void setRepeat(@RepeatType.RepeatMode int type, int count) {
        repeatMode = type;
        if (type == RepeatType.NONE) count = 0;
        repeatCount = count;
    }

    @LuaBridge
    public void setAutoBack(boolean auto) {
        autoBack = auto;
    }

    @LuaBridge
    public void setDuration(double d) {
        duration = (int) (d * 1000);
    }

    @LuaBridge
    public void setDelay(double d) {
        delay= (int) (d * 1000);
    }

    @LuaBridge
    public void setInterpolator(int type) {
        interpolator = Utils.parse(type);
    }

    @LuaBridge
    public void cancel() {
        if (animation != null)
            animation.cancel();
    }

    @LuaBridge
    public void setStartCallback(LVCallback callback) {
        if (startCallback != null)
            startCallback.destroy();
        startCallback = callback;
    }

    @LuaBridge
    public void setEndCallback(LVCallback callback) {
        if (endCallback != null)
            endCallback.destroy();
        endCallback = callback;
    }

    @LuaBridge
    public void setRepeatCallback(LVCallback callback) {
        if (repeatCallback != null)
            repeatCallback.destroy();
        repeatCallback = callback;
    }

    @LuaBridge
    public UDBaseAnimation clone() {
        UDBaseAnimation anim = cloneObj();
        anim.repeatMode = repeatMode;
        anim.repeatCount = repeatCount;
        anim.autoBack = autoBack;
        anim.duration = duration;
        anim.delay = delay;
        anim.interpolator = interpolator;
        return anim;
    }
    //</editor-fold>

    @Override
    public void onAnimationStart(Animation animation) {
        if (startCallback != null)
            startCallback.call();
    }

    @Override
    public void onAnimationEnd(Animation animation) {
        if (endCallback != null)
            endCallback.call(true);
    }

    @Override
    public void onAnimationRepeat(Animation animation) {
        if (repeatCallback != null)
            repeatCallback.call();
    }

    public Animation getAnimation() {
        if (animation != null) {
            animation.reset();
            if (delay != 0)
                animation.setStartTime(AnimationUtils.currentAnimationTimeMillis() + delay);
            else
                animation.setStartTime(Animation.START_ON_FIRST_FRAME);
            return animation;
        }
        Animation anim = build();
        animation = anim;
        anim.setRepeatMode(repeatMode);
        anim.setRepeatCount(repeatCount);
        anim.setFillAfter(!autoBack);
        anim.setInterpolator(interpolator);
        anim.setDuration(duration);
        if (delay != 0)
            anim.setStartTime(AnimationUtils.currentAnimationTimeMillis() + delay);
        else
            anim.setStartTime(Animation.START_ON_FIRST_FRAME);
        anim.setAnimationListener(this);
        return anim;
    }

    protected static float getRealValue(int type, float value) {
        return type == AnimationValueType.ABSOLUTE ? DimenUtil.dpiToPx(value) : value;
    }

    protected abstract Animation build();

    protected abstract UDBaseAnimation cloneObj();
}