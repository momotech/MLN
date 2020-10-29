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

    public static String findByModuleClass(String module, String className) {
        return findByModuleClass(FileUtils.getCurrentJarPath(), module, className);
    }

    public static String findByModuleClass(File current, String module, String className) {
        checkNull(module, "module");
        checkNull(className, "class name");
        File moduleDir = new File(current, module);
        if (!moduleDir.isDirectory())
            throw new IllegalArgumentException(module + " is not a directory in path(" + current + ").");
        File srcDir = new File(moduleDir, JAVA_PATH);
        if (!srcDir.isDirectory())
            throw new IllegalArgumentException(srcDir + " is not a directory.");
        String classPath = StringReplaceUtils.replaceAllChar(className, '.', File.separatorChar) + ".java";
        File javaFile = new File(srcDir, classPath);
        if (!javaFile.isFile())
            throw new IllegalArgumentException(javaFile + " is not a file.");
        return javaFile.getAbsolutePath();
    }

    public static String findByModuleJni(String module, String jni) {
        return findByModuleJni(FileUtils.getCurrentJarPath(), module, jni);
    }

    public static String findByModuleJni(File current, String module, String jni) {
        checkNull(module, "module");
        checkNull(module, "jni");
        File moduleDir = new File(current, module);
        if (!moduleDir.isDirectory())
            throw new IllegalArgumentException(module + " is not a directory in current path(" + FileUtils.getCurrentJarPath() + ").");
        File srcDir = new File(moduleDir, JNI_PATH);
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
