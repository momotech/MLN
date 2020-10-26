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

    private static final String MODULE = "-module";
    private static final String CLASS_NAME = "-class";
    private static final String JNI_NAME = "-jni";

    private static final String CALLBACK = "-callback";

    private static final String[] keys = {
            IN_PATH, OUT_PATH, OUT_NAME, MODULE, CLASS_NAME, JNI_NAME
    };

    private static final String[] boolKeys = {
            CALLBACK
    };

    private static String echoUsage() {
        return "usage: java -jar mlncgen.jar <options> [options]\n"+
                "-in: 输入文件（必须，或使用module+class代替）\n" +
                "-module: 模块名称\n" +
                "-class: java全类名称\n" +
                "-out: 输出文件路径（必须，或使用module+jni代替）\n" +
                "-jni: c文件输出模块\n" +
                "-name: 输出文件名称（可选）\n" +
                "-callback: 生成fast callback" +
                "说明: userdata必须继承LuaUserdata，且bridge方法必须都非静态方法，并需要增加@LuaApiUsed注解;\n"+
                "\t静态bridge中所有bridge方法必须是静态方法，并需要增加@LuaApiUsed注解;\n" +
                "\tcallback中必须有native方法，且native方法参数至少3个";
    }

    private static final File Project = new File("/Users/XiongFangyu/Desktop/MMLua4Android");
    private static final String TestDir = "/Users/XiongFangyu/Desktop/MMLua4Android/mmui/src/main/java";
    private static final String TestDir2 = "/Users/XiongFangyu/Desktop/MMLua4Android/mlnservics/src/main/java";

    public static void main(String[] args) throws Exception {
//        testMethodParams();
//        testParse(Project, "mmui", "com.immomo.mmui.ud.AdapterLuaFunction");
//        autoGenerate(Project, "mmui", "com.immomo.mmui.ud.recycler.UDRecyclerView", "bridge", "mmrecyclerview.c");
//        testParse(TestDir, "com.immomo.mmui.ud.UDColor");
//        testParse(TestDir + "/com/immomo/mmui/ud/UDLabel.java");
//        testParse(TestDir + "/com/immomo/mmui/ud/anim/InteractiveBehavior.java");
//        testParse(TestDir + "/com/immomo/mmui/databinding/LTCDataBinding.java");
//        testAnnotation();
//        autoGenerate(TestDir + "/com/immomo/mmui/ud/anim/UDAnimation.java", "/Users/XiongFangyu/Downloads", "temp.c");
//        autoGenerate(TestDir + "/com/immomo/mmui/ud/UDVStack.java", "/Users/XiongFangyu/Downloads", "temp.c");
//        autoGenerate(TestDir + "/com/immomo/mmui/ud/UDColor.java", "/Users/XiongFangyu/Downloads", "temp.c");
//        autoGenerate(TestDir + "/com/immomo/mmui/ud/UDStyleString.java", "/Users/XiongFangyu/Downloads", "temp.c");
//        autoGenerate(TestDir + "/com/immomo/mmui/databinding/LTCDataBinding.java",
//                "/Users/XiongFangyu/Downloads", "temp.c");
//        autoGenerateCallback(Project, "mmui", "com.immomo.mmui.ud.RecyclerLuaFunction", "bridge", "temp.c");
        mainGenerate(args);
    }

    private static void mainGenerate(String[] args) throws Exception {
        ShellParams shellParams = new ShellParams(boolKeys, keys, args);
        String javaFile = shellParams.getValue(IN_PATH);
        String outPath = shellParams.getValue(OUT_PATH);
        String fileName = shellParams.getValue(OUT_NAME);
        if (fileName == null) {
            fileName = "temp.c";
        }
        if (javaFile == null) {
            try {
                javaFile = FileFinder.findByModuleClass(shellParams.getValue(MODULE), shellParams.getValue(CLASS_NAME));
            } catch (Exception e) {
                System.out.println(echoUsage());
                throw new Exception(e.getMessage());
            }
        }
        if (outPath == null) {
            try {
                outPath = FileFinder.findByModuleJni(shellParams.getValue(MODULE), shellParams.getValue(JNI_NAME));
            } catch (Exception e) {
                System.out.println(echoUsage());
                throw new Exception(e.getMessage());
            }
        }

        if (shellParams.containKey(CALLBACK)) {
            autoGenerateCallback(javaFile, outPath, fileName);
        } else {
            autoGenerate(javaFile, outPath, fileName);
        }
        File f = new File(outPath, fileName);
        System.out.println("generate success! " + f);
    }

    private static void autoGenerate(File project, String module, String className, String jni, String outName) throws Exception {
        final String javaFile;
        final String out;
        if (project != null) {
            javaFile = (FileFinder.findByModuleClass(project, module, className));
            out = (FileFinder.findByModuleJni(project, module, jni));
        } else {
            javaFile = (FileFinder.findByModuleClass(module, className));
            out = (FileFinder.findByModuleJni(module, jni));
        }
        autoGenerate(javaFile, out, outName);
    }

    private static void autoGenerateCallback(File project, String module, String className, String jni, String outName) throws Exception {
        final String javaFile;
        final String out;
        if (project != null) {
            javaFile = (FileFinder.findByModuleClass(project, module, className));
            out = (FileFinder.findByModuleJni(project, module, jni));
        } else {
            javaFile = (FileFinder.findByModuleClass(module, className));
            out = (FileFinder.findByModuleJni(module, jni));
        }
        autoGenerateCallback(javaFile, out, outName);
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

    private static void autoGenerateCallback(String javaFile, String outPath, String fileName) throws Exception {
        byte[] data = FileUtils.readBytes(new File(javaFile));
        String content = ClearCommentUtils.clearComment(new String(data));
        Parser p = new Parser(content);
        String cn = p.getClassName();
        if (cn == null || cn.isEmpty()) {
            throw new Exception("class name is empty!");
        }
        NativeCallbackGenerator g = new NativeCallbackGenerator(p);
        FileUtils.writeFile(new File(outPath, fileName), g.toString().getBytes());
    }

    private static void testParse(File project, String module, String className) throws Exception {
        File f = new File(FileFinder.findByModuleClass(project, module, className));
        byte[] data = FileUtils.readBytes(f);
        String content = ClearCommentUtils.clearComment(new String(data));
        Parser p = new Parser(content);
        System.out.println(p.toString());
    }

    private static void testParse(String javaFile) throws Exception {
        byte[] data = FileUtils.readBytes(new File(javaFile));
        String content = ClearCommentUtils.clearComment(new String(data));
        Parser p = new Parser(content);
        System.out.println(p.toString());
    }

    private static void testAnnotation() throws Exception {
        final String src = "@CGenerate(params = \"F\", returnType = \"\", other=1, bbb=true)" +
                "@CGenerate @CGenerate(p=1) ";
        System.out.println(Annotation.parseMultiAnnotation(src));
    }

    private static void testMethodParams() throws Exception {
        final String src = "xxxx(final int a,String b , Map<String, Object > c, List<> d)asgasfa";
        System.out.println(Parser.parseMethodParams(src.toCharArray(), src.indexOf('('), src.length()));
    }
}
