/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.animations;


import com.immomo.mmui.anim.Animator;
import com.immomo.mmui.anim.base.Animation;

import java.util.List;

public class MultiAnimation extends Animation {


    private List<Animation> animations;
    private long[] pointers;
    private boolean isRunTogether = true;

    public MultiAnimation() {
        super(null);
        // 不能有默认值
        beginTime = null;
        repeatCount = null;
        repeatForever = null;
        autoReverse = null;
    }

    public List<Animation> getAnimations() {
        return animations;
    }

    public void runTogether(List<Animation> animations) {
        this.animations = animations;
        isRunTogether = true;

    }

    public void runSequentially(List<Animation> animations) {
        this.animations = animations;
        isRunTogether = false;
    }

    public boolean isRunTogether() {
        return isRunTogether;
    }

    @Override
    public String getAnimationName() {
        return MultiAnimation.class.getSimpleName();
    }

    @Override
    public void fullAnimationParams() {
        if (animations != null) {
            pointers = new long[animations.size()];

            for (int i = 0; i < animations.size(); i++) {
                Animation animation = animations.get(i);
                pointers[i] = animation.getAnimationPointer();
                animation.fullAnimationParams();
            }

            Animator.getInstance().nativeSetMultiAnimationParams(getAnimationPointer(), pointers, isRunTogether);
            if (beginTime != null) {
                Animator.getInstance().nativeSetMultiAnimationBeginTime(getAnimationPointer(), beginTime);
            }
            if (repeatCount != null) {
                Animator.getInstance().nativeSetMultiAnimationRepeatCount(getAnimationPointer(), repeatCount);
            }
            if (repeatForever != null) {
                Animator.getInstance().nativeSetMultiAnimationRepeatForever(getAnimationPointer(), repeatForever);
            }
            if (autoReverse != null) {
                Animator.getInstance().nativeSetMultiAnimationAutoReverse(getAnimationPointer(), autoReverse);
            }
        }

    }

    @Override
    public void onUpdateAnimation() {
        if (animations != null) {
            long[] pointers = Animator.getInstance().nativeGetMultiAnimationRunningList(getAnimationPointer());
            if (null != pointers)
                for (long p : pointers) {
                    for (Animation animation : animations) {
                        if (p == animation.getAnimationPointer())
                            animation.onUpdateAnimation();
                    }
                }
        }
    }

    @Override
    public void reset() {
        if (animations != null) {
            for (int i = 0; i < animations.size(); i++) {
                Animation animation = animations.get(i);
                animation.reset();
            }
        }
    }

    @Override
    public void onAnimationStart() {
        if (animations != null) {
            for (int i = 0; i < animations.size(); i++) {
                Animation animation = animations.get(i);
                animation.onAnimationStart();
            }
        }
    }

    @Override
    public void onAnimationFinish() {
        if (animations != null) {
            for (int i = 0; i < animations.size(); i++) {
                Animation animation = animations.get(i);
                animation.onAnimationFinish();
            }
        }
    }


}