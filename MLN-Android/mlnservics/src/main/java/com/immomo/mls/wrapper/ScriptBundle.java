/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.wrapper;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.IntDef;

import com.immomo.mls.LuaToolUtilInfo;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSConfigs;
import com.immomo.mls.adapter.dependence.DepInfo;
import com.immomo.mls.lite.LuaClient;
import com.immomo.mls.utils.ParsedUrl;
import com.immomo.mls.utils.UrlParams;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by Xiong.Fangyu on 2019/3/20
 * <p>
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

    /**
     * 入口文件路径
     * 不可为空
     */
    private String url;
    /**
     * 入口文件路径参数拼接类
     */
    private UrlParams urlParams;
    /**
     * 根路径，不可为空
     */
    private String basePath;

    /**
     * 工具类路径
     */
    private String luaToolBasePath;
    /**
     * lua入口文件
     */
    private ScriptFile main;
    /**
     * 其他可能被require的文件
     */
    private Map<String, ScriptFile> children;
    /**
     * 当前脚本包所对应的依赖信息
     */
    private DepInfo dependenceInfo;
    /**
     * luaViewManager持有 小心内存泄露 ScriptBundle不要被长生命周期对象持有
     */
    private Context context;
    /**
     * 传递给lua页面的对象 类似于bundle
     */
    private HashMap<Object, Object> params;
    /**
     * 用于清除的tag 默认是lifecyclewner 小心内存泄露 ScriptBundle不要被长生命周期对象持有
     */
    private Object tag;//用于清除资源
    private boolean forceLoadAssetResource;//强制加载预埋包
    private String localFile;//本地资源
    private ParsedUrl parsedUrl;//版本
    private int flag = 0;
    private AtomicInteger useByte = new AtomicInteger(0);

    public ScriptBundle(Builder builder) {
        this.url = builder.url;
        this.params = builder.params;
        this.basePath = builder.basePath;
        this.parsedUrl = builder.parsedUrl;
        this.localFile = builder.localFile;
        this.tag = builder.tag;
        this.context = builder.context;
        this.main = builder.main;
        this.children = builder.children;
        this.forceLoadAssetResource = builder.forceLoadAssetResource;
        if (builder.urlParams == null) {
            initUrlParam();
        } else {
            this.urlParams = builder.urlParams;
        }
    }

    private void initUrlParam() {
        try {
            if (!TextUtils.isEmpty(url)) {
                urlParams = new UrlParams(url);
            }
        } catch (Exception e) {
            MLSAdapterContainer.getConsoleLoggerAdapter().e(LuaClient.TAG, e);
            urlParams = new UrlParams("");
        }
    }

    public UrlParams getUrlParams() {
        return urlParams;
    }


    /**
     * 构造方法
     *
     * @param basePath 根路径
     */
    public ScriptBundle(String url, String basePath) {
        this.basePath = basePath;
        this.url = url;
        initUrlParam();
    }

    /**
     * 将入口脚本 和其他依赖脚本 赋值给本身
     *
     * @param luaDirectory 用于内存缓存 能有效避免内存泄露
     */
    public void setDirectory(LuaDirectory luaDirectory) {
        this.main = luaDirectory.getMain();
        this.children = luaDirectory.getChildren();
    }

    public DepInfo getDependenceInfo() {
        return dependenceInfo;
    }

    public void setDependenceInfo(DepInfo dependenceInfo) {
        this.dependenceInfo = dependenceInfo;
    }

    /**
     * 本地工具依赖包信息集合
     */
    private List<LuaToolUtilInfo> luaToolLocalInfoList = null;

    /**
     * 本地工具依赖兜底包信息集合
     */
    private List<LuaToolUtilInfo> luaToolLocalAssetInfoList = null;

    public List<LuaToolUtilInfo> getLuaToolLocalInfoList() {
        return luaToolLocalInfoList;
    }

    public void setLuaToolLocalInfoList(List<LuaToolUtilInfo> luaToolLocalInfoList) {
        this.luaToolLocalInfoList = luaToolLocalInfoList;
    }

    public List<LuaToolUtilInfo> getLuaToolLocalAssetInfoList() {
        return luaToolLocalAssetInfoList;
    }

    public void setLuaToolLocalAssetInfoList(List<LuaToolUtilInfo> luaToolLocalAssetInfoList) {
        this.luaToolLocalAssetInfoList = luaToolLocalAssetInfoList;
    }


    public String getBasePath() {
        return basePath;
    }

    public void setBasePath(String basePath) {
        this.basePath = basePath;
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

    public void setTag(Object tag) {
        this.tag = tag;
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

    public Context getContext() {
        return context;
    }

    public void setContext(Context context) {
        this.context = context;
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


    public boolean isForceLoadAssetResource() {
        return forceLoadAssetResource;
    }


    public HashMap<Object, Object> getParams() {
        return params;
    }

    public void setParams(HashMap<Object, Object> params) {
        this.params = params;
    }

    public Object tag() {
        return tag;
    }

    public String getLocalFile() {
        return localFile;
    }

    public void setLocalFile(String localFile) {
        this.localFile = localFile;
    }

    public ParsedUrl getParsedUrl() {
        return parsedUrl;
    }

    public void setParsedUrl(ParsedUrl parsedUrl) {
        this.parsedUrl = parsedUrl;
    }

    public void clear() {
        this.context = null;
        this.tag = null;
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


    public Builder newBuilder() {

            return new Builder(this);
    }

    public static class Builder {
        private final String url;
        /**
         * 根路径，不可为空
         */
        private String basePath;
        /**
         * 向lua传递的参数
         */
        public HashMap<Object, Object> params;
        private Object tag;
        private boolean forceLoadAssetResource;
        private String localFile;//本地资源
        private ParsedUrl parsedUrl;//版本
        private Context context;
        /**
         * lua入口文件
         */
        private ScriptFile main;
        /**
         * 子文件
         */
        private Map<String, ScriptFile> children;
        /**
         * 入口文件路径参数拼接类
         */
        private UrlParams urlParams;

        public Builder(String url, String basePath) {
            this.url = url;
            this.basePath = basePath;
        }

        public Builder(ScriptBundle request) {
            this.url = request.url;
            this.basePath = request.basePath;
            this.params = request.params;
            this.main = request.main;
            this.tag = request.tag;
            this.children = request.children;
            this.context = request.context;
            this.forceLoadAssetResource = request.forceLoadAssetResource;
            this.parsedUrl = request.parsedUrl;
            this.localFile = request.localFile;
            this.urlParams = request.urlParams;

        }

        public Builder tag(Object tag) {
            this.tag = tag;
            return this;
        }

        public Builder basePath(String basePath) {
            this.basePath = basePath;
            return this;
        }

        public Builder localFile(String localFile) {
            this.localFile = localFile;
            return this;
        }

        public Builder parsedUrl(ParsedUrl url) {
            this.parsedUrl = url;
            return this;
        }

        public Builder mainScriptFile(ScriptFile main) {
            this.main = main;
            return this;
        }

        public Builder childrenScriptFile(Map<String, ScriptFile> children) {
            this.children = children;
            return this;
        }

        public Builder context(Context context) {
            this.context = context;
            return this;
        }

        public Builder params(HashMap<Object, Object> params) {
            this.params = params;
            return this;
        }

        public Builder forceLoadAssetResource(boolean forceLoadAssetResource) {
            this.forceLoadAssetResource = forceLoadAssetResource;
            return this;
        }

        public ScriptBundle build() {
            return new ScriptBundle(this);
        }
    }
}