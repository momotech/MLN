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

public class SpringAnimation extends ValueAnimation {
    private float springSpeed = 12;
    private float springBounciness = 4;


    private float[] currentVelocityS;


    private float tension;
    private float friction;
    private float mass;

    public SpringAnimation(View targetView, int animProperty) {
        super(targetView, animProperty);
    }


    @Override
    public String getAnimationName() {
        return SpringAnimation.class.getSimpleName();
    }

    public void setSpringSpeed(float springSpeed) {
        this.springSpeed = springSpeed;
    }

    public void setSpringBounciness(float springBounciness) {
        this.springBounciness = springBounciness;
    }


    /**
     * currentVelocityS.length 和 from to保持一致
     *
     * @param currentVelocityS：
     */
    public void setCurrentVelocityS(float... currentVelocityS) {
        this.currentVelocityS = currentVelocityS;
    }

    public void setTension(float tension) {
        this.tension = tension;
    }

    public void setFriction(float friction) {
        this.friction = friction;
    }

    public void setMass(float mass) {
        this.mass = mass;
    }

    @Override
    public void fullAnimationParams() {
        super.fullAnimationParams();
        int count = animatable.getValuesCount();

        if (currentVelocityS == null || currentVelocityS.length != count) {
            currentVelocityS = new float[count];
            animatable.readValue(getTarget(), currentVelocityS);
        }

        Animator.getInstance().nativeSetSpringAnimationParams(getAnimationPointer(), fromValue, toValue, currentVelocityS,
                new float[]{springSpeed, springBounciness, tension, friction, mass, beginTime, repeatCount, threshold},
                repeatForever, autoReverse);
    }


}