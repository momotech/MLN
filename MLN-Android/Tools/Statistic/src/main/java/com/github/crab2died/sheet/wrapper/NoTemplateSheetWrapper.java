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

package com.github.crab2died.sheet.wrapper;

import java.util.List;

/**
 * <p>无模板、基于注解导出的sheet包装类</p>
 * author : Crab2Died
 * date : 2015/5/1  10:35
 */
public class NoTemplateSheetWrapper {

    /**
     * 待导出行数据
     */
    private List<?> data;

    /**
     * 基于注解的class
     */
    private Class clazz;

    /**
     * 是否写入表头
     */
    private boolean isWriteHeader;

    /**
     * sheet名
     */
    private String sheetName;

    public NoTemplateSheetWrapper() {
    }

    public NoTemplateSheetWrapper(List<?> data, Class clazz) {
        this.data = data;
        this.clazz = clazz;
    }

    public NoTemplateSheetWrapper(List<?> data, Class clazz, boolean isWriteHeader) {
        this.data = data;
        this.clazz = clazz;
        this.isWriteHeader = isWriteHeader;
    }

    public NoTemplateSheetWrapper(List<?> data, Class clazz, boolean isWriteHeader, String sheetName) {
        this.data = data;
        this.clazz = clazz;
        this.isWriteHeader = isWriteHeader;
        this.sheetName = sheetName;
    }

    public List<?> getData() {
        return data;
    }

    public void setData(List<?> data) {
        this.data = data;
    }

    public Class getClazz() {
        return clazz;
    }

    public void setClazz(Class clazz) {
        this.clazz = clazz;
    }

    public boolean isWriteHeader() {
        return isWriteHeader;
    }

    public void setWriteHeader(boolean writeHeader) {
        isWriteHeader = writeHeader;
    }

    public String getSheetName() {
        return sheetName;
    }

    public void setSheetName(String sheetName) {
        this.sheetName = sheetName;
    }
}
