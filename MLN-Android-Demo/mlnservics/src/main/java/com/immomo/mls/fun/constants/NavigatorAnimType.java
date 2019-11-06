package com.immomo.mls.fun.constants;

import androidx.annotation.IntDef;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by XiongFangyu on 2018/8/13.
 */
@ConstantClass(alias = "AnimType")
public interface NavigatorAnimType {
    @Constant
    int Default = 0;
    @Constant
    int None = 1;
    @Constant
    int LeftToRight = 2;
    @Constant
    int RightToLeft = 3;
    @Constant
    int TopToBottom = 4;
    @Constant
    int BottomToTop = 5;
    @Constant
    int Scale = 6;
    @Constant
    int Fade = 7;

    @IntDef({Default, None, LeftToRight, RightToLeft, TopToBottom, BottomToTop, Scale, Fade})
    @Retention(RetentionPolicy.SOURCE)
    @interface AnimType {}
}
