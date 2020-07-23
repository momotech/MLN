/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.xfy.shell;

import java.io.File;

public class Main {

    private static final String IN_PATH = "-in";
    private static final String OUT_PATH = "-out";
    private static final String OUT_NAME = "-name";

    private static String echoUsage() {
        return "usage: java -jar mlncgen.jar -in <javaFilePath> -out <outPath> [-name <outName>]\n"+
                "说明: userdata必须继承LuaUserdata，且bridge方法必须都非静态方法，并需要增加@LuaApiUsed注解;\n"+
                "\t静态bridge中所有bridge方法必须是静态方法，并需要增加@LuaApiUsed注解。";
    }

    public static void main(String[] args) throws Exception {
//        testParse("/Users/XiongFangyu/Downloads/LTCDataBinding.java");
//        autoGenerate("/Users/XiongFangyu/Downloads/LTCDataBinding.java", "/Users/XiongFangyu/Downloads", "temp.c");

        mainGenerate(args);
    }

    private static void mainGenerate(String[] args) throws Exception {
        int len = args.length;
        if (len < 4) {
            throw new Exception("参数不够！\n" + echoUsage());
        }
        String javaFile = null;
        String outPath = null;
        String fileName = "temp.c";
        for (int i = 0; i < len ; i ++) {
            String arg = args[i];
            switch (arg) {
                case IN_PATH:
                    javaFile = i < (len - 1) ? args[++i] : null;
                    break;
                case OUT_PATH:
                    outPath = i < (len - 1) ? args[++i] : null;
                    break;
                case OUT_NAME:
                    fileName = i < (len - 1) ? args[++i] : null;
                    break;
            }
        }
        if (javaFile == null || outPath == null || fileName == null) {
            throw new Exception("参数有错误！\n" + echoUsage());
        }

        autoGenerate(javaFile, outPath, fileName);
        File f = new File(outPath, fileName);
        System.out.println("generate success! " + f);
    }

    private static void autoGenerate(String javaFile, String outPath, String fileName) throws Exception {
        byte[] data = FileUtils.readBytes(new File(javaFile));
        String content = ClearCommentUtils.clearComment(new String(data));
        Parser p = new Parser(content);
        String cn = p.getClassName();
        if (cn == null || cn.isEmpty()) {
            throw new Exception("class name is empty!");
        }
        NativeGenerator g = new NativeGenerator(p);
        FileUtils.writeFile(new File(outPath , fileName), g.toString().getBytes());
    }

    private static void testParse(String javaFile) throws Exception {
        byte[] data = FileUtils.readBytes(new File(javaFile));
        String content = ClearCommentUtils.clearComment(new String(data));
        Parser p = new Parser(content);
        System.out.println(p.toString());
    }
}