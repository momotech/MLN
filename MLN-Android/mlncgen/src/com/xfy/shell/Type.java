package com.xfy.shell;

import java.util.Arrays;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public class Type {
    private static final String[] PrimitiveTypes;
    private static final String Void = "void";

    static {
        PrimitiveTypes = new String[]{
                "boolean",
                "byte",
                "char",
                "short",
                "int",
                "float",
                "long",
                "double"
        };
        Arrays.sort(PrimitiveTypes);
    }

    enum PrimitiveType {
        Boolean,
        Int,
        Number
    }

    private static PrimitiveType parse(String s) {
        if ("boolean".equals(s))
            return PrimitiveType.Boolean;
        char c = s.charAt(0);
        if (c == 'f' || c == 'd' || c == 'l') {
            return PrimitiveType.Number;
        }
        return PrimitiveType.Int;
    }

    boolean isPrimitive;
    PrimitiveType primitiveType;
    boolean isVoid;
    boolean isArray;
    boolean isString;
    String name;

    public Type(String name) {
        isArray = name.charAt(name.length() - 1) == ']';
        if (isArray) {
            name = name.substring(0, name.indexOf('['));
        }
        isString = "String".equals(name);
        if (isString) {
            this.name = "java.lang.String";
            return;
        }
        this.name = name;
        isVoid = Void.equals(name);
        if (isVoid)
            return;
        isPrimitive = Arrays.binarySearch(PrimitiveTypes, name) >= 0;
        if (isPrimitive) {
            primitiveType = parse(name);
        }
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder().append(name);
        if (isArray)
            sb.append("[]");
        return sb.toString();
    }

    public String toCName() {
        if (isPrimitive) {
            switch (primitiveType) {
                case Boolean:
                    return "int";
                case Number:
                    return "lua_Number";
                default:
                    return "lua_Integer";
            }
        }
        if (isString) {
            return "jstring";
        }
        return "jobject";
    }
}
