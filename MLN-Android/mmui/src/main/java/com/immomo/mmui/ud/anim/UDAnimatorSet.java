/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.anim;

import androidx.annotation.NonNull;

import com.immomo.mmui.anim.animations.MultiAnimation;
import com.immomo.mmui.anim.base.Animation;

import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by wang.yang on 2020/6/8.
 */
@LuaApiUsed
public class UDAnimatorSet extends UDBaseAnimation {

    public static final String LUA_CLASS_NAME = "AnimatorSet";
    private List<UDAnimation> animationList = new ArrayList<>();

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public UDAnimatorSet(long L) {
        super(L);
        javaUserdata = defaultAnimation();
    }
    public static native void _init();
    public static native void _register(long l, String parent);

    @Override
    public void initPercentBehavior() {
        if (percentBehavior == null) {
            percentBehavior = new SetPercentBehavior();
        }
        percentBehavior.setAnimation(this);  // 设置相关属性信息
    }

    @Override
    protected Animation defaultAnimation() {
        return new MultiAnimation();
    }

    public List<UDAnimation> getAnimationList() {
        return animationList;
    }

    private static List<UDAnimation> toList(@NonNull LuaTable table) {
        List<UDAnimation> ret = new ArrayList<>();
        if (!table.startTraverseTable()) {
            return ret;
        }
        LuaValue[] next;
        while ((next = table.next()) != null) {
            ret.add((UDAnimation) next[1]);
        }
        table.endTraverseTable();
        table.destroy();
        return ret;
    }

    @LuaApiUsed
    public void together(LuaTable udAnimations) {
        if (udAnimations == null) {
            return;
        }
        List<UDAnimation> list = toList(udAnimations);
        animationList.clear();
        animationList.addAll(list);
        if (list.isEmpty()) {
            return;
        }
        List<Animation> animations = new ArrayList<>();
        for (UDAnimation udAnimation : list) {
            animations.add(udAnimation.getJavaUserdata());
        }
        ((MultiAnimation) javaUserdata).runTogether(animations);
    }

    @LuaApiUsed
    public void sequentially(LuaTable udAnimations) {
        if (udAnimations == null) {
            return;
        }
        List<UDAnimation> list = toList(udAnimations);
        animationList.clear();
        animationList.addAll(list);
        if (list.isEmpty()) {
            return;
        }
        List<Animation> animations = new ArrayList<>();
        for (UDAnimation udAnimation : list) {
            animations.add(udAnimation.getJavaUserdata());
        }
        ((MultiAnimation) javaUserdata).runSequentially(animations);
    }

    // 重写回调，回调的Animation为子Animation
    @Override
    public void repeat(Animation animation, int count) {
        if (repeatBlock != null) {
            UDAnimation subAnimation = getSubAnimation(animation);
            if (subAnimation != null) {
                repeatBlock.invoke(varargsOf(subAnimation, LuaNumber.valueOf(count)));
            } else {
                repeatBlock.invoke(varargsOf(this, LuaNumber.valueOf(count)));
            }
        }
    }

    private UDAnimation getSubAnimation(Animation animation) {
        UDAnimation subAnimation = null;
        if (animation != null) {
            for (UDAnimation udAnimation : animationList) {
                if (udAnimation.getJavaUserdata() == animation) {
                    subAnimation = udAnimation;
                    break;
                }
            }
        }
        return subAnimation;
    }
}