package com.immomo.mls.fun.constants;

import android.graphics.Path;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by zhang.ke
 * on 2019/7/25
 */
@ConstantClass
public interface FillType {
    @Constant
    int WINDING = Path.FillType.WINDING.ordinal();
    @Constant
    int EVEN_ODD = Path.FillType.EVEN_ODD.ordinal();
    @Constant
    int INVERSE_WINDING = Path.FillType.INVERSE_WINDING.ordinal();
    @Constant
    int INVERSE_EVEN_ODD = Path.FillType.INVERSE_EVEN_ODD.ordinal();
}
