package com.xfy.shell;

import java.io.File;
import java.io.IOException;

public class Main {

    private static final String IN_PATH = "-in";
    private static final String OUT_PATH = "-out";
    private static final String OUT_NAME = "-name";

    private static String echoUsage() {
        return "usage: java -jar mlncgen.jar -in <javaFilePath> -out <outPath> [-name <outName>]";
    }

    public static void main(String[] args) throws Exception {
//        testParse();
//        autoGenerate("~/Desktop/UDCanvansTest.java", "~/Desktop", "temp.c");

        mainGenerate(args);
    }

    private static void mainGenerate(String[] args) throws Exception {
        int len = args.length;
        if (len < 4) {
            throw new Exception(echoUsage());
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
            throw new Exception(echoUsage());
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

    private static void testParse() throws IOException {
        final String javaFile = "~/Desktop/UDCanvansTest.java";
        byte[] data = FileUtils.readBytes(new File(javaFile));
        String content = ClearCommentUtils.clearComment(new String(data));
        Parser p = new Parser(content);
        System.out.println(p.toString());
    }
}
