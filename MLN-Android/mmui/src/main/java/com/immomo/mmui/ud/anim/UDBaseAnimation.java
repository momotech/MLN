/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.anim;

import com.immomo.mls.annotation.BridgeType;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.utils.LVCallback;
import com.immomo.mmui.anim.base.Animation;
import com.immomo.mmui.anim.base.AnimationListener;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by wang.yang on 2020/6/8.
 */
@LuaClass(abstractClass = true)
public abstract class UDBaseAnimation implements AnimationListener {

    public static final String LUA_CLASS_NAME = "BaseAnimation";
    protected Animation animation;

    private Float delay;
    private Integer repeatCount;
    private Boolean repeatForever;
    private Boolean autoReverses;

    @LuaBridge(alias = "startBlock")
    protected LVCallback startCallback;
    @LuaBridge(alias = "pauseBlock")
    protected LVCallback pauseCallback;
    @LuaBridge(alias = "resumeBlock")
    protected LVCallback resumeCallback;
    @LuaBridge(alias = "repeatBlock")
    protected LVCallback repeatCallback;
    @LuaBridge(alias = "finishBlock")
    protected LVCallback stopCallback;

    // 必须有此构造函数
    public UDBaseAnimation(Globals globals, LuaValue[] init) {

    }

    // lua虚拟机清除相关userdata时，会调用此方法，可无
    public void __onLuaGc() {
    }

    //<editor-fold desc="API">
    @LuaBridge
    public void start() {
        getAnimation();
        animation.start();
    }

    @LuaBridge
    public void pause() {
        if (animation != null) {
            animation.pause();
        }
    }

    @LuaBridge
    public void resume() {
        if (animation != null) {
            animation.resume();
        }
    }

    @LuaBridge
    public void stop() {
        if (animation != null) {
            animation.finish();
        }
    }

    public Animation getAnimation() {
        if (animation == null) {
            animation = defaultAnimation();
        }
        setParams();
        return animation;
    }

    @LuaBridge(alias = "delay", type = BridgeType.GETTER)
    public float getDelay() {
        return delay;
    }

    @LuaBridge(alias = "delay", type = BridgeType.SETTER)
    public void setDelay(float delay) {
        this.delay = delay;
    }

    @LuaBridge(alias = "autoReverses", type = BridgeType.GETTER)
    public boolean getAutoReverses() {
        return autoReverses;
    }

    @LuaBridge(alias = "autoReverses", type = BridgeType.SETTER)
    public void setAutoReverses(boolean autoReverses) {
        this.autoReverses = autoReverses;
    }

    @LuaBridge(alias = "repeatForever", type = BridgeType.GETTER)
    public boolean getRepeatForever() {
        return repeatForever;
    }

    @LuaBridge(alias = "repeatForever", type = BridgeType.SETTER)
    public void setRepeatForever(boolean repeatForever) {
        this.repeatForever = repeatForever;
    }

    @LuaBridge(alias = "repeatCount", type = BridgeType.GETTER)
    public int getRepeatCount() {
        return repeatCount;
    }

    @LuaBridge(alias = "repeatCount", type = BridgeType.SETTER)
    public void setRepeatCount(int repeatCount) {
        this.repeatCount = repeatCount;
    }

    //</editor-fold>

    protected abstract Animation defaultAnimation();

    private void setParams() {
        if (delay != null) {
            animation.setBeginTime(delay);
        }
        if (autoReverses != null) {
            animation.setAutoReverse(autoReverses);
        }
        if (repeatForever != null) {
            animation.setRepeatForever(repeatForever);
        }
        if (repeatCount != null) {
            animation.setRepeatCount(repeatCount);
        }
        if (startCallback != null || pauseCallback != null || resumeCallback != null || repeatCallback != null || stopCallback != null) {
            animation.setOnAnimationListener(this);
        }
    }

    @Override
    public void start(Animation animation) {
        if (startCallback != null) {
            startCallback.call(this);
        }
    }

    @Override
    public void pause(Animation animation) {
        if (pauseCallback != null) {
            pauseCallback.call(this);
        }
    }

    @Override
    public void resume(Animation animation) {
        if (resumeCallback != null) {
            resumeCallback.call(this);
        }
    }

    @Override
    public void finish(Animation animation, boolean finish) {
        if (stopCallback != null) {
            stopCallback.call(this, finish);
        }
    }
}