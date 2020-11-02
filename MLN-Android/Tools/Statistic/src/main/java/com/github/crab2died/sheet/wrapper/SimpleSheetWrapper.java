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
 * <p>无模板，无注解的简单sheet包装类</p>
 * author : Crab2Died
 * date : 2015/5/1  10:35
 */
public class SimpleSheetWrapper {

    /**
     * 每个sheet的列表数据
     */
    private List<?> data;

    /**
     * 每个sheet的表头
     */
    private List<String> header;

    /**
     * 每个sheet的名字
     */
    private String sheetName;

    public SimpleSheetWrapper() {
    }

    public SimpleSheetWrapper(List<?> data, List<String> header, String sheetName) {
        this.data = data;
        this.header = header;
        this.sheetName = sheetName;
    }

    public SimpleSheetWrapper(List<?> data, List<String> header) {
        this.data = data;
        this.header = header;
    }

    public SimpleSheetWrapper(List<?> data, String sheetName) {
        this.data = data;
        this.sheetName = sheetName;
    }

    public SimpleSheetWrapper(List<?> data) {
        this.data = data;
    }

    public List<?> getData() {
        return data;
    }

    public void setData(List<?> data) {
        this.data = data;
    }

    public List<String> getHeader() {
        return header;
    }

    public void setHeader(List<String> header) {
        this.header = header;
    }

    public String getSheetName() {
        return sheetName;
    }

    public void setSheetName(String sheetName) {
        this.sheetName = sheetName;
    }
}
