/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding.interfaces;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-03-25 23:37
 */
public interface IItemChangeCallback<T> {
    /**
     *
     * @param item 改变的item
     * @param path item的属性变量
     * @param old 改变之前的值
     * @param news 改变之后的值
     */
    void callBack(Object item, String path, T old, T news);
}