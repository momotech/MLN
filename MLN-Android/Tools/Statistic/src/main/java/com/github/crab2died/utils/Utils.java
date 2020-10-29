/*
 *
 *                  Copyright 2017 Crab2Died
 *                     All rights reserved.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Browse for more information ：
 * 1) https://gitee.com/Crab2Died/Excel4J
 * 2) https://github.com/Crab2died/Excel4J
 *
 */

package com.github.crab2died.utils;

import com.github.crab2died.annotation.ExcelField;
import com.github.crab2died.converter.DefaultConvertible;
import com.github.crab2died.converter.WriteConvertible;
import com.github.crab2died.exceptions.Excel4JException;
import com.github.crab2died.handler.ExcelHeader;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellValue;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.util.*;
import java.util.regex.Pattern;

/**
 * Excel4J工具类
 * author : Crab2Died
 * date : 2017/5/24  9:43
 */
public class Utils {

    /**
     * getter或setter枚举
     */
    public enum FieldAccessType {

        GETTER, SETTER
    }

    /**
     * <p>根据JAVA对象注解获取Excel表头信息</p>
     *
     * @param clz 类型
     * @return 表头信息
     */
    public static List<ExcelHeader> getHeaderList(Class<?> clz) throws Excel4JException {

        List<ExcelHeader> headers = new ArrayList<>();
        List<Field> fields = new ArrayList<>();
        for (Class<?> clazz = clz; clazz != Object.class; clazz = clazz.getSuperclass()) {
            fields.addAll(Arrays.asList(clazz.getDeclaredFields()));
        }
        for (Field field : fields) {
            // 是否使用ExcelField注解
            if (field.isAnnotationPresent(ExcelField.class)) {
                ExcelField er = field.getAnnotation(ExcelField.class);
                try {
                    headers.add(new ExcelHeader(
                            er.title(),
                            er.order(),
                            er.writeConverter().newInstance(),
                            er.readConverter().newInstance(),
                            field.getName(),
                            field.getType()
                    ));
                } catch (InstantiationException | IllegalAccessException e) {
                    throw new Excel4JException(e);
                }
            }
        }
        Collections.sort(headers);
        return headers;
    }

    /**
     * 获取excel列表头
     *
     * @param titleRow excel行
     * @param clz      类型
     * @return ExcelHeader集合
     * @throws Excel4JException 异常
     */
    public static Map<Integer, ExcelHeader> getHeaderMap(Row titleRow, Class<?> clz)
            throws Excel4JException {

        List<ExcelHeader> headers = getHeaderList(clz);
        Map<Integer, ExcelHeader> maps = new HashMap<>();
        for (Cell c : titleRow) {
            String title = c.getStringCellValue();
            for (ExcelHeader eh : headers) {
                if (eh.getTitle().equals(title.trim())) {
                    maps.put(c.getColumnIndex(), eh);
                    break;
                }
            }
        }
        return maps;
    }

    /**
     * 获取单元格内容
     *
     * @param c 单元格
     * @return 单元格内容
     */
    public static String getCellValue(Cell c) {
        String o;
        switch (c.getCellType()) {
            case BLANK:
                o = "";
                break;
            case BOOLEAN:
                o = String.valueOf(c.getBooleanCellValue());
                break;
            case FORMULA:
                o = calculationFormula(c);
                break;
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(c)) {
                    o = DateUtils.date2Str(c.getDateCellValue());
                } else {
                    o = String.valueOf(c.getNumericCellValue());
                    o = matchDoneBigDecimal(o);
                    o = RegularUtils.converNumByReg(o);
                }
                break;
            case STRING:
                o = c.getStringCellValue();
                break;
            default:
                o = null;
                break;
        }
        return o;
    }

    /**
     * 字符串转对象
     *
     * @param strField 字符串
     * @param clazz    待转类型
     * @return 转换后数据
     */
    public static Object str2TargetClass(String strField, Class<?> clazz) {
        if (null == strField || "".equals(strField))
            return null;
        if ((Long.class == clazz) || (long.class == clazz)) {
            strField = matchDoneBigDecimal(strField);
            strField = RegularUtils.converNumByReg(strField);
            return Long.parseLong(strField);
        }
        if ((Integer.class == clazz) || (int.class == clazz)) {
            strField = matchDoneBigDecimal(strField);
            strField = RegularUtils.converNumByReg(strField);
            return Integer.parseInt(strField);
        }
        if ((Float.class == clazz) || (float.class == clazz)) {
            strField = matchDoneBigDecimal(strField);
            return Float.parseFloat(strField);
        }
        if ((Double.class == clazz) || (double.class == clazz)) {
            strField = matchDoneBigDecimal(strField);
            return Double.parseDouble(strField);
        }
        if ((Character.class == clazz) || (char.class == clazz)) {
            return strField.toCharArray()[0];
        }
        if ((Boolean.class == clazz) || (boolean.class == clazz)) {
            return Boolean.parseBoolean(strField);
        }
        if (Date.class == clazz) {
            return DateUtils.str2DateUnmatch2Null(strField);
        }
        return strField;
    }

    /**
     * 科学计数法数据转换
     *
     * @param bigDecimal 科学计数法
     * @return 数据字符串
     */
    private static String matchDoneBigDecimal(String bigDecimal) {
        // 对科学计数法进行处理
        boolean flg = Pattern.matches("^-?\\d+(\\.\\d+)?(E-?\\d+)?$", bigDecimal);
        if (flg) {
            BigDecimal bd = new BigDecimal(bigDecimal);
            bigDecimal = bd.toPlainString();
        }
        return bigDecimal;
    }

    /**
     * <p>根据java对象属性{@link Field}获取该属性的getter或setter方法名，
     * 另对{@link boolean}及{@link Boolean}做了行管处理</p>
     *
     * @param clazz      操作对象
     * @param fieldName  对象属性
     * @param methodType 方法类型，getter或setter枚举
     * @return getter或setter方法
     * @throws IntrospectionException 异常
     * @author Crab2Died
     */
    public static Method getterOrSetter(Class clazz, String fieldName, FieldAccessType methodType)
            throws IntrospectionException {

        if (null == fieldName || "".equals(fieldName))
            return null;

        BeanInfo beanInfo = Introspector.getBeanInfo(clazz);
        PropertyDescriptor[] props = beanInfo.getPropertyDescriptors();
        for (PropertyDescriptor prop : props) {
            if (fieldName.equals(prop.getName())) {
                if (FieldAccessType.SETTER == methodType) {
                    return prop.getWriteMethod();
                }
                if (FieldAccessType.GETTER == methodType) {
                    return prop.getReadMethod();
                }
            }
        }
        throw new IntrospectionException("Can not get the getter or setter method");
    }

    /**
     * <p>根据对象的属性名{@code fieldName}获取某个java的属性{@link Field}</p>
     *
     * @param clazz     java对象的class属性
     * @param fieldName 属性名
     * @return {@link Field}   java对象的属性
     * @author Crab2Died
     */
    private static Field matchClassField(Class clazz, String fieldName) {

        List<Field> fields = new ArrayList<>();
        for (; clazz != Object.class; clazz = clazz.getSuperclass()) {
            fields.addAll(Arrays.asList(clazz.getDeclaredFields()));
        }
        for (Field field : fields) {
            if (fieldName.equals(field.getName())) {
                return field;
            }
        }
        throw new IllegalArgumentException("[" + clazz.getName() + "] can`t found field with [" + fieldName + "]");
    }

    /**
     * 根据属性名与属性类型获取字段内容
     *
     * @param bean             对象
     * @param fieldName        字段名
     * @param writeConvertible 写入转换器
     * @return 对象指定字段内容
     * @throws Excel4JException 异常
     */
    public static String getProperty(Object bean, String fieldName, WriteConvertible writeConvertible)
            throws Excel4JException {

        if (bean == null || fieldName == null)
            throw new IllegalArgumentException("Operating bean or filed class must not be null");
        Method method;
        Object object;
        try {
            method = getterOrSetter(bean.getClass(), fieldName, FieldAccessType.GETTER);
            object = method.invoke(bean);
        } catch (IntrospectionException | IllegalAccessException | InvocationTargetException e) {
            throw new Excel4JException(e);
        }
        if (null != writeConvertible && writeConvertible.getClass() != DefaultConvertible.class) {
            // 写入转换器
            object = writeConvertible.execWrite(object);
        }
        return object == null ? "" : object.toString();
    }

    /**
     * 根据属性名与属性类型获取字段内容
     *
     * @param bean  对象
     * @param name  字段名
     * @param value 字段类型
     */
    public static void copyProperty(Object bean, String name, Object value)
            throws Excel4JException {

        if (null == name || null == value)
            return;
        Field field = matchClassField(bean.getClass(), name);
        if (null == field)
            return;
        Method method;
        try {
            method = getterOrSetter(bean.getClass(), name, FieldAccessType.SETTER);

            if (value.getClass() == field.getType()) {
                method.invoke(bean, value);
            } else {
                method.invoke(bean, str2TargetClass(value.toString(), field.getType()));
            }
        } catch (IntrospectionException | IllegalAccessException | InvocationTargetException e) {
            throw new Excel4JException(e);
        }

    }

    /**
     * 计算公式结果
     *
     * @param cell 单元格类型为公式的单元格
     * @return 返回单元格计算后的值 格式化成String
     * @author QingMings
     * Email:1821063757@qq.com
     * date 2018-01-13
     */
    public static String calculationFormula(Cell cell) {

        CellValue cellValue = cell.getSheet().getWorkbook().getCreationHelper()
                .createFormulaEvaluator().evaluate(cell);
        return cellValue.formatAsString();
    }
}
