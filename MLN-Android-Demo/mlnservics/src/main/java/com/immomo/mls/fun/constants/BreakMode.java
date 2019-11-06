package com.immomo.mls.fun.constants;

import android.text.TextUtils;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@ConstantClass
public interface BreakMode {
    @Constant
    int CLIPPING = -1;
    @Constant
    int HEAD = TextUtils.TruncateAt.START.ordinal();
    @Constant
    int TAIL = TextUtils.TruncateAt.END.ordinal();
    @Constant
    int MIDDLE = TextUtils.TruncateAt.MIDDLE.ordinal();
}
