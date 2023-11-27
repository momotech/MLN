package com.immomo.demo;

import com.immomo.mls.annotation.MLN;
import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

@ConstantClass
@MLN(type = MLN.Type.Const)
public interface FontStyle2 {
    @Constant
    int NORMAL = 0;
    @Constant
    int BOLD = 1;
    @Constant
    int ITALIC = 2;
    @Constant
    int BOLD_ITALIC = 3;
}
