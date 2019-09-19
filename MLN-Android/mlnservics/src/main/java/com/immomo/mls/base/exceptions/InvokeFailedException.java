/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.base.exceptions;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

/**
 * Created by XiongFangyu on 2018/7/30.
 */
public final class InvokeFailedException extends IllegalStateException {
    public InvokeFailedException(Method m, Object[] params, Throwable cause) {
        super(String.format("call method %s(%s) failed.", m.getName(), getParamsString(params)), cause);
    }

    public InvokeFailedException(Constructor c, Object[] params, Throwable cause) {
        super(String.format("call constructor %s(%s) failed.", c.getName(), getParamsString(params)), cause);
    }

    public InvokeFailedException(String msg) {
        super(msg);
    }

    public InvokeFailedException(String msg, Throwable cause) {
        super(msg, cause);
    }

    private static String getParamsString(Object[] p) {
        if (p == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0, l = p.length; i < l; i++) {
            Object o = p[i];
            if (o == null) {
                sb.append("null");
            } else {
                sb.append(o.getClass().getName());
            }
            if (i != l - 1) {
                sb.append(", ");
            }
        }
        return sb.toString();
    }
}