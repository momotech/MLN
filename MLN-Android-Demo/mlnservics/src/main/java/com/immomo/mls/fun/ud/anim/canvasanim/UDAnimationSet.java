package com.immomo.mls.fun.ud.anim.canvasanim;

import android.view.animation.Animation;
import android.view.animation.AnimationSet;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-05-28
 */
@LuaClass
public class UDAnimationSet extends UDBaseAnimation {
    public static final String LUA_CLASS_NAME = "AnimationSet";

    private final AnimationSet animationSet;

    private final boolean shareInterpolator;

    public UDAnimationSet(Globals g, LuaValue[] init) {
        super(g, init);
        if (init != null && init.length == 1) {
            shareInterpolator = init[0].toBoolean();
        } else {
            shareInterpolator = false;
        }
        animationSet = new AnimationSet(shareInterpolator);
    }

    private UDAnimationSet(Globals g, UDAnimationSet src) {
        super(g, null);
        shareInterpolator = src.shareInterpolator;
        animationSet = new AnimationSet(shareInterpolator);
    }

    //<editor-fold desc="api">
    @LuaBridge
    public void addAnimation(UDBaseAnimation animation) {
        animationSet.addAnimation(animation.getAnimation());
    }
    //</editor-fold>

    @Override
    protected Animation build() {
        return animationSet;
    }

    @Override
    protected UDAnimationSet cloneObj() {
        return new UDAnimationSet(globals, this);
    }
}
