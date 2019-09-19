/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.util;

import static com.immomo.mls.fun.constants.GravityConstants.*;
/**
 * Created by Xiong.Fangyu on 2019/4/24
 */
public class GravityUtils {
    public static String toString(int gravity) {
        final StringBuilder result = new StringBuilder();
        if ((gravity & TOP) == TOP) {
            result.append("TOP").append(' ');
        }
        if ((gravity & BOTTOM) == BOTTOM) {
            result.append("BOTTOM").append(' ');
        }
        if ((gravity & LEFT) == LEFT) {
            result.append("LEFT").append(' ');
        }
        if ((gravity & RIGHT) == RIGHT) {
            result.append("RIGHT").append(' ');
        }
        if ((gravity & CENTER) == CENTER) {
            result.append("CENTER").append(' ');
        } else {
            if ((gravity & CENTER_VERTICAL) == CENTER_VERTICAL) {
                result.append("CENTER_VERTICAL").append(' ');
            }
            if ((gravity & CENTER_HORIZONTAL) == CENTER_HORIZONTAL) {
                result.append("CENTER_HORIZONTAL").append(' ');
            }
        }
        if (result.length() == 0) {
            result.append("NO GRAVITY").append(' ');
        }
        result.deleteCharAt(result.length() - 1);
        return result.toString();
    }
}