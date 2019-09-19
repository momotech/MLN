/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019-08-08
 * Time         :   14:57
 * Description  :   TabSegment 滑动过程中进度值回调,介于 0 和 1 之间
 */

public interface ITabLayoutScrollProgress {
    void tabScrollProgress(double progresss, int fromIndex, int toIndex);
}