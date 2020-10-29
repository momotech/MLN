/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

import org.luaj.vm2.LuaValue;

import java.lang.reflect.Method;
import java.util.HashMap;

/**
 * Created by Xiong.Fangyu on 2019/2/26
 * <p>
 * jni层使用
 *
 * @see #getClassName(Class) 获取jni可识别的类名
 * @see #getClassSignature(Class) 获取jni可识别的类签名
 * @see #getMethodSignature(Method) 获取jni可识别的函数签名
 * @see #isValidClassType(Class, boolean) 是否是基础类型或基础封装类或是LuaValue类型，或相关数组类型
 */
public class SignatureUtils {
    private static final String VALID_METHOD_SIG = "([Lorg/luaj/vm2/LuaValue;)[Lorg/luaj/vm2/LuaValue;";
    private static final String VALID_STATIC_METHOD_SIG = "(J[Lorg/luaj/vm2/LuaValue;)[Lorg/luaj/vm2/LuaValue;";

    private static final HashMap<Class, String> primitive;
    private static final Class[] Primitive;

    static {
        primitive = new HashMap<>(9);
        primitive.put(boolean.class, "Z");
        primitive.put(byte.class, "B");
        primitive.put(char.class, "C");
        primitive.put(short.class, "S");
        primitive.put(int.class, "I");
        primitive.put(long.class, "J");
        primitive.put(float.class, "F");
        primitive.put(double.class, "D");
        primitive.put(void.class, "V");

        Primitive = new Class[]{
                Boolean.class,
                Byte.class,
                Character.class,
                Short.class,
                Integer.class,
                Long.class,
                Float.class,
                Double.class,
                Void.class
        };
    }

    /**
     * 获取jni可识别的类名
     */
    public static String getClassName(Class clz) {
        return StringReplaceUtils.replaceAllChar(clz.getName(), '.', '/');
    }

    /**
     * 获取jni可识别的类签名
     */
    public static String getClassSignature(Class clz) {
        if (clz.isArray()) {
            String name = clz.getName();
            if (clz.getComponentType().isPrimitive()) {
                return name;
            }
            return StringReplaceUtils.replaceAllChar(name, '.', '/');
        }
        if (clz.isPrimitive()) {
            return primitive.get(clz);
        }
        String name = StringReplaceUtils.replaceAllChar(clz.getName(), '.', '/');
        return "L" + name + ";";
    }

    public static boolean isValidUserdataMethodSignature(String sig) {
        return VALID_METHOD_SIG.equals(sig);
    }

    public static boolean isValidStaticMethodSignature(String sig) {
        return VALID_STATIC_METHOD_SIG.equals(sig);
    }

    /**
     * 获取jni可识别的函数签名
     */
    public static String getMethodSignature(Method m) {
        Class[] params = m.getParameterTypes();
        Class returnType = m.getReturnType();
        if (params == null || params.length == 0) {
            return "()" + getClassSignature(returnType);
        }
        StringBuilder sb = new StringBuilder("(");
        for (Class c : params) {
            sb.append(getClassSignature(c));
        }
        return sb.append(")").append(getClassSignature(returnType)).toString();
    }

    /**
     * 是否是基础类型或基础封装类或是LuaValue类型，或相关数组类型
     */
    public static boolean isValidClassType(Class clz, boolean arrayIsValid) {
        Class cc = clz.getComponentType();
        if (cc != null) {
            return arrayIsValid && isValidClassType(cc, false);
        } else {
            return clz.isPrimitive() || isPrimitive(clz) || LuaValue.class.isAssignableFrom(clz);
        }
    }

    private static boolean isPrimitive(Class clz) {
        for (Class c : Primitive) {
            if (c == clz)
                return true;
        }
        return false;
    }
}