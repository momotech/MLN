package com.immomo.mls.fun.ud.net;

import androidx.annotation.IntDef;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by XiongFangyu on 2018/8/24.
 */
@ConstantClass
public interface EncType {
    @Constant
    int NORMAL = 0;
    @Constant
    int NO = 1;

    @IntDef({NORMAL, NO})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Type {}
}
