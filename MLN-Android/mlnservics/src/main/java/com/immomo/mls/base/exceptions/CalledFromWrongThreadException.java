/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.base.exceptions;

/**
 * Created by XiongFangyu on 2018/8/8.
 */
public class CalledFromWrongThreadException extends RuntimeException {
    public CalledFromWrongThreadException(String msg) {
        super(msg);
    }
}