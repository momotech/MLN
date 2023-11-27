/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

/**
 * Created by Xiong.Fangyu on 2019-08-12
 */
public class ProGuardError extends Error {
    public ProGuardError(String msg) {
        super(msg);
    }

    public ProGuardError(String msg, Throwable e) {
        super(msg, e);
    }
}