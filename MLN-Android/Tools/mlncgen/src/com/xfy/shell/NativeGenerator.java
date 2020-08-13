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
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static com.xfy.shell.Template.BLANK;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public class NativeGenerator {
    private static final String ANNOTATION = "@LuaApiUsed";
    private boolean useStatic;
    private String code;

    public NativeGenerator(Parser parser) {
        useStatic = parser.isStatic();
        StringBuilder sb = new StringBuilder(Template.CreatedByGenerator).append(getDate()).append('\n')
                .append(!useStatic ? Template.UserdataStart : Template.StaticStart)
                .append(Template.statisticHeader)
                .append(String.format(Template.DefineLuaClassName, parser.getLuaClassName()))
                .append(Template.MethodCom);
        StringBuilder meta = new StringBuilder();
        StringBuilder init = new StringBuilder();

        List<Method> methods = parser.getMethods();
        int size = methods.size();
        StringBuilder[] methodImpl = new StringBuilder[size];
        int[] jumpIndex = new int[size >> 1];
        int jumpSize = 0;

        String getMethodId = useStatic ? "ID = (*env)->GetStaticMethodID(env, clz, \"" : "ID = (*env)->GetMethodID(env, clz, \"";
        start: for (int i = 0; i < size; i ++) {
            for (int j = 0; j < jumpSize; j ++) {
                if (i == jumpIndex[j]) {
                    continue start;
                }
            }

            Method m = methods.get(i);
            if (!m.containAnnotation(ANNOTATION)) {
                continue;
            }
            String luaFunName = m.name;

            Method otherMethod = getCorrespondingMethod(m, methods, jumpIndex, jumpSize);

            sb.append("static jmethodID ").append(m.name).append("ID;\n");
            if (otherMethod != null) {
                jumpSize ++;
                sb.append("static jmethodID ").append(otherMethod.name).append("ID;\n");
                luaFunName = StringReplaceUtils.changeFirstLetterLow(m.getNameWithoutPrefix());
            }

            sb.append("static int _").append(luaFunName).append("(lua_State *L);\n");

            meta.append("            {\"").append(luaFunName).append("\", _").append(luaFunName).append("},\n");

            init.append("    ").append(m.name).append(getMethodId)
                    .append(m.name).append("\", \"").append(getMethodSig(m)).append("\");\n");
            if (otherMethod != null) {
                init.append("    ").append(otherMethod.name).append(getMethodId)
                        .append(otherMethod.name).append("\", \"").append(getMethodSig(otherMethod)).append("\");\n");
            }

            StringBuilder impl = new StringBuilder("/**\n");
            if (otherMethod != null) {
                if (m.isGetter()) {
                    impl.append(" * ").append(m.toSig()).append('\n')
                            .append(" * ").append(otherMethod.toSig()).append('\n');
                } else {
                    impl.append(" * ").append(otherMethod.toSig()).append('\n')
                            .append(" * ").append(m.toSig()).append('\n');
                }
            } else {
                impl.append(" * ").append(m.toSig()).append('\n');
            }
            impl.append(" */\n")
                    .append("static int _").append(luaFunName).append("(lua_State *L) {\n")
                    .append(Template.statisticStart)
                    .append("    PRE\n");
            if (otherMethod != null) {
                impl.append(Template.GETTER_PRE);
                if (m.isGetter()) {
                    impl.append(getMethodImpl(m, 2))
                        .append("    }\n")
                        .append(getMethodImpl(otherMethod, 1));
                } else {
                    impl.append(getMethodImpl(otherMethod, 2))
                        .append("    }\n")
                        .append(getMethodImpl(m, 1));
                }
            } else {
                impl.append(getMethodImpl(m, 1));
            }
            impl.append("}\n");
            methodImpl[i] = impl;
        }
        String className = parser.getPackageName() + "." + parser.getClassName();
        className = StringReplaceUtils.replaceAllChar(className, '.', '_');
        String jniStart = Template.JNIStart.replace("${ClassName}", className);
        String jniEnd = useStatic ? Template.StaticJNIEnd.replace("${ClassName}", className)
                : Template.UserdataJNIEnd.replace("${ClassName}", className);
        sb.append(Template.EditorEnd)
                .append(Template.METAStart)
                .append(meta)
                .append(Template.METAEnd)
                .append(jniStart)
                .append(init)
                .append(jniEnd)
                .append(Template.IMPStart);

        for (StringBuilder s : methodImpl) {
            if (s == null)
                continue;
            sb.append(s);
        }

        sb.append(Template.EditorEnd);

        code = sb.toString();
    }

    private Method getCorrespondingMethod(Method src, List<Method> list, int[] jumpIndex, int jumpSize) {
        Method ret = null;
        if (src.isSetter()) {
            ret = src.generateGetter();
            int i = list.indexOf(ret);
            if (i >= 0) {
                jumpIndex[jumpSize] = i;
            } else {
                ret = null;
            }
        } else if (src.isGetter()) {
            ret = src.generateSetter();
            int i = list.indexOf(ret);
            if (i >= 0) {
                jumpIndex[jumpSize] = i;
            } else {
                ret = null;
            }
        }
        return ret;
    }

    private static String getDate() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // 日期时间转字符串
        LocalDateTime now = LocalDateTime.now();
        return now.format(formatter);
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

    public static final String getMethodSig(Method m) {
        Type[] params = m.params;
        StringBuilder sb = new StringBuilder().append('(');

        for (Type p : params) {
            appendType(sb, p);
        }

        sb.append(')');
        appendType(sb, m.returnType);

        return sb.toString();
    }

    private static final void appendType(StringBuilder sb, Type p) {
        if (p.isArray)
            sb.append('[');
        if (p.isPrimitive || p.isVoid) {
            sb.append(primitive.get(p.name));
        } else {
            sb.append('L').append(StringReplaceUtils.replaceAllChar(p.name, '.', '/')).append(';');
        }
    }

    private static void appendTab(StringBuilder sb, int tabCount) {
        for (int i = 0; i < tabCount; i ++) {
            sb.append("    ");
        }
    }

    private static void replaceStringBuilder(StringBuilder sb, String key, String replacement) {
        Pattern pattern = Pattern.compile(key, Pattern.LITERAL);
        Matcher matcher = pattern.matcher(sb);
        while (matcher.find()) {
            sb.replace(matcher.start(), matcher.end(), replacement);
        }
    }

    private static void replaceTab(StringBuilder sb, int tabCount) {
        StringBuilder tab = new StringBuilder();
        appendTab(tab, tabCount);
        String tabStr = tab.toString();

        replaceStringBuilder(sb, BLANK, tabStr);
    }

    private String getMethodImpl(Method m, int tabCount) {
        StringBuilder sb = new StringBuilder();
        Type[] params = m.params;
        Type rType = m.returnType;
        int len = params.length;

        StringBuilder paramsSb = new StringBuilder();
        StringBuilder freeSb = new StringBuilder();
        int paramsOffset = 0;
        for (int i = 0; i < len; i ++) {
            Type pt = params[i];
            if (pt.isGlobals) {
                throw new RuntimeException("方法" + m.name + "中第" + (i + 1) + "个参数解析错误，请使用long代替Globals");
            }
            if (i == 0 && useStatic && pt.isLong) {
                paramsOffset = -1;
                paramsSb.append(", (jlong) L");
                continue;
            }
            appendTab(sb, tabCount);
            sb.append(pt.toCName()).append(" p").append(i + 1 + paramsOffset)
                    .append(" = ").append(getLuaParam(pt, i + paramsOffset + 2)).append('\n');
            paramsSb.append(", ");
            if (pt.isPrimitive)
                paramsSb.append("(j").append(pt.name).append(')');
            else
                freeSb.append(BLANK).append("FREE(env, p").append(i + 1 + paramsOffset).append(");\n");
            paramsSb.append('p').append(i + paramsOffset + 1);
        }
        StringBuilder tab = new StringBuilder();
        appendTab(tab, tabCount);

        StringBuilder freeSbClone = new StringBuilder(freeSb);
        replaceTab(freeSb, tabCount);
        String freeCode = freeSb.toString();
        replaceTab(freeSbClone, tabCount + 1);
        String freeCodeInCatch = freeSbClone.toString();

        String catchJavaException = String.format(Template.catchJavaException, m.name, freeCodeInCatch).replace(BLANK, tab);

        String statistic = String.format(useStatic ? Template.staticStatisticEnd : Template.userdataStatisticEnd, m.name);
        if (rType.isVoid) {
            sb.append(tab).append(getJniCall(rType)).append(m.name).append("ID").append(paramsSb).append(");\n")
                    .append(catchJavaException)
                    .append(freeCode)
                    .append(tab).append("lua_settop(L, 1);\n")
                    .append(statistic)
                    .append(tab).append("return 1;\n");
        } else if (rType.isPrimitive) {
            sb.append(tab).append("j").append(rType.name).append(" ret = ").append(getJniCall(rType)).append(m.name).append("ID").append(paramsSb).append(");\n")
                    .append(catchJavaException)
                    .append(freeCode);
            sb.append(tab);
            switch (rType.primitiveType) {
                case Number:
                    sb.append("lua_pushnumber(L, (lua_Number) ret);\n");
                    break;
                case Boolean:
                    sb.append("lua_pushboolean(L, (int) ret);\n");
                    break;
                default:
                    sb.append("lua_pushinteger(L, (lua_Integer) ret);\n");
            }
            sb.append(statistic)
                    .append(tab).append("return 1;\n");
        } else if (rType.isString) {
            sb.append(tab).append("jobject ret = ").append(getJniCall(rType)).append(m.name).append("ID").append(paramsSb).append(");\n")
                    .append(catchJavaException)
                    .append(freeCode)
                    .append(tab).append("pushJavaString(env, L, ret);\n")
                    .append(tab).append("FREE(env, ret);\n")
                    .append(statistic)
                    .append(tab).append("return 1;\n");
        } else {
            sb.append(tab).append("jobject ret = ").append(getJniCall(rType)).append(m.name).append("ID").append(paramsSb).append(");\n")
                    .append(catchJavaException)
                    .append(freeCode)
                    .append(tab).append("pushJavaValue(env, L, ret);\n")
                    .append(tab).append("FREE(env, ret);\n")
                    .append(statistic)
                    .append(tab).append("return 1;\n");
        }

        return sb.toString();
    }

    private static String getLuaParam(Type t, int index) {
        if (t.isPrimitive) {
            switch (t.primitiveType) {
                case Boolean:
                    return "lua_toboolean(L, " + index + ");";
                case Number:
                    return "luaL_checknumber(L, " + index + ");";
                default:
                    return "luaL_checkinteger(L, " + index + ");";
            }
        }
        if (t.isString) {
            return String.format("lua_isnil(L, %d) ? NULL : newJString(env, lua_tostring(L, %d));", index, index);
        }
        return String.format("lua_isnil(L, %d) ? NULL : toJavaValue(env, L, %d);", index, index);
    }

    private String getJniCall(Type rt) {
        if (useStatic) {
            if (rt.isPrimitive || rt.isVoid) {
                return "(*env)->CallStatic" + getFirstUpper(rt.name) + "Method(env, _globalClass, ";
            }
            return "(*env)->CallStaticObjectMethod(env, _globalClass, ";
        }
        if (rt.isPrimitive || rt.isVoid) {
            return "(*env)->Call" + getFirstUpper(rt.name) + "Method(env, jobj, ";
        }
        return "(*env)->CallObjectMethod(env, jobj, ";
    }

    private static String getFirstUpper(String str) {
        char[] cs = str.toCharArray();
        cs[0] += 'A' - 'a';
        return new String(cs);
    }

    @Override
    public String toString() {
        return code;
    }
}
