/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.processor;

import com.squareup.javapoet.ClassName;
import com.immomo.mls.annotation.BridgeType;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.processing.RoundEnvironment;
import javax.lang.model.element.Element;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.TypeElement;
import javax.lang.model.element.VariableElement;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;

/**
 * Created by Xiong.Fangyu on 2019/3/15
 */
class PreProcess {
    private static final String SETTER_PREFIX = "set";
    private static final int UPPER_OFFSET = 'A' - 'a';
    private static final String GETTER_PREFIX = "get";
    private static final String GETTER_BOOL_PREFIX = "is";

    private static final String LUA_GC_NAME = "__onLuaGc";
    private static final String LUA_EQ_NAME = "__onLuaEq";
    private static final String SET_UD_NAME = "__setUserdata";
    private static final String LUA_INDEX   = "__index";
    private static final String LUA_NEWINDEX   = "__newindex";

    static Logger logger;
    static Options options;

    static Map<TypeElement, LuaClassGenerator> process(Set<ClassName> skip,
                                                       Set<? extends TypeElement> annotations,
                                                       RoundEnvironment roundEnv,
                                                       Options options,
                                                       Logger logger) {
        PreProcess.logger = logger;
        PreProcess.options = options;
        
        Set<? extends Element> set = roundEnv.getElementsAnnotatedWith(LuaClass.class);
        final int len = set.size();
        Map<TypeElement, LuaClassGenerator> result = new HashMap<>(len);
        for (Element e : set) {
            if (!(e instanceof TypeElement)) {
                continue;
            }
            TypeElement te = (TypeElement) e;
            if (!skip.isEmpty() && skip.contains(ClassName.get(te)))
                continue;
            parse(result, te);
        }
        
        PreProcess.logger = null;
        PreProcess.options = null;
        return result;
    }
    
    private static LuaClassGenerator parse(Map<TypeElement, LuaClassGenerator> all, TypeElement element) {
        LuaClass luaClass = element.getAnnotation(LuaClass.class);
        if (luaClass == null)
            return null;
        LuaClassGenerator result = all.get(element);
        if (result != null) {
            return result;
        }
        LuaClassGenerator parentGenerator = getParentGenerator(all, element);

        List<? extends Element> list = element.getEnclosedElements();
        final int len = list.size();

        int skipI = 0;
        final int[] skipIndex = new int[len / 2];
        LuaClassGenerator.Builder builder = new LuaClassGenerator.Builder(logger, element, luaClass);
        builder.setParent(parentGenerator);

        for (int i = 0; i < len; i ++) {
            if (i != 0 && search(skipIndex, i))
                continue;
            Element e = list.get(i);
            LuaBridge bridge = e.getAnnotation(LuaBridge.class);
            String methodname = e.getSimpleName().toString();
            if (LUA_GC_NAME.equals(methodname)) {
                builder.setLuaGc(e);
                continue;
            }
            if (LUA_INDEX.equals(methodname)) {
                builder.setLuaIndex(e);
                continue;
            }
            if (LUA_NEWINDEX.equals(methodname)) {
                builder.setLuaNewIndex(e);
                continue;
            }
            if (SET_UD_NAME.equals(methodname)) {
                builder.setSettingUD(e);
                continue;
            }
            if (LUA_EQ_NAME.equals(methodname)) {
                builder.setLuaEq(e);
                continue;
            }
            if (bridge == null)
                continue;
            BridgeType type = bridge.type();
            if (e instanceof VariableElement) {
                if (type != BridgeType.NORMAL) {
                    error(e, "bridge field must be normal type");
                    return null;
                }
                builder.addPropertyElement(e, e, bridge);
                continue;
            }
            if (type == BridgeType.SETTER || type == BridgeType.GETTER) {
                String otherName = getPropertyMethodName(bridge, e, type);
                Element e2 = findOtherPropertyElement(list, otherName, i, skipIndex, skipI);
                if (e2 == null) {
                    error(e, "cannot find %s method or property for %s", otherName, methodname);
                    return null;
                }
                skipI++;
                if (type == BridgeType.SETTER) {
                    builder.addPropertyElement(e2, e, bridge);
                } else {
                    builder.addPropertyElement(e, e2, bridge);
                }
            } else {
                builder.addNormalElement(e, bridge);
            }
        }
        result = builder.build();
        all.put(element, result);
        return result;
    }

    private static Element findOtherPropertyElement(List<? extends Element> list,
                                             String otherName,
                                             int index,
                                             int[] skipIndex,
                                             int skipI) {
        for (int j = index + 1 ; j < list.size() ;j ++) {
            if (j != 0 && search(skipIndex, j))
                continue;
            Element e2 = list.get(j);
            LuaBridge b2 = e2.getAnnotation(LuaBridge.class);
            if (b2 == null)
                continue;
            if (e2.getSimpleName().toString().equals(otherName)) {
                skipIndex[skipI] = j;
                return e2;
            }
        }
        return null;
    }

    private static LuaClassGenerator getParentGenerator(Map<TypeElement, LuaClassGenerator> all, TypeElement e) {
        TypeElement parent = findParentType(e);
        LuaClassGenerator parentGenerator = null;
        LuaClass lc;
        if (parent != null && (lc = parent.getAnnotation(LuaClass.class)) != null) {
            parentGenerator = all.get(parent);
            if (parentGenerator == null) {
                String name = parent.getQualifiedName().toString();
                name = name.substring(0, name.lastIndexOf("."));
                if (isSkipPackage(name)) {
                    parentGenerator = new LuaClassGenerator.Builder(logger, parent, lc).build();
                } else {
                    parentGenerator = parse(all, parent);
                }
            }
        }
        return parentGenerator;
    }

    private static TypeElement findParentType(TypeElement typeElement) {
        TypeMirror type = typeElement.getSuperclass();
        if (type.getKind() == TypeKind.NONE) {
            return null;
        }
        return (TypeElement) ((DeclaredType) type).asElement();
    }
    private static String getPropertyMethodName(LuaBridge b, Element e, BridgeType t) {
        String ret = null;
        if (t == BridgeType.SETTER) {
            ret = b.getterIs();
        } else {
            ret = b.setterIs();
        }
        if (!isEmpty(ret))
            return ret;
        final String prefix = getPrefix(e, t);
        String name = e.getSimpleName().toString();
        if (t == BridgeType.SETTER && name.startsWith(SETTER_PREFIX)) {
            return name.replace(SETTER_PREFIX, prefix);
        }
        if (t == BridgeType.GETTER) {
            if (name.startsWith(GETTER_PREFIX)) {
                return name.replace(GETTER_PREFIX, SETTER_PREFIX);
            }
            if (name.startsWith(GETTER_BOOL_PREFIX)) {
                return name.replace(GETTER_BOOL_PREFIX, SETTER_PREFIX);
            }
        }
        String alias = b.alias();
        if (isEmpty(alias)) {
            name = alias;
        }
        name = changeFirstLetterToUpperCase(name);
        return getPrefix(e, t) + name;
    }

    private static boolean isBooleanReturnType(Element e) {
        if (e instanceof ExecutableElement) {
            return TypeKind.BOOLEAN.equals(((ExecutableElement) e).getReturnType().getKind());
        }
        return false;
    }

    private static String getPrefix(Element e, BridgeType t) {
        String prefix;
        if (t == BridgeType.SETTER) {
            if (isBooleanReturnType(e)) {
                prefix = GETTER_BOOL_PREFIX;
            } else {
                prefix = GETTER_PREFIX;
            }
        } else {
            prefix = SETTER_PREFIX;
        }
        return prefix;
    }

    private static String changeFirstLetterToUpperCase(String s) {
        char first = s.charAt(0);
        if (first >= 'a' && first <= 'z') {
            return String.valueOf((char) (first + UPPER_OFFSET)) + s.substring(1);
        }
        return s;
    }

    private static boolean isSkipPackage(String name) {
        if (options.isSdk || options.skipPackage == null)
            return false;
        for (String s : options.skipPackage) {
            if (name.startsWith(s))
                return true;
        }
        return false;
    }

    private static boolean search(int[] arr, int key) {
        for (int i = 0, l = arr.length; i < l;i ++) {
            if (arr[i] == key)
                return true;
        }
        return false;
    }

    private static boolean isEmpty(String s) {
        return s == null || s.length() == 0;
    }

    private static void note(String msg, Object... params) {
        if (logger != null) {
            logger.note(null, msg, params);
        }
    }

    private static void error(Element e, String m, Object... params) {
        if (logger != null) {
            logger.error(e, m, params);
        }
    }
}