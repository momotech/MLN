/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.base;

import android.view.View;

import com.immomo.mmui.anim.Animator;

public abstract class Animation {

    public enum TimingFunction {
        DEFAULT,
        LINEAR,
        EASEIN,
        EASEOUT,
        EASEINOUT,
    }


    private long mAnimationPointer;
    private View mTarget;

    protected Float beginTime = 0f;
    protected Integer repeatCount = 0;

    protected Boolean repeatForever = false;
    protected Boolean autoReverse = false;

    protected AnimationListener animationListener;


    public Animation(View targetView) {
        mTarget = targetView;
    }


    public void setBeginTime(Float beginTime) {
        this.beginTime = beginTime;
    }

    public void setRepeatForever(Boolean repeatForever) {
        this.repeatForever = repeatForever;
    }

    public void setAutoReverse(Boolean autoReverse) {
        this.autoReverse = autoReverse;
    }

    public void setRepeatCount(Integer count) {
        this.repeatCount = count;
    }


    public void start() {
        getAnimationPointer();
        fullAnimationParams();
        Animator.getInstance().addAnimation(this);
    }

    public void finish() {
        if (mAnimationPointer != 0)
            Animator.getInstance().removeAnimation(this);
    }

    public void pause() {
        if (mAnimationPointer != 0)
            Animator.getInstance().nativePause(mAnimationPointer, true);
    }

    public void resume() {
        if (mAnimationPointer != 0)
            Animator.getInstance().nativePause(mAnimationPointer, false);
    }

    public View getTarget() {
        return mTarget;
    }

    public long getAnimationPointer() {
        if (mAnimationPointer == 0) {
            mAnimationPointer = Animator.getInstance().createNativeAnimation(this);
        }
        return mAnimationPointer;
    }

    public String getAnimationKey(String key) {
        return getAnimationName() + (key == null ? "" : key) + hashCode();
    }


    public abstract String getAnimationName();

    public abstract void fullAnimationParams();

    public abstract void onUpdateAnimation();

    public abstract void reset();

    public abstract void onAnimationStart();

    public abstract void onAnimationFinish();

    public void setOnAnimationListener(AnimationListener animationListener) {
        this.animationListener = animationListener;
    }

    public void animationFinish(Animation animation, boolean finished) {
        onAnimationFinish();
        if (null != animationListener) {
            animationListener.finish(animation, finished);
        }
    }


    public void animationRepeat(Animation animation, int count) {
        animation.reset();

        if (null != animationListener) {
            animationListener.repeat(animation, count);
        }
    }


    public void animationPaused(Animation animation, boolean focusPaused) {
        if (null != animationListener) {
            if (focusPaused)
                animationListener.pause(animation);
            else
                animationListener.resume(animation);

        }
    }

    public void animationStart(Animation animation) {
        onAnimationStart();
        if (null != animationListener) {
            animationListener.start(animation);
        }
    }

}