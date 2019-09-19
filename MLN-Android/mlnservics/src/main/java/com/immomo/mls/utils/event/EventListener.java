/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils.event;

import com.immomo.mls.fun.java.Event;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
public interface EventListener {
    void onEventReceive(Event event);
}