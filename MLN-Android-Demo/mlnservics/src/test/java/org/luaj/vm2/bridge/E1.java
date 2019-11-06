package org.luaj.vm2.bridge;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by Xiong.Fangyu on 2019-07-03
 */
@ConstantClass(alias = "Const")
public interface E1 {
    @Constant
    int A = 11;
    @Constant
    int B = 12;
}
