package com.immomo.mls.fun.constants;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by XiongFangyu on 2018/8/21.
 */
@ConstantClass
public interface RectCorner {
    @Constant
    int TOP_LEFT = 1;
    @Constant
    int TOP_RIGHT = 2;
    @Constant
    int BOTTOM_LEFT = 4;
    @Constant
    int BOTTOM_RIGHT = 8;
    @Constant
    int ALL_CORNERS = 15;
}
