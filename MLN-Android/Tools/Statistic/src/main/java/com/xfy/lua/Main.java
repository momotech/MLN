/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.lua;


import java.io.File;
import java.io.FileFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2020/7/28
 */
public class Main {
    private static String Suffix = ".xlsx";

    private static final String DIR = "-d";
    private static final String OUT_PATH = "-out";
    private static final String OUT_NAME = "-name";

    private static final String[] BoolKeys = {
            DIR
    };

    private static final String[] Keys = {
            OUT_PATH, OUT_NAME
    };

    private static String echoUsage() {
        return "java -jar Statistic.jar [options] <path1> [path2] ...\n" +
                "options:\n" +
                "\t-out: 输出文件路径，可选，默认为桌面\n" +
                "\t-name: 输出文件名，可选，默认为temp\n" +
                "\t-d: 输入类型为文件夹，会合并所有文件夹中文件，再统计，可选\n" +
                "eg: java -jar Statistic.jar file1 file2\n" +
                "\t合并file1、file2统计后生成excel到桌面下，文件名为temp.xlsx\n" +
                "eg: java -jar Statistic.jar -d dir1 dir2\n" +
                "\t合并dir1和dir2下所有文件，统计后在桌面生成temp.xlsx文件\n" +
                "eg: java -jar Statistic.jar -d -out outDir dir1 dir2\n" +
                "\t合并dir1和dir2下所有文件，统计后在outDir目录生成temp.xlsx文件\n";
    }

    private static String getDesktopPath() {
        String home = System.getenv("HOME");
        if (home == null || home.length() == 0)
            return null;
        return home + File.separator + "Desktop";
    }

    public static void main(String[] args) throws Exception {
//        System.out.println(new BridgeInfo(JSON.parseObject(Test.bridgeTest)));
//        generateExcel(Test.bridgeTest, "~/Desktop", "test.xlsx");



        if (args.length == 0) {
            System.out.println(echoUsage());
            return;
        }
        generateAuto(args);
    }

    private static void generateAuto(String[] args) throws Exception {
        ShellParams params = new ShellParams(BoolKeys, Keys, args);
        int useLen = 0;
        String name = params.getValue(OUT_NAME);
        if (name == null) {
            name = "temp_" + System.currentTimeMillis() + Suffix;
        } else {
            if (name.indexOf('.') < 0)
                name = name + Suffix;
            useLen += 2;
        }
        String outPath = params.getValue(OUT_PATH);
        if (outPath == null) {
            outPath = getDesktopPath();
            if (outPath == null)
                throw new IllegalArgumentException("获取不到桌面路径");
        } else {
            useLen += 2;
        }
        boolean dir = params.containKey(DIR);
        if (dir) {
            useLen += 1;
        }
        int argLen = args.length;
        if (argLen <= useLen) {
            System.out.println(echoUsage());
            return;
        }
        String[] paths = new String[argLen - useLen];
        System.arraycopy(args, useLen, paths, 0, argLen - useLen);
        generateExcel(paths, outPath, name, dir);
        System.out.println("成功：" + new File(outPath, name));
    }

    private static void generateExcel(String[] paths, String outPath, String name, boolean dir) throws Exception {
        File[] inFiles;
        if (dir) {
            List<File> fileList = new ArrayList<>();
            for (String p : paths) {
                File dp = new File(p);
                if (!dp.isDirectory())
                    throw new IllegalArgumentException(dp + " is not a directory!\n" + echoUsage());
                File[] children = dp.listFiles(fileFilter);
                if (children != null && children.length > 0) {
                    fileList.addAll(Arrays.asList(children));
                }
            }
            inFiles = new File[fileList.size()];
            inFiles = fileList.toArray(inFiles);
        } else {
            inFiles = new File[paths.length];
            int i = 0;
            for (String p : paths) {
                File f = new File(p);
                if (!f.isFile())
                    throw new IllegalArgumentException(f + " is not a file!\n" + echoUsage());
                inFiles[i++] = f;
            }
        }
        Statistic.generateExcel(inFiles, outPath, name);
    }

    private static void generateExcel(File f, String outPath, String name) throws Exception {
        if (!f.isFile())
            throw new IllegalArgumentException(f + " is not a file!");
        Statistic.generateExcel(f, outPath, name);
    }

    private static FileFilter fileFilter = new FileFilter() {
        @Override
        public boolean accept(File pathname) {
            return pathname.isFile();
        }
    };
}
