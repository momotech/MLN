package org.luaj.vm2.bridge;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by Xiong.Fangyu on 2019-07-03
 */
@ConstantClass(alias = "Const")
public interface E2 {
    @Constant
    String C = "c";
    @Constant
    String D = "d";
}
