/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.processor;


import com.immomo.mls.annotation.LuaBridge;

import javax.lang.model.element.Element;

/**
 * Created by XiongFangyu on 2018/8/29.
 */
class PropertyElement {
    Element setter;
    Element getter;
    LuaBridge bridge;
}