/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.shell;

import java.util.*;

/**
 * Created by Xiong.Fangyu on 2020/9/8
 */
public class Annotation {
    protected String simpleName;
    protected String packageName;
    protected Map<String, Value> values;

    public String getSimpleName() {
        return simpleName;
    }

    public String getPackageName() {
        return packageName;
    }

    public Map<String, Value> getValues() {
        return values;
    }

    private static Annotation LuaApiUsed;
    public static Annotation getLuaApiUsed() {
        if (LuaApiUsed == null) {
            LuaApiUsed = new Annotation();
            LuaApiUsed.simpleName = "LuaApiUsed";
        }
        return LuaApiUsed;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Annotation)) return false;
        Annotation that = (Annotation) o;
        return simpleName.equals(that.simpleName) &&
                Objects.equals(packageName, that.packageName) &&
                Objects.equals(values, that.values);
    }

    @Override
    public int hashCode() {
        return Objects.hash(simpleName, packageName, values);
    }

    private static int findBlankIndex(String s) {
        int min = s.length() + 1;
        int idx = s.indexOf(' ');
        if (idx >= 0 && idx < min) {
            min = idx;
        }
        idx = s.indexOf('\t');
        if (idx >= 0 && idx < min) {
            min = idx;
        }
        idx = s.indexOf('\n');
        if (idx >= 0 && idx < min) {
            min = idx;
        }
        if (min == s.length() + 1)
            return -1;
        return min;
    }

    public static Annotation parse(String src) {
        src = src.trim();
        if (src.isEmpty())
            return null;
        if (src.charAt(0) != '@')
            return null;
        src = src.substring(1);
        Annotation ret = new Annotation();
        int start = src.indexOf('(');
        if (start < 0) {
            int bi = findBlankIndex(src);
            if (bi > 0)
                src = src.substring(0, bi);
            ret.simpleName = src;
            return ret;
        }
        int end = src.lastIndexOf(')');
        if (end <= start)
            return null;
        ret.simpleName = src.substring(0, start).trim();
        src = src.substring(start + 1, end).trim();
        if (src.isEmpty())
            return ret;
        String[] kvs = src.split(",");
        ret.values = new HashMap<>();
        for (String s : kvs) {
            String[] kv = s.split("=");
            String key = kv[0].trim();
            String value = kv[1].trim();
            final Value v;
            if (value.charAt(0) == '"') {
                v = new Value(Type.StringType(), value.substring(1, value.length() - 1));
            } else if (value.equals("true") || value.equals("false")) {
                v = new Value(Type.getType("boolean"), value);
            } else {
                v = new Value(Type.getType("int"), value);
            }
            ret.values.put(key, v);
        }
        return ret;
    }

    public static List<Annotation> parseMultiAnnotation(String src) {
        src = src.trim();
        if (src.isEmpty())
            return null;
        if (src.charAt(0) != '@')
            return null;
        List<Annotation> annotations = new ArrayList<>();
        int fromIndex = 0;
        int len = src.length();
        int idx;
        while (true) {
            idx = src.indexOf('@', fromIndex + 1);
            if (idx < 0) {
                Annotation an = parse(src.substring(fromIndex, len));
                if (an != null)
                    annotations.add(an);
                break;
            }
            Annotation an = parse(src.substring(fromIndex, idx));
            if (an != null)
                annotations.add(an);
            fromIndex = idx;
        }
        return annotations;
    }

    public static final class Value {
        public final Type type;
        public final String realValue;

        public Value(Type type, String realValue) {
            this.type = type;
            this.realValue = realValue;
        }

        @Override
        public String toString() {
            if (type.isString())
                return "\""+ realValue +"\"";
            return realValue;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof Value)) return false;
            Value value = (Value) o;
            return type.equals(value.type) &&
                    realValue.equals(value.realValue);
        }

        @Override
        public int hashCode() {
            return Objects.hash(type, realValue);
        }
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("@");
        if (packageName != null)
            sb.append(packageName).append('.');
        sb.append(simpleName).append('(');
        if (values != null) {
            int idx = 0;
            for (Map.Entry<String, Value> e : values.entrySet()) {
                if (idx++ != 0)
                    sb.append(',');
                sb.append(e.getKey()).append('=').append(e.getValue().toString());
            }
        }
        sb.append(')');
        return sb.toString();
    }
}
