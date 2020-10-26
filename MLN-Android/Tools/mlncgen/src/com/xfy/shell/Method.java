/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.shell;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public final class Method implements Comparable<Method> {
    private static final String GET_PRE = "get";
    private static final String SET_PRE = "set";
    private static final String IS_PRE = "is";
    private static final String N_GET_PRE = "nGet";
    private static final String N_SET_PRE = "nSet";
    private static final String N_IS_PRE = "nIs";
    String name;
    String jmethodID;
    Type returnType;
    Type[] params;
    boolean isStatic;
    boolean isNative;
    boolean isConstructor;
    List<Annotation> annotations;

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        if (annotations != null) {
            for (Annotation s : annotations) {
                sb.append(s).append('\n');
            }
        }
        if (isStatic) {
            sb.append("static ");
        }
        if (isNative) {
            sb.append(" native ");
        }
        if (isConstructor) {
            sb.append(name).append('(');
        } else {
            sb.append(returnType.toString())
                    .append(" ").append(name).append('(');
        }
        for (Type t : params) {
            sb.append(t).append(',');
        }
        if (params.length > 0)
            sb.setLength(sb.length() - 1);
        sb.append(')');
        return sb.toString();
    }

    public boolean isOldTypeBridge() {
        if (!returnType.isLuaValueArr())
            return false;
        if (isStatic) {
            return params.length == 2 && params[0].isLong() && params[1].isLuaValueArr();
        }
        return params.length == 1 && params[0].isLuaValueArr();
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

    public boolean containLuaApiUsed() {
        if (annotations == null)
            return false;
        return annotations.contains(Annotation.getLuaApiUsed());
    }

    public CGenerate getCGenerate() {
        if (annotations == null)
            return null;
        for (Annotation a : annotations) {
            if ("CGenerate".equals(a.getSimpleName()))
                return new CGenerate(a);
        }
        return null;
    }

    public boolean isGetter() {
        return !isConstructor
                && params.length == 0
                && !returnType.isVoid()
                && (name.startsWith(GET_PRE) || name.startsWith(IS_PRE) || name.startsWith(N_GET_PRE) || name.startsWith(N_IS_PRE));
    }

    private boolean paramsTypeEquals() {
        if (params.length <= 0)
            return false;
        Type first = null;
        for (Type p : params) {
            if (first == null)
                first = p;
            else if (!first.equals(p))
                return false;
        }
        return true;
    }

    public boolean isSetter() {
        return !isConstructor
                && returnType.isVoid()
                && (params.length == 1 || paramsTypeEquals())
                && (name.startsWith(SET_PRE) || name.startsWith(N_SET_PRE));
    }

    public Method generateGetter() {
        if (!isSetter())
            throw new IllegalStateException("this method is not a getter method!");
        Method m = new Method();
        m.params = new Type[0];
        if (params.length > 1) {
            m.returnType = this.params[0].copyOf();
            m.returnType.setArray();
        } else {
            m.returnType = this.params[0];
        }
        m.isStatic = isStatic;
        m.isNative = isNative;
        final String suffix;
        final boolean nativeStart;
        if (name.startsWith(N_SET_PRE)) {
            suffix = name.substring(N_SET_PRE.length());
            nativeStart = true;
        } else {
            suffix = name.substring(SET_PRE.length());
            nativeStart = false;
        }
        if (m.returnType.getPrimitiveType() == Type.PrimitiveType.Boolean) {
            m.name = nativeStart ? N_IS_PRE + suffix : IS_PRE + suffix;
        } else {
            m.name = nativeStart ? N_GET_PRE + suffix : GET_PRE + suffix;
        }
        return m;
    }

    public String getNameWithoutPrefix() {
        if (isGetter()) {
            if (name.startsWith(IS_PRE))
                return name.substring(IS_PRE.length());
            if (name.startsWith(N_IS_PRE))
                return name.substring(N_IS_PRE.length());
            if (name.startsWith(N_GET_PRE))
                return name.substring(N_GET_PRE.length());
            return name.substring(GET_PRE.length());
        } else if (isSetter()) {
            if (name.startsWith(N_SET_PRE))
                return name.substring(N_SET_PRE.length());
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

    @Override
    public int compareTo(Method o) {
        Type[] p1 = this.params;
        Type[] p2 = o.params;
        if (p1.length != p2.length)
            return p1.length < p2.length ? 1 : -1;
        int idx = 0;
        for (Type t1 : p1) {
            int ret = t1.compareTo(p2[idx ++]);
            if (ret != 0)
                return ret;
        }
        return 0;
    }

    private static final HashMap<String, String> primitive;
    static {
        primitive = new HashMap<>(9);
        primitive.put("boolean", "Z");
        primitive.put("byte", "B");
        primitive.put("char", "C");
        primitive.put("short", "S");
        primitive.put("int", "I");
        primitive.put("long", "J");
        primitive.put("float", "F");
        primitive.put("double", "D");
        primitive.put("void", "V");
    }

    private static void appendType(StringBuilder sb, Type p) {
        if (p.isArray())
            sb.append('[');
        if (p.isPrimitive() || p.isVoid()) {
            sb.append(primitive.get(p.getName()));
        } else {
            sb.append('L').append(StringReplaceUtils.replaceAllChar(p.getName(), '.', '/')).append(';');
        }
    }

    public String getParamsSig() {
        StringBuilder sb = new StringBuilder();
        appendParamsSig(sb);
        return sb.toString();
    }

    public void appendParamsSig(StringBuilder sb) {
        for (Type p : params) {
            appendType(sb, p);
        }
    }

    public String getMethodSig() {
        StringBuilder sb = new StringBuilder().append('(');
        appendParamsSig(sb);
        sb.append(')');
        appendType(sb, returnType);
        return sb.toString();
    }
}
