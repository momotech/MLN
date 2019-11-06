package com.immomo.mls.fun.ud.anim.canvasanim;

import android.view.animation.Animation;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by Xiong.Fangyu on 2019-05-27
 */
@ConstantClass
public interface AnimationValueType {
    @Constant
    int ABSOLUTE = Animation.ABSOLUTE;
    @Constant
    int RELATIVE_TO_SELF = Animation.RELATIVE_TO_SELF;
    @Constant
    int RELATIVE_TO_PARENT = Animation.RELATIVE_TO_PARENT;
}
