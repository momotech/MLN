/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.wrapper;

import com.immomo.mls.MLSConfigs;

import org.luaj.vm2.Globals;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import androidx.annotation.IntDef;

/**
 * Created by Xiong.Fangyu on 2019/3/20
 *
 * 脚本包，可保存一个lua工程的所有文件
 */
public class ScriptBundle {
    public static final int TYPE_NETWORK = 1;
    public static final int TYPE_FILE = 2;  //cache
    public static final int TYPE_ASSETS = 4;
    private static final int TYPE_MASK = TYPE_NETWORK + TYPE_FILE + TYPE_ASSETS;

    public static final int BUNDLE = 1 << 3;
    public static final int SINGLE_FILE = 1 << 4;
    private static final int MODE_MASK = BUNDLE + SINGLE_FILE;

    public static final int ACTION_DOWNLOADED = 1 << 5;
    public static final int ACTION_UNZIP = 1 << 6;
    private static final int ACTION_MASK = ACTION_DOWNLOADED + ACTION_UNZIP;

    public static final int FROM_PRELOAD = 1 << 7;

    @Target(ElementType.PARAMETER)
    @IntDef({TYPE_NETWORK,
            TYPE_FILE,
            TYPE_ASSETS,
            BUNDLE,
            SINGLE_FILE,
            ACTION_DOWNLOADED,
            ACTION_UNZIP,
            FROM_PRELOAD})
    @Retention(RetentionPolicy.SOURCE)
    @interface Flag {

    }

    public String debugType() {
        int type = flag & TYPE_MASK;
        switch (type) {
            case TYPE_NETWORK:
                return "network";
            case TYPE_FILE:
                return "file";
            case TYPE_ASSETS:
                return "assets";
            default:
                return "";
        }
    }

    public String debugAction() {
        StringBuilder sb = new StringBuilder();
        if ((flag & ACTION_DOWNLOADED) == ACTION_DOWNLOADED) {
            sb.append("download");
        }
        if ((flag & ACTION_UNZIP) == ACTION_UNZIP) {
            sb.append("unzip");
        }
        return sb.toString();
    }

    private final String url;
    /**
     * 根路径，不可为空
     */
    private final String basePath;
    /**
     * lua入口文件
     */
    private ScriptFile main;
    /**
     * 其他可能被require的文件
     */
    private Map<String, ScriptFile> children;
    private int flag = 0;
    private AtomicInteger useByte = new AtomicInteger(0);
    private HashMap<String, String> params;

    /**
     * 构造方法
     * @param basePath 根路径
     */
    public ScriptBundle(String url, String basePath) {
        this.basePath = basePath;
        this.url = url;
    }

    public String getBasePath() {
        return basePath;
    }

    public ScriptFile getMain() {
        return main;
    }

    public void setMain(ScriptFile main) {
        this.main = main;
    }

    public void addUseByte(int l) {
        useByte.addAndGet(l);
    }

    public boolean checkUseByte() {
        return useByte.get() < MLSConfigs.maxAutoPreloadByte;
    }

    public Map<String, ScriptFile> getChildren() {
        return children;
    }

    public int size() {
        return children != null ? children.size() : 0;
    }

    public ScriptFile getChild(String chunkname) {
        return children != null ? children.get(chunkname) : null;
    }

    public void addChild(ScriptFile c) {
        addChild(c.getChunkName(), c);
    }

    public void addChild(String chunkname, ScriptFile c) {
        if (children == null) {
            children = new HashMap<>();
        }
        children.put(chunkname, c);
    }

    public boolean hasChildren() {
        return children != null;
    }

    public String getFlagDebugString() {
        return "type: " + debugType() + "\t" +
                "action: " + debugAction() + "\t" +
                "preload: " + ((flag & FROM_PRELOAD) == FROM_PRELOAD);
    }

    public int getAction() {
        return flag & ACTION_MASK;
    }

    public void addFlag(@Flag int flag) {
        this.flag |= flag;
    }

    public boolean hasFlag(@Flag int flag) {
        return (this.flag & flag) == flag;
    }

    public String getUrl() {
        return url;
    }

    public HashMap<String, String> getParams() {
        return params;
    }

    public void setParams(HashMap<String, String> params) {
        this.params = params;
    }

    @Override
    public String toString() {
        return "ScriptBundle{" +
                "url='" + url + '\'' +
                ", basePath='" + basePath + '\'' +
                ", main=" + main +
                ", children=" + (children != null ? children.keySet() : "null") +
                ", flag=" + getFlagDebugString() +
                '}';
    }
}