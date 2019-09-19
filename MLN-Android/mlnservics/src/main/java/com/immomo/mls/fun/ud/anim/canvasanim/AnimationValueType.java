/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim.canvasanim;

import android.view.animation.Animation;

import com.immomo.mls.wrapper.Constant;
import com.immomo.mls.wrapper.ConstantClass;

/**
 * Created by Xiong.Fangyu on 2019-05-27
 */
@ConstantClass
public interface AnimationValueType {
    @Constant
    int ABSOLUTE = Animation.ABSOLUTE;
    @Constant
    int RELATIVE_TO_SELF = Animation.RELATIVE_TO_SELF;
    @Constant
    int RELATIVE_TO_PARENT = Animation.RELATIVE_TO_PARENT;
}