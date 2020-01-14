/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim.canvasanim;

import android.view.animation.Animation;
import android.view.animation.AnimationSet;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2019-05-28
 */
@LuaClass
public class UDAnimationSet extends UDBaseAnimation {
    public static final String LUA_CLASS_NAME = "AnimationSet";

    private final AnimationSet animationSet;

    private final boolean shareInterpolator;

    private final List<UDBaseAnimation> animations;

    public UDAnimationSet(Globals g, LuaValue[] init) {
        super(g, init);
        if (init != null && init.length == 1) {
            shareInterpolator = init[0].toBoolean();
        } else {
            shareInterpolator = false;
        }
        animationSet = new AnimationSet(shareInterpolator);
        animations = new ArrayList<>();
    }

    private UDAnimationSet(Globals g, UDAnimationSet src) {
        super(g, null);
        shareInterpolator = src.shareInterpolator;
        animationSet = new AnimationSet(shareInterpolator);
        animations = new ArrayList<>(src.animations.size());
        for (UDBaseAnimation uda : src.animations) {
            addAnimation(uda.clone());
        }
    }

    //<editor-fold desc="api">
    @LuaBridge
    public void addAnimation(UDBaseAnimation animation) {
        animations.add(animation);
        animationSet.addAnimation(animation.getAnimation());
    }
    //</editor-fold>

    @Override
    public Animation getAnimation() {
        cancelCalled = false;
        if (animation == null) {
            animation = build();
        }

        animation.setRepeatMode(repeatMode);
        animation.setRepeatCount(repeatCount);
        animation.setFillAfter(!autoBack);
        animation.setFillEnabled(false);
        animation.setFillBefore(false);
        animation.setInterpolator(interpolator);
        animation.setStartOffset(delay);
        animation.setAnimationListener(this);
        return animation;
    }

    @Override
    protected Animation build() {
        return animationSet;
    }

    @Override
    protected UDAnimationSet cloneObj() {
        return new UDAnimationSet(globals, this);
    }

    @Override
    public void cancel() {
        for (UDBaseAnimation child : animations) {
            child.cancel();
        }
        super.cancel();
    }
}