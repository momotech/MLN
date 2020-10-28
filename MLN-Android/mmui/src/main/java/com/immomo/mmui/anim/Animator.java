/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim;

import android.util.LongSparseArray;

import com.immomo.mmui.anim.animations.MultiAnimation;
import com.immomo.mmui.anim.base.Animation;

import java.util.ArrayList;
import java.util.List;


public class Animator {

    private LongSparseArray<Animation> animationArray = new LongSparseArray<>();

    public static Animator getInstance() {
        return SingleTonHolder._INSTANCE;
    }


    private static class SingleTonHolder {
        private static final Animator _INSTANCE = new Animator();
    }


    private Animator() {
        nativeInitCreateAnimator();
    }


    public long createNativeAnimation(Animation animation) {
        return Animator.getInstance().nativeCreateAnimation(animation.getAnimationName(), animation.getAnimationKey(null));
    }

    public void addAnimation(Animation animation) {

        animationArray.put(animation.getAnimationPointer(), animation);
        nativeAddAnimation(animation.getAnimationPointer());
    }

    public void removeAnimation(Animation animation) {
        removeAnimation(animation.getAnimationPointer());
    }

    private void removeAnimation(long animationPointer) {
        nativeRemoveAnimation(animationPointer);
    }

    /**
     * @param target : 动画对象
     */
    public void removeAnimationOfView(Object target) {


        List<Integer> temp = new ArrayList<>();
        for (int i = 0; i < animationArray.size(); i++) {

            Animation animation = animationArray.valueAt(i);

            if (null != animation && animation.getTarget() == target) {
                temp.add(i);
            }

            if (animation instanceof MultiAnimation) {
                List<Animation> subAnimations = ((MultiAnimation) animation).getAnimations();
                for (Animation a : subAnimations) {
                    if (a.getTarget() == target) {
                        temp.add(i);
                        break;
                    }
                }
            }

        }

        for (int index : temp) {
            Animation animation = animationArray.valueAt(index);
            if (animation != null)
                removeAnimation(animation.getAnimationPointer());
        }

    }

    static void onUpdateAnimation(long pointer) {
        //只有一级动画
        Animator.getInstance().updateValueAnimation(pointer);
    }

    static void onAnimationRelRunStart(long pointer) {
        //子动画，和multi动画都回调
        Animator.getInstance().animationStart(pointer);

    }

    static void onAnimationFinish(long pointer, boolean finish) {
        //子动画，和multi动画都回调
        Animator.getInstance().animationFinish(pointer, finish);
    }

    static void onAnimationRepeat(long caller, long executor, int count) {
        //子动画，和multi动画都回调
        Animator.getInstance().animationRepeat(caller, executor ,count);

    }

    static void onAnimationPause(long pointer, boolean paused) {
        //暂无调用
        Animator.getInstance().animationPause(pointer, paused);
    }


    private void animationStart(long animationPointer) {
        Animation animation = animationArray.get(animationPointer);
        if (animation != null)
            animation.animationStart(animation);
    }

    // 动画集合不回调整体的repeatCount，只回调子Animation的repeatCount
    private void animationRepeat(long callerPointer, long executorPointer, int count) {
        Animation animation = animationArray.get(callerPointer);
        if (animation != null) {
            if (animation instanceof MultiAnimation) {
                Animation subAnimation = getSubAnimation((MultiAnimation) animation, executorPointer);
                if (subAnimation != null) {
                    animation.animationRepeat(subAnimation, count);
                } else {
                    animation.animationRepeat(animation, count);
                }
            } else {
                animation.animationRepeat(animation, count);
            }
        }
    }

    private Animation getSubAnimation(MultiAnimation multiAnimation, long animationPointer) {
        Animation subAnimation = null;
        List<Animation> subAnimations = multiAnimation.getAnimations();
        if (subAnimations != null) {
            for (Animation animation : subAnimations) {
                if (animation.getAnimationPointer() == animationPointer) {
                    subAnimation = animation;
                    break;
                }
            }
        }
        return subAnimation;
    }

    private void animationPause(long animationPointer, boolean focusPaused) {
        Animation animation = animationArray.get(animationPointer);
        if (animation != null)
            animation.animationPaused(animation, focusPaused);
    }

    private void animationFinish(long animationPointer, boolean finished) {
        int index = animationArray.indexOfKey(animationPointer);
        Animation animation = animationArray.valueAt(index);
        animationArray.removeAt(index);
        if (animation != null) {
            animation.animationFinish(animation, finished);
            removeAnimation(animationPointer);
        }
    }

    private void updateValueAnimation(long animationPointer) {
        Animation animation = animationArray.get(animationPointer);
        if (animation != null) {
            animation.onUpdateAnimation();
        }
    }

    private native void nativeInitCreateAnimator();

    private native void nativeAddAnimation(long animation);

    private native long nativeCreateAnimation(String animationName, String key);

    public native long[] nativeGetMultiAnimationRunningList(long animation);

    public native float[] nativeGetCurrentValues(long animation);

    public native void nativeSetObjectAnimationParams(long aniPoint, float[] f, float[] t, float[] fParams, boolean repeatForever, boolean autoReverse, int timingFunction);

    public native void nativeSetMultiAnimationParams(long aniPoint, long[] subAniPoints, boolean isRunTogether);
    public native void nativeSetMultiAnimationBeginTime(long aniPoint, float beginTime);
    public native void nativeSetMultiAnimationRepeatCount(long aniPoint, float repeatCount);
    public native void nativeSetMultiAnimationRepeatForever(long aniPoint, boolean repeatForever);
    public native void nativeSetMultiAnimationAutoReverse(long aniPoint, boolean autoReverse);

    public native void nativeSetSpringAnimationParams(long aniPoint, float[] f, float[] t, float[] currentVelocity, float[] fParams, boolean repeatForever, boolean autoReverse);

    private native void nativeRemoveAnimation(long aniPointer);

    public native void nativeAnimatorRelease();

    public native void nativePause(long animationP, boolean b);


}