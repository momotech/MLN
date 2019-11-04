package com.immomo.mls.fun.constants;

import android.view.inputmethod.EditorInfo;

import com.immomo.mls.wrapper.ConstantClass;
import com.immomo.mls.wrapper.Constant;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
@ConstantClass
public interface ReturnType {
    @Constant
    int Default = EditorInfo.IME_ACTION_NONE;
    @Constant
    int Go = EditorInfo.IME_ACTION_GO;
    @Constant
    int Search = EditorInfo.IME_ACTION_SEARCH;
    @Constant
    int Send = EditorInfo.IME_ACTION_SEND;
    @Constant
    int Next = EditorInfo.IME_ACTION_NEXT;
    @Constant
    int Done = EditorInfo.IME_ACTION_DONE;
}
