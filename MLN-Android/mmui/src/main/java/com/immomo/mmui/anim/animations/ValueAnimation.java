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
import com.immomo.mmui.anim.base.Animation;
import com.immomo.mmui.anim.base.AnimationUpdateListener;
import com.immomo.mmui.anim.base.AnimatableFactory;
import com.immomo.mmui.anim.utils.ColorUtil;


public abstract class ValueAnimation extends Animation {

    protected Animatable animatable;
    private AnimationUpdateListener animationUpdateListener;

    float[] fromValue;
    float[] toValue;

    float threshold = 1.0f;


    public ValueAnimation(View targetView, int animProperty) {
        super(targetView);
        animatable = AnimatableFactory.getAnimatable(animProperty);
    }


    public void setFromValue(float... fromValue) {
        this.fromValue = fromValue;

    }

    public void setToValue(float... toValue) {
        this.toValue = toValue;

    }

    public Animatable getAnimatable() {
        return animatable;
    }

    public float[] getFromValue() {
        return fromValue;
    }

    public float[] getToValue() {
        return toValue;
    }

    public void setColorToValue(int toColor) {
        this.toValue = ColorUtil.colorToArray(toColor);
    }

    public void setColorFromValue(int fromColor) {
        this.fromValue = ColorUtil.colorToArray(fromColor);
    }

    public void setOnAnimationUpdateListener(AnimationUpdateListener animationUpdateListener) {
        this.animationUpdateListener = animationUpdateListener;
    }


    @Override
    public void fullAnimationParams() {
        int count = animatable.getValuesCount();
        if (fromValue == null || fromValue.length != count) {
            fromValue = new float[count];
            animatable.readValue(getTarget(), fromValue);
        }

        if (toValue == null || toValue.length != count) {
            toValue = new float[count];
            animatable.readValue(getTarget(), toValue);
        }
        threshold = animatable.getThreshold();
    }


    @Override
    public void reset() {
        float[] values = Animator.getInstance().nativeGetCurrentValues(getAnimationPointer());
        if (values != null) {
            if (null != animatable)
                animatable.writeValue(getTarget(), values);
        }
    }

    @Override
    public void onUpdateAnimation() {
        float[] values = Animator.getInstance().nativeGetCurrentValues(getAnimationPointer());
        if (values != null) {
            if (null != animatable)
                animatable.writeValue(getTarget(), values);

            if (animationUpdateListener != null) {
                animationUpdateListener.updateAnimation(this, values);
            }
        }
    }

    @Override
    public void onAnimationStart() {
        if (null != animatable)
            animatable.beforeDoValue(getTarget());
    }

    @Override
    public void onAnimationFinish() {
        if (null != animatable)
            animatable.afterDoValue(getTarget());
    }
}