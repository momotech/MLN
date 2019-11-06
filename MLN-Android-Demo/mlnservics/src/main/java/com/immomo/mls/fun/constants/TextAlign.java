package com.immomo.mls.fun.constants;

import android.view.Gravity;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@ConstantClass
public interface TextAlign {
    @Constant
    int LEFT = Gravity.CENTER | Gravity.LEFT;
    @Constant
    int CENTER = Gravity.CENTER;
    @Constant
    int RIGHT = Gravity.RIGHT | Gravity.CENTER;
}
