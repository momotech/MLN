/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.constants;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import androidx.annotation.IntDef;


/**
 * Created by zhang.ke
 * on 2019/11/5
 */
@ConstantClass(alias = "SafeArea")
public interface SafeAreaConstants {
    @Constant
    int CLOSE = 0;
    @Constant
    int LEFT = 1;
    @Constant
    int TOP = 2;
    @Constant
    int RIGHT = 4;
    @Constant
    int BOTTOM = 8;



    @IntDef({LEFT, TOP, RIGHT, BOTTOM})
    @Retention(RetentionPolicy.SOURCE)
    @interface SafeArea {
    }
}
