/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.shell;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import static com.xfy.shell.Template.*;

/**
 * Created by Xiong.Fangyu on 2020/9/24
 */
public class ReturnGenerator {

    public static String defaultReturn(Type rType, CGenerate.SpecialType sp) {
        if (rType.isVoid())
            return "";
        if (sp != null && sp != CGenerate.SpecialType.Normal) {
            switch (sp) {
                case Userdata:
                case Function:
                case Table:
                    return "0";
                case Globals:
                    return "(jlong) L";
            }
        }
        if (rType.isPrimitive()) {
            switch (rType.getPrimitiveType()) {
                case Void:
                    return "";
                default:
                    return "0";
            }
        }
        return "NULL";
    }

    public static String callMethodAndReturn(Method m, int tabCount, CharSequence param, CharSequence freeCode, CharSequence freeCodeInCatch) {
        StringBuilder sb = new StringBuilder();

        StringBuilder tab = new StringBuilder();
        appendTab(tab, tabCount);

        String catchJavaException = String.format(Template.catchJavaException, m.name, freeCodeInCatch).replace(BLANK, tab);

        String statistic = String.format(m.isStatic ? Template.staticStatisticEnd : Template.userdataStatisticEnd, m.name).replace(BLANK, tab);
        Type rType = m.returnType;
        CGenerate cGenerate = m.getCGenerate();
        CGenerate.SpecialType sp = cGenerate != null ? cGenerate.getReturnType() : null;
        if (rType.isVoid()) {
            sb.append(tab).append(getJniCall(m.isStatic, rType)).append(m.jmethodID).append(param).append(");\n")
                    .append(catchJavaException)
                    .append(freeCode)
                    .append(tab).append(String.format(LUA_SET_TOP, 1)).append(";\n")
                    .append(statistic)
                    .append(tab).append("return 1;\n");
        } else {
            StringBuilder returnCount = new StringBuilder();
            sb.append(tab).append(rType.jniName()).append(" ret = ").append(getJniCall(m.isStatic, rType)).append(m.jmethodID).append(param).append(");\n")
                    .append(catchJavaException)
                    .append(freeCode)
                    .append(noneVoidReturnGenerate(returnCount, rType, sp, tabCount))
                    .append(statistic)
                    .append(tab).append("return ").append(returnCount).append(";\n");
        }
        return sb.toString();
    }

    public static String noneVoidReturnGenerate(StringBuilder returnCount, Type rType, CGenerate.SpecialType sp, int tabCount) {
        if (rType.isVoid())
            throw new IllegalArgumentException();

        StringBuilder ret = new StringBuilder();
        if (rType.isArray()) {
            appendTab(ret, tabCount).append(GetArrayLength);
            StringBuilder tab = new StringBuilder();
            appendTab(tab, tabCount);
            if (rType.isPrimitive()) {
                String name = rType.getName();
                String upName = StringReplaceUtils.changeFirstLetterToUpperCase(name);
                appendTab(ret, tabCount).append(String.format(GetPrimitiveArray, name, upName));
                String pushCode;
                switch (rType.getPrimitiveType()) {
                    case Boolean:
                        pushCode = "lua_pushboolean(L, arr[i]);";
                        break;
                    case Number:
                        pushCode = "push_number(L, (jdouble)arr[i]);";
                        break;
                    default:
                        pushCode = "lua_pushinteger(L, (lua_Integer) arr[i])";
                }
                ret.append(String.format(TraverseArr, pushCode).replace(BLANK, tab.toString()));
                appendTab(ret, tabCount).append(String.format(ReleasePrimitiveArray, upName));
            } else {
                StringBuilder pushCode = new StringBuilder(GetObjectArray);
                if (rType.isString())
                    appendTab(pushCode, tabCount + 1).append("push_string(env, L, (jstring) t);\n");
                else
                    appendTab(pushCode, tabCount + 1).append("pushJavaValue(env, L, t);\n");
                appendTab(pushCode, tabCount + 1).append("FREE(env, t);");
                ret.append(String.format(TraverseArr, pushCode.toString()).replace(BLANK, tab.toString()));
                appendTab(ret, tabCount).append("FREE(env, ret);\n");
            }
            returnCount.append("size");
            return ret.toString();
        }
        if (rType.isPrimitive()) {
            appendTab(ret, tabCount);
            if (sp != null && sp != CGenerate.SpecialType.Normal) {
                switch (sp) {
                    case Function:
                        ret.append(String.format(GET_GNV, LUA_FUNCTION));
                        break;
                    case Table:
                        ret.append(String.format(GET_GNV, LUA_TABLE));
                        break;
                    case Userdata:
                        ret.append(String.format(GET_GNV, LUA_USERDATA));
                        break;
                }
            } else {
                switch (rType.getPrimitiveType()) {
                    case Number:
                        ret.append("push_number(L, (jdouble) ret);\n");
                        break;
                    case Boolean:
                        ret.append("lua_pushboolean(L, (int) ret);\n");
                        break;
                    default:
                        ret.append("lua_pushinteger(L, (lua_Integer) ret);\n");
                }
            }
        } else {
            if (rType.isString())
                appendTab(ret, tabCount).append("pushJavaString(env, L, ret);\n");
            else
                appendTab(ret, tabCount).append("pushJavaValue(env, L, ret);\n");
            appendTab(ret, tabCount).append("FREE(env, ret);\n");
        }
        returnCount.append("1");
        return ret.toString();
    }

    static StringBuilder appendTab(StringBuilder sb, int tabCount) {
        while (tabCount -- > 0){
            sb.append("    ");
        }
        return sb;
    }

    static void replaceTab(StringBuilder sb, int tabCount) {
        String tabStr = appendTab(new StringBuilder(), tabCount).toString();

        replaceStringBuilder(sb, BLANK, tabStr);
    }

    static void replaceStringBuilder(StringBuilder sb, String key, String replacement) {
        Pattern pattern = Pattern.compile(key, Pattern.LITERAL);
        Matcher matcher = pattern.matcher(sb);
        while (matcher.find(0)) {
            sb.replace(matcher.start(), matcher.end(), replacement);
        }
    }
    private static String getJniCall(boolean useStatic, Type rt) {
        if (useStatic) {
            if ((rt.isPrimitive() || rt.isVoid()) && !rt.isArray()) {
                return "(*env)->CallStatic" + getFirstUpper(rt.getName()) + "Method(env, _globalClass, ";
            }
            return "(*env)->CallStaticObjectMethod(env, _globalClass, ";
        }
        if ((rt.isPrimitive() || rt.isVoid()) && !rt.isArray()) {
            return "(*env)->Call" + getFirstUpper(rt.getName()) + "Method(env, jobj, ";
        }
        return "(*env)->CallObjectMethod(env, jobj, ";
    }

    static String getFirstUpper(String str) {
        char[] cs = str.toCharArray();
        cs[0] += 'A' - 'a';
        return new String(cs);
    }
}
