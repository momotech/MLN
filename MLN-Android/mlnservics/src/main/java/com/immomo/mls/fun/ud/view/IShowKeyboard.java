/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;


/**
 *  键盘弹起来后，点击其他空白区域，是否消失键盘接口
 */
public interface IShowKeyboard {

    boolean showKeyboard();  // true 代表继续展示键盘
}