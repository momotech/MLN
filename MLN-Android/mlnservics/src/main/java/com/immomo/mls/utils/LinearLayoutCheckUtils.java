/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import android.view.ViewGroup;

import com.immomo.mls.fun.weight.LinearLayout;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2018/12/27
 * Time         :   下午5:01
 * Description  :   为了配合iOS,在SDK中增加工具：在debug阶段，当某个view被add到LinearLayout中时，若LinearLayout在方向上（如果LinearLayout是横向的，则取宽的值，若是纵向的，则取高的值）的长度是wrap_content，子view是match_parent，则子View不能是第一个View，是的话报错
 */
public class LinearLayoutCheckUtils {

    public static void checkLinearLayout(LinearLayout v) {

        ViewGroup.LayoutParams childParams = v.getChildAt(0) != null ? v.getChildAt(0).getLayoutParams() : null;

        // 纵向
        if (v.getOrientation() == LinearLayout.VERTICAL) {

            if (v.getLayoutParams() != null && v.getLayoutParams().height == LinearLayout.LayoutParams.WRAP_CONTENT) {

                if (childParams != null && childParams.height == LinearLayout.LayoutParams.MATCH_PARENT)
                    throw new IllegalStateException("linearlayout vertical height wrap_content , but firt child view height match_parent ");
            }

        }

        // 横向
        if (v.getOrientation() == LinearLayout.HORIZONTAL) {

            if (v.getLayoutParams() != null && v.getLayoutParams().width == LinearLayout.LayoutParams.WRAP_CONTENT) {

                if (childParams != null && childParams.width == LinearLayout.LayoutParams.MATCH_PARENT)
                    throw new IllegalStateException("linearlayout horizontal width wrap_content , but firt child view width match_parent");
            }

        }
    }
}