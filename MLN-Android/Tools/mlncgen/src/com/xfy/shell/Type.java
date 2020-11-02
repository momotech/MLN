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
public class Type implements Comparable<Type>{
    private static final String[] PrimitiveTypes;
    private static final Map<String, Type> PrimitiveTypeMap;
    private static final Map<String, Type> PrimitiveArrTypeMap;

    private static final String Void = "void";

    private static final String CORE_PACKAGE = "org.luaj.vm2";
    private static final String LUAVALUE = "LuaValue";
    private static final String LUAVALUE_PACKAGE = CORE_PACKAGE + "." + LUAVALUE;
    private static final String LUAFUNCTION = "LuaFunction";
    private static final String LUAFUNCTION_PACKAGE = CORE_PACKAGE + "." + LUAFUNCTION;
    private static final String LUATABLE = "LuaTable";
    private static final String LUATABLE_PACKAGE = CORE_PACKAGE + "." + LUATABLE;
    private static final String LUAUSERDATA = "LuaUserdata";
    private static final String LUAUSERDATA_PACKAGE = CORE_PACKAGE + "." + LUATABLE;
    private static final String LUAVALUE_ARR = LUAVALUE + "[]";
    private static final String LUAVALUE_ARR_PACKAGE = CORE_PACKAGE + LUAVALUE_ARR;
    private static final String GLOBALS = "Globals";
    private static final String GLOBALS_PACKAGE = CORE_PACKAGE + "." + GLOBALS;

    private static Type voidType;
    private static Type stringType;
    private static Type globalsType;
    private static Type luaValueType;
    private static Type luaFunctionType;
    private static Type luaTableType;
    private static Type luaUserdataType;

    public static Type VoidType() {
        if (voidType == null)
            voidType = new Type(PrimitiveType.Void, Void);
        return voidType;
    }

    public static Type StringType() {
        if (stringType == null) {
            stringType = new Type();
            stringType.isString = true;
            stringType.name = "java.lang.String";
        }
        return stringType;
    }

    public static Type GlobalsType() {
        if (globalsType == null) {
            globalsType = new Type();
            globalsType.name = GLOBALS_PACKAGE;
            globalsType.isGlobals = true;
        }
        return globalsType;
    }

    public static Type LuaValueType() {
        if (luaValueType == null) {
            luaValueType = new Type();
            luaValueType.name = LUAVALUE_PACKAGE;
            luaValueType.isLuaValue = true;
        }
        return luaValueType;
    }

    public static Type LuaFunctionType() {
        if (luaFunctionType == null) {
            luaFunctionType = new Type();
            luaFunctionType.name = LUAFUNCTION_PACKAGE;
        }
        return luaFunctionType;
    }

    public static Type LuaTableType() {
        if (luaTableType == null) {
            luaTableType = new Type();
            luaTableType.name = LUATABLE_PACKAGE;
        }
        return luaTableType;
    }

    public static Type LuaUserdataType() {
        if (luaUserdataType == null) {
            luaUserdataType = new Type();
            luaUserdataType.name = LUAUSERDATA_PACKAGE;
            luaUserdataType.isUserdata = true;
        }
        return luaUserdataType;
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
        PrimitiveArrTypeMap = new HashMap<>(8);
        for (int i = 0; i < 8; i ++) {
            PrimitiveTypeMap.put(PrimitiveTypes[i], new Type(parse(PrimitiveTypes[i]), PrimitiveTypes[i]));
            Type at = new Type(parse(PrimitiveTypes[i]), PrimitiveTypes[i]);
            at.isArray = true;
            PrimitiveArrTypeMap.put(PrimitiveTypes[i] + "[]", at);
        }
        PrimitiveTypeMap.put("void", VoidType());
    }

    @Override
    public int compareTo(Type o) {
        if (isPrimitive) {
            if (!o.isPrimitive)
                return -1;
            return primitiveType.compareTo(o.primitiveType);
        }
        if (o.isPrimitive)
            return 1;
        if (isString) {
            if (o.isString)
                return 0;
            return -1;
        }
        if (o.isString)
            return 1;
        return 0;
    }

    enum PrimitiveType {
        Boolean,
        Int,
        Number,
        Void
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

    private boolean isPrimitive;
    private PrimitiveType primitiveType;
    private boolean isVoid;
    private boolean isArray;
    private boolean isString;
    private boolean isGlobals;
    private boolean isLong;
    private boolean isLuaValue;
    private boolean isUserdata;
    private String name;

    Type copyOf() {
        Type copy = new Type();
        copy.isPrimitive = isPrimitive;
        copy.primitiveType = primitiveType;
        copy.isVoid = isVoid;
        copy.isArray = isArray;
        copy.isString = isString;
        copy.isGlobals = isGlobals;
        copy.isLong = isLong;
        copy.isLuaValue = isLuaValue;
        copy.name = name;
        return copy;
    }

    public String getSimpleName() {
        if (isPrimitive)
            return name;
        if (isVoid)
            return name;
        if (isString)
            return "String";
        if (isLuaValue)
            return "any";
        int idx = name.lastIndexOf('.');
        if (idx > 0)
            return name.substring(idx + 1);
        return name;
    }

    boolean needAddPackage() {
        return !isVoid && !isString && !isGlobals && !isPrimitive && !isLuaValue;
    }

    boolean isLuaValueArr() {
        return isArray && isLuaValue;
    }

    public static Type getType(String name) {
        Type t;
        t = PrimitiveTypeMap.get(name);
        if (t != null) {
            return t;
        }
        t = PrimitiveArrTypeMap.get(name);
        if (t != null) {
            return t;
        }
        int arrStart = name.indexOf('[');
        if (arrStart > 0) {
            t = getType(name.substring(0, arrStart)).copyOf();
            t.isArray = true;
            return t;
        }
        if ("String".equals(name) || "java.lang.String".equals(name)) {
            return StringType();
        }
        if (GLOBALS.equals(name) || GLOBALS_PACKAGE.equals(name)) {
            return GlobalsType();
        }
        if (LUAVALUE.equals(name) || LUAVALUE_PACKAGE.equals(name)) {
            return LuaValueType();
        }
        if (LUAFUNCTION.equals(name) || LUAFUNCTION_PACKAGE.equals(name)) {
            return LuaFunctionType();
        }
        if (LUATABLE.equals(name) || LUATABLE_PACKAGE.equals(name)) {
            return LuaTableType();
        }
        if (LUAUSERDATA.equals(name) || LUAUSERDATA_PACKAGE.equals(name)) {
            return LuaUserdataType();
        }
        return new Type(name);
    }

    private Type() {}

    private Type(PrimitiveType t, String name) {
        this.name = name;
        this.primitiveType = t;
        if (t == PrimitiveType.Void) {
            isVoid = true;
            return;
        }
        isPrimitive = true;
        isLong = "long".equals(name);
    }

    private Type(String name) {
        isArray = name.charAt(name.length() - 1) == ']';
        if (isArray) {
            name = name.substring(0, name.indexOf('['));
        }
        this.name = name;
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
            if (isArray) {
                return "j" + name + "Array";
            }
            return "j" + name;
        }
        if (isArray)
            return "jobjectArray";
        if (isString) {
            return "jstring";
        }
        if (isVoid)
            return "void";
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

    public boolean setImportPackage(String im) {
        if (im.endsWith(name)) {
            name = im;
            return true;
        }
        return false;
    }

    public void setPackage(String p) {
        name = p + "." + name;
    }

    public boolean isPrimitive() {
        return isPrimitive;
    }

    public PrimitiveType getPrimitiveType() {
        return primitiveType;
    }

    public void setArray() {
        isArray = true;
    }

    public boolean isVoid() {
        return isVoid;
    }

    public boolean isArray() {
        return isArray;
    }

    public boolean isString() {
        return isString;
    }

    public boolean isGlobals() {
        return isGlobals;
    }

    public boolean isLong() {
        return isLong;
    }

    public boolean isLuaValue() {
        return isLuaValue;
    }

    public String getName() {
        return name;
    }

    public boolean isUserdata() {
        return isUserdata;
    }
}