/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter;

import com.immomo.mls.utils.LVCallback;

import java.util.Map;

/**
 * Created by XiongFangyu on 2018/7/2.
 */
public interface MLSGlobalEventAdapter {
    String KEY_DST = "dst_l_evn";
    String KEY_MSG = "event_msg";

    void addEventListener(String event, LVCallback callback);

    void addListener(String event, LVCallback callback);

    void postEvent(String event, String[] env, Map msg);

    void removeEventListener(String event, LVCallback... callback);

    void clearEventListener();
}