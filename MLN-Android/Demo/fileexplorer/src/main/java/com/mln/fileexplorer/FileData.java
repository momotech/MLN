package com.mln.fileexplorer;

import android.annotation.SuppressLint;

import androidx.annotation.IntDef;

import java.io.File;
import java.lang.annotation.Retention;

import static java.lang.annotation.RetentionPolicy.SOURCE;

/**
 * Created by Xiong.Fangyu on 2019-05-28
 */
public class FileData {
    private static final int EXIST = 1;
    private static final int DIRECTORY = 1 << 1;

    private static final int TYPE_OFFSET = 4;
    private static final int TYPE_MASK = 0xf << (32 - TYPE_OFFSET);

    public static final int TYPE_FILE = 1 << 31;
    public static final int TYPE_ASSETS = 1 << 30;

    @Retention(SOURCE)
    @IntDef({TYPE_FILE, TYPE_ASSETS})
    public @interface TYPE {}

    private final String parentPath;

    private final String parentName;

    private final String path;

    private final String name;

    private String desc;

    private int flag;

    private boolean parentFlag = false;

    private static String deleteLastSeparator(String s) {
        int l = s.length();
        if (l > 1 && s.charAt(l - 1) == File.separatorChar)
            s = s.substring(0, l - 1);
        return s;
    }

    private static String deleteFirstSeparator(String s) {
        if (s.length() > 0 && s.charAt(0) == File.separatorChar)
            s = s.substring(1);
        return s;
    }

    public FileData(File file) {
        File parent = file.getParentFile();
        if (parent != null) {
            path = parent.getAbsolutePath();
            parentPath = parent.getParent();
            parentName = parent.getName();
        } else {
            path = File.separator;
            parentPath = null;
            parentName = null;
        }
        name = file.getName();
        setExist(file.exists());
        setDirectory(file.isDirectory());
        setType(TYPE_FILE);
    }

    public FileData(String path, String name) {
        path = deleteLastSeparator(path);
        name = deleteFirstSeparator(deleteLastSeparator(name));
        this.path = path;
        this.name = name;
        int i = path.lastIndexOf(File.separatorChar);
        if (i >= 0) {
            if (i == 0)
                parentPath = File.separator;
            else
                parentPath = path.substring(0, i);
            parentName = path.substring(i + 1);
        } else if (name != null && !name.isEmpty()) {
            parentPath = "";
            parentName = path;
        } else {
            parentPath = parentName = null;
        }
    }

    public FileData(String path, String name, String parentPath, String parentName) {
        path = deleteLastSeparator(path);
        name = deleteFirstSeparator(deleteLastSeparator(name));
        this.path = path;
        this.name = name;
        parentPath = deleteLastSeparator(parentPath);
        parentName = deleteFirstSeparator(deleteLastSeparator(parentName));
        this.parentPath = parentPath;
        this.parentName = parentName;
    }

    public FileData(FileData src) {
        path = src.path;
        name = src.name;
        parentPath = src.parentPath;
        parentName = src.parentName;
    }

    public String getPath() {
        return path;
    }

    public String getName() {
        return name;
    }

    public String getPathName() {
        return (path != null && !path.isEmpty()) ? (path + File.separator + name) : name;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public FileData getParent() {
        if (parentPath == null || parentName == null || (getType() != TYPE_ASSETS && parentName.length() == 0))
            return null;
        FileData ret = new FileData(parentPath, parentName);
        ret.setDirectory(true);
        ret.setExist(true);
        ret.setType(getType());
        return ret;
    }

    public boolean isParentDirectory() {
        return parentFlag;
    }

    public void setParentDirectory(boolean pd) {
        parentFlag = pd;
    }

    public void setExist(boolean exist) {
        if (exist)
            flag |= EXIST;
        else
            flag &= ~EXIST;
    }

    public void setDirectory(boolean isDir) {
        if (isDir)
            flag |= DIRECTORY;
        else
            flag &= ~DIRECTORY;
    }

    public void setType(@TYPE int type) {
        flag = flag & ~TYPE_MASK | (type & TYPE_MASK);
    }

    public boolean isExists() {
        return (flag & EXIST) == EXIST;
    }

    public boolean isDirectory() {
        return (flag & DIRECTORY) == DIRECTORY;
    }

    @SuppressLint("WrongConstant")
    public @TYPE int getType() {
        return flag & TYPE_MASK;
    }
}
