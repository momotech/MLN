package com.immomo.mmui.gesture;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * 重新查找消费事件的view的时机
 * Created by wang.yang on 2020/10/27.
 */
@ConstantClass
public interface DispatchDelay {
    @Constant
    int Default = 1;
    @Constant
    int MultiFinger = 2;
}
