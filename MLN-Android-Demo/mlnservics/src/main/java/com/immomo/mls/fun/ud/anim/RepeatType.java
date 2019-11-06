package com.immomo.mls.fun.ud.anim;

import android.animation.ValueAnimator;
import androidx.annotation.IntDef;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by XiongFangyu on 2018/8/10.
 */
@ConstantClass
public interface RepeatType {
    @Constant
    int NONE = 0;
    @Constant
    int FROM_START = ValueAnimator.RESTART;
    @Constant
    int REVERSE = ValueAnimator.REVERSE;

    @IntDef({FROM_START, REVERSE})
    @Retention(RetentionPolicy.SOURCE)
    public @interface RepeatMode {}
}
