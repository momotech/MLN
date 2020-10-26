/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.processor;

import com.google.auto.common.MoreElements;
import com.immomo.mls.annotation.CreatedByApt;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.squareup.javapoet.ArrayTypeName;
import com.squareup.javapoet.ClassName;
import com.squareup.javapoet.CodeBlock;
import com.squareup.javapoet.FieldSpec;
import com.squareup.javapoet.JavaFile;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.ParameterizedTypeName;
import com.squareup.javapoet.TypeName;
import com.squareup.javapoet.TypeSpec;

import java.util.ArrayList;
import java.util.List;
import java.util.StringJoiner;

import javax.lang.model.element.Element;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.Name;
import javax.lang.model.element.TypeElement;
import javax.lang.model.element.TypeParameterElement;
import javax.lang.model.element.VariableElement;
import javax.lang.model.type.TypeKind;

/**
 * Created by Xiong.Fangyu on 2019/3/15
 */
class Generator {
    private static final String UD_CLASS_SUFFIX = "_udwrapper";
    private static final String SB_CLASS_SUFFIX = "_sbwrapper";

    private static final String PACKAGE_NAME = "org.luaj.vm2";
    private static final ClassName LuaUserdata = ClassName.get(PACKAGE_NAME, "LuaUserdata");
    private static final ClassName JavaUserdata = ClassName.get(PACKAGE_NAME, "JavaUserdata");
    private static final ClassName LuaApiUsed = ClassName.get(PACKAGE_NAME + ".utils", "LuaApiUsed");
    private static final ClassName Globals = ClassName.get(PACKAGE_NAME, "Globals");
    private static final TypeName LuaValue = ClassName.get(PACKAGE_NAME, "LuaValue");
    private static final TypeName LuaNumber = ClassName.get(PACKAGE_NAME, "LuaNumber");
    private static final TypeName LuaString = ClassName.get(PACKAGE_NAME, "LuaString");
    private static final TypeName LuaTable = ClassName.get(PACKAGE_NAME, "LuaTable");
    private static final TypeName LuaFunction = ClassName.get(PACKAGE_NAME, "LuaFunction");


    private static final TypeName UserdataTranslator = ClassName.get("com.immomo.mls.wrapper", "Translator");
    private static final TypeName PrimitiveArrayUtils = ClassName.get("com.immomo.mls.utils.convert","PrimitiveArrayUtils");
    private static final TypeName ObjectArrayUtils = ClassName.get("org.luaj.vm2.jse", "Utils");

    private static final TypeName LuaValue_Arr = ArrayTypeName.of(LuaValue);

    Type type = Type.UserData;
    TypeElement typeElement;
    boolean abstractClass = false;
    List<NormalElement> normalElements;
    List<PropertyElement> propertyElements;
    Logger logger;
    Generator parent;

    ExecutableElement __onLuaEq;
    ExecutableElement __onLuaGc;
    ExecutableElement __setUserdata;
    ExecutableElement __index;
    ExecutableElement __newindex;

    ClassName baseClass;
    ClassName thisClassName;

    JavaFile generateFile() {
        TypeSpec t = create();
        this.logger = null;
        return JavaFile.builder(getPackage(), t)
                .addFileComment("Generated code from LProcess. Do not modify!")
                .build();
    }

    private TypeSpec create() {
        final ClassName superClz;
        if (parent == null) {
            if (type == Type.UserData)
                superClz = baseClass;
            else
                superClz = TypeName.OBJECT;
        } else {
            superClz = parent.thisClassName;
        }
        TypeSpec.Builder builder = TypeSpec.classBuilder(thisClassName);
        builder.addAnnotation(CreatedByApt.class);
        builder.addAnnotation(LuaApiUsed);
        builder.superclass(superClz);
        builder.addModifiers(Modifier.PUBLIC);

        if (type == Type.UserData) {
            addDefaultMethodsForUD(builder);
        } else {
            addDefaultMethodsForStatic(builder);
        }
        return builder.build();
    }

    private void addDefaultMethodsForStatic(TypeSpec.Builder builder) {
        List<String> methods = addMethods(builder, true);
        addMethodNamesField(builder, methods);
    }

    private int getInitElement() {
        List<? extends Element> list = typeElement.getEnclosedElements();
        /// 0: globals LuaValue[]
        /// 1: globals
        /// 2: LuaValue[]
        /// 3: default constructor
        ExecutableElement ees[] = new ExecutableElement[4];
        for (Element e : list) {
            if ("<init>".equals(e.getSimpleName().toString())) {
                ExecutableElement ee = (ExecutableElement) e;
                byte type = 0;
                for (VariableElement te : ee.getParameters()) {
                    TypeName tn = TypeName.get(te.asType());
                    if (Globals.equals(tn)) {
                        type |= 1;
                    } else if (LuaValue_Arr.equals(tn)) {
                        type |= (1 << 1);
                    }
                }
                switch (type) {
                    case 0:
                        ees[3] = ee;
                        break;
                    case 1:
                        ees[1] = ee;
                        break;
                    case 1<<1:
                        ees[2] = ee;
                        break;
                    case 3:
                        ees[0] = ee;
                        break;
                }
            }
        }
        for (int i = 0; i < 4; i ++) {
            if (ees[i] != null) return i;
        }
        return -1;
    }

    private void addNewUserdataImpl(MethodSpec.Builder con) {
        int idx = getInitElement();
        if (idx == -1) error(typeElement, "no support constructor for this userdata\n" +
                "support: default constructor\n" +
                "         <init>(Globals g)\n" +
                "         <init>(LuaValue[] v)\n" +
                "         <init>(Globals g, LuaValue[] v)");
        switch (idx) {
            case 0:
                con.addStatement("return new $T(globals, v)", typeElement);
                break;
            case 1:
                con.addStatement("return new $T(globals)", typeElement);
                break;
            case 2:
                con.addStatement("return new $T(v)", typeElement);
                break;
            case 3:
                con.addStatement("return new $T()", typeElement);
                break;
        }
    }

    private void addDefaultMethodsForUD(TypeSpec.Builder builder) {
        /**
         * java层构造方法
         * public LuaUserdata(Globals g, Object jud)
         */
        MethodSpec.Builder con = MethodSpec.constructorBuilder()
                .addModifiers(Modifier.PUBLIC)
                .addParameter(Globals, "g")
                .addParameter(Object.class, "jud")
                .addStatement("super(g, jud)");
        builder.addMethod(con.build());
        /**
         * native层构造方法
         * protected LuaUserdata(long L, LuaValue[] v)
         */
        con = MethodSpec.constructorBuilder()
                .addModifiers(Modifier.PROTECTED)
                .addParameter(long.class, "L")
                .addParameter(LuaValue_Arr, "v")
                .addStatement("super(L, v)");
        /// 继承其他类情况下，不应该再次初始化
        if (parent == null)
            con.addStatement("javaUserdata = newUserdata(v)");
        if (__setUserdata != null) {
            con.addStatement("(($T) javaUserdata).__setUserdata(this)", typeElement);
        }
        builder.addMethod(con.build());
        /**
         * 增加protected Object newUserdata(LuaValue[] v) 方法
         * 初始化javaUserdata，减少userdata创建次数
         */
        con = MethodSpec
                .methodBuilder("newUserdata")
                .addModifiers(Modifier.PROTECTED)
                .returns(Object.class)
                .addParameter(LuaValue_Arr, "v");
        if (abstractClass) {
            con.addStatement("return null");
        } else {
            addNewUserdataImpl(con);
        }
        builder.addMethod(con.build());
        /**
         * 重写getJavaUserdata方法
         */
        con = MethodSpec
                .methodBuilder("getJavaUserdata")
                .addModifiers(Modifier.PUBLIC)
                .returns(TypeName.get(typeElement.asType()))
                .addStatement("return ($T) javaUserdata", typeElement);
        builder.addMethod(con.build());

        List<String> methods = addMethods(builder, false);
        addMethodNamesField(builder, methods);

        /// 增加__index方法
        if (__index != null) {
            MethodSpec.Builder mb = MethodSpec
                    .methodBuilder("__index")
                    .addModifiers(Modifier.PUBLIC)
                    .addAnnotation(LuaApiUsed)
                    .returns(LuaValue_Arr)
                    .addParameter(String.class, "n")
                    .addParameter(LuaValue_Arr, "p")
                    .addStatement("return getJavaUserdata().__index(n, p)");
            builder.addMethod(mb.build());
        }
        /// 增加__newindex方法
        if (__newindex != null) {
            MethodSpec.Builder mb = MethodSpec
                    .methodBuilder("__newindex")
                    .addModifiers(Modifier.PUBLIC)
                    .addAnnotation(LuaApiUsed)
                    .returns(TypeName.VOID)
                    .addParameter(String.class, "n")
                    .addParameter(LuaValue, "p")
                    .addStatement("getJavaUserdata().__newindex(n, p)");
            builder.addMethod(mb.build());
        }

        /**
         * 重写 toString()
         */
        MethodSpec.Builder mb = MethodSpec.methodBuilder("toString")
                .addModifiers(Modifier.PUBLIC)
                .addAnnotation(LuaApiUsed)
                .returns(String.class)
                .addStatement("return String.valueOf(javaUserdata)");
        builder.addMethod(mb.build());
        /**
         * 重写equals
         */
        mb = MethodSpec.methodBuilder("equals")
                .addModifiers(Modifier.PUBLIC)
                .returns(boolean.class)
                .addParameter(Object.class, "other")
                .addStatement("if (other == null) return false")
                .addStatement("if (other == this) return true")
                .addStatement("if (other.getClass() != getClass()) return false")
                .addStatement("if (javaUserdata != null) return javaUserdata.equals((($T)other).getJavaUserdata())", LuaUserdata)
                .addStatement("return (($T)other).getJavaUserdata() == null", LuaUserdata);
        builder.addMethod(mb.build());
        mb = MethodSpec.methodBuilder("__onLuaEq")
                .addModifiers(Modifier.PROTECTED)
                .returns(boolean.class)
                .addAnnotation(LuaApiUsed)
                .addParameter(Object.class, "other")
                .addStatement("return equals(other)");
        builder.addMethod(mb.build());

        /**
         * 只有在有__onLuaGc时，才重写__onLuaGc
         */
        if (__onLuaGc != null) {
            mb = MethodSpec.methodBuilder("__onLuaGc")
                    .addModifiers(Modifier.PROTECTED)
                    .addAnnotation(LuaApiUsed)
                    .returns(void.class)
                    .addCode("if (javaUserdata != null) {\n" +
                    "  final $T jud = ($T)javaUserdata;\n" +
                    "  javaUserdata = null;\n" +
                    "  jud.__onLuaGc();\n" +
                    "  javaUserdata = null;\n"+
                    "}\n", typeElement, typeElement)
                    .addStatement("super.__onLuaGc()");
            builder.addMethod(mb.build());
        }
    }

    private void addMethodNamesField(TypeSpec.Builder builder, List<String> methods) {
        FieldSpec.Builder fb = FieldSpec
                .builder(String[].class, "methods", Modifier.PUBLIC, Modifier.STATIC, Modifier.FINAL);
        CodeBlock.Builder cb = CodeBlock.builder().add("new String[] {\n");
        final int l = methods.size();
        for (int i = 0; i < l; i++) {
            String m = methods.get(i);
            cb.add("$S", m);
            if (i < l - 1) {
                cb.add(",\n");
            }
        }
        cb.add("}");
        fb.initializer(cb.build());
        builder.addField(fb.build());
    }

    /**
     * 添加方法
     *
     * @param builder
     */
    private List<String> addMethods(TypeSpec.Builder builder, boolean sb) {
        List<String> methods = new ArrayList<>();
        for (NormalElement ne : normalElements) {
            final ExecutableElement e = (ExecutableElement) ne.element;
            final String mn = getMethodName(e, ne.bridge);
            MethodSpec.Builder mb = MethodSpec
                    .methodBuilder(mn)
                    .addModifiers(Modifier.PUBLIC)
                    .addAnnotation(LuaApiUsed)
                    .returns(LuaValue_Arr);
            if (sb) {
                mb.addModifiers(Modifier.STATIC)
                        .addParameter(long.class, "L");
            }
            mb.addParameter(LuaValue_Arr, "p");
            addMethodImpl(mb, e, sb);
            builder.addMethod(mb.build());
            methods.add(mn);
        }
        for (PropertyElement pe : propertyElements) {
            final String mn = getMethodName(pe.getter, pe.bridge);
            MethodSpec.Builder mb = MethodSpec
                    .methodBuilder(mn)
                    .addModifiers(Modifier.PUBLIC)
                    .addAnnotation(LuaApiUsed)
                    .returns(LuaValue_Arr);
            if (sb) {
                mb.addModifiers(Modifier.STATIC)
                        .addParameter(long.class, "L");
            }
            mb.addParameter(LuaValue_Arr, "p");
            /// 直接设置属性
            if (pe.setter == pe.getter) {
                addPropertyImpl(mb, (VariableElement) pe.setter, sb);
            } else {
                addPropertyMethodImpl(mb, (ExecutableElement) pe.getter, (ExecutableElement) pe.setter, sb);
            }
            builder.addMethod(mb.build());
            methods.add(mn);
        }
        return methods;
    }

    /**
     * 定制参数和返回值
     * 设置  e = xxx; return null;
     * return e;
     * 传入参数为 [L (long),]p LuaValue_Arr(LuaValue[]类型)
     */
    private void addPropertyImpl(MethodSpec.Builder mb, VariableElement e, boolean sb) {
        TypeName type = TypeName.get(e.asType());

        final String call = String.format(!sb ? "((%s)javaUserdata).%s" : "%s.%s", typeElement.getSimpleName().toString(), e.getSimpleName().toString());
        if (isLuaValue(type)) {
            mb.addCode("if (p == null || p.length == 0) \n\treturn LuaValue.varargsOf");
            mb.addStatement("($N)", call)
                    .addStatement("$N = ($T) p[0]", call, type);
        } else if (isBoolean(type)) {
            mb.addCode("if (p == null || p.length == 0) \n\treturn LuaValue.varargsOf");
            mb.addStatement("($N ? $T.True() : $T.False())", call, LuaValue, LuaValue)
                    .addStatement("$N = p[0].toBoolean()", call);
        } else if (isInt(type)) {
            mb.addCode("if (p == null || p.length == 0) \n\treturn LuaValue.varargsOf");
            mb.addStatement("($T.valueOf($N))", LuaNumber, call)
                    .addStatement("$N = p[0].toInt()", call);
        } else if (isDouble(type)) {
            mb.addCode("if (p == null || p.length == 0) \n\treturn LuaValue.varargsOf");
            mb.addStatement("($T.valueOf($N))", LuaNumber, call)
                    .addStatement("$N = ($T)p[0].toDouble()", call, type);
        } else if (isString(type)) {
            mb.addCode("if (p == null || p.length == 0) \n\treturn LuaValue.varargsOf");
            mb.addStatement("($T.valueOf($N))", LuaString, call)
                    .addStatement("$N = p[0].toJavaString()", call);
        } else if (type instanceof ArrayTypeName) {
            if (sb)
                mb.addStatement("$T globals = $T.getGlobalsByLState(L)", Globals, Globals);
            mb.addCode("if (p == null || p.length == 0) \n\treturn LuaValue.varargsOf");
            mb.addStatement("($T.toLuaArray(globals, $N))", ObjectArrayUtils, call);
            TypeName ct = ((ArrayTypeName) type).componentType;
            if (ct.isPrimitive()) {
                String word = ct.toString();
                char[] cs = word.toCharArray();
                cs[0] -= 'a' - 'A';
                word = new String(cs);
                //(Utils.toLuaArray(globals, call)
                mb.addStatement("$N = $T.to" + word + "Array(p[0].toLuaTable())", call, PrimitiveArrayUtils);
            } else {
                mb.addStatement("$N = ($T[])$T.toNativeArray(p[0].toLuaTable(), $T.class)",call,  ct, ObjectArrayUtils, ct);
            }
        } else {
            ClassName cn = getTopClassName(type);
            if (sb)
                mb.addStatement("$T globals = $T.getGlobalsByLState(L)", Globals, Globals);
            mb.addCode("if (p == null || p.length == 0) \n\treturn LuaValue.varargsOf");
            mb.addStatement("($T.translateJavaToLua(globals, $N))", UserdataTranslator, call)
                    .addStatement("$N = ($T)$T.translateLuaToJava(p[0], $T.class)", call, type, UserdataTranslator, cn);
        }
        mb.addStatement("return null");
    }

    /**
     * 定制属性方法的参数和返回值
     * setter(xxx); return null;
     * return getter();
     * 传入参数为 [L (long),]p LuaValue_Arr(LuaValue[]类型)
     */
    private void addPropertyMethodImpl(MethodSpec.Builder mb, ExecutableElement getter, ExecutableElement setter, boolean sb) {
        if (getter.getParameters().size() != 0 || getter.getReturnType().getKind() == TypeKind.VOID) {
            error(getter, "getter must have no params and have a none void return type！");
            return;
        }
        TypeName type = TypeName.get(getter.getReturnType());
        if (setter.getParameters().size() != 1
                || setter.getReturnType().getKind() != TypeKind.VOID
                || !type.equals(TypeName.get(setter.getParameters().get(0).asType()))) {
            error(setter, "setter must have one params with type %s, and have a void return type!", type.toString());
            return;
        }
        mb.addCode("if (p == null || p.length == 0) \n\treturn LuaValue.varargsOf");
        final String gcall = String.format(!sb ? "((%s)javaUserdata).%s()" : "%s.%s()", typeElement.getSimpleName().toString(), getter.getSimpleName().toString());
        final String scall = String.format(!sb ? "((%s)javaUserdata).%s(%s)" : "%s.%s(%s)", typeElement.getSimpleName().toString(), setter.getSimpleName().toString(), "%s");
        if (isLuaValue(type)) {
            mb.addStatement("($N)", gcall)
                    .addStatement(String.format(scall, "($T) p[0]"), type);
        } else if (isBoolean(type)) {
            mb.addStatement("($N ? $T.True() : $T.False())", gcall, LuaValue, LuaValue)
                    .addStatement(String.format(scall, "p[0].toBoolean()"));
        } else if (isInt(type)) {
            mb.addStatement("($T.valueOf($N))", LuaNumber, gcall)
                    .addStatement(String.format(scall, "p[0].toInt()"));
        } else if (isDouble(type)) {
            mb.addStatement("($T.valueOf($N))", LuaNumber, gcall)
                    .addStatement(String.format(scall, "($T) p[0].toDouble()"), type);
        } else if (isString(type)) {
            mb.addStatement("($T.valueOf($N))", LuaString, gcall)
                    .addStatement(String.format(scall, "p[0].toJavaString()"));
        } else {
            ClassName cn = getTopClassName(type);
            if (sb)
                mb.addStatement("$T globals = $T.getGlobalsByLState(L)", Globals, Globals);
            mb.addStatement("($T.translateJavaToLua(globals, $N))", UserdataTranslator, gcall)
                    .addStatement(String.format(scall, "($T)$T.translateLuaToJava(p[0], $T.class)"), type, UserdataTranslator, cn);
        }
        mb.addStatement("return null");
    }

    /**
     * 参数中是否含有globals
     */
    private boolean hasGlobals(List<? extends VariableElement> pts) {
        for (VariableElement e : pts) {
            if (Globals.equals(TypeName.get(e.asType()))) return true;
        }
        return false;
    }

    /**
     * 定制参数和返回值
     * 传入参数为 [L (long),] p LuaValue_Arr(LuaValue[]类型)
     */
    private void addMethodImpl(MethodSpec.Builder mb, ExecutableElement e, boolean sb) {
        List<? extends VariableElement> paramTypes = e.getParameters();
        TypeName returnType = TypeName.get(e.getReturnType());
        final int plen = paramTypes == null ? 0 : paramTypes.size();
        // 函数无参
        if (plen == 0) {
            final String call = !sb ? "(($T)javaUserdata).$N()" : "$T.$N()";
            directlyCall(mb, call, e.getSimpleName(), returnType, !sb);
            return;
        }
        // 函数参数为LuaValue[] 特殊处理
        if (plen == 1 && LuaValue_Arr.equals(TypeName.get(paramTypes.get(0).asType()))) {
            final String call = !sb ? "(($T)javaUserdata).$N(p)" : "$T.$N(p)";
            directlyCall(mb, call, e.getSimpleName(), returnType, !sb);
            return;
        }
        // 静态函数，且只有Globas参数时，特殊处理
        if (sb && plen == 1 && Globals.equals(TypeName.get(paramTypes.get(0).asType()))) {
            final String call = "$T.$N(globals)";
            mb.addStatement("$T globals = $T.getGlobalsByLState(L)", Globals, Globals);
            directlyCall(mb, call, e.getSimpleName(), returnType, true);
            return;
        }
        boolean initGlobals = !sb;
        if (sb && hasGlobals(paramTypes)) {
            mb.addStatement("$T globals = $T.getGlobalsByLState(L)", Globals, Globals);
            initGlobals = true;
        }
        int globalCount = 0;
        /**
         * 为每个函数参数创建局部变量 pn = (type)p[n]
         */
        for (int i = 0; i < plen; i++) {
            int index = i - globalCount;
            VariableElement pe = paramTypes.get(i);
            TypeName vt = TypeName.get(pe.asType());
            mb.addCode("$T p$L=", vt, i);
            if (Globals.equals(vt)) {
                ++globalCount;
                mb.addStatement("globals");
            } else if (vt.isPrimitive()) {
                if (isBoolean(vt)) {
                    mb.addStatement("p[$L].toBoolean()", index);
                } else if (isInt(vt)) {
                    mb.addStatement("($T) p[$L].toInt()", vt, index);
                } else if (isDouble(vt)) {
                    mb.addStatement("($T) p[$L].toDouble()", vt, index);
                }
            } else if (vt.isBoxedPrimitive()) {
                TypeName uvt = vt.unbox();
                if (isBoolean(uvt)) {
                    mb.addStatement("(p.length > $L && p[$L].isBoolean()) ? p[$L].toBoolean() : null", index, index, index);
                } else if (isInt(uvt)) {
                    mb.addStatement("($T) ((p.length > $L && p[$L].isNumber()) ? p[$L].toInt() : null)", vt, index, index, index);
                } else if (isDouble(uvt)) {
                    mb.addStatement("($T) ((p.length > $L && p[$L].isNumber()) ? ($T) p[$L].toDouble() : null)", vt, index, index, vt.unbox(), index);
                }
            } else if (isString(vt)) {
                mb.addStatement("(p.length > $L && p[$L].isString()) ? p[$L].toJavaString() : null", index, index, index);
            } else if (isLuaValue(vt)) {
                mb.addStatement("($T)(p.length > $L ? p[$L] : null)", vt, index, index);
            } else if (vt instanceof ArrayTypeName) {
                /// array 类型
                TypeName ct = ((ArrayTypeName) vt).componentType;
                String tableCode = String.format("p.length > %d && p[%d].isTable() ? p[%d].toLuaTable() : null", index, index, index);
                if (ct.isPrimitive()) {
                    String word = ct.toString();
                    char[] cs = word.toCharArray();
                    cs[0] -= 'a' - 'A';
                    word = new String(cs);
                    mb.addStatement("$T.to" + word + "Array(" + tableCode + ")", PrimitiveArrayUtils);
                } else {
                    mb.addStatement("($T[])$T.toNativeArray(" + tableCode + ", $T.class)", ct, ObjectArrayUtils, ct);
                }
            } else {
                ClassName cn = getTopClassName(vt);
                mb.addStatement("((p.length > $L && !p[$L].isNil()) ? ($T)$T.translateLuaToJava(p[$L], $T.class) : null)", index, index, vt, UserdataTranslator, index, cn);
            }
        }
        /**
         * 非空返回值的情况下，创建局部变量 pn =
         *                                  method_call();
         */
        if (!isVoid(returnType)) {
            mb.addCode("$T p$L = ", returnType, plen);
        }
        if (!sb) {
            mb.addCode("(($T)javaUserdata).$N(", typeElement, e.getSimpleName());
        } else {
            mb.addCode("$T.$N(", typeElement, e.getSimpleName());
        }
        for (int i = 0; i < plen; i++) {
            mb.addCode("p$L", i);
            if (i != plen - 1) {
                mb.addCode(",");
            }
        }
        mb.addStatement(")");
        if (isVoid(returnType)) {
            mb.addStatement("return null");
            return;
        }
        if (isLuaValueArray(returnType)) {
            mb.addStatement("return p$L", plen);
            return;
        }
        returnExceptVoidAndLuaValue(mb, "p" + plen, returnType, initGlobals);
    }

    private static void returnExceptVoidAndLuaValue(MethodSpec.Builder mb, final String call, TypeName returnType, boolean initGlobals) {
        if (isBoolean(returnType)) {
            mb.addCode("return ");
            LuaValue_varargsOf(mb, getLuaBoolean(call), LuaValue, LuaValue);
        } else if (isInt(returnType)) {
            mb.addCode("return ");
            LuaValue_varargsOf(mb,
                    getLuaNumberI(call), LuaNumber);
        } else if (isDouble(returnType)) {
            mb.addCode("return ");
            LuaValue_varargsOf(mb,
                    getLuaNumberD(call), LuaNumber);
        } else if (isString(returnType)) {
            mb.addCode("return ");
            LuaValue_varargsOf(mb,
                    getLuaString(call), LuaString);
        } else if (isLuaValue(returnType)) {
            mb.addCode("return ");
            LuaValue_varargsOf(mb, call);
        } else if (returnType instanceof ArrayTypeName) {
            TypeName ct = ((ArrayTypeName) returnType).componentType;
            if (!initGlobals)
                mb.addStatement("$T globals = $T.getGlobalsByLState(L)", Globals, Globals);
            mb.addCode("return ");
            if (ct.isPrimitive()) {
                LuaValue_varargsOf(mb, "$T.toTable(globals, " + call + ")", PrimitiveArrayUtils);
            } else {
                LuaValue_varargsOf(mb, "$T.toLuaArray(globals, " + call + ")", ObjectArrayUtils);
            }
        } else {
            if (!initGlobals)
                mb.addStatement("$T globals = $T.getGlobalsByLState(L)", Globals, Globals);
            mb.addCode("return ");
            LuaValue_varargsOf(mb,
                    translateJavaToLua(call), UserdataTranslator);
        }
    }

    private void directlyCall(MethodSpec.Builder mb, String call, Name methodName, TypeName returnType, boolean initGlobals) {
        if (isVoid(returnType)) {
            mb.addStatement(call, typeElement, methodName).addStatement("return null");
            return;
        }
        if (isLuaValueArray(returnType)) {
            mb.addStatement("return " + call, typeElement, methodName);
            return;
        }
        call = call
                .replaceAll("\\$T", typeElement.getSimpleName().toString())
                .replaceAll("\\$N", methodName.toString());
        returnExceptVoidAndLuaValue(mb, call, returnType, initGlobals);
    }

    private static ClassName getTopClassName(TypeName tn) {
        if (tn instanceof ParameterizedTypeName) {
            return ((ParameterizedTypeName) tn).rawType;
        }
        if (tn instanceof ClassName) {
            ClassName top = ((ClassName) tn).topLevelClassName();
            if (top != null)
                return top;
            return (ClassName) tn;
        }
        return null;
    }

    private static boolean isVoid(TypeName t) {
        return t == TypeName.VOID;
    }

    private static boolean isLuaValue(TypeName t) {
        return t.equals(LuaValue)
                || t.equals(LuaNumber)
                || t.equals(LuaString)
                || t.equals(LuaUserdata)
                || t.equals(JavaUserdata)
                || t.equals(LuaTable)
                || t.equals(LuaFunction);
    }

    private static boolean isLuaValueArray(TypeName t) {
        return t.equals(LuaValue_Arr);
    }

    private static boolean isString(TypeName t) {
        return TypeName.get(String.class).equals(t);
    }

    private static boolean isBoolean(TypeName t) {
        return t == TypeName.BOOLEAN;
    }

    private static boolean isInt(TypeName t) {
        return t == TypeName.BYTE
                || t == TypeName.SHORT
                || t == TypeName.CHAR
                || t == TypeName.INT;
    }

    private static boolean isDouble(TypeName t) {
        return t == TypeName.FLOAT || t == TypeName.LONG || t == TypeName.DOUBLE;
    }

    private static void LuaValue_varargsOf(MethodSpec.Builder mb, String code, Object... format) {
        Object f[] = null;
        if (format != null) {
            f = new Object[format.length + 1];
            System.arraycopy(format, 0, f, 1, format.length);
            f[0] = LuaValue;
        } else {
            f = new Object[]{LuaValue};
        }
        mb.addStatement("$T.varargsOf(" + code + ")", f);
    }

    private static String getLuaBoolean(String s) {//other--LuaBoolean
        return "((" + s + ") ? $T.True() : $T.False())";
    }

    private static String getLuaNumberI(String s) {//LuaNumber
        return "$T.valueOf((int)" + s + ")";
    }

    private static String getLuaNumberD(String s) {//LuaNumber
        return "$T.valueOf((double)" + s + ")";
    }

    private static String getLuaString(String s) {//LuaString
        return "$T.valueOf(" + s + ")";
    }

    private static String translateJavaToLua(String s) {//UserdataTranslator
        return "$T.translateJavaToLua(globals, " + s + ")";
    }

    public static String join(CharSequence var0, CharSequence... var1) {
        StringJoiner joiner = new StringJoiner(var0);
        int len = var1.length;

        for (int i = 0; i < len; ++i) {
            joiner.add(var1[i]);
        }

        return joiner.toString();
    }

    private static String getMethodName(Element e, LuaBridge b) {
        String methodName = b.alias();
        if (isEmpty(methodName)) {
            methodName = e.getSimpleName().toString();
        }
        return methodName;
    }

    private String getClassName() {
        String suffix = null;
        switch (type) {
            case UserData:
                suffix = UD_CLASS_SUFFIX;
                break;
            default:
                suffix = SB_CLASS_SUFFIX;
                break;
        }
        return typeElement.getSimpleName().toString() + suffix;
    }

    private String getPackage() {
        return MoreElements.getPackage(typeElement).getQualifiedName().toString();
    }

    private void note(String msg, Object... params) {
        if (logger != null) {
            logger.note(null, msg, params);
        }
    }

    public void error(Element element, String message, Object... args) {
        if (logger != null)
            logger.error(element, message, args);
    }

    static class Builder {
        Type t = Type.UserData;
        TypeElement type;
        final List<NormalElement> normalElements = new ArrayList<>(15);
        final List<PropertyElement> propertyElements = new ArrayList<>(15);
        Logger logger;
        Generator parent;
        ClassName baseClass;
        boolean abstractClass = false;

        ExecutableElement __onLuaEq;
        ExecutableElement __onLuaGc;
        ExecutableElement __setUserdata;
        ExecutableElement __index;
        ExecutableElement __newindex;

        Builder(Logger logger, TypeElement type, LuaClass lc) {
            this.logger = logger;
            this.type = type;
            if (lc.isStatic()) {
                t = Type.Static;
            }
            abstractClass = lc.abstractClass();
            baseClass = lc.gcByLua() ? LuaUserdata : JavaUserdata;
        }

        Builder setLuaGc(Element gc) {
            __onLuaGc = (ExecutableElement) gc;
            return this;
        }

        Builder setLuaIndex(Element e) {
            __index = (ExecutableElement) e;
            return this;
        }

        Builder setLuaNewIndex(Element e) {
            __newindex = (ExecutableElement) e;
            return this;
        }

        Builder setSettingUD(Element e) {
            __setUserdata = (ExecutableElement) e;
            return this;
        }

        Builder setLuaEq(Element eq) {
            __onLuaEq = (ExecutableElement) eq;
            return this;
        }


        Builder setParent(Generator parent) {
            this.parent = parent;
            return this;
        }

        Builder addPropertyElement(Element getter, Element setter, LuaBridge bridge) {
            PropertyElement e = new PropertyElement();
            e.getter = getter;
            e.setter = setter;
            e.bridge = bridge;
            propertyElements.add(e);
            return this;
        }

        Builder addNormalElement(Element e, LuaBridge luaBridge) {
            NormalElement n = new NormalElement();
            n.bridge = luaBridge;
            n.element = e;
            normalElements.add(n);
            return this;
        }

        Generator build() {
            Generator r = new Generator();
            r.type = t;
            r.typeElement = type;
            r.normalElements = normalElements;
            r.propertyElements = propertyElements;
            r.logger = logger;
            r.parent = parent;
            r.thisClassName = ClassName.get(r.getPackage(), r.getClassName());
            r.baseClass = baseClass;
            r.__onLuaGc = __onLuaGc;
            r.__onLuaEq = __onLuaEq;
            r.__setUserdata = __setUserdata;
            r.__index = __index;
            r.__newindex = __newindex;
            r.abstractClass = abstractClass;
            return r;
        }
    }

    private static boolean isEmpty(String s) {
        return s == null || s.length() == 0;
    }

    @Override
    public String toString() {
        return "Generator{" +
                "type=" + type +
                ", typeElement=" + typeElement +
                ", normalElements=" + normalElements +
                ", propertyElements=" + propertyElements +
                ", logger=" + logger +
                ", parent=" + parent +
                ", baseClass=" + baseClass +
                ", thisClassName=" + thisClassName +
                '}';
    }
}