package com.immomo.mls.fun.ud.view;

import androidx.annotation.IntDef;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@ConstantClass
public interface VisibilityType {
    @Constant
    int NORMAL = 0;
    @Constant
    int LifeCycle = 1;

    @IntDef({NORMAL, LifeCycle})
    @Retention(RetentionPolicy.SOURCE)
    public @interface Type {}
}