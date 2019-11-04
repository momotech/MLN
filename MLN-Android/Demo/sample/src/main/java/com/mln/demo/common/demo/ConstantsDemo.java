package com.mln.demo.common.demo;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by MLN Templates
 * 注册方法：
 * @see com.immomo.mls.MLSBuilder#registerConstants(Class[])
 */
@ConstantClass
public interface ConstantsDemo {
    /**
     * Lua可通过 ConstantsDemo.a 读取
     */
    @Constant
    int a = 1;
    /**
     * Lua可通过 ConstantsDemo.c 读取
     */
    @Constant(alias = "c")
    int b = 2;
}
