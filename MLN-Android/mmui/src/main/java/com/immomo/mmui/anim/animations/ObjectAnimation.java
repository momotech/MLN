/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.animations;

import android.view.View;

import com.immomo.mmui.anim.Animator;
import com.immomo.mmui.anim.animatable.Animatable;

public class ObjectAnimation extends ValueAnimation {

    private float duration;


    private TimingFunction timingFunction = TimingFunction.LINEAR;

    public ObjectAnimation(View targetView, int animProperty) {
        super(targetView, animProperty);
    }

    @Override
    public String getAnimationName() {
        return ObjectAnimation.class.getSimpleName();
    }

    /**
     * @param duration:秒
     */
    public void setDuration(float duration) {
        this.duration = duration;
    }

    public void setTimingFunction(TimingFunction timingFunction) {
        this.timingFunction = timingFunction;
    }


    @Override
    public void fullAnimationParams() {
        super.fullAnimationParams();
        Animator.getInstance().nativeSetObjectAnimationParams(getAnimationPointer(), fromValue, toValue,
                new float[]{beginTime, duration, repeatCount, threshold},
                repeatForever, autoReverse, timingFunction.ordinal());
    }
}