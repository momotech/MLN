package com.immomo.mls.fun.constants;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by XiongFangyu on 2018/8/13.
 */
@ConstantClass
public interface NetworkState {
    @Constant
    int UNKNOWN = 0;
    @Constant
    int NO_NETWORK = 1;
    @Constant
    int CELLULAR = 2;
    @Constant
    int WIFI = 3;
}
