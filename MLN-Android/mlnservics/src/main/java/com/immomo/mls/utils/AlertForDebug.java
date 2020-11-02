/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.utils;

/**
 * Created by Xiong.Fangyu on 2019-09-17
 */
public class AlertForDebug extends RuntimeException {

    public static AlertForDebug showInDebug(String s) {
        return new AlertForDebug(s);
    }

    public AlertForDebug(String s) {
        super(s);
    }
}