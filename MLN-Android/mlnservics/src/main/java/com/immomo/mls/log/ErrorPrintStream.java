/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.log;

/**
 * Created by Xiong.Fangyu on 2020/8/21
 */
public interface ErrorPrintStream {
    void error(final String s);
    void error(final String msg, final ErrorType errorType);
}
