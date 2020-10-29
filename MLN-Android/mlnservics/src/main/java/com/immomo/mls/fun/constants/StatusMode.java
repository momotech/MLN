package com.immomo.mls.fun.constants;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by zhang.ke。
 * on 2019/1/10
 * 统一两端状态栏的差异，定义状态栏模式：
 * wiki：https://moji.wemomo.com/doc#/detail/121973
 */
@ConstantClass
public interface StatusMode {
    @Constant
    int NON_FULLSCREEN = 0;

    @Constant
    int FULLSCREEN = 1;

    @Constant
    int TRANSLUCENT = 2;
}
