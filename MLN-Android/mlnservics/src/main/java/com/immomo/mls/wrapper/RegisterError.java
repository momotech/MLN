/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

/**
 * Created by Xiong.Fangyu on 2019/3/18
 */
public class RegisterError extends Error {

    public RegisterError(Throwable c) {
        super(c);
    }

    public RegisterError(String msg) {
        super(msg);
    }

    public RegisterError(String msg, Throwable e) {
        super(msg, e);
    }
}