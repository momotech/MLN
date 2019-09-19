/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public interface MLSThreadAdapter {
    enum Priority {
        HIGH,
        MEDIUM,
        LOW
    }

    void execute(Priority p, Runnable action);

    void executeTaskByTag(Object tag, Runnable task);

    void cancelTask(Object tag, Runnable task);

    void cancelTaskByTag(Object tag);
}