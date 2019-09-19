/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.luanative.util;

//import com.intellij.openapi.module.Module;
//import com.intellij.openapi.module.ModuleManager;
//import com.intellij.openapi.project.Project;
//import com.intellij.openapi.roots.ModuleRootManager;
//import com.intellij.openapi.ui.Messages;
//import com.intellij.openapi.vfs.VirtualFile;

public class LuaNativeEntryFileUtil {

//    private Project project;
//    private VirtualFile srcFile;
//
//    public LuaNativeEntryFileUtil(Project project) {
//        this.project = project;
//        setup();
//    }
//
//    private void setup() {
//        Module[] modules = ModuleManager.getInstance(project).getModules();
//        for (Module module:modules) {
//            VirtualFile[] files = ModuleRootManager.getInstance(module).getSourceRoots();
//            for (VirtualFile file: files) {
//                if (file.isDirectory() && file.getUrl().endsWith("src")) {
//                    srcFile = file;
//                } else {
//                    Messages.showMessageDialog(project, "未找到src目录", "错误", Messages.getErrorIcon());
//                }
//            }
//        }
//    }
//
//    public VirtualFile getSrcFile() {
//        return srcFile;
//    }
//
//    public String getSrcRelativePath(String filePath) {
//        if (!LuaNativeUtil.isLuaFile(filePath)) {
//            return null;
//        }
//        String tmp = filePath.replace(srcFile.getUrl(),"");
//        if (tmp != null && tmp.startsWith("/")) {
//            tmp = tmp.replaceFirst("/", "");
//        }
//        return tmp;
//    }

}