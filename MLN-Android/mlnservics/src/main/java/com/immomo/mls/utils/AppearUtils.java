/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import com.immomo.mls.fun.ud.view.UDViewPager;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019/4/11
 * Time         :   下午5:09
 * Description  :   viewPager调用scrollToPage(position,true) ios会调用过程中每个position页的willappear和diddisappear android只调用滚动开始页和滚动结束页 问题修复
 * Description  :
 */
public class AppearUtils {

    public static boolean sAnimatedToPage = false;

    public static void appearOrDisappearMiddlePosition(UDViewPager userdata, int lastPosition, int currentSelectedPosition,boolean autoScroll) {

        if (userdata == null || !sAnimatedToPage || autoScroll)
            return;

        int min = Math.min(lastPosition, currentSelectedPosition);
        int max = Math.max(lastPosition, currentSelectedPosition);

        for (int i = min + 1; i < max; i++) {
            userdata.callbackCellWillAppear(i);
            userdata.callbackCellDidDisAppear(i);
        }
    }
}