/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.interfaces;

import com.immomo.mmui.databinding.annotation.ListNotifyType;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-09 18:58
 */
public interface IListChangedCallback {

    /**
     * list改变回调
     * @param type 改变类型
     * @param positionStart 改变的index
     * @param itemCount 改变的数量
     */
    void notifyChange(@ListNotifyType int type, int positionStart, int itemCount);
}