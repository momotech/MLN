/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.anim;

import com.immomo.mmui.anim.base.Animation;
import com.immomo.mmui.anim.base.AnimationListener;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by wang.yang on 2020/6/8.
 */
@LuaApiUsed
public abstract class UDBaseAnimation extends LuaUserdata<Animation> implements AnimationListener {

    public static final String LUA_CLASS_NAME = "_BaseAnimation";

    protected PercentBehavior percentBehavior;

    private Float delay;
    private Integer repeatCount;
    private Boolean repeatForever;
    private Boolean autoReverses;

    protected LuaFunction startBlock;
    protected LuaFunction pauseBlock;
    protected LuaFunction resumeBlock;
    protected LuaFunction repeatBlock;
    protected LuaFunction finishBlock;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDBaseAnimation(long L) {
        super(L, null);
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    // lua虚拟机清除相关userdata时，会调用此方法，可无
    @Override
    protected void __onLuaGc() {
        // 清理lua回调
        if (startBlock != null) {
            startBlock.destroy();
            startBlock = null;
        }
        if (pauseBlock != null) {
            pauseBlock.destroy();
            pauseBlock = null;
        }
        if (resumeBlock != null) {
            resumeBlock.destroy();
            resumeBlock = null;
        }
        if (repeatBlock != null) {
            repeatBlock.destroy();
            repeatBlock = null;
        }
        if (finishBlock != null) {
            finishBlock.destroy();
            finishBlock = null;
        }
        super.__onLuaGc();
    }

    protected abstract Animation defaultAnimation();

    protected void initPercentBehavior() {
        if (percentBehavior == null) {
            percentBehavior = new PercentBehavior();
        }
        percentBehavior.setAnimation(this);  // 设置相关属性信息
    }

    public PercentBehavior getPercentBehavior() {
        if (percentBehavior == null)
            initPercentBehavior();
        return percentBehavior;
    }

    //<editor-fold desc="API">

    //<editor-fold desc="Blocks">
    @LuaApiUsed
    public LuaFunction getStartBlock() {
        return startBlock;
    }

    @LuaApiUsed
    public void setStartBlock(LuaFunction startBlock) {
        this.startBlock = startBlock;
    }

    @LuaApiUsed
    public LuaFunction getPauseBlock() {
        return pauseBlock;
    }

    @LuaApiUsed
    public void setPauseBlock(LuaFunction pauseBlock) {
        this.pauseBlock = pauseBlock;
    }

    @LuaApiUsed
    public LuaFunction getResumeBlock() {
        return resumeBlock;
    }

    @LuaApiUsed
    public void setResumeBlock(LuaFunction resumeBlock) {
        this.resumeBlock = resumeBlock;
    }

    @LuaApiUsed
    public LuaFunction getRepeatBlock() {
        return repeatBlock;
    }

    @LuaApiUsed
    public void setRepeatBlock(LuaFunction repeatBlock) {
        this.repeatBlock = repeatBlock;
    }

    @LuaApiUsed
    public LuaFunction getFinishBlock() {
        return finishBlock;
    }

    @LuaApiUsed
    public void setFinishBlock(LuaFunction finishBlock) {
        this.finishBlock = finishBlock;
    }
    //</editor-fold>

    @LuaApiUsed
    public void update(float percent) {
        initPercentBehavior();
        percentBehavior.update(percent);
    }

    @LuaApiUsed
    public void start() {
        getJavaUserdata();
        javaUserdata.start();
    }

    @LuaApiUsed
    public void pause() {
        if (javaUserdata != null)
            javaUserdata.pause();
    }

    @LuaApiUsed
    public void resume() {
        if (javaUserdata != null)
        javaUserdata.resume();
    }

    @LuaApiUsed
    public void stop() {
        if (javaUserdata != null)
        javaUserdata.finish();
    }

    @Override
    public Animation getJavaUserdata() {
        if (javaUserdata == null)
            javaUserdata = defaultAnimation();
        setParams();
        return javaUserdata;
    }

    @LuaApiUsed
    public float getDelay() {
        return delay;
    }

    @LuaApiUsed
    public void setDelay(float delay) {
        this.delay = delay;
    }

    @LuaApiUsed
    public boolean isAutoReverses() {
        return autoReverses;
    }

    @LuaApiUsed
    public void setAutoReverses(boolean autoReverses) {
        this.autoReverses = autoReverses;
    }

    @LuaApiUsed
    public boolean isRepeatForever() {
        return repeatForever;
    }

    @LuaApiUsed
    public void setRepeatForever(boolean repeatForever) {
        this.repeatForever = repeatForever;
    }

    @LuaApiUsed
    public int getRepeatCount() {
        return repeatCount;
    }

    @LuaApiUsed
    public void setRepeatCount(int repeatCount) {
        this.repeatCount = repeatCount;
    }

    //</editor-fold>

    private void setParams() {
        if (delay != null) {
            javaUserdata.setBeginTime(delay);
        }
        if (autoReverses != null) {
            javaUserdata.setAutoReverse(autoReverses);
        }
        if (repeatForever != null) {
            javaUserdata.setRepeatForever(repeatForever);
        }
        if (repeatCount != null) {
            javaUserdata.setRepeatCount(repeatCount);
        }
        if (startBlock != null || pauseBlock != null || resumeBlock != null || repeatBlock != null || finishBlock != null) {
            javaUserdata.setOnAnimationListener(this);
        }
    }

    @Override
    public void start(Animation animation) {
        if (startBlock != null) {
            startBlock.fastInvoke(this);
        }
    }

    @Override
    public void pause(Animation animation) {
        if (pauseBlock != null) {
            pauseBlock.fastInvoke(this);
        }
    }

    @Override
    public void resume(Animation animation) {
        if (resumeBlock != null) {
            resumeBlock.fastInvoke(this);
        }
    }

    @Override
    public void finish(Animation animation, boolean finish) {
        if (finishBlock != null) {
            finishBlock.invoke(varargsOf(this, finish ? True() : False()));
        }
    }
}