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
 * Date: 2020-06-02 16:36
 */
public interface IListChangeObservable {

    void addListChangedCallback(IListChangedCallback iListChangedCallback);

    void removeListChangeCallback(IListChangedCallback iListChangedCallback);
}