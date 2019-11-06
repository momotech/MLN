package com.immomo.mls.fun.constants;

import android.text.InputType;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@ConstantClass
public interface EditTextViewInputMode {
    @Constant
    int Normal = InputType.TYPE_CLASS_TEXT;
    @Constant
    int Number = InputType.TYPE_CLASS_NUMBER;
}
