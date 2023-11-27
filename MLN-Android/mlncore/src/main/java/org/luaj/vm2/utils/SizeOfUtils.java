/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.utils;

import android.util.ArrayMap;

import com.immomo.mlncore.MLNCore;

import java.lang.ref.Reference;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Map;

/**
 * Created by Xiong.Fangyu on 2019-09-24
 *
 * 获取类最少占用内存
 * 获取对象最少占用内存
 *
 * 由于Java对象内存和机器有关（32位和64位），且和虚拟机是否开启指针压缩有关
 * 并且还有padding填充对齐，所以此工具中计算并不准确，可作为参考值
 */
public class SizeOfUtils {
    /**
     * 对象头占用
     */
    private static final int PTR_HEAD = 8;
    /**
     * 指针占用，按4字节计算
     */
    private static final int PTR_SIZE = 4;
    /**
     * 数组长度占用，按int计算
     */
    private static final int LENGTH_SIZE = 4;
    /**
     * 若获取类中信息出错，按16字节算
     */
    private static final int DEFUALT_SIZE = 16;

    private static final Map<Class, Long> classMemCache = new ArrayMap<>(20);

    private SizeOfUtils() {}

    /**
     * 获取某个类最少占用内存
     * 头部+基本数据类型占用+引用类型占用（指针）+数组类型占用（指针）+ 父类型占用
     *
     * 不计算其中引用类型的实际占用大小
     * 不计算其中数组类型的实际占用大小
     *
     * @param clz 类
     * @return 最少内存占用
     */
    public static long sizeof(Class clz) {
        long size = PTR_HEAD + _sizeof(clz);
        Class parent = clz.getSuperclass();
        while (parent != null) {
            size += _sizeof(parent);
            parent = parent.getSuperclass();
        }
        return size;
    }

    /**
     * 获取某个对象的内存占用
     * {@link #sizeof(Class)} + 引用类型实际占用 + 数组类型实际占用
     * @param obj 对象
     * @return 最少内存占用
     */
    public static long sizeof(Object obj) {
        Class clz = obj.getClass();
        long size = PTR_HEAD + _sizeof(clz, obj);
        Class parent = clz.getSuperclass();
        while (parent != null) {
            size += _sizeof(parent, obj);
            parent = parent.getSuperclass();
        }
        return size;
    }

    private static long _sizeof(Class clz, Object obj) {
        if (clz == Object.class)
            return _sizeof(clz);
        long size = 0;
        Field[] fields = clz.getDeclaredFields();
        for (Field f : fields) {
            f.setAccessible(true);
            Class type = f.getType();
            if (type == clz.getEnclosingClass())
                continue;
            if ((type.getModifiers() & Modifier.STATIC) == Modifier.STATIC)
                continue;
            if (type.isPrimitive()) {
                size += _primitiveSize(type);
                continue;
            }
            /// 数组类型 对象头+指针长度+数组长度的长度+数据区长度
            if (type.isArray()) {
                size += PTR_HEAD + PTR_SIZE + LENGTH_SIZE;
                Object arr = null;
                try {
                    arr = f.get(obj);
                } catch (IllegalAccessException ignore) {}
                if (arr != null) {
                    size += _sizeofArr(arr, type.getComponentType());
                }
                continue;
            }
            /// 对象类型 对象头+指针长度+数据区
            size += PTR_HEAD + PTR_SIZE;
            /// 若是弱软虚引用，不计入
            if (Reference.class.isAssignableFrom(type))
                continue;
            Object ref = null;
            try {
                ref = f.get(obj);
            } catch (IllegalAccessException ignore) { }
            if (ref != null) {
                size += sizeof(ref);
            }
        }
        return size;
    }

    private static long _sizeofArr(Object arr, Class componentClass) {
        int len = Array.getLength(arr);
        if (len == 0)
            return 0;
        if (componentClass.isPrimitive()) {
            return _primitiveSize(componentClass) * len;
        }
        long size = 0;
        if (componentClass.isArray()) {
            for (int i = 0; i < len; i ++) {
                size += _sizeofArr(Array.get(arr, i), componentClass.getComponentType());
            }
        } else {
            for (int i = 0; i < len; i ++) {
                size += sizeof(Array.get(arr, i));
            }
        }
        return size;
    }

    /**
     * 获取某个类最少占用内存
     * 不计算父类
     */
    private static synchronized long _sizeof(Class clz) {
        Long cache = classMemCache.get(clz);
        if (cache != null)
            return cache;
        long size = 0;
        try {
            Field[] fields = clz.getDeclaredFields();
            for (Field f : fields) {
                Class type = f.getType();
                if ((type.getModifiers() & Modifier.STATIC) == Modifier.STATIC)
                    continue;
                if (type.isPrimitive()) {
                    size += _primitiveSize(type);
                    continue;
                }
                /// 数组类型 对象头+指针长度+数组长度的长度
                /// 先加上数组长度的长度
                if (type.isArray()) {
                    size += PTR_HEAD + PTR_SIZE + LENGTH_SIZE;
                    continue;
                }
                /// 对象类型 对象头+指针长度
                size += PTR_HEAD + PTR_SIZE;
            }
        } catch (Throwable e) {
            if (MLNCore.DEBUG)
                throw e;
            size += DEFUALT_SIZE;
        }
        classMemCache.put(clz, size);
        return size;
    }

    /**
     * 获取基础数据类型的内存占用
     * @param type 基本数据类型
     */
    private static int _primitiveSize(Class type) {
        if (type == boolean.class)
            return 1;
        if (type == byte.class)
            return 1;
        if (type == char.class)
            return 2;
        if (type == short.class)
            return 2;
        if (type == int.class)
            return 4;
        if (type == float.class)
            return 4;
        return 8;
    }
}