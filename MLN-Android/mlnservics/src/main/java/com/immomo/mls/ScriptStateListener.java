/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

/**
 * Created by XiongFangyu on 2018/8/15.
 */
public interface ScriptStateListener {
    enum Reason{
        LOAD_FAILED,
        COMPILE_FAILED,
        EXCUTE_FAILED,
    }

    void onSuccess();

    void onFailed(Reason reason);
}