/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

import android.content.Context;

import com.immomo.mls.Constants;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.StringReplaceUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

/**
 * Created by Xiong.Fangyu on 2019/3/20
 *
 * 脚本数据类
 */
public class ScriptFile {
    private final String chunkName;
    public final boolean isMain;
    public final boolean pathType;
    public final String path;

    private byte[] sourceData;
    private boolean compiled = false;
    private final boolean isAssetsPath;
    /**
     * 构造方法
     * @param chunkName require时需要的名称
     * @param data      lua源码或二进制码
     * @param isMain    是否是主入口
     */
    public ScriptFile(String chunkName, byte[] data, boolean isMain) {
        this.chunkName = chunkName;
        this.sourceData = data;
        this.isMain = isMain;
        path = null;
        pathType = false;
        isAssetsPath = false;
    }

    /**
     * 构造方法
     * @param chunkName require时需要的名称
     * @param path      脚本路径
     * @param isMain    是否是主入口
     */
    public ScriptFile(String chunkName, String path, boolean isMain) {
        this(chunkName, path, isMain, path.startsWith(Constants.ASSETS_PREFIX));
    }

    public ScriptFile(String chunkName, String path, boolean isMain, boolean isAssets) {
        this.chunkName = chunkName;
        this.path = path;
        pathType = true;
        this.isMain = isMain;
        this.isAssetsPath = isAssets;
    }

    /**
     * 判断源码或二进制码是否已存在在内存
     */
    public boolean hasSourceData() {
        return sourceData != null;
    }

    /**
     * 返回内存中的源码或二进制码
     */
    public byte[] getSourceData() {
        return sourceData;
    }

    public int getSourceDataLength() {
        return sourceData != null ? sourceData.length : 0;
    }

    /**
     * 在内存中保存读入的源码或二进制码
     * @param sourceData nullable
     */
    public void setSourceData(byte[] sourceData) {
        this.sourceData = sourceData;
    }

    public boolean isCompiled() {
        return compiled;
    }

    public void setCompiled(boolean compiled) {
        this.compiled = compiled;
    }

    /**
     * 设置文件，并读入内存中
     * @return true 读取成功
     */
    public boolean setFilePath(File f) {
        if (!f.isFile())
            return false;
        try {
            InputStream is = new FileInputStream(f);
            byte[] sourceData = new byte[is.available()];
            boolean ret = is.read(sourceData) == sourceData.length;
            if (ret)
                setSourceData(sourceData);
            return ret;
        } catch (Throwable ignore) {
            return false;
        }
    }

    public boolean isAssetsPath() {
        return isAssetsPath;
    }

    public String getAssetsPath() {
        if (!isAssetsPath)
            return path;
        if (path.startsWith(Constants.ASSETS_PREFIX))
            return path.substring(Constants.ASSETS_PREFIX.length());
        return path;
    }
    /**
     * 设置assets目录下文件，并读入内存中
     * @return true 读取成功
     */
    public boolean setAssetsPath(Context context, String assetsPath) {
        try {
            InputStream is = context.getAssets().open(assetsPath);
            byte[] sourceData = new byte[is.available()];
            boolean ret = is.read(sourceData) == sourceData.length;
            if (ret)
                setSourceData(sourceData);
            return ret;
        } catch (Throwable ignore) {
            return false;
        }
    }

    public String getChunkName() {
        return chunkName;
    }

    /**
     * 将{@link #chunkName}拼接到给定的跟目录下，创建需要的目录，并返回绝对路径
     * @param basePath 根目录
     */
    public String getPath(String basePath) {
        return createDirAndReturn(basePath, getFileName(Constants.POSTFIX_LUA));
    }

    /**
     * 将{@link #chunkName}拼接到给定的跟目录下，创建需要的目录，并返回绝对路径
     * @param basePath 根目录
     */
    public String getBinPath(String basePath) {
        return createDirAndReturn(basePath, getFileName(Constants.POSTFIX_B_LUA));
    }

    private String createDirAndReturn(String basePath, String name) {
        File f = new File(basePath, name);
        File parent = f.getParentFile();
        if (!parent.isDirectory()) {
            parent.mkdirs();
        }
        return f.getAbsolutePath();
    }

    private String getFileName(String suffix) {
        String name = chunkName;
        if (name.indexOf('.') >= 0) {
            if (name.endsWith(Constants.POSTFIX_LUA)) {
                /// 不用判断equals
                if (suffix != Constants.POSTFIX_LUA) {
                    name = StringReplaceUtils.replaceAllChar(name, '.', '/');
                    name = name.replace("/lua", suffix);
                }
            } else {
                name = StringReplaceUtils.replaceAllChar(name, '.', '/') + suffix;
            }
        } else {
            name = name + suffix;
        }
        return name;
    }

    @Override
    public String toString() {
        return "ScriptFile{" +
                "chunkName='" + chunkName + '\'' +
                ", has sourceData=" + (sourceData != null) +
                ", compiled=" + compiled +
                ", isMain=" + isMain +
                '}';
    }
}