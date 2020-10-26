/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.shell;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import static com.xfy.shell.Template.*;

/**
 * Created by Xiong.Fangyu on 2020/7/27
 */
public class NativeCallbackGenerator {
    private static final String _Call = "_Call(%s)";
    private static final String _Method = "_Method(%s)";
    private static final String _PRE4PARAMS = "_PRE4PARAMS";
    private String code;

    public NativeCallbackGenerator(Parser parser) {
        StringBuilder sb = new StringBuilder(Template.CreatedByGenerator).append(getDate()).append('\n')
                .append(Template.CallbackInclude);
        String className = parser.getClassName();
        String jniClassName = StringReplaceUtils.replaceAllChar(parser.getPackageName(), '.', '_') + "_" + className;
        sb.append(CallDef)
                .append(String.format(Template.MethodDef, jniClassName))
                .append(Template.Pre4ParamsDef)
                .append(Template.PushNumberAndStringDef);

        List<Method> methods = parser.getMethods();
        for (Method m : methods) {
            if (!m.isNative)
                continue;
            Type[] params = m.params;
            if (!checkParams(m, params))
                continue;
            Type rType = m.returnType;
            sb.append(String.format(_Call, rType.jniName()))
                    .append(' ')
                    .append(String.format(_Method, m.name.replace("_", "_1")))
                    .append('(')
                    .append(_PRE4PARAMS);
            int l = params.length;
            String[] pushParams = new String[l - 2];
            CGenerate cGenerate = m.getCGenerate();
            CGenerate.SpecialType[] specialTypes = cGenerate != null ? cGenerate.getParamType() : null;
            int specialLen = specialTypes != null ? specialTypes.length : 0;
            String defaultReturn = ReturnGenerator.defaultReturn(rType, cGenerate != null ? cGenerate.getReturnType() : null);
            for (int i = 2; i < l; i ++) {
                Type p = params[i];
                sb.append(',').append(p.jniName()).append(" p").append(i - 1);
                pushParams[i - 2] = pushParam(p, (i < specialLen ? specialTypes[i] : null), "p" + (i - 1), defaultReturn);
            }
            sb.append(") {\n    lua_State *L = (lua_State *) Ls;\n");
            if (rType.isVoid()) {
                sb.append("    check_and_call_method(L, ")
                        .append(l - 2)
                        .append(", {\n");
                for (String pp : pushParams) {
                    sb.append("        ").append(pp).append('\n');
                }
                sb.append("    })\n").append("}\n");
            } else {
                sb.append("    ").append(rType.jniName()).append(" fr = ")
                        .append(defaultReturn)
                        .append(";\n");
                sb.append("    call_method_return(L, ").append(l - 2).append(", 1, {\n");
                for (String pp : pushParams) {
                    sb.append("        ").append(pp).append('\n');
                }
                sb.append("    },{\n");
                if (rType.isPrimitive()) {
                    switch (rType.getPrimitiveType()) {
                        case Int:
                        case Number:
                            sb.append("        if (").append(String.format(LUA_IS_NUMBER, -1)).append(")\n")
                            .append("            fr = (").append(rType.jniName()).append(") lua_tonumber(L, -1);\n");
                            break;
                        case Boolean:
                            sb.append("        fr = lua_toboolean(L, -1);\n");
                    }
                } else if (rType.isString()) {
                    sb.append("        if (").append(String.format(LUA_IS_STRING, -1)).append(")\n")
                            .append("            fr = newJString(env, lua_tostring(L, -1));\n");
                } else {
                    sb.append("        fr = toJavaValue(env, L, -1);\n");
                }
                sb.append("    }, return fr)\n")
                        .append("    return fr;\n")
                        .append("}\n");
            }
        }
        code = sb.toString();
    }

    private final static Type B = Type.getType("boolean");
    private final static Type F = Type.getType("float");
    private final static Type D = Type.getType("double");
    private static String pushParam(Type t, CGenerate.SpecialType sp, String pname, String dr) {
        if (sp != null && sp != CGenerate.SpecialType.Normal) {
            if (!t.isLong())
                throw new IllegalArgumentException("设置传入参数为" + sp + "时，类型必须时long");
            switch (sp) {
                case Table:
                    return String.format(PUSH_NATIVE_VALUE, pname, LUA_TABLE, pname, sp.toString(), pname, dr).replace(BLANK, "        ");
                case Function:
                    return String.format(PUSH_NATIVE_VALUE, pname, LUA_FUNCTION, pname, sp.toString(), pname, dr).replace(BLANK, "        ");
                case Userdata:
                    return String.format(PUSH_NATIVE_VALUE, pname, LUA_USERDATA, pname, sp.toString(), pname, dr).replace(BLANK, "        ");
            }
        }
        if (t.isPrimitive()) {
            if (t == B) {
                return "lua_pushboolean(L, (int)" + pname + ");";
            }
            if (t == F || t == D) {
                return "push_number(L, " + pname + ");";
            }
            return "lua_pushinteger(L, (lua_Integer)" + pname + ");";
        }
        if (t.isString()) {
            return "push_string(env, L, " + pname + ");";
        }
        if (t.equals(Type.LuaTableType()))
            throw new IllegalArgumentException("请使用long代替LuaTable");
        return "pushUserdataFromJUD(env, L, "+pname+");";
    }

    private static boolean checkParams(Method m, Type[] types) {
        /// 至少要2个参数
        if (types.length < 2) {
            return false;
        }
        Type longType = Type.getType("long");
        if (types[0] != longType || types[1] != longType)
            return false;
        for (int i = 2, l = types.length; i < l; i++) {
            if (!types[i].isPrimitive() && !types[i].isString() && !types[i].isUserdata()) {
                System.err.println("只支持基础数据类型、String和Userdata，方法"+m.name+"第"+i+"个参数类型错误："+types[i]);
                return false;
            }
        }
        return true;
    }

    private static String getDate() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // 日期时间转字符串
        LocalDateTime now = LocalDateTime.now();
        return now.format(formatter);
    }

    @Override
    public String toString() {
        return code;
    }
}
