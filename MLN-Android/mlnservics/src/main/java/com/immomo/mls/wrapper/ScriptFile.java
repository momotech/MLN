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
    }

    /**
     * 构造方法
     * @param chunkName require时需要的名称
     * @param path      脚本路径
     * @param isMain    是否是主入口
     */
    public ScriptFile(String chunkName, String path, boolean isMain) {
        this.chunkName = chunkName;
        this.path = path;
        pathType = true;
        this.isMain = isMain;
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
        return path != null && path.startsWith(Constants.ASSETS_PREFIX);
    }

    public String getAssetsPath() {
        if (path == null || !path.startsWith(Constants.ASSETS_PREFIX))
            return path;
        return path.substring(Constants.ASSETS_PREFIX.length());
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
     * 如果该文件由{@link Globals#preloadData(String, byte[])} or {@link Globals#preloadFile(String, String)}预加载过
     * 则保存已编译的二进制数据到文件中
     * @param g         虚拟机
     * @param basePath  根目录，将通过{@link #getPath(String)}方法拼接成绝对路径
     * @return true 保存成功
     */
    public boolean saveIfPreloaded(Globals g, String basePath) {
        try {
            return g.savePreloadData(chunkName, getPath(basePath));
        } catch (RuntimeException ignore) {
            return false;
        }
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
                    name = name.replaceAll("\\.", "/");
                    name = name.replace("/lua", suffix);
                }
            } else {
                name = name.replaceAll("\\.", "/") + suffix;
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