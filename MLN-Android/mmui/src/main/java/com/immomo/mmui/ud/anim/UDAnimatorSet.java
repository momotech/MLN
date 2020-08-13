/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.anim;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.utils.convert.ConvertUtils;
import com.immomo.mmui.anim.animations.MultiAnimation;
import com.immomo.mmui.anim.base.Animation;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by wang.yang on 2020/6/8.
 */
@LuaClass
public class UDAnimatorSet extends UDBaseAnimation {

    public static final String LUA_CLASS_NAME = "AnimatorSet";
    private List<UDAnimation> animationList = new ArrayList<>();
    private SetPercentBehavior percentBehavior;

    // 必须有此构造函数
    public UDAnimatorSet(Globals globals, LuaValue[] init) {
        super(globals, init);
        animation = new MultiAnimation();
    }

    // lua虚拟机清除相关userdata时，会调用此方法，可无
    public void __onLuaGc() {
    }

    @Override
    protected Animation defaultAnimation() {
        return new MultiAnimation();
    }


    @LuaBridge
    public void together(LuaTable udAnimations) {
        if (udAnimations == null) {
            return;
        }
        List<UDAnimation> list = ConvertUtils.toList(udAnimations);
        animationList.clear();
        animationList.addAll(list);
        if (list.isEmpty()) {
            return;
        }
        List<Animation> animations = new ArrayList<>();
        for (UDAnimation udAnimation : list) {
            animations.add(udAnimation.getAnimation());
        }
        ((MultiAnimation) animation).runTogether(animations);
    }

    @LuaBridge
    public void sequentially(LuaTable udAnimations) {
        if (udAnimations == null) {
            return;
        }
        List<UDAnimation> list = ConvertUtils.toList(udAnimations);
        animationList.clear();
        animationList.addAll(list);
        if (list.isEmpty()) {
            return;
        }
        List<Animation> animations = new ArrayList<>();
        for (UDAnimation udAnimation : list) {
            animations.add(udAnimation.getAnimation());
        }
        ((MultiAnimation) animation).runSequentially(animations);
    }

    // 重写回调，回调的Animation为子Animation
    @Override
    public void repeat(Animation animation, int count) {
        if (repeatCallback != null) {
            UDAnimation subAnimation = getSubAnimation(animation);
            if (subAnimation != null) {
                repeatCallback.call(subAnimation, count);
            } else {
                repeatCallback.call(this, count);
            }
        }
    }

    private UDAnimation getSubAnimation(Animation animation) {
        UDAnimation subAnimation = null;
        if (animation != null) {
            for (UDAnimation udAnimation : animationList) {
                if (udAnimation.getAnimation() == animation) {
                    subAnimation = udAnimation;
                    break;
                }
            }
        }
        return subAnimation;
    }

    @LuaBridge
    public void update(float percent) {
        if (percentBehavior == null) {
            percentBehavior = new SetPercentBehavior();
        }
        percentBehavior.setAnimation((MultiAnimation) getAnimation());  // 设置相关属性信息
        percentBehavior.update(percent);
    }
}