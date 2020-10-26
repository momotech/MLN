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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

import static com.xfy.shell.Template.*;
import static com.xfy.shell.ReturnGenerator.*;

/**
 * Created by Xiong.Fangyu on 2020-02-12
 */
public class NativeGenerator {
    private static final String STATIC_GETID = " = (*env)->GetStaticMethodID(env, clz, \"";
    private static final String NORMAL_GETID = " = (*env)->GetMethodID(env, clz, \"";
    private final boolean useStatic;
    private final String code;
    private final Parser parser;

    public NativeGenerator(Parser parser) {
        this.parser = parser;
        useStatic = parser.isStatic();
        StringBuilder sb = new StringBuilder(Template.CreatedByGenerator).append(getDate()).append('\n')
                .append(!useStatic ? Template.UserdataStart : Template.StaticStart)
                .append(Template.statisticHeader);
        List<String> luaClassNames = parser.getLuaClassName();
        if (luaClassNames == null)
            throw new IllegalArgumentException("找不到LUA_CLASS_NAME，请在"+ parser.getClassName()+"类中声明参数");
        if (luaClassNames.size() > 1) {
            for (int i = 0; i < luaClassNames.size(); i ++) {
                if (i == 0) {
                    sb.append(String.format(Template.DefineLuaClassName, "_C_" + parser.getSimpleClassName()));
                }
                sb.append(String.format(DefineMultiLuaClassName, i, luaClassNames.get(i)));
            }
        } else {
            sb.append(String.format(Template.DefineLuaClassName, luaClassNames.get(0)));
        }
        sb.append(!useStatic ? Template.DefineMetaName : "")
                .append(Template.MethodCom);
        /// fillUDMetatable函数中_methohds的定义
        StringBuilder meta = new StringBuilder();
        /// _init函数实现
        StringBuilder init = new StringBuilder();

        List<Method> methods = parser.getMethods();
        List<Method> constructor = new ArrayList<>();
        Iterator<Method> iterator = methods.iterator();
        while (iterator.hasNext()) {
            Method m = iterator.next();
            if (m.isConstructor) {
                iterator.remove();
                if (m.getCGenerate() != null)
                    constructor.add(m);
            }
        }
        if (parser.isAbstract()) {
            constructor.clear();
        }
        final int cLen = constructor.size();
        /// if (pc == x) { javaObj = xxxxxx }
        StringBuilder newObjByConstructor = new StringBuilder();
        /// 特殊构造函数实现
        if (cLen > 0) {
            boolean hasDefaultConstructor = false;
            constructor.sort(null);
            /// 每个构造函数的签名，错误输出时使用
            StringBuilder constructorsSig = new StringBuilder();
            for (int i = 0; i < constructor.size(); i++) {
                Method m = constructor.get(i);
                CGenerate cGenerate = m.getCGenerate();
                hasDefaultConstructor = cGenerate.isDefaultConstructor();
                sb.append(String.format(ConstructorDefine, i));
                methods.remove(m);
                appendTab(init, 1).append(String.format(ConstructorFind, i, m.getParamsSig()));
                int pl = m.params.length - 1;
                Type[] ps = Arrays.copyOfRange(m.params, 1, pl + 1);
                boolean inJudge = false;
                if (i == 0) {
                    if (hasDefaultConstructor) {
                        appendTab(newObjByConstructor, 1).append("jobject javaObj = NULL;\n");
                    } else {
                        newObjByConstructor.append(NewJavaObjImpl_Top);
                        appendTab(newObjByConstructor, 1)
                                .append("if (pc == ")
                                .append(ps.length)
                                .append(") {\n");
                        constructorsSig.append(parser.getFirstLuaClassName()).append('(');
                        inJudge = true;
                    }
                } else if (hasDefaultConstructor) {
                    newObjByConstructor.append(" else {\n");
                    inJudge = true;
                } else {
                    newObjByConstructor.append(" else if (pc == ")
                            .append(ps.length)
                            .append(") {\n");
                    constructorsSig.append(';').append(parser.getFirstLuaClassName()).append('(');
                    inJudge = true;
                }
                for (int j = 0; j < pl; j ++) {
                    if (j != 0)
                        constructorsSig.append(',');
                    constructorsSig.append(ps[j].getSimpleName());
                }
                constructorsSig.append(')');
                StringBuilder callParams = new StringBuilder();
                StringBuilder freeSb = new StringBuilder();
                CGenerate.SpecialType[] sps = cGenerate.getParamType();
                if (sps != null && sps.length > 1) {
                    sps = Arrays.copyOf(sps, sps.length - 1);
                }
                luaToNative(newObjByConstructor, callParams, freeSb, ps, sps, inJudge ? 2 : 1, 1, m.name, true);
                appendTab(newObjByConstructor, inJudge ? 2 : 1);
                newObjByConstructor.append(String.format(NewJavaObjPre, i))
                        .append(callParams)
                        .append(");\n");
                if (freeSb.length() > 0) {
                    replaceTab(freeSb, inJudge ? 2 : 1);
                    newObjByConstructor.append(freeSb).append('\n');
                }
                if (i != 0 || !hasDefaultConstructor)
                    appendTab(newObjByConstructor, 1).append('}');
                if (hasDefaultConstructor)
                    break;
            }
            if (!hasDefaultConstructor) {
                newObjByConstructor.append(" else {\n")
                        .append(String.format(ConstructorParamsCountError, constructorsSig.toString()));
                appendTab(newObjByConstructor, 1).append("}\n");
            }
        }

        sb.append(MethodDefineFolderStart);
        int size = methods.size();
        StringBuilder[] methodImpl = new StringBuilder[size];
        int[] jumpIndex = new int[size >> 1];
        int jumpSize = 0;

        int initStatus = 0;
        String getMethodId = useStatic ? STATIC_GETID : NORMAL_GETID;
        for (int i = 0; i < size; i ++) {
            if (Arrays.binarySearch(jumpIndex, 0, jumpSize, i) >= 0)
                continue ;

            Method m = methods.get(i);
            if (m.isNative) {
                if (m.name.equals("_init")) {
                    initStatus |= 1;
                } else if (m.name.equals("_register")) {
                    initStatus |= 2;
                }
            }
            if (!validMethod(m)) {
                continue;
            }
            String luaFunName = m.name;
            String alias = null;
            CGenerate cGenerate = m.getCGenerate();
            if (cGenerate != null) {
                alias = cGenerate.alias();
                if (alias != null && alias.length() > 0) {
                    luaFunName = alias;
                } else {
                    alias = null;
                }
            }

            Method otherMethod = getCorrespondingMethod(m, methods, jumpIndex, jumpSize);
            List<Method> sameNameMethods = null;

            if (otherMethod != null) {
                jumpSize ++;
                Arrays.sort(jumpIndex, 0, jumpSize);
                m.jmethodID = m.name + "ID";
                otherMethod.jmethodID = otherMethod.name + "ID";
                sb.append("static jmethodID ").append(m.jmethodID).append(";\n");
                sb.append("static jmethodID ").append(otherMethod.jmethodID).append(";\n");
                if (alias == null)
                    luaFunName = StringReplaceUtils.changeFirstLetterLow(m.getNameWithoutPrefix());
            } else {
                sameNameMethods = getSameNameMethod(methods, i, jumpIndex, jumpSize);
                if (sameNameMethods != null) {
                    jumpSize += sameNameMethods.size();
                    m.jmethodID = m.name + "0ID";
                    sb.append("static jmethodID ").append(m.jmethodID).append(";\n");
                    int idx = 0;
                    for (Method snm : sameNameMethods) {
                        idx ++;
                        snm.jmethodID = snm.name + idx + "ID";
                        sb.append("static jmethodID ").append(snm.jmethodID).append(";\n");
                    }
                } else {
                    m.jmethodID = m.name + "ID";
                    sb.append("static jmethodID ").append(m.jmethodID).append(";\n");
                }
            }

            sb.append("static int _").append(luaFunName).append("(lua_State *L);\n");

            appendTab(meta, 3).append("{\"").append(luaFunName).append("\", _").append(luaFunName).append("},\n");

            if (otherMethod != null) {
                appendTab(init, 1).append(m.jmethodID).append(getMethodId)
                        .append(m.name).append("\", \"").append(m.getMethodSig()).append("\");\n");
                appendTab(init, 1).append(otherMethod.jmethodID).append(getMethodId)
                        .append(otherMethod.name).append("\", \"").append(otherMethod.getMethodSig()).append("\");\n");
            } else if (sameNameMethods != null) {
                appendTab(init, 1).append(m.jmethodID).append(getMethodId)
                        .append(m.name).append("\", \"").append(m.getMethodSig()).append("\");\n");
                for (Method snm : sameNameMethods) {
                    appendTab(init, 1).append(snm.jmethodID).append(getMethodId)
                            .append(snm.name).append("\", \"").append(snm.getMethodSig()).append("\");\n");
                }
            } else {
                appendTab(init, 1).append(m.jmethodID).append(getMethodId)
                        .append(m.name).append("\", \"").append(m.getMethodSig()).append("\");\n");
            }

            StringBuilder impl = new StringBuilder("/**\n");
            /// 生成注释
            if (otherMethod != null) {
                if (m.isGetter()) {
                    impl.append(" * ").append(m.toSig()).append('\n')
                            .append(" * ").append(otherMethod.toSig()).append('\n');
                } else {
                    impl.append(" * ").append(otherMethod.toSig()).append('\n')
                            .append(" * ").append(m.toSig()).append('\n');
                }
            } else if (sameNameMethods != null) {
                impl.append(" * ").append(m.toSig()).append('\n');
                for (Method snm : sameNameMethods) {
                    impl.append(" * ").append(snm.toSig()).append('\n');
                }
            } else {
                impl.append(" * ").append(m.toSig()).append('\n');
            }

            impl.append(" */\n")
                    .append("static int _").append(luaFunName).append("(lua_State *L) {\n")
                    .append(Template.statisticStart)
                    .append("    PRE\n");
            if (otherMethod != null) {
                appendTab(impl, 1).append(String.format(Template.IF_LUA_PARAMS_COUNT, 1));
                if (m.isGetter()) {
                    impl.append(getMethodImpl(m, 2, false));
                    appendTab(impl, 1).append("}\n")
                        .append(getMethodImpl(otherMethod, 1, false));
                } else {
                    impl.append(getMethodImpl(otherMethod, 2, false));
                    appendTab(impl, 1).append("}\n")
                        .append(getMethodImpl(m, 1, false));
                }
            } else if (sameNameMethods != null) {
                sameNameMethods.add(m);
                sameNameMethods.sort(null);
                while (!sameNameMethods.isEmpty()) {
                    List<Method> sameParamCount = new ArrayList<>();
                    int paramCount = -1;
                    Iterator<Method> it = sameNameMethods.iterator();
                    while (it.hasNext()) {
                        Method a = it.next();
                        int pc = a.params.length;
                        CGenerate mc = a.getCGenerate();
                        pc -= mc != null ? mc.getParamGlobalCount() : 0;
                        if (paramCount == -1 || paramCount == pc) {
                            paramCount = pc;
                            sameParamCount.add(a);
                            it.remove();
                        } else
                            break;
                    }
                    if (!sameNameMethods.isEmpty()) {
                        appendTab(impl, 1).append("REMOVE_TOP(L)\n");
                    }
                    appendTab(impl, 1).append(String.format(Template.IF_LUA_PARAMS_COUNT, paramCount + 1));
                    StringBuilder methodSig = new StringBuilder();
                    boolean hasJudge = false;
                    for (Method tm : sameParamCount) {
                        if (paramCount > 0) {
                            methodSig.append('(');
                            String judge = appendParamsJudge(tm, methodSig);
                            methodSig.append(") ");
                            if (judge.isEmpty()) {
                                hasJudge = false;
                                impl.append(getMethodImpl(tm, 2, true));
                            } else {
                                hasJudge = true;
                                appendTab(impl, 2).append("if (").append(judge).append(") {\n");
                                impl.append(getMethodImpl(tm, 3, true));
                                appendTab(impl, 2).append("}\n");
                            }
                        } else {
                            hasJudge = false;
                            impl.append(getMethodImpl(tm, 2, false));
                        }
                    }
                    if (hasJudge) {
                        String name = sameParamCount.get(0).name;
                        StringBuilder tab = new StringBuilder();
                        appendTab(tab, 2);
                        String error = String.format(MethodParamsCountError, name, paramCount, methodSig.toString()).replace(BLANK, tab);
                        impl.append(error);
                        appendTab(impl, 2).append(ReturnLuaError);
                    }
                    appendTab(impl, 1).append("}\n");
                }
                appendTab(impl, 1).append(String.format(Template.LUA_SET_TOP, 1)).append(";\n");
                appendTab(impl, 1).append("return 1;\n");
            } else {
                impl.append(getMethodImpl(m, 1, false));
            }
            impl.append("}\n");
            methodImpl[i] = impl;
        }
        if (initStatus != 3) {
            throw new RuntimeException("类" + parser.getClassName() + " 必须有public static native void _init()和public static native void _register(long l, String parent)两个方法");
        }
        String className = parser.getPackageName() + "." + parser.getClassName();
        className = StringReplaceUtils.replaceAllChar(className, '.', '_');
        String jniStart = Template.JNIStart.replace("${ClassName}", className);
        String jniEnd;
        if (useStatic) {
            jniEnd = Template.StaticJNIEnd;
        } else {
            final String replacement;
            if (parser.isAbstract()) {
                replacement = "";
            } else if (constructor.size() > 0) {
                if (luaClassNames.size() > 1) {
                    StringBuilder r = new StringBuilder();
                    for (int i = 0; i < luaClassNames.size(); i ++) {
                        r.append(String.format(PushMultiNativeConstructor, i));
                    }
                    replacement = r.toString();
                } else {
                    replacement = PushNativeConstructor;
                }
            } else {
                replacement = PushConstructor;
            }
            jniEnd = Template.UserdataJNIEnd.replace(Template.CONSTRUCTOR, replacement);
        }
        sb.append(Template.EditorEnd);
        if (useStatic) {
            sb.append(Template.METAStart);
        } else {
            sb.append(Template.UDMETAStart);
        }
        sb.append(meta);
        if (useStatic) {
            sb.append(Template.METAEnd);
        } else {
            sb.append(Template.UDMETAEnd);
        }
        if (constructor.size() > 0) {
            sb.append('\n').append(ConstructorFunctionDefine);
        }
        sb.append(jniStart)
                .append(init)
                .append(jniEnd)
                .append(Template.IMPStart);

        for (StringBuilder s : methodImpl) {
            if (s == null)
                continue;
            sb.append(s);
        }

        sb.append(Template.EditorEnd);
        if (constructor.size() > 0) {
            sb.append('\n')
                    .append(ExecuteNewUdImpl)
                    .append('\n')
                    .append(NewJavaObjImpl)
                    .append(newObjByConstructor)
                    .append(NewJavaObjImplEnd);
        }
        code = sb.toString();
    }

    private boolean validMethod(Method m) {
        return m.containLuaApiUsed() && m.isStatic == useStatic && !m.isOldTypeBridge();
    }

    private String appendParamsJudge(Method m, StringBuilder methodSig) {
        CGenerate cg = m.getCGenerate();
        Type[] params = m.params;
        CGenerate.SpecialType[] specialTypes = cg != null ? cg.getParamType() : null;
        int speLen = specialTypes == null ? 0 : specialTypes.length;
        StringBuilder sb = new StringBuilder();
        int skipCount = 0;
        boolean hasJudge = false;
        for (int i = 0, l = params.length; i < l; i ++) {
            CGenerate.SpecialType st = null;
            if (i < speLen) {
                st = specialTypes[i];
            }
            if (st == CGenerate.SpecialType.Globals) {
                skipCount ++;
                continue;
            }
            int idx = i - skipCount;
            Type t = params[i];
            if (idx != 0) {
                if (hasJudge && (t.isPrimitive() || t.isString()))
                    sb.append("&&");
                methodSig.append(',');
            }
            if (t.isPrimitive()) {
                hasJudge = true;
                if (st != null && st != CGenerate.SpecialType.Normal) {
                    switch (st) {
                        case Table:
                            sb.append(String.format(LUA_IS_TABLE, idx + 2));
                            methodSig.append("table");
                            break;
                        case Function:
                            sb.append(String.format(LUA_IS_FUNCTION, idx + 2));
                            methodSig.append("function");
                            break;
                        case Userdata:
                            sb.append(String.format(LUA_IS_USERDATA, idx + 2));
                            methodSig.append("userdata");
                            break;
                    }
                } else if (t.getPrimitiveType() == Type.PrimitiveType.Boolean) {
                    sb.append(String.format(Template.LUA_IS_BOOL, idx + 2));
                    methodSig.append("boolean");
                } else {
                    sb.append(String.format(Template.LUA_IS_NUMBER, idx + 2));
                    methodSig.append(t.getSimpleName());
                }
            } else if (t.isString()) {
                hasJudge = true;
                sb.append(String.format(Template.LUA_IS_STRING, idx + 2));
                methodSig.append(t.getSimpleName());
            } else {
                methodSig.append(t.getSimpleName());
            }
        }
        return sb.toString();
    }

    private List<Method> getSameNameMethod(List<Method> list, int src, int[] jumpIndex, int jumpSize) {
        Method m = list.get(src);
        String name = m.name;
        List<Method> ret = null;
        int oldJumpIndex = jumpSize;
        for (int i = src + 1; i < list.size(); i ++) {
            if (Arrays.binarySearch(jumpIndex, 0, oldJumpIndex, i) >= 0)
                continue;
            Method om = list.get(i);
            if (om.name.equals(name) && validMethod(om)) {
                if (ret == null) {
                    ret = new ArrayList<>();
                }
                ret.add(om);
                jumpIndex[jumpSize ++] = i;
            }
        }
        if (ret != null)
            Arrays.sort(jumpIndex, 0, jumpSize);
        return ret;
    }

    private Method getCorrespondingMethod(Method src, List<Method> list, int[] jumpIndex, int jumpSize) {
        Method ret = null;
        if (src.isSetter()) {
            ret = src.generateGetter();
            int i = list.indexOf(ret);
            if (i >= 0 && validMethod(list.get(i))) {
                jumpIndex[jumpSize] = i;
            } else {
                ret = null;
            }
        } else if (src.isGetter()) {
            String simpleName = src.getNameWithoutPrefix();
            for (int i = 0, l = list.size(); i < l; i ++) {
                if (Arrays.binarySearch(jumpIndex, 0, jumpSize, i) >= 0)
                    continue ;
                ret = list.get(i);
                if (simpleName.equals(ret.getNameWithoutPrefix())
                        && validMethod(ret)
                        && ret.isSetter()
                        && ret.generateGetter().equals(src)) {
                    jumpIndex[jumpSize] = i;
                    break;
                }
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

    private void luaToNative(StringBuilder sb, StringBuilder callParams, StringBuilder freeSb,
                               Type[] params, CGenerate.SpecialType[] sTypes, int tabCount, int luaFrom,
                               String methodName, boolean noNil) {
        int paramsOffset = 0;
        final int len = params.length;
        for (int i = 0; i < len; i ++) {
            Type pt = params[i];
            if (pt.isGlobals()) {
                throw new RuntimeException("类" + parser.getClassName() + "方法" + methodName + "中第" + (i + 1) + "个参数解析错误，请使用long代替Globals");
            }
            int luaParamIndex = i + luaFrom - paramsOffset;
            CGenerate.SpecialType specialType = sTypes != null && sTypes.length > i ? sTypes[i] : null;
            if (specialType != null && specialType != CGenerate.SpecialType.Normal) {
                if (!pt.isLong())
                    throw new RuntimeException("类" + parser.getClassName() + "方法" + methodName + "中第" + (i + 1) + "个参数和注解中CGenerate类型不对应，需要long类型，实际是" + pt.getName());
                switch (specialType) {
                    case Table:
                        appendTab(sb, tabCount).append(String.format(LUA_CHECK_TABLE, luaParamIndex)).append(";\n");
                        appendTab(sb, tabCount).append("jlong p").append(i + 1)
                                .append(" = (jlong) ").append(String.format(TO_GNV, luaParamIndex)).append(";\n");
                        break;
                    case Function:
                        appendTab(sb, tabCount).append(String.format(LUA_CHECK_FUNCTION, luaParamIndex)).append(";\n");
                        appendTab(sb, tabCount).append("jlong p").append(i + 1)
                                .append(" = (jlong) ").append(String.format(TO_GNV, luaParamIndex)).append(";\n");
                        break;
                    case Globals:
                        appendTab(sb, tabCount).append("jlong p").append(i + 1)
                                .append(" = (jlong) L;\n");
                        paramsOffset ++;
                        break;
                    case Userdata:
                        appendTab(sb, tabCount).append(String.format(LUA_CHECK_USERDATA, luaParamIndex)).append(";\n");
                        appendTab(sb, tabCount).append("jlong p").append(i + 1)
                                .append(" = (jlong) ").append(String.format(TO_GNV, luaParamIndex)).append(";\n");
                        break;
                }
            } else {
                /// 从lua栈中获取参数 xxx p${i} = xxxx();
                appendTab(sb, tabCount).append(pt.toCName()).append(" p").append(i + 1)
                        .append(" = ").append(getLuaParam(pt, luaParamIndex, noNil)).append('\n');
            }
            callParams.append(", ");
            if (pt.isPrimitive()) {
                /// 强制转换类型 (jxxx) p
                if (specialType == null || specialType == CGenerate.SpecialType.Normal)
                    callParams.append("(").append(pt.jniName()).append(')');
            } else {
                freeSb.append(BLANK).append("FREE(env, p").append(i + 1).append(");\n");
            }
            callParams.append('p').append(i + 1);
        }
    }

    private String getMethodImpl(Method m, int tabCount, boolean noNil) {
        StringBuilder sb = new StringBuilder();

        /// jni call 参数
        StringBuilder paramsSb = new StringBuilder();
        StringBuilder freeSb = new StringBuilder();
        CGenerate cGenerate = m.getCGenerate();
        CGenerate.SpecialType[] paramSpecialTypes = cGenerate != null ? cGenerate.getParamType() : null;
        luaToNative(sb, paramsSb, freeSb, m.params, paramSpecialTypes, tabCount, 2, m.name, noNil);

        StringBuilder tab = new StringBuilder();
        appendTab(tab, tabCount);

        StringBuilder freeSbClone = new StringBuilder(freeSb);
        replaceTab(freeSb, tabCount);
        String freeCode = freeSb.toString();
        replaceTab(freeSbClone, tabCount + 1);
        String freeCodeInCatch = freeSbClone.toString();

        sb.append(ReturnGenerator.callMethodAndReturn(m, tabCount, paramsSb, freeCode, freeCodeInCatch));

        return sb.toString();
    }

    private static String getLuaParam(Type t, int index, boolean noNil) {
        if (t.isPrimitive()) {
            switch (t.getPrimitiveType()) {
                case Boolean:
                    return "lua_toboolean(L, " + index + ");";
                case Number:
                    return "luaL_checknumber(L, " + index + ");";
                default:
                    return "luaL_checkinteger(L, " + index + ");";
            }
        }
        if (t.isString()) {
            if (noNil) {
                return String.format("newJString(env, lua_tostring(L, %d));", index);
            } else
                return String.format(LUA_IS_NIL + " ? NULL : newJString(env, lua_tostring(L, %d));", index, index);
        }
        if (noNil) {
            return String.format("toJavaValue(env, L, %d);", index);
        }
        return String.format(LUA_IS_NIL + " ? NULL : toJavaValue(env, L, %d);", index, index);
    }

    @Override
    public String toString() {
        return code;
    }
}
