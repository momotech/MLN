/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.lua;


import com.alibaba.fastjson.JSON;
import com.github.crab2died.ExcelUtils;
import com.github.crab2died.OnSheetPreparedListener;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.util.CellRangeAddress;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2020/7/28
 */
public class Statistic {
    private static final List<String> Header;
    static {
        Header = new ArrayList<>();
        Header.add("类名");
        Header.add("方法名");
        Header.add("调用次数");
        Header.add("总时长");
        Header.add("平均时长");
        Header.add("类方法调用次数");
        Header.add("类方法调用总时长");
    }

    public static void generateExcel(File file, String outPath, String name) throws Exception {
        generateExcel(new File[] {file}, outPath, name);
    }

    public static void generateExcel(File[] files, String outPath, String name) throws Exception {
        BridgeInfo out = null;
        for (File f : files) {
            String data = new String(FileUtils.readBytes(f));
            BridgeInfo bi = new BridgeInfo(JSON.parseObject(data));
            if (out == null) {
                out = bi;
            } else {
                out.add(bi);
            }
        }
        File outFile = new File(outPath, name);
        writeExcel(out, outFile.getAbsolutePath());
    }
    /**
     * className|methodName|count|time|avtime|allcount|alltime
     */
    private static List<List<Object>> parseExcelData(BridgeInfo info, List<CellRangeAddress> cellRangeAddresses) {
        List<List<Object>> result = new ArrayList<>();

        List<BridgeInfo.ClassInfo> classInfo = info.getClassInfo();
        int clzLen = classInfo.size();
        int firstRow = 1, lastRow = 1;
        for (int i = 0; i < clzLen; i ++) {
            BridgeInfo.ClassInfo ci = classInfo.get(i);
            List<Object> line = new ArrayList<>();
            line.add(ci.getName());
            result.add(line);
            List<Object> firstLine = line;
            List<BridgeInfo.MethodInfo> methodInfo = ci.getMethodInfo();
            int methodLen = methodInfo.size();
            for (int j = 0; j < methodLen; j ++) {
                BridgeInfo.MethodInfo mi = methodInfo.get(j);
                if (j != 0) {
                    line = new ArrayList<>();
                    line.add(null);
                    result.add(line);
                }
                line.add(mi.getName());
                line.add(mi.getAllCount());
                line.add(mi.getAllTime());
                line.add(mi.getAvTime());
            }
            firstLine.add(ci.getAllBridgeCount());
            firstLine.add(ci.getAllTime());
            if (cellRangeAddresses != null && methodLen > 1) {
                lastRow = firstRow + methodLen - 1;
                cellRangeAddresses.add(new CellRangeAddress(firstRow, lastRow, 0, 0));
                cellRangeAddresses.add(new CellRangeAddress(firstRow, lastRow, 5, 5));
                cellRangeAddresses.add(new CellRangeAddress(firstRow, lastRow, 6, 6));
            }
            firstRow += methodLen;
        }
        return result;
    }

    public static void writeExcel(BridgeInfo info, String path) throws IOException {
        final List<CellRangeAddress> addresses = new ArrayList<>();
        List<List<Object>> ret = parseExcelData(info, addresses);
        ExcelUtils.getInstance().exportObjects2Excel(ret, Header, path, sheet -> {
            for (CellRangeAddress a : addresses) {
                sheet.addMergedRegion(a);
            }
        });
    }
}
