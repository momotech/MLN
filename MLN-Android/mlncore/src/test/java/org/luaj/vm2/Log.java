/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

/**
 * Created by XiongFangyu on 2018/8/10.
 */

public class Log {

    public static void i(Object s) {
        System.out.println(String.valueOf(s));
    }

    public static void e(Object s) {
        System.err.println(s);
    }

    public static void f(String s, Object... obj) {
        System.out.println(String.format(s, obj));
    }

    public static void ef(String s, Object... obj) {
        System.err.println(String.format(s, obj));
    }
}