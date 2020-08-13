/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.shell;

import java.util.Arrays;
import java.util.List;
import java.util.Objects;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public final class Method {
    private static final String GET_PRE = "get";
    private static final String SET_PRE = "set";
    private static final String IS_PRE = "is";
    String name;
    Type returnType;
    Type[] params;
    boolean isStatic;
    boolean isNative;
    boolean isConstructor;
    List<String> annotations;

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        if (annotations != null) {
            for (String s : annotations) {
                sb.append(s).append('\n');
            }
        }
        if (isStatic) {
            sb.append("static ");
        }
        if (isNative) {
            sb.append(" native ");
        }
        sb.append(returnType.toString())
                .append(" ").append(name).append('(');
        for (Type t : params) {
            sb.append(t).append(',');
        }
        if (params.length > 0)
            sb.setLength(sb.length() - 1);
        sb.append(')');
        return sb.toString();
    }

    public String toSig() {
        StringBuilder sb = new StringBuilder();
        if (isStatic) {
            sb.append("static ");
        }
        if (isNative) {
            sb.append(" native ");
        }
        sb.append(returnType.toString())
                .append(" ").append(name).append('(');
        for (Type t : params) {
            sb.append(t).append(',');
        }
        if (params.length > 0)
            sb.setLength(sb.length() - 1);
        sb.append(')');
        return sb.toString();
    }

    public boolean containAnnotation(String anno) {
        return annotations != null && annotations.contains(anno);
    }

    public boolean isGetter() {
        return !isConstructor
                && params.length == 0
                && !returnType.isVoid
                && (name.startsWith(GET_PRE) || name.startsWith(IS_PRE));
    }

    public boolean isSetter() {
        return !isConstructor
                && params.length == 1
                && returnType.isVoid
                && (name.startsWith(SET_PRE));
    }

    public Method generateSetter() {
        if (!isGetter())
            throw new IllegalStateException("this method is not a getter method!");
        Method m = new Method();
        m.returnType = Type.VoidType();
        m.params = new Type[] {this.returnType};
        m.isStatic = isStatic;
        m.isNative = isNative;
        if (name.startsWith(IS_PRE)) {
            m.name = SET_PRE + name.substring(IS_PRE.length());
        } else {
            m.name = SET_PRE + name.substring(GET_PRE.length());
        }
        return m;
    }

    public Method generateGetter() {
        if (!isSetter())
            throw new IllegalStateException("this method is not a getter method!");
        Method m = new Method();
        m.params = new Type[0];
        m.returnType = this.params[0];
        m.isStatic = isStatic;
        m.isNative = isNative;
        String suffix = name.substring(SET_PRE.length());
        if (m.returnType.primitiveType == Type.PrimitiveType.Boolean) {
            m.name = IS_PRE + suffix;
        } else {
            m.name = GET_PRE + suffix;
        }
        return m;
    }

    public String getNameWithoutPrefix() {
        if (isGetter()) {
            if (name.startsWith(IS_PRE))
                return name.substring(IS_PRE.length());
            return name.substring(GET_PRE.length());
        } else if (isSetter()) {
            return name.substring(SET_PRE.length());
        }
        return null;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Method)) return false;
        Method method = (Method) o;
        return isStatic == method.isStatic &&
                isNative == method.isNative &&
                isConstructor == method.isConstructor &&
                name.equals(method.name) &&
                returnType.equals(method.returnType) &&
                Arrays.equals(params, method.params);
    }

    @Override
    public int hashCode() {
        int result = Objects.hash(name, returnType, isStatic, isNative, isConstructor);
        result = 31 * result + Arrays.hashCode(params);
        return result;
    }
}
