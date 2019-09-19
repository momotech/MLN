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

/**
 * Created by Xiong.Fangyu on 2019-08-06
 *
 * Android Test only
 *
 */
@ConstantClass
public interface MotionEvent {
    @Constant
    int x               = 0;
    @Constant
    int y               = 1;
    @Constant
    int pid             = 2;

    @Constant
    int action          = 3;
    @Constant
    int rawX            = 4;
    @Constant
    int rawY            = 5;
    @Constant
    int pCount          = 6;
    @Constant
    int index           = 7;
    @Constant
    int time            = 8;

    @Constant
    int idxFrom         = 10;

    @Constant
    int ACTION_DOWN         = android.view.MotionEvent.ACTION_DOWN;
    @Constant
    int ACTION_MOVE         = android.view.MotionEvent.ACTION_MOVE;
    @Constant
    int ACTION_UP           = android.view.MotionEvent.ACTION_UP;
    @Constant
    int ACTION_CANCEL       = android.view.MotionEvent.ACTION_CANCEL;
    @Constant
    int ACTION_POINTER_DOWN = android.view.MotionEvent.ACTION_POINTER_DOWN;
    @Constant
    int ACTION_POINTER_UP   = android.view.MotionEvent.ACTION_POINTER_UP;
}