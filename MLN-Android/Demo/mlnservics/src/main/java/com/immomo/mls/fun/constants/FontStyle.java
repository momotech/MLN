package com.immomo.mls.fun.constants;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@ConstantClass
public interface FontStyle {
    @Constant
    int NORMAL = 0;
    @Constant
    int BOLD = 1;
    @Constant
    int ITALIC = 2;
    @Constant
    int BOLD_ITALIC = 3;
}
