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
import java.util.Map;
import java.util.Objects;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public class Type {
    private static final String[] PrimitiveTypes;
    private static final Map<String, Type> PrimitiveTypeMap;
    private static final String Void = "void";

    private static final String CORE_PACKAGE = "org.luaj.vm2";
    private static final String GLOBALS = "Globals";
    private static final String GLOBALS_PACKAGE = CORE_PACKAGE + "." + GLOBALS;

    private static Type voidType;
    private static Type stringType;
    private static Type globalsType;

    public static Type VoidType() {
        if (voidType == null)
            voidType = new Type(Void);
        return voidType;
    }

    public static Type StringType() {
        if (stringType == null)
            stringType = new Type("String");
        return stringType;
    }

    public static Type GlobalsType() {
        if (globalsType == null)
            globalsType = new Type(GLOBALS);
        return globalsType;
    }

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
        PrimitiveTypeMap = new HashMap<>(9);
        for (int i = 0; i < 8; i ++) {
            PrimitiveTypeMap.put(PrimitiveTypes[i], new Type(PrimitiveTypes[i]));
        }
        PrimitiveTypeMap.put("void", VoidType());
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
    boolean isGlobals;
    boolean isLong;
    String name;

    boolean needAddPackage() {
        return !isVoid && !isString && !isGlobals && !isPrimitive;
    }

    public static Type getType(String name) {
        Type t = PrimitiveTypeMap.get(name);
        if (t != null) {
            return t;
        }
        if ("String".equals(name) || "java.lang.String".equals(name)) {
            return StringType();
        }
        if (GLOBALS.equals(name) || GLOBALS_PACKAGE.equals(name)) {
            return GlobalsType();
        }
        t = new Type(name);
        return t;
    }

    private Type(String name) {
        isArray = name.charAt(name.length() - 1) == ']';
        if (isArray) {
            name = name.substring(0, name.indexOf('['));
        }
        isString = "String".equals(name) || "java.lang.String".equals(name);
        if (isString) {
            this.name = "java.lang.String";
            return;
        }
        isGlobals = GLOBALS.equals(name) || GLOBALS_PACKAGE.equals(name);
        if (isGlobals) {
//            throw new RuntimeException("如果需要Globals虚拟机，请将第一个参数设置为long类型，并通过Globals.getGlobalsByLState(long)方法获取虚拟机");
            this.name = GLOBALS_PACKAGE;
        }
        this.name = name;
        isVoid = Void.equals(name);
        if (isVoid)
            return;
        isLong = "long".equals(name);
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

    public String jniName() {
        if (isPrimitive) {
            return "j" + name;
        }
        if (isString) {
            return "jstring";
        }
        return "jobject";
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Type)) return false;
        Type type = (Type) o;
        return isPrimitive == type.isPrimitive &&
                isVoid == type.isVoid &&
                isArray == type.isArray &&
                isString == type.isString &&
                isGlobals == type.isGlobals &&
                isLong == type.isLong &&
                primitiveType == type.primitiveType &&
                name.equals(type.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(isPrimitive, primitiveType, isVoid, isArray, isString, isGlobals, isLong, name);
    }
}