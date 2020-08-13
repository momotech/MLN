/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.xfy.shell;

import java.io.File;

/**
 * Created by Xiong.Fangyu on 2020/7/24
 */
public class FileFinder {

    private static final String MAIN_PATH = "src"+ File.separatorChar + "main";
    private static final String JAVA_PATH = MAIN_PATH + File.separatorChar + "java";
    private static final String JNI_PATH = MAIN_PATH + File.separatorChar + "jni";

    private static String pwd() {
        return System.getenv("PWD");
    }

    public static String findByModuleClass(String module, String className) {
        checkNull(module, "module");
        checkNull(className, "class name");
        File moduleDir = new File(pwd(), module);
        if (!moduleDir.isDirectory())
            throw new IllegalArgumentException(module + " is not a directory in current path(" + pwd() + ").");
        File srcDir = new File(module, JAVA_PATH);
        if (!srcDir.isDirectory())
            throw new IllegalArgumentException(srcDir + " is not a directory.");
        String classPath = StringReplaceUtils.replaceAllChar(className, '.', File.separatorChar) + ".java";
        File javaFile = new File(srcDir, classPath);
        if (!javaFile.isFile())
            throw new IllegalArgumentException(javaFile + " is not a file.");
        return javaFile.getAbsolutePath();
    }

    public static String findByModuleJni(String module, String jni) {
        checkNull(module, "module");
        checkNull(module, "jni");
        File moduleDir = new File(pwd(), module);
        if (!moduleDir.isDirectory())
            throw new IllegalArgumentException(module + " is not a directory in current path(" + pwd() + ").");
        File srcDir = new File(module, JNI_PATH);
        if (!srcDir.isDirectory())
            throw new IllegalArgumentException(srcDir + " is not a directory.");
        File javaFile = new File(srcDir, jni);
        return javaFile.getAbsolutePath();
    }

    private static void checkNull(Object o, String err) {
        if (o == null)
            throw new NullPointerException(err + " is null!");
    }
}
