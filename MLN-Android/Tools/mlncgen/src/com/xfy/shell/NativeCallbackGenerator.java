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

/**
 * Created by Xiong.Fangyu on 2020/7/27
 */
public class NativeCallbackGenerator {
    private static final String _Void_Call = "_Void_Call";
    private static final String _Method = "_Method";
    private static final String _PRE4PARAMS = "_PRE4PARAMS";

    private String code;

    public NativeCallbackGenerator(Parser parser) {
        StringBuilder sb = new StringBuilder(Template.CreatedByGenerator).append(getDate()).append('\n')
                .append(Template.CallbackInclude);
        String className = parser.getClassName();
        String voidCall = className + _Void_Call;
        String methodCall = className + _Method;
        String paramCall = className + _PRE4PARAMS;
        String jniClassName = StringReplaceUtils.replaceAllChar(parser.getPackageName(), '.', '_') + "_" + className;
        sb.append(String.format(Template.VoidCallDef, voidCall))
                .append(String.format(Template.MethodDef, methodCall, jniClassName))
                .append(String.format(Template.Pre4ParamsDef, paramCall))
                .append(Template.PushNumberAndStringDef);

        List<Method> methods = parser.getMethods();
        for (Method m : methods) {
            if (!m.isNative)
                continue;
            Type[] params = m.params;
            if (!checkParams(params))
                continue;
            sb.append(voidCall)
                    .append(' ')
                    .append(methodCall)
                    .append('(')
                    .append(m.name)
                    .append(")(")
                    .append(paramCall)
                    .append(' ');
            int l = params.length;
            String[] pushParams = new String[l - 2];
            for (int i = 2; i < l; i ++) {
                Type p = params[i];
                if (i != 2) {
                    sb.append(',');
                }
                sb.append(p.jniName()).append(" p").append(i - 1);
                pushParams[i - 2] = pushParam(p, "p" + (i - 1));
            }
            sb.append(") {\n")
                    .append("    lua_State *L = (lua_State *) Ls;\n")
                    .append("    check_and_call_method(L, ")
                    .append(l - 2)
                    .append(", {\n");
            for (String pp : pushParams) {
                sb.append("        ").append(pp).append('\n');
            }
            sb.append("    })\n").append("}\n");
        }
        code = sb.toString();
    }

    private final static Type B = Type.getType("boolean");
    private final static Type F = Type.getType("float");
    private final static Type D = Type.getType("double");
    private static String pushParam(Type t, String pname) {
        if (t == B) {
            return "lua_pushboolean(L, (int)" + pname + ");";
        }
        if (t == F || t == D) {
            return "push_number(L, " + pname + ");";
        }
        if (t.isString) {
            return "push_string(env, L, " + pname + ");";
        }
        return "lua_pushinteger(L, (int)" + pname + ");";
    }

    private static boolean checkParams(Type[] types) {
        /// 至少要3个参数
        if (types.length <= 2) {
            return false;
        }
        Type longType = Type.getType("long");
        if (types[0] != longType || types[1] != longType)
            return false;
        for (int i = 2, l = types.length; i < l; i++) {
            if (!types[i].isPrimitive && !types[i].isString)
                return false;
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
