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

package com.github.crab2died;

import com.github.crab2died.converter.DefaultConvertible;
import com.github.crab2died.exceptions.Excel4JException;
import com.github.crab2died.exceptions.Excel4jReadException;
import com.github.crab2died.handler.ExcelHeader;
import com.github.crab2died.handler.SheetTemplate;
import com.github.crab2died.handler.SheetTemplateHandler;
import com.github.crab2died.sheet.wrapper.MapSheetWrapper;
import com.github.crab2died.sheet.wrapper.NoTemplateSheetWrapper;
import com.github.crab2died.sheet.wrapper.NormalSheetWrapper;
import com.github.crab2died.sheet.wrapper.SimpleSheetWrapper;
import com.github.crab2died.utils.Utils;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.csv.CSVRecord;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.*;
import java.lang.reflect.Array;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * Excel4J的主要操作工具类
 * <p>
 * 主要包含6大操作类型,并且每个类型都配有一个私有handler：<br>
 * 1.读取Excel操作基于注解映射,handler为{@link ExcelUtils#readExcel2ObjectsHandler}<br>
 * 2.读取Excel操作无映射,handler为{@link ExcelUtils#readExcel2ObjectsHandler}<br>
 * 3.基于模板、注解导出Excel,handler为{@link ExcelUtils#exportExcelByModuleHandler}<br>
 * 4.基于模板、注解导出Map数据,handler为{@link ExcelUtils#exportExcelByModuleHandler}<br>
 * 5.无模板基于注解导出,handler为{@link ExcelUtils#exportExcelByMapHandler}<br>
 * 6.无模板无注解导出,handler为{@link ExcelUtils#exportExcelBySimpleHandler}<br>
 * 7.读取CSV操作基于注解,handler为{@link ExcelUtils#readCSVByMapHandler}
 * 8.基于注解导出CSV, handler为{@link ExcelUtils#exportCSVByMapHandler}
 * <p>
 * 另外列举了部分常用的参数格式的方法(不同参数的排列组合实在是太多,没必要完全列出)
 * 如遇没有自己需要的参数类型的方法,可通过最全的方法来自行变换<br>
 * <p>
 * 详细用法请关注: https://gitee.com/Crab2Died/Excel4J
 *
 * @author Crab2Died
 */
public final class ExcelUtils {

    /**
     * 单例模式
     * 通过{@link ExcelUtils#getInstance()}获取对象实例
     */
    private static volatile ExcelUtils excelUtils;

    private ExcelUtils() {
    }

    /**
     * 双检锁保证单例
     */
    public static ExcelUtils getInstance() {
        if (null == excelUtils) {
            synchronized (ExcelUtils.class) {
                if (null == excelUtils) {
                    excelUtils = new ExcelUtils();
                }
            }
        }
        return excelUtils;
    }

    /*---------------------------------------1.读取Excel操作基于注解映射--------------------------------------------*/
    /*  一. 操作流程 ：                                                                                            */
    /*      1) 读取表头信息,与给出的Class类注解匹配                                                                  */
    /*      2) 读取表头下面的数据内容, 按行读取, 并映射至java对象                                                      */
    /*  二. 参数说明                                                                                               */
    /*      *) excelPath        =>      目标Excel路径                                                              */
    /*      *) InputStream      =>      目标Excel文件流                                                            */
    /*      *) clazz            =>      java映射对象                                                               */
    /*      *) offsetLine       =>      开始读取行坐标(默认0)                                                       */
    /*      *) limitLine        =>      最大读取行数(默认表尾)                                                      */
    /*      *) sheetIndex       =>      Sheet索引(默认0)                                                           */

    /**
     * 读取Excel操作基于注解映射成绑定的java对象
     *
     * @param excelPath  待导出Excel的路径
     * @param clazz      待绑定的类(绑定属性注解{@link com.github.crab2died.annotation.ExcelField})
     * @param offsetLine Excel表头行(默认是0)
     * @param limitLine  最大读取行数(默认表尾)
     * @param sheetIndex Sheet索引(默认0)
     * @param <T>        绑定的数据类
     * @return 返回转换为设置绑定的java对象集合
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public <T> List<T> readExcel2Objects(String excelPath, Class<T> clazz, int offsetLine,
                                         int limitLine, int sheetIndex)
            throws Excel4JException, IOException {

        try (Workbook workbook = WorkbookFactory.create(new FileInputStream(new File(excelPath)))) {
            return readExcel2ObjectsHandler(workbook, clazz, offsetLine, limitLine, sheetIndex);
        }
    }

    /**
     * 读取Excel操作基于注解映射成绑定的java对象
     *
     * @param is         待导出Excel的数据流
     * @param clazz      待绑定的类(绑定属性注解{@link com.github.crab2died.annotation.ExcelField})
     * @param offsetLine Excel表头行(默认是0)
     * @param limitLine  最大读取行数(默认表尾)
     * @param sheetIndex Sheet索引(默认0)
     * @param <T>        绑定的数据类
     * @return 返回转换为设置绑定的java对象集合
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public <T> List<T> readExcel2Objects(InputStream is, Class<T> clazz, int offsetLine,
                                         int limitLine, int sheetIndex)
            throws Excel4JException, IOException {

        try (Workbook workbook = WorkbookFactory.create(is)) {
            return readExcel2ObjectsHandler(workbook, clazz, offsetLine, limitLine, sheetIndex);
        }
    }

    /**
     * 读取Excel操作基于注解映射成绑定的java对象
     *
     * @param excelPath  待导出Excel的路径
     * @param clazz      待绑定的类(绑定属性注解{@link com.github.crab2died.annotation.ExcelField})
     * @param offsetLine Excel表头行(默认是0)
     * @param sheetIndex Sheet索引(默认0)
     * @param <T>        绑定的数据类
     * @return 返回转换为设置绑定的java对象集合
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public <T> List<T> readExcel2Objects(String excelPath, Class<T> clazz, int offsetLine, int sheetIndex)
            throws Excel4JException, IOException {
        return readExcel2Objects(excelPath, clazz, offsetLine, Integer.MAX_VALUE, sheetIndex);
    }

    /**
     * 读取Excel操作基于注解映射成绑定的java对象
     *
     * @param excelPath  待导出Excel的路径
     * @param clazz      待绑定的类(绑定属性注解{@link com.github.crab2died.annotation.ExcelField})
     * @param sheetIndex Sheet索引(默认0)
     * @param <T>        绑定的数据类
     * @return 返回转换为设置绑定的java对象集合
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public <T> List<T> readExcel2Objects(String excelPath, Class<T> clazz, int sheetIndex)
            throws Excel4JException, IOException {
        return readExcel2Objects(excelPath, clazz, 0, Integer.MAX_VALUE, sheetIndex);
    }

    /**
     * 读取Excel操作基于注解映射成绑定的java对象
     *
     * @param excelPath 待导出Excel的路径
     * @param clazz     待绑定的类(绑定属性注解{@link com.github.crab2died.annotation.ExcelField})
     * @param <T>       绑定的数据类
     * @return 返回转换为设置绑定的java对象集合
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public <T> List<T> readExcel2Objects(String excelPath, Class<T> clazz)
            throws Excel4JException, IOException {
        return readExcel2Objects(excelPath, clazz, 0, Integer.MAX_VALUE, 0);
    }

    /**
     * 读取Excel操作基于注解映射成绑定的java对象
     *
     * @param is         待导出Excel的数据流
     * @param clazz      待绑定的类(绑定属性注解{@link com.github.crab2died.annotation.ExcelField})
     * @param sheetIndex Sheet索引(默认0)
     * @param <T>        绑定的数据类
     * @return 返回转换为设置绑定的java对象集合
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public <T> List<T> readExcel2Objects(InputStream is, Class<T> clazz, int sheetIndex)
            throws Excel4JException, IOException {
        return readExcel2Objects(is, clazz, 0, Integer.MAX_VALUE, sheetIndex);
    }

    /**
     * 读取Excel操作基于注解映射成绑定的java对象
     *
     * @param is    待导出Excel的数据流
     * @param clazz 待绑定的类(绑定属性注解{@link com.github.crab2died.annotation.ExcelField})
     * @param <T>   绑定的数据类
     * @return 返回转换为设置绑定的java对象集合
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public <T> List<T> readExcel2Objects(InputStream is, Class<T> clazz)
            throws Excel4JException, IOException {
        return readExcel2Objects(is, clazz, 0, Integer.MAX_VALUE, 0);
    }

    private <T> List<T> readExcel2ObjectsHandler(Workbook workbook, Class<T> clazz, int offsetLine,
                                                 int limitLine, int sheetIndex) throws Excel4JException {

        Sheet sheet = workbook.getSheetAt(sheetIndex);
        Row row = sheet.getRow(offsetLine);
        List<T> list = new ArrayList<>();
        Map<Integer, ExcelHeader> maps = Utils.getHeaderMap(row, clazz);
        if (maps == null || maps.size() <= 0)
            throw new Excel4jReadException(
                    "The Excel format to read is not correct, and check to see if the appropriate rows are set"
            );
        long maxLine = sheet.getLastRowNum() > ((long) offsetLine + limitLine) ?
                ((long) offsetLine + limitLine) : sheet.getLastRowNum();

        for (int i = offsetLine + 1; i <= maxLine; i++) {
            row = sheet.getRow(i);
            if (null == row)
                continue;
            T obj;
            try {
                obj = clazz.newInstance();
            } catch (InstantiationException | IllegalAccessException e) {
                throw new Excel4JException(e);
            }
            for (Cell cell : row) {
                int ci = cell.getColumnIndex();
                ExcelHeader header = maps.get(ci);
                if (null == header)
                    continue;
                String val = Utils.getCellValue(cell);
                Object value;
                String filed = header.getFiled();
                // 读取转换器
                if (null != header.getReadConverter() &&
                        header.getReadConverter().getClass() != DefaultConvertible.class) {
                    value = header.getReadConverter().execRead(val);
                } else {
                    // 默认转换
                    value = Utils.str2TargetClass(val, header.getFiledClazz());
                }
                Utils.copyProperty(obj, filed, value);
            }
            list.add(obj);
        }
        return list;
    }

    /*---------------------------------------2.读取Excel操作无映射-------------------------------------------------*/
    /*  一. 操作流程 ：                                                                                            */
    /*      *) 按行读取Excel文件,存储形式为  Cell->String => Row->List<Cell> => Excel->List<Row>                    */
    /*  二. 参数说明                                                                                               */
    /*      *) excelPath        =>      目标Excel路径                                                              */
    /*      *) InputStream      =>      目标Excel文件流                                                            */
    /*      *) offsetLine       =>      开始读取行坐标(默认0)                                                       */
    /*      *) limitLine        =>      最大读取行数(默认表尾)                                                      */
    /*      *) sheetIndex       =>      Sheet索引(默认0)                                                           */

    /**
     * 读取Excel表格数据,返回{@code List[List[String]]}类型的数据集合
     *
     * @param excelPath  待读取Excel的路径
     * @param offsetLine Excel表头行(默认是0)
     * @param limitLine  最大读取行数(默认表尾)
     * @param sheetIndex Sheet索引(默认0)
     * @return 返回{@code List<List<String>>}类型的数据集合
     * @throws IOException 异常
     * @author Crab2Died
     */
    public List<List<String>> readExcel2List(String excelPath, int offsetLine, int limitLine, int sheetIndex)
            throws IOException {

        try (Workbook workbook = WorkbookFactory.create(new FileInputStream(new File(excelPath)))) {
            return readExcel2ObjectsHandler(workbook, offsetLine, limitLine, sheetIndex);
        }
    }

    /**
     * 读取Excel表格数据,返回{@code List[List[String]]}类型的数据集合
     *
     * @param is         待读取Excel的数据流
     * @param offsetLine Excel表头行(默认是0)
     * @param limitLine  最大读取行数(默认表尾)
     * @param sheetIndex Sheet索引(默认0)
     * @return 返回{@code List<List<String>>}类型的数据集合
     * @throws IOException      异常
     * @author Crab2Died
     */
    public List<List<String>> readExcel2List(InputStream is, int offsetLine, int limitLine, int sheetIndex)
            throws IOException {

        try (Workbook workbook = WorkbookFactory.create(is)) {
            return readExcel2ObjectsHandler(workbook, offsetLine, limitLine, sheetIndex);
        }
    }

    /**
     * 读取Excel表格数据,返回{@code List[List[String]]}类型的数据集合
     *
     * @param excelPath  待读取Excel的路径
     * @param offsetLine Excel表头行(默认是0)
     * @return 返回{@code List<List<String>>}类型的数据集合
     * @throws IOException 异常
     * @author Crab2Died
     */
    public List<List<String>> readExcel2List(String excelPath, int offsetLine)
            throws IOException {

        try (Workbook workbook = WorkbookFactory.create(new FileInputStream(new File(excelPath)))) {
            return readExcel2ObjectsHandler(workbook, offsetLine, Integer.MAX_VALUE, 0);
        }
    }

    /**
     * 读取Excel表格数据,返回{@code List[List[String]]}类型的数据集合
     *
     * @param is         待读取Excel的数据流
     * @param offsetLine Excel表头行(默认是0)
     * @return 返回{@code List<List<String>>}类型的数据集合
     * @throws IOException 异常
     * @author Crab2Died
     */
    public List<List<String>> readExcel2List(InputStream is, int offsetLine)
            throws IOException {

        try (Workbook workbook = WorkbookFactory.create(is)) {
            return readExcel2ObjectsHandler(workbook, offsetLine, Integer.MAX_VALUE, 0);
        }
    }

    /**
     * 读取Excel表格数据,返回{@code List[List[String]]}类型的数据集合
     *
     * @param excelPath 待读取Excel的路径
     * @return 返回{@code List<List<String>>}类型的数据集合
     * @throws IOException 异常
     * @author Crab2Died
     */
    public List<List<String>> readExcel2List(String excelPath)
            throws IOException {

        try (Workbook workbook = WorkbookFactory.create(new FileInputStream(new File(excelPath)))) {
            return readExcel2ObjectsHandler(workbook, 0, Integer.MAX_VALUE, 0);
        }
    }

    /**
     * 读取Excel表格数据,返回{@code List[List[String]]}类型的数据集合
     *
     * @param is 待读取Excel的数据流
     * @return 返回{@code List<List<String>>}类型的数据集合
     * @throws IOException 异常
     * @author Crab2Died
     */
    public List<List<String>> readExcel2List(InputStream is)
            throws IOException {

        try (Workbook workbook = WorkbookFactory.create(is)) {
            return readExcel2ObjectsHandler(workbook, 0, Integer.MAX_VALUE, 0);
        }
    }

    private List<List<String>> readExcel2ObjectsHandler(Workbook workbook, int offsetLine,
                                                        int limitLine, int sheetIndex) {

        List<List<String>> list = new ArrayList<>();
        Sheet sheet = workbook.getSheetAt(sheetIndex);
        long maxLine = sheet.getLastRowNum() > ((long) offsetLine + limitLine) ?
                ((long) offsetLine + limitLine) : sheet.getLastRowNum();
        for (int i = offsetLine; i <= maxLine; i++) {
            List<String> rows = new ArrayList<>();
            Row row = sheet.getRow(i);
            if (null == row)
                continue;
            for (Cell cell : row) {
                String val = Utils.getCellValue(cell);
                rows.add(val);
            }
            list.add(rows);
        }
        return list;
    }


    /*-------------------------------------------3.基于模板、注解导出excel------------------------------------------*/
    /*  一. 操作流程 ：                                                                                            */
    /*      1) 初始化模板                                                                                          */
    /*      2) 根据Java对象映射表头                                                                                 */
    /*      3) 写入数据内容                                                                                        */
    /*  二. 参数说明                                                                                               */
    /*      *) templatePath     =>      模板路径                                                                   */
    /*      *) sheetIndex       =>      Sheet索引(默认0)                                                           */
    /*      *) data             =>      导出内容List集合                                                            */
    /*      *) extendMap        =>      扩展内容Map(具体就是key匹配替换模板#key内容)                                  */
    /*      *) clazz            =>      映射对象Class                                                              */
    /*      *) isWriteHeader    =>      是否写入表头                                                               */
    /*      *) targetPath       =>      导出文件路径                                                               */
    /*      *) os               =>      导出文件流                                                                 */

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出Excel
     *
     * @param templatePath  Excel模板路径
     * @param sheetIndex    指定导出Excel的sheet索引号(默认为0)
     * @param data          待导出数据的集合
     * @param extendMap     扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz         映射对象Class
     * @param isWriteHeader 是否写表头
     * @param targetPath    生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(String templatePath, int sheetIndex, List<?> data,
                                    Map<String, String> extendMap, Class clazz,
                                    boolean isWriteHeader, String targetPath)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByModuleHandler
                (templatePath, sheetIndex, data, extendMap, clazz, isWriteHeader)) {
            sheetTemplate.write2File(targetPath);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出Excel
     *
     * @param templatePath  Excel模板路径
     * @param sheetIndex    指定导出Excel的sheet索引号(默认为0)
     * @param data          待导出数据的集合
     * @param extendMap     扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz         映射对象Class
     * @param isWriteHeader 是否写表头
     * @param os            生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(String templatePath, int sheetIndex, List<?> data,
                                    Map<String, String> extendMap, Class clazz,
                                    boolean isWriteHeader, OutputStream os)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByModuleHandler
                (templatePath, sheetIndex, data, extendMap, clazz, isWriteHeader)) {
            sheetTemplate.write2Stream(os);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出Excel
     *
     * @param templatePath  Excel模板路径
     * @param data          待导出数据的集合
     * @param extendMap     扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz         映射对象Class
     * @param isWriteHeader 是否写表头
     * @param targetPath    生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(String templatePath, List<?> data, Map<String, String> extendMap,
                                    Class clazz, boolean isWriteHeader, String targetPath)
            throws Excel4JException {

        exportObjects2Excel(templatePath, 0, data, extendMap, clazz, isWriteHeader, targetPath);
    }

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出Excel
     *
     * @param templatePath  Excel模板路径
     * @param data          待导出数据的集合
     * @param extendMap     扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz         映射对象Class
     * @param isWriteHeader 是否写表头
     * @param os            生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(String templatePath, List<?> data, Map<String, String> extendMap,
                                    Class clazz, boolean isWriteHeader, OutputStream os)
            throws Excel4JException {

        exportObjects2Excel(templatePath, 0, data, extendMap, clazz, isWriteHeader, os);
    }

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出Excel
     *
     * @param templatePath Excel模板路径
     * @param data         待导出数据的集合
     * @param extendMap    扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz        映射对象Class
     * @param targetPath   生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(String templatePath, List<?> data, Map<String, String> extendMap,
                                    Class clazz, String targetPath)
            throws Excel4JException {

        exportObjects2Excel(templatePath, 0, data, extendMap, clazz, true, targetPath);
    }

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出Excel
     *
     * @param templatePath Excel模板路径
     * @param data         待导出数据的集合
     * @param extendMap    扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz        映射对象Class
     * @param os           生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(String templatePath, List<?> data, Map<String, String> extendMap,
                                    Class clazz, OutputStream os)
            throws Excel4JException {

        exportObjects2Excel(templatePath, 0, data, extendMap, clazz, true, os);
    }

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出Excel
     *
     * @param templatePath Excel模板路径
     * @param data         待导出数据的集合
     * @param clazz        映射对象Class
     * @param targetPath   生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(String templatePath, List<?> data, Class clazz, String targetPath)
            throws Excel4JException {

        exportObjects2Excel(templatePath, 0, data, null, clazz, true, targetPath);
    }

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出Excel
     *
     * @param templatePath Excel模板路径
     * @param data         待导出数据的集合
     * @param clazz        映射对象Class
     * @param os           生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(String templatePath, List<?> data, Class clazz, OutputStream os)
            throws Excel4JException {

        exportObjects2Excel(templatePath, 0, data, null, clazz, true, os);
    }

    // 单sheet导出
    private SheetTemplate exportExcelByModuleHandler(String templatePath,
                                                     int sheetIndex,
                                                     List<?> data,
                                                     Map<String, String> extendMap,
                                                     Class clazz,
                                                     boolean isWriteHeader)
            throws Excel4JException {

        SheetTemplate template = SheetTemplateHandler.sheetTemplateBuilder(templatePath);
        generateSheet(sheetIndex, data, extendMap, clazz, isWriteHeader, template);
        return template;
    }

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出多sheet的Excel
     *
     * @param sheetWrappers sheet包装类
     * @param templatePath  Excel模板路径
     * @param targetPath    导出Excel文件路径
     * @throws Excel4JException 异常
     */
    public void normalSheet2Excel(List<NormalSheetWrapper> sheetWrappers, String templatePath, String targetPath)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByModuleHandler(templatePath, sheetWrappers)) {
            sheetTemplate.write2File(targetPath);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于Excel模板与注解{@link com.github.crab2died.annotation.ExcelField}导出多sheet的Excel
     *
     * @param sheetWrappers sheet包装类
     * @param templatePath  Excel模板路径
     * @param os            生成的Excel待输出数据流
     * @throws Excel4JException 异常
     */
    public void normalSheet2Excel(List<NormalSheetWrapper> sheetWrappers, String templatePath, OutputStream os)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByModuleHandler(templatePath, sheetWrappers)) {
            sheetTemplate.write2Stream(os);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    // 多sheet导出
    private SheetTemplate exportExcelByModuleHandler(String templatePath,
                                                     List<NormalSheetWrapper> sheets)
            throws Excel4JException {

        SheetTemplate template = SheetTemplateHandler.sheetTemplateBuilder(templatePath);
        for (NormalSheetWrapper sheet : sheets) {
            generateSheet(sheet.getSheetIndex(), sheet.getData(), sheet.getExtendMap(), sheet.getClazz(),
                    sheet.isWriteHeader(), template);
        }
        return template;
    }

    // 生成sheet数据
    private void generateSheet(int sheetIndex, List<?> data, Map<String, String> extendMap, Class clazz,
                               boolean isWriteHeader, SheetTemplate template)
            throws Excel4JException {

        SheetTemplateHandler.loadTemplate(template, sheetIndex);
        SheetTemplateHandler.extendData(template, extendMap);
        List<ExcelHeader> headers = Utils.getHeaderList(clazz);
        if (isWriteHeader) {
            // 写标题
            SheetTemplateHandler.createNewRow(template);
            for (ExcelHeader header : headers) {
                SheetTemplateHandler.createCell(template, header.getTitle(), null);
            }
        }

        for (Object object : data) {
            SheetTemplateHandler.createNewRow(template);
            SheetTemplateHandler.insertSerial(template, null);
            for (ExcelHeader header : headers) {
                SheetTemplateHandler.createCell(template, Utils.getProperty(object, header.getFiled(),
                        header.getWriteConverter()), null);
            }
        }
    }


    /*-------------------------------------4.基于模板、注解导出Map数据----------------------------------------------*/
    /*  一. 操作流程 ：                                                                                            */
    /*      1) 初始化模板                                                                                          */
    /*      2) 根据Java对象映射表头                                                                                */
    /*      3) 写入数据内容                                                                                        */
    /*  二. 参数说明                                                                                               */
    /*      *) templatePath     =>      模板路径                                                                  */
    /*      *) sheetIndex       =>      Sheet索引(默认0)                                                          */
    /*      *) data             =>      导出内容Map集合                                                            */
    /*      *) extendMap        =>      扩展内容Map(具体就是key匹配替换模板#key内容)                                 */
    /*      *) clazz            =>      映射对象Class                                                             */
    /*      *) isWriteHeader    =>      是否写入表头                                                              */
    /*      *) targetPath       =>      导出文件路径                                                              */
    /*      *) os               =>      导出文件流                                                                */

    /**
     * 基于模板、注解导出{@code Map[String, List[?]]}类型数据
     * 模板定制详见定制说明
     *
     * @param templatePath  Excel模板路径
     * @param sheetIndex    指定导出Excel的sheet索引号(默认为0)
     * @param data          待导出的{@code Map<String, List<?>>}类型数据
     * @param extendMap     扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz         映射对象Class
     * @param isWriteHeader 是否写入表头
     * @param targetPath    生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportMap2Excel(String templatePath, int sheetIndex, Map<String, List<?>> data,
                                Map<String, String> extendMap, Class clazz,
                                boolean isWriteHeader, String targetPath)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByMapHandler(templatePath, sheetIndex, data, extendMap, clazz,
                isWriteHeader)) {
            sheetTemplate.write2File(targetPath);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于模板、注解导出{@code Map[String, List[?]]}类型数据
     * 模板定制详见定制说明
     *
     * @param templatePath  Excel模板路径
     * @param sheetIndex    指定导出Excel的sheet索引号(默认为0)
     * @param data          待导出的{@code Map<String, List<?>>}类型数据
     * @param extendMap     扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz         映射对象Class
     * @param isWriteHeader 是否写入表头
     * @param os            生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportMap2Excel(String templatePath, int sheetIndex, Map<String, List<?>> data,
                                Map<String, String> extendMap, Class clazz, boolean isWriteHeader, OutputStream os)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByMapHandler(templatePath, sheetIndex, data, extendMap, clazz,
                isWriteHeader)) {
            sheetTemplate.write2Stream(os);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于模板、注解导出{@code Map[String, List[?]]}类型数据
     * 模板定制详见定制说明
     *
     * @param templatePath Excel模板路径
     * @param data         待导出的{@code Map<String, List<?>>}类型数据
     * @param extendMap    扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz        映射对象Class
     * @param targetPath   生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportMap2Excel(String templatePath, Map<String, List<?>> data,
                                Map<String, String> extendMap, Class clazz, String targetPath)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByMapHandler(templatePath, 0, data, extendMap, clazz, true)) {
            sheetTemplate.write2File(targetPath);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于模板、注解导出{@code Map[String, List[?]]}类型数据
     * 模板定制详见定制说明
     *
     * @param templatePath Excel模板路径
     * @param data         待导出的{@code Map<String, List<?>>}类型数据
     * @param extendMap    扩展内容Map数据(具体就是key匹配替换模板#key内容,详情请查阅Excel模板定制方法)
     * @param clazz        映射对象Class
     * @param os           生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportMap2Excel(String templatePath, Map<String, List<?>> data,
                                Map<String, String> extendMap, Class clazz, OutputStream os)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByMapHandler(templatePath, 0, data, extendMap, clazz, true)) {
            sheetTemplate.write2Stream(os);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于模板、注解导出{@code Map[String, List[?]]}类型数据
     * 模板定制详见定制说明
     *
     * @param templatePath Excel模板路径
     * @param data         待导出的{@code Map<String, List<?>>}类型数据
     * @param clazz        映射对象Class
     * @param targetPath   生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportMap2Excel(String templatePath, Map<String, List<?>> data,
                                Class clazz, String targetPath)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByMapHandler(templatePath, 0, data, null, clazz, true)) {
            sheetTemplate.write2File(targetPath);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于模板、注解导出{@code Map[String, List[?]]}类型数据
     * 模板定制详见定制说明
     *
     * @param templatePath Excel模板路径
     * @param data         待导出的{@code Map<String, List<?>>}类型数据
     * @param clazz        映射对象Class
     * @param os           生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @author Crab2Died
     */
    public void exportMap2Excel(String templatePath, Map<String, List<?>> data,
                                Class clazz, OutputStream os)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByMapHandler(templatePath, 0, data, null, clazz, true)) {
            sheetTemplate.write2Stream(os);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    // 单sheet导出
    private SheetTemplate exportExcelByMapHandler(String templatePath,
                                                  int sheetIndex,
                                                  Map<String, List<?>> data,
                                                  Map<String, String> extendMap,
                                                  Class clazz,
                                                  boolean isWriteHeader)
            throws Excel4JException {

        // 加载模板
        SheetTemplate template = SheetTemplateHandler.sheetTemplateBuilder(templatePath);

        // 生成sheet
        generateSheet(template, sheetIndex, data, extendMap, clazz, isWriteHeader);

        return template;
    }

    /**
     * 基于模板、注解的多sheet导出{@code Map[String, List[?]]}类型数据
     * 模板定制详见定制说明
     *
     * @param sheetWrappers sheet包装类
     * @param templatePath  Excel模板
     * @param targetPath    导出Excel路径
     * @throws Excel4JException 异常
     */
    public void mapSheet2Excel(List<MapSheetWrapper> sheetWrappers, String templatePath, String targetPath)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByMapHandler(sheetWrappers, templatePath)) {
            sheetTemplate.write2File(targetPath);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于模板、注解的多sheet导出{@code Map[String, List[?]]}类型数据
     * 模板定制详见定制说明
     *
     * @param sheetWrappers sheet包装类
     * @param templatePath  Excel模板
     * @param os            输出流
     * @throws Excel4JException 异常
     */
    public void mapSheet2Excel(List<MapSheetWrapper> sheetWrappers, String templatePath, OutputStream os)
            throws Excel4JException {

        try (SheetTemplate sheetTemplate = exportExcelByMapHandler(sheetWrappers, templatePath)) {
            sheetTemplate.write2Stream(os);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
    }

    // 多sheet导出
    private SheetTemplate exportExcelByMapHandler(List<MapSheetWrapper> sheetWrappers,
                                                  String templatePath)
            throws Excel4JException {

        // 加载模板
        SheetTemplate template = SheetTemplateHandler.sheetTemplateBuilder(templatePath);

        // 多sheet生成
        for (MapSheetWrapper sheet : sheetWrappers) {
            generateSheet(template,
                    sheet.getSheetIndex(),
                    sheet.getData(),
                    sheet.getExtendMap(),
                    sheet.getClazz(),
                    sheet.isWriteHeader()
            );
        }

        return template;
    }

    // sheet生成
    private void generateSheet(SheetTemplate template, int sheetIndex,
                               Map<String, List<?>> data, Map<String, String> extendMap,
                               Class clazz, boolean isWriteHeader)
            throws Excel4JException {

        SheetTemplateHandler.loadTemplate(template, sheetIndex);
        SheetTemplateHandler.extendData(template, extendMap);
        List<ExcelHeader> headers = Utils.getHeaderList(clazz);
        if (isWriteHeader) {
            // 写标题
            SheetTemplateHandler.createNewRow(template);
            for (ExcelHeader header : headers) {
                SheetTemplateHandler.createCell(template, header.getTitle(), null);
            }
        }
        for (Map.Entry<String, List<?>> entry : data.entrySet()) {
            for (Object object : entry.getValue()) {
                SheetTemplateHandler.createNewRow(template);
                SheetTemplateHandler.insertSerial(template, entry.getKey());
                for (ExcelHeader header : headers) {
                    SheetTemplateHandler.createCell(template,
                            Utils.getProperty(object, header.getFiled(), header.getWriteConverter()),
                            entry.getKey()
                    );
                }
            }
        }
    }


    /*--------------------------------------5.无模板基于注解导出---------------------------------------------------*/
    /*  一. 操作流程 ：                                                                                            */
    /*      1) 根据Java对象映射表头                                                                                */
    /*      2) 写入数据内容                                                                                       */
    /*  二. 参数说明                                                                                              */
    /*      *) data             =>      导出内容List集合                                                          */
    /*      *) isWriteHeader    =>      是否写入表头                                                              */
    /*      *) sheetName        =>      Sheet索引名(默认0)                                                        */
    /*      *) clazz            =>      映射对象Class                                                             */
    /*      *) isXSSF           =>      是否Excel2007及以上版本                                                   */
    /*      *) targetPath       =>      导出文件路径                                                              */
    /*      *) os               =>      导出文件流                                                                */

    /**
     * 无模板、基于注解的数据导出
     *
     * @param data          待导出数据
     * @param clazz         {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param isWriteHeader 是否写入表头
     * @param sheetName     指定导出Excel的sheet名称
     * @param isXSSF        导出的Excel是否为Excel2007及以上版本(默认是)
     * @param targetPath    生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, Class clazz, boolean isWriteHeader,
                                    String sheetName, boolean isXSSF, String targetPath)
            throws Excel4JException, IOException {

        try (FileOutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelNoTemplateHandler(data, clazz, isWriteHeader, sheetName, isXSSF)) {
            workbook.write(fos);
        }
    }

    /**
     * 无模板、基于注解的数据导出
     *
     * @param data          待导出数据
     * @param clazz         {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param isWriteHeader 是否写入表头
     * @param sheetName     指定导出Excel的sheet名称
     * @param isXSSF        导出的Excel是否为Excel2007及以上版本(默认是)
     * @param os            生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, Class clazz, boolean isWriteHeader,
                                    String sheetName, boolean isXSSF, OutputStream os)
            throws Excel4JException, IOException {

        try (Workbook workbook = exportExcelNoTemplateHandler(data, clazz, isWriteHeader, sheetName, isXSSF)) {
            workbook.write(os);
        }
    }

    /**
     * 无模板、基于注解的数据导出
     *
     * @param data          待导出数据
     * @param clazz         {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param isWriteHeader 是否写入表头
     * @param targetPath    生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, Class clazz, boolean isWriteHeader, String targetPath)
            throws Excel4JException, IOException {

        try (FileOutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelNoTemplateHandler(data, clazz, isWriteHeader, null, true)) {
            workbook.write(fos);
        }
    }

    /**
     * 无模板、基于注解的数据导出
     *
     * @param data          待导出数据
     * @param clazz         {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param isWriteHeader 是否写入表头
     * @param os            生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, Class clazz, boolean isWriteHeader, OutputStream os)
            throws Excel4JException, IOException {

        try (Workbook workbook = exportExcelNoTemplateHandler(data, clazz, isWriteHeader, null, true)) {
            workbook.write(os);
        }
    }

    /**
     * 无模板、基于注解的数据导出
     *
     * @param data  待导出数据
     * @param clazz {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param os    生成的Excel待输出数据流
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, Class clazz, OutputStream os)
            throws Excel4JException, IOException {

        try (Workbook workbook = exportExcelNoTemplateHandler(data, clazz, true, null, true)) {
            workbook.write(os);
        }
    }

    /**
     * 无模板、基于注解的数据导出
     *
     * @param data       待导出数据
     * @param clazz      {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param targetPath 生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @throws IOException      异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, Class clazz, String targetPath)
            throws Excel4JException, IOException {

        try (FileOutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelNoTemplateHandler(data, clazz, true, null, true)) {
            workbook.write(fos);
        }
    }

    // 单sheet数据导出
    private Workbook exportExcelNoTemplateHandler(List<?> data, Class clazz, boolean isWriteHeader,
                                                  String sheetName, boolean isXSSF)
            throws Excel4JException {

        Workbook workbook;
        if (isXSSF) {
            workbook = new XSSFWorkbook();
        } else {
            workbook = new HSSFWorkbook();
        }

        generateSheet(workbook, data, clazz, isWriteHeader, sheetName);

        return workbook;
    }

    /**
     * 无模板、基于注解、多sheet数据
     *
     * @param sheets     待导出sheet数据
     * @param targetPath 生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @throws IOException      异常
     */
    public void noTemplateSheet2Excel(List<NoTemplateSheetWrapper> sheets, String targetPath)
            throws Excel4JException, IOException {

        try (OutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelNoTemplateHandler(sheets, true)) {
            workbook.write(fos);
        }
    }

    /**
     * 无模板、基于注解、多sheet数据
     *
     * @param sheets     待导出sheet数据
     * @param isXSSF     导出的Excel是否为Excel2007及以上版本(默认是)
     * @param targetPath 生成的Excel输出全路径
     * @throws Excel4JException 异常
     * @throws IOException      异常
     */
    public void noTemplateSheet2Excel(List<NoTemplateSheetWrapper> sheets, boolean isXSSF, String targetPath)
            throws Excel4JException, IOException {

        try (OutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelNoTemplateHandler(sheets, isXSSF)) {
            workbook.write(fos);
        }
    }

    /**
     * 无模板、基于注解、多sheet数据
     *
     * @param sheets 待导出sheet数据
     * @param os     生成的Excel输出文件流
     * @throws Excel4JException 异常
     * @throws IOException      异常
     */
    public void noTemplateSheet2Excel(List<NoTemplateSheetWrapper> sheets, OutputStream os)
            throws Excel4JException, IOException {

        try (Workbook workbook = exportExcelNoTemplateHandler(sheets, true)) {
            workbook.write(os);
        }
    }

    /**
     * 无模板、基于注解、多sheet数据
     *
     * @param sheets 待导出sheet数据
     * @param isXSSF 导出的Excel是否为Excel2007及以上版本(默认是)
     * @param os     生成的Excel输出文件流
     * @throws Excel4JException 异常
     * @throws IOException      异常
     */
    public void noTemplateSheet2Excel(List<NoTemplateSheetWrapper> sheets, boolean isXSSF, OutputStream os)
            throws Excel4JException, IOException {

        try (Workbook workbook = exportExcelNoTemplateHandler(sheets, isXSSF)) {
            workbook.write(os);
        }
    }

    // 多sheet数据导出
    private Workbook exportExcelNoTemplateHandler(List<NoTemplateSheetWrapper> sheetWrappers, boolean isXSSF)
            throws Excel4JException {

        Workbook workbook;
        if (isXSSF) {
            workbook = new XSSFWorkbook();
        } else {
            workbook = new HSSFWorkbook();
        }

        // 导出sheet
        for (NoTemplateSheetWrapper sheet : sheetWrappers) {
            generateSheet(workbook, sheet.getData(),
                    sheet.getClazz(), sheet.isWriteHeader(),
                    sheet.getSheetName()
            );
        }

        return workbook;
    }

    // 生成sheet数据
    private void generateSheet(Workbook workbook, List<?> data, Class clazz,
                               boolean isWriteHeader, String sheetName)
            throws Excel4JException {

        Sheet sheet;
        if (null != sheetName && !"".equals(sheetName)) {
            sheet = workbook.createSheet(sheetName);
        } else {
            sheet = workbook.createSheet();
        }
        Row row = sheet.createRow(0);
        List<ExcelHeader> headers = Utils.getHeaderList(clazz);
        if (isWriteHeader) {
            // 写标题
            for (int i = 0; i < headers.size(); i++) {
                row.createCell(i).setCellValue(headers.get(i).getTitle());
            }
        }
        // 写数据
        Object _data;
        for (int i = 0; i < data.size(); i++) {
            row = sheet.createRow(i + 1);
            _data = data.get(i);
            for (int j = 0; j < headers.size(); j++) {
                row.createCell(j).setCellValue(Utils.getProperty(_data,
                        headers.get(j).getFiled(),
                        headers.get(j).getWriteConverter()));
            }
        }

    }

    /*---------------------------------------6.无模板无注解导出----------------------------------------------------*/
    /*  一. 操作流程 ：                                                                                           */
    /*      1) 写入表头内容(可选)                                                                                  */
    /*      2) 写入数据内容                                                                                       */
    /*  二. 参数说明                                                                                              */
    /*      *) data             =>      导出内容List集合                                                          */
    /*      *) header           =>      表头集合,有则写,无则不写                                                   */
    /*      *) sheetName        =>      Sheet索引名(默认0)                                                        */
    /*      *) isXSSF           =>      是否Excel2007及以上版本                                                   */
    /*      *) targetPath       =>      导出文件路径                                                              */
    /*      *) os               =>      导出文件流                                                                */

    /**
     * 无模板、无注解的数据(形如{@code List[?]}、{@code List[List[?]]}、{@code List[Object[]]})导出
     *
     * @param data       待导出数据
     * @param header     设置表头信息
     * @param sheetName  指定导出Excel的sheet名称
     * @param isXSSF     导出的Excel是否为Excel2007及以上版本(默认是)
     * @param targetPath 生成的Excel输出全路径
     * @throws IOException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, List<String> header, String sheetName,
                                    boolean isXSSF, String targetPath)
            throws IOException {

        try (OutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelBySimpleHandler(data, header, sheetName, isXSSF)) {
            workbook.write(fos);
        }
    }

    /**
     * 无模板、无注解的数据(形如{@code List[?]}、{@code List[List[?]]}、{@code List[Object[]]})导出
     *
     * @param data      待导出数据
     * @param header    设置表头信息
     * @param sheetName 指定导出Excel的sheet名称
     * @param isXSSF    导出的Excel是否为Excel2007及以上版本(默认是)
     * @param os        生成的Excel待输出数据流
     * @throws IOException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, List<String> header, String sheetName,
                                    boolean isXSSF, OutputStream os)
            throws IOException {

        try (Workbook workbook = exportExcelBySimpleHandler(data, header, sheetName, isXSSF)) {
            workbook.write(os);
        }
    }

    /**
     * 无模板、无注解的数据(形如{@code List[?]}、{@code List[List[?]]}、{@code List[Object[]]})导出
     *
     * @param data       待导出数据
     * @param header     设置表头信息
     * @param targetPath 生成的Excel输出全路径
     * @throws IOException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, List<String> header, String targetPath)
            throws IOException {

        try (OutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelBySimpleHandler(data, header, null, true)) {
            workbook.write(fos);
        }
    }

    /**
     * 无模板、无注解的数据(形如{@code List[?]}、{@code List[List[?]]}、{@code List[Object[]]})导出
     *
     * @param data   待导出数据
     * @param header 设置表头信息
     * @param os     生成的Excel待输出数据流
     * @throws IOException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, List<String> header, OutputStream os)
            throws IOException {

        try (Workbook workbook = exportExcelBySimpleHandler(data, header, null, true)) {
            workbook.write(os);
        }
    }

    /**
     * 无模板、无注解的数据(形如{@code List[?]}、{@code List[List[?]]}、{@code List[Object[]]})导出
     *
     * @param data       待导出数据
     * @param targetPath 生成的Excel输出全路径
     * @throws IOException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, String targetPath)
            throws IOException {

        try (OutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelBySimpleHandler(data, null, null, true)) {
            workbook.write(fos);
        }
    }

    /**
     * 无模板、无注解的数据(形如{@code List[?]}、{@code List[List[?]]}、{@code List[Object[]]})导出
     *
     * @param data 待导出数据
     * @param os   生成的Excel待输出数据流
     * @throws IOException 异常
     * @author Crab2Died
     */
    public void exportObjects2Excel(List<?> data, OutputStream os)
            throws IOException {

        try (Workbook workbook = exportExcelBySimpleHandler(data, null, null, true)) {
            workbook.write(os);
        }
    }

    public void exportObjects2Excel(List<?> data, List<String> header, String targetPath, OnSheetPreparedListener listener)
            throws IOException {

        try (OutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelBySimpleHandler(data, header, null, true, listener)) {
            workbook.write(fos);
        }
    }

    private Workbook exportExcelBySimpleHandler(List<?> data, List<String> header,
                                                String sheetName, boolean isXSSF, OnSheetPreparedListener listener) {

        Workbook workbook;
        if (isXSSF) {
            workbook = new XSSFWorkbook();
        } else {
            workbook = new HSSFWorkbook();
        }
        // 生成sheet
        Sheet sheet = this.generateSheet(workbook, data, header, sheetName);
        if (listener != null)
            listener.onPrepared(sheet);
        return workbook;
    }

    private Workbook exportExcelBySimpleHandler(List<?> data, List<String> header,
                                                String sheetName, boolean isXSSF) {

        Workbook workbook;
        if (isXSSF) {
            workbook = new XSSFWorkbook();
        } else {
            workbook = new HSSFWorkbook();
        }
        // 生成sheet
        Sheet sheet = this.generateSheet(workbook, data, header, sheetName);

        return workbook;
    }

    /**
     * 无模板、无注解、多sheet数据
     *
     * @param sheets     待导出sheet数据
     * @param targetPath 生成的Excel输出全路径
     * @throws IOException 异常
     */
    public void simpleSheet2Excel(List<SimpleSheetWrapper> sheets, String targetPath)
            throws IOException {

        try (OutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelBySimpleHandler(sheets, true)) {
            workbook.write(fos);
        }
    }

    /**
     * 无模板、无注解、多sheet数据
     *
     * @param sheets     待导出sheet数据
     * @param isXSSF     导出的Excel是否为Excel2007及以上版本(默认是)
     * @param targetPath 生成的Excel输出全路径
     * @throws IOException 异常
     */
    public void simpleSheet2Excel(List<SimpleSheetWrapper> sheets, boolean isXSSF, String targetPath)
            throws IOException {

        try (OutputStream fos = new FileOutputStream(targetPath);
             Workbook workbook = exportExcelBySimpleHandler(sheets, isXSSF)) {
            workbook.write(fos);
        }
    }

    /**
     * 无模板、无注解、多sheet数据
     *
     * @param sheets 待导出sheet数据
     * @param os     生成的Excel待输出数据流
     * @throws IOException 异常
     */
    public void simpleSheet2Excel(List<SimpleSheetWrapper> sheets, OutputStream os)
            throws IOException {

        try (Workbook workbook = exportExcelBySimpleHandler(sheets, true)) {
            workbook.write(os);
        }
    }

    /**
     * 无模板、无注解、多sheet数据
     *
     * @param sheets 待导出sheet数据
     * @param isXSSF 导出的Excel是否为Excel2007及以上版本(默认是)
     * @param os     生成的Excel待输出数据流
     * @throws IOException 异常
     */
    public void simpleSheet2Excel(List<SimpleSheetWrapper> sheets, boolean isXSSF, OutputStream os)
            throws IOException {

        try (Workbook workbook = exportExcelBySimpleHandler(sheets, isXSSF)) {
            workbook.write(os);
        }
    }

    private Workbook exportExcelBySimpleHandler(List<SimpleSheetWrapper> sheets, boolean isXSSF) {

        Workbook workbook;
        if (isXSSF) {
            workbook = new XSSFWorkbook();
        } else {
            workbook = new HSSFWorkbook();
        }
        // 生成多sheet
        for (SimpleSheetWrapper sheet : sheets) {
            this.generateSheet(workbook, sheet.getData(), sheet.getHeader(), sheet.getSheetName());
        }

        return workbook;
    }

    // 生成sheet数据内容
    private Sheet generateSheet(Workbook workbook, List<?> data, List<String> header, String sheetName) {

        Sheet sheet;
        if (null != sheetName && !"".equals(sheetName)) {
            sheet = workbook.createSheet(sheetName);
        } else {
            sheet = workbook.createSheet();
        }

        int rowIndex = 0;
        if (null != header && header.size() > 0) {
            // 写标题
            Row row = sheet.createRow(rowIndex++);
            for (int i = 0; i < header.size(); i++) {
                row.createCell(i, CellType.STRING).setCellValue(header.get(i));
            }
        }
        for (Object object : data) {
            Row row = sheet.createRow(rowIndex++);
            if (object.getClass().isArray()) {
                for (int j = 0; j < Array.getLength(object); j++) {
                    Object o = Array.get(object, j);
                    row.createCell(j, parseType(o)).setCellValue(o.toString());
                }
            } else if (object instanceof Collection) {
                Collection<?> items = (Collection<?>) object;
                int j = 0;
                for (Object item : items) {
                    CellType type = parseType(item);
                    Cell cell = row.createCell(j++, type);
                    if (type == CellType.NUMERIC) {
                        cell.setCellValue(((Number) item).doubleValue());
                    } else if (type != CellType.BLANK){
                        cell.setCellValue(item.toString());
                    }
                }
            } else {
                row.createCell(0, CellType.STRING).setCellValue(object.toString());
            }
        }
        return sheet;
    }

    private CellType parseType(Object obj) {
        if (obj == null)
            return CellType.BLANK;
        Class clz = obj.getClass();
        if (clz == Boolean.class)
            return CellType.BOOLEAN;
        if (obj instanceof Number)
            return CellType.NUMERIC;
        return CellType.STRING;
    }

    /*---------------------------------------7.基于注解的CSV读取--------------------------------------------------*/
    /*  一. 操作流程 ：                                                                                           */
    /*      1) 读取表头信息,与给出的Class类注解匹配                                                                 */
    /*      2) 读取表头下面的数据内容, 按行读取, 并映射至java对象                                                     */
    /*  二. 参数说明                                                                                              */
    /*      *) path             =>      待读取文件路径                                                            */
    /*      *) is               =>      待读取文件流                                                              */
    /*      *) clazz            =>      映射对象                                                                  */

    /**
     * 基于注解读取CSV文件
     *
     * @param path  待读取文件路径
     * @param clazz 待绑定的类(绑定属性注解{@link com.github.crab2died.annotation.ExcelField})
     * @return 返回转换为设置绑定的java对象集合
     * @throws Excel4jReadException exception
     */
    public <T> List<T> readCSV2Objects(String path, Class<T> clazz) {

        try (InputStream is = new FileInputStream(new File(path))) {
            return readCSVByMapHandler(is, clazz);
        } catch (IOException | Excel4JException e) {
            throw new Excel4jReadException("read [" + path + "] CSV Error: ", e);
        }
    }

    /**
     * 基于注解读取CSV文件
     *
     * @param is    待读取文件输入流
     * @param clazz 待绑定的类(绑定属性注解{@link com.github.crab2died.annotation.ExcelField})
     * @return 返回转换为设置绑定的java对象集合
     * @throws Excel4jReadException exception
     */
    public <T> List<T> readCSV2Objects(InputStream is, Class<T> clazz) {

        try {
            return readCSVByMapHandler(is, clazz);
        } catch (Excel4JException | IOException e) {
            throw new Excel4jReadException("read CSV Error: ", e);
        }
    }

    // 读取csv
    private <T> List<T> readCSVByMapHandler(InputStream is, Class<T> clazz)
            throws IOException, Excel4JException {

        List<T> records = new ArrayList<>();

        List<ExcelHeader> headers = Utils.getHeaderList(clazz);
        if (null == headers || headers.size() <= 0) {
            throw new Excel4jReadException("[" + clazz + "] must configuration @ExcelFiled");
        }
        String[] csvHeaders = new String[headers.size()];
        for (int i = 0; i < headers.size(); i++) {
            csvHeaders[i] = headers.get(i).getTitle();
        }
        CSVFormat format = CSVFormat.EXCEL.withHeader(csvHeaders).withSkipHeaderRecord(true);
        try (Reader read = new InputStreamReader(is, StandardCharsets.UTF_8);
             CSVParser parser = new CSVParser(read, format)) {
            for (CSVRecord _parser : parser) {
                T obj;
                try {
                    obj = clazz.newInstance();
                } catch (InstantiationException | IllegalAccessException e) {
                    throw new Excel4jReadException(e);
                }
                for (ExcelHeader header : headers) {
                    String value = _parser.get(header.getTitle());
                    Object objectVal;
                    String filed = header.getFiled();
                    // 读取转换器
                    if (null != header.getReadConverter() &&
                            header.getReadConverter().getClass() != DefaultConvertible.class) {
                        objectVal = header.getReadConverter().execRead(value);
                    } else {
                        // 默认转换
                        objectVal = Utils.str2TargetClass(value, header.getFiledClazz());
                    }
                    Utils.copyProperty(obj, filed, objectVal);
                }
                records.add(obj);
            }
        }
        return records;
    }

    /*---------------------------------------8.基于注解的CSV导出--------------------------------------------------*/
    /*  一. 操作流程 ：                                                                                           */
    /*      1) 写入表头内容(可选)                                                                                  */
    /*      2) 写入数据内容                                                                                       */
    /*  二. 参数说明                                                                                              */
    /*      *) data             =>      导出内容List集合                                                          */
    /*      *) isWriteHeader    =>      是否写表头                                                                */
    /*      *) path             =>      导出文件路径                                                              */
    /*      *) os               =>      导出文件流                                                                */
    /*      *) clazz            =>      映射对象                                                                  */

    /**
     * 基于注解导出CSV文件
     *
     * @param data  待导出
     * @param clazz {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param path  导出文件路径
     * @throws Excel4JException exception
     */
    public void exportObjects2CSV(List<?> data, Class clazz, String path)
            throws Excel4JException {

        try {
            Writer writer = new FileWriter(path);
            exportCSVByMapHandler(data, clazz, true, writer);
        } catch (Excel4JException | IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于注解导出CSV文件流
     *
     * @param data  待导出
     * @param clazz {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param os    输出流
     * @throws Excel4JException exception
     */
    public void exportObjects2CSV(List<?> data, Class clazz, OutputStream os)
            throws Excel4JException {

        try {
            Writer writer = new OutputStreamWriter(os);
            exportCSVByMapHandler(data, clazz, true, writer);
        } catch (Excel4JException | IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于注解导出CSV文件
     *
     * @param data          待导出
     * @param clazz         {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param isWriteHeader 是否写入文件
     * @param path          导出文件路径
     * @throws Excel4JException exception
     */
    public void exportObjects2CSV(List<?> data, Class clazz, boolean isWriteHeader, String path)
            throws Excel4JException {

        try {
            Writer writer = new FileWriter(path);
            exportCSVByMapHandler(data, clazz, isWriteHeader, writer);
        } catch (Excel4JException | IOException e) {
            throw new Excel4JException(e);
        }
    }

    /**
     * 基于注解导出CSV文件流
     *
     * @param data          待导出
     * @param clazz         {@link com.github.crab2died.annotation.ExcelField}映射对象Class
     * @param isWriteHeader 是否写入文件
     * @param os            输出流
     * @throws Excel4JException exception
     */
    public void exportObjects2CSV(List<?> data, Class clazz, boolean isWriteHeader, OutputStream os)
            throws Excel4JException {

        try {
            Writer writer = new OutputStreamWriter(os);
            exportCSVByMapHandler(data, clazz, isWriteHeader, writer);
        } catch (Excel4JException | IOException e) {
            throw new Excel4JException(e);
        }
    }

    private static final byte[] UTF_8_DOM = {(byte) 0xEF, (byte) 0xBB, (byte) 0xBF};

    // 生成CSV
    private void exportCSVByMapHandler(List<?> data, Class clazz, boolean isWriteHeader, Appendable appendable)
            throws Excel4JException, IOException {

        List<ExcelHeader> headers = Utils.getHeaderList(clazz);
        appendable.append(new String(UTF_8_DOM, StandardCharsets.UTF_8));

        try (CSVPrinter printer = new CSVPrinter(appendable, CSVFormat.EXCEL)) {

            if (isWriteHeader) {
                for (ExcelHeader header : headers) {
                    printer.print(header.getTitle());
                }
                printer.println();
            }
            // 写数据
            for (Object _data : data) {
                for (ExcelHeader header : headers) {
                    printer.print(
                            Utils.getProperty(_data, header.getFiled(), header.getWriteConverter())
                    );
                }
                printer.println();
            }
            printer.flush();
        }
    }

}
