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

package com.github.crab2died.handler;

import com.github.crab2died.exceptions.Excel4JException;
import org.apache.poi.ss.usermodel.*;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Calendar;
import java.util.Date;
import java.util.Map;

public class SheetTemplateHandler {

    // 构建SheetTemplate
    public static SheetTemplate sheetTemplateBuilder(String templatePath)
            throws Excel4JException {
        SheetTemplate sheetTemplate = new SheetTemplate();
        try {
            // 读取模板文件
            sheetTemplate.workbook = WorkbookFactory.create(new FileInputStream(new File(templatePath)));
        } catch (Exception e) {
            // 读取模板相对文件
            try {
                sheetTemplate.workbook = WorkbookFactory.create(
                        SheetTemplateHandler.class.getResourceAsStream(templatePath)
                );
            } catch (IOException e1) {
                throw new Excel4JException(e1);
            }
        }
        return sheetTemplate;
    }

    public static SheetTemplate sheetTemplateBuilder(InputStream is)
            throws Excel4JException {
        SheetTemplate sheetTemplate = new SheetTemplate();

        // 读取模板文件
        try {
            sheetTemplate.workbook = WorkbookFactory.create(is);
        } catch (IOException e) {
            throw new Excel4JException(e);
        }
        return sheetTemplate;
    }

    /*-----------------------------------初始化模板开始-----------------------------------*/

    public static void loadTemplate(SheetTemplate template, int sheetIndex) {

        if (sheetIndex < 0) sheetIndex = 0;
        template.sheetIndex = sheetIndex;
        template.sheet = template.workbook.getSheetAt(sheetIndex);
        initModuleConfig(template);
        template.currentRowIndex = template.initRowIndex;
        template.currentColumnIndex = template.initColumnIndex;
        template.lastRowIndex = template.sheet.getLastRowNum();
    }

    /**
     * 初始化数据信息
     */
    private static void initModuleConfig(SheetTemplate template) {

        for (Row row : template.sheet) {
            for (Cell c : row) {
                if (c.getCellType() != CellType.STRING)
                    continue;
                String str = c.getStringCellValue().trim().toLowerCase();
                // 寻找序号列
                if (HandlerConstant.SERIAL_NUMBER.equals(str)) {
                    template.serialNumberColumnIndex = c.getColumnIndex();
                }
                // 寻找数据列
                if (HandlerConstant.DATA_INIT_INDEX.equals(str)) {
                    template.initColumnIndex = c.getColumnIndex();
                    template.initRowIndex = row.getRowNum();
                    template.rowHeight = row.getHeightInPoints();
                }
                // 初始化自定义模板样式
                initStyles(template, c, str);
            }
        }
    }

    /**
     * 初始化样式信息
     */
    private static void initStyles(SheetTemplate template, Cell cell, String moduleContext) {
        if (null == moduleContext || "".equals(moduleContext))
            return;
        if (!moduleContext.startsWith("&"))
            moduleContext = moduleContext.toLowerCase();
        if (HandlerConstant.DEFAULT_STYLE.equals(moduleContext)) {
            template.defaultStyle = cell.getCellStyle();
            clearCell(cell);
        }
        if (moduleContext.startsWith("&") && moduleContext.length() > 1) {
            template.classifyStyle.put(moduleContext.substring(1), cell.getCellStyle());
            clearCell(cell);
        }
        if (HandlerConstant.APPOINT_LINE_STYLE.equals(moduleContext)) {
            template.appointLineStyle.put(cell.getRowIndex(), cell.getCellStyle());
            clearCell(cell);
        }
        if (HandlerConstant.SINGLE_LINE_STYLE.equals(moduleContext)) {
            template.singleLineStyle = cell.getCellStyle();
            clearCell(cell);
        }
        if (HandlerConstant.DOUBLE_LINE_STYLE.equals(moduleContext)) {
            template.doubleLineStyle = cell.getCellStyle();
            clearCell(cell);
        }
    }

    private static void clearCell(Cell cell) {
        cell.setCellStyle(null);
        cell.setCellValue("");
    }

    /*-----------------------------------初始化模板结束-----------------------------------*/

    /*------------------------------------数据填充开始------------------------------------*/

    /**
     * 根据map替换相应的常量，通过Map中的值来替换#开头的值
     *
     * @param data 替换映射
     */
    public static void extendData(SheetTemplate template, Map<String, String> data) {
        if (data == null)
            return;
        for (Row row : template.sheet) {
            for (Cell c : row) {
                if (c.getCellType() != CellType.STRING)
                    continue;
                String str = c.getStringCellValue().trim();
                if (str.startsWith("#") && data.containsKey(str.substring(1))) {
                    c.setCellValue(data.get(str.substring(1)));
                }
            }
        }
    }

    /**
     * 创建新行，在使用时只要添加完一行，需要调用该方法创建
     */
    public static void createNewRow(SheetTemplate template) {
        if (template.lastRowIndex > template.currentRowIndex && template.currentRowIndex != template.initRowIndex) {
            template.sheet.shiftRows(template.currentRowIndex, template.lastRowIndex, 1, true, true);
            template.lastRowIndex++;
        }
        template.currentRow = template.sheet.createRow(template.currentRowIndex);
        template.currentRow.setHeightInPoints(template.rowHeight);
        template.currentRowIndex++;
        template.currentColumnIndex = template.initColumnIndex;
    }

    /**
     * 插入序号，会自动找相应的序号标示的位置完成插入
     *
     * @param styleKey 样式标识
     */
    public static void insertSerial(SheetTemplate template, String styleKey) {
        if (template.serialNumberColumnIndex < 0)
            return;
        template.serialNumber++;
        Cell c = template.currentRow.createCell(template.serialNumberColumnIndex);
        setCellStyle(template, c, styleKey);
        c.setCellValue(template.serialNumber);
    }

    /**
     * <p>设置Excel元素样式及内容</p>
     *
     * @param value    内容
     * @param styleKey 样式
     */
    public static void createCell(SheetTemplate template, Object value, String styleKey) {
        Cell cell = template.currentRow.createCell(template.currentColumnIndex);
        setCellStyle(template, cell, styleKey);
        if (null == value || "".equals(value)) {
            template.currentColumnIndex++;
            return;
        }

        if (String.class == value.getClass()) {
            cell.setCellValue((String) value);
            template.currentColumnIndex++;
            return;
        }

        if (int.class == value.getClass()) {
            cell.setCellValue((int) value);
            template.currentColumnIndex++;
            return;
        }

        if (Integer.class == value.getClass()) {
            cell.setCellValue((Integer) value);
            template.currentColumnIndex++;
            return;
        }

        if (double.class == value.getClass()) {
            cell.setCellValue((double) value);
            template.currentColumnIndex++;
            return;
        }

        if (Double.class == value.getClass()) {
            cell.setCellValue((Double) value);
            template.currentColumnIndex++;
            return;
        }

        if (Date.class == value.getClass()) {
            cell.setCellValue((Date) value);
            template.currentColumnIndex++;
            return;
        }

        if (boolean.class == value.getClass()) {
            cell.setCellValue((boolean) value);
            template.currentColumnIndex++;
            return;
        }

        if (Boolean.class == value.getClass()) {
            cell.setCellValue((Boolean) value);
            template.currentColumnIndex++;
            return;
        }

        if (Calendar.class == value.getClass()) {
            cell.setCellValue((Calendar) value);
            template.currentColumnIndex++;
            return;
        }

        if (RichTextString.class == value.getClass()) {
            cell.setCellValue((RichTextString) value);
            template.currentColumnIndex++;
            return;
        }
        // default value#toString
        cell.setCellValue(value.toString());
        template.currentColumnIndex++;
    }

    /**
     * 设置某个元素的样式
     *
     * @param cell     cell元素
     * @param styleKey 样式标识
     */
    private static void setCellStyle(SheetTemplate template, Cell cell, String styleKey) {
        if (null != styleKey && null != template.classifyStyle.get(styleKey)) {
            cell.setCellStyle(template.classifyStyle.get(styleKey));
            return;
        }

        if (null != template.appointLineStyle && template.appointLineStyle.containsKey(cell.getRowIndex())) {
            cell.setCellStyle(template.appointLineStyle.get(cell.getRowIndex()));
            return;
        }
        if (null != template.singleLineStyle && (cell.getRowIndex() % 2 != 0)) {
            cell.setCellStyle(template.singleLineStyle);
            return;
        }
        if (null != template.doubleLineStyle && (cell.getRowIndex() % 2 == 0)) {
            cell.setCellStyle(template.doubleLineStyle);
            return;
        }
        if (null != template.defaultStyle)
            cell.setCellStyle(template.defaultStyle);
    }

    /*-----------------------------------数据填充结束-----------------------------------*/

}
