/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.xfy.shell;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public final class Method {
    String name;
    Type returnType;
    Type[] params;
    boolean isStatic;

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder(returnType.toString()).append(isStatic ? " static " : " ").append(name).append('(');
        for (Type t : params) {
            sb.append(t).append(',');
        }
        if (params.length > 0)
            sb.setLength(sb.length() - 1);
        sb.append(')');
        return sb.toString();
    }
}