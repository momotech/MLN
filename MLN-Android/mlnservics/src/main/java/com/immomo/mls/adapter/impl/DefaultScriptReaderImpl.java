/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter.impl;

import android.annotation.SuppressLint;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.Constants;
import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.ScriptReader;
import com.immomo.mls.adapter.X64PathAdapter;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.IOUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.util.PreloadUtils;
import com.immomo.mls.utils.ERROR;
import com.immomo.mls.utils.GlobalStateUtils;
import com.immomo.mls.utils.LuaUrlUtils;
import com.immomo.mls.utils.ParsedUrl;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.utils.loader.Callback;
import com.immomo.mls.utils.loader.LoadTypeUtils;
import com.immomo.mls.utils.loader.ScriptInfo;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptFile;

import org.luaj.vm2.Globals;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.lang.ref.WeakReference;

/**
 * Created by Xiong.Fangyu on 2019-08-27
 *
 * 加载流程：
 * ┌──────────┐
 * │ url info │
 * └──────────┘
 * ↓
 * ┌──────────────────────────┐
 * │ forceDownload？删除本地文件│
 * └──────────────────────────┘
 * ↓
 * ┌───────────────────────────────────────┐
 * │ 本地文件?读取本地文件:下载或从assets中解压 │
 * └───────────────────────────────────────┘
 * ↓
 * ┌──────────────┐
 * │ 通知读脚本成功 │
 * └──────────────┘
 *
 * 以上任何步骤出错，则流程断开，调用{@link #callbackError(Callback, ParsedUrl, ScriptLoadException)}
 */
public class DefaultScriptReaderImpl implements ScriptReader {
    private static final String TAG = "ScriptReader";
    private static final String ASSETS = "android_asset";

    private final Object tag = TAG + hashCode();
    protected String srcUrl;
    protected ParsedUrl mSrcParsedUrl;
    protected String entryFile;

    protected int loadType;
    private String errorString;
    protected boolean destroyed = false;

    protected long timeout;

    public DefaultScriptReaderImpl(String url) {
        srcUrl = url;
        init();
    }

    /**
     * Called once by constructor
     */
    protected void init() {
        mSrcParsedUrl = new ParsedUrl(srcUrl);
        entryFile = mSrcParsedUrl.getEntryFile();
    }

    /**
     * Called in main thread
     */
    @Override
    public void loadScriptImpl(ScriptInfo info) {
        this.loadType = info.loadType;
        final String hotReloadUrl = info.hotReloadUrl;
        final Globals globals = info.globals;
        final Callback callback = info.callback;
        timeout = info.timeout;

        /// step1: 若开启了debug，先加载debug.lua
        if (MLSEngine.DEBUG)
            PreloadUtils.checkDebug(info.globals);

        /// step2: 检查url，并初始化resourceFinder
        final ParsedUrl newUrl = hotReloadUrl == null ? mSrcParsedUrl : new ParsedUrl(hotReloadUrl);
        globals.clearResourceFinder();
        globals.addResourceFinder(MLSAdapterContainer.getResourceFinderAdapter().newFinder(srcUrl, newUrl));

        /// step3: 环境准备完成
        GlobalStateUtils.onEnvPrepared(srcUrl);

        /// step4: 根据url检查文件
        checkFileByUrl(newUrl, callback);
    }

    /**
     * Called in main thread
     * 根据url检查文件
     *
     * @param url      根据此url检查文件
     * @param callback 查找文件回调
     */
    protected void checkFileByUrl(final ParsedUrl url, final Callback callback) {
        final boolean forceDownload = LoadTypeUtils.has(loadType, Constants.LT_FORCE_DOWNLOAD) && !LoadTypeUtils.has(loadType, Constants.LT_MAIN_THREAD);
        /// 强制下载的情况下，在其他线程中执行
        if (forceDownload) {
            executeTask(url, callback, forceDownload);
            return;
        }

        /// 先检查对应本地文件
        try {
            ScriptBundle ret = check(url);
            if (ret != null) {
                callbackSuccess(callback, ret);
                return;
            }
        } catch (ScriptLoadException e) {
            callbackError(callback, url, e);
            return;
        }

        /// 无本地文件情况下，在其他线程中执行下载加载逻辑
        executeTask(url, callback, forceDownload);
    }

    //<editor-fold desc="Task">

    /**
     * 执行异步读取任务
     */
    protected void executeTask(final ParsedUrl url, final Callback callback, boolean forceDownload) {
        final Runnable task;
        if (url.isNetworkType()) {
            task = newNetworkTask(url, callback, forceDownload);
        } else {
            task = newLocalTask(url, callback, forceDownload);
        }
        if (task == null) {
            callbackError(callback, url, new ScriptLoadException(ERROR.FILE_NOT_FOUND, new FileNotFoundException(url.toString())));
            return;
        }
        innerExecuteTask(task);
    }

    /**
     * 执行异步任务
     */
    protected void innerExecuteTask(@NonNull Runnable task) {
        MLSAdapterContainer.getThreadAdapter().executeTaskByTag(getTaskTag(), task);
    }

    /**
     * 获取网络异步任务
     */
    protected @NonNull
    Runnable newNetworkTask(final ParsedUrl url, final Callback callback, boolean forceDownload) {
        return new NetTask(url, callback, forceDownload);
    }

    /**
     * 获取本地异步任务，可为空
     */
    protected @Nullable
    Runnable newLocalTask(final ParsedUrl url, final Callback callback, boolean forceDownload) {
        if (url.isAssetsPath())
            return new LocalTask(url, callback, forceDownload);
        return null;
    }

    /**
     * 解压assets中的脚本，或复制脚本
     */
    protected class LocalTask extends BaseTask {

        protected LocalTask(ParsedUrl url, Callback callback, boolean forceDownload) {
            super(url, callback, forceDownload);
        }

        @Override
        protected void download() throws ScriptLoadException {
            if (isAssetsSingleLua(url)) {
                return;//assets目录的.lua单文件，拷贝至sd卡
            }
            copyAssetsToSDCard(url.getAssetsPath(), path, name);
        }

        protected void copyAssetsToSDCard(String assetsPath, String targetPath, String name) throws ScriptLoadException {
            InputStream is = null;
            try {
                is = MLSEngine.getContext().getAssets().open(assetsPath);
                checkTimeout();
                copyAssetsInputStreamToSDCard(is, assetsPath, targetPath, name);
            } catch (ScriptLoadException se) {
                throw se;
            } catch (Exception e) {
                throw new ScriptLoadException(ERROR.UNKNOWN_ERROR, e);
            } finally {
                IOUtil.closeQuietly(is);
            }
        }

        protected void copyAssetsInputStreamToSDCard(InputStream is, String assetsPath, String targetPath, String name) throws Exception {
            if (FileUtil.isSuffix(assetsPath, Constants.POSTFIX_LV_ZIP)) {
                FileUtil.unzip(targetPath, is);
            } else {
                String target;
                if (!targetPath.endsWith(File.separator)) {
                    target = targetPath + File.separator + name;
                } else {
                    target = targetPath + name;
                }
                if (!FileUtil.copy(is, target)) {
                    throw new IllegalStateException("copy assets file " + assetsPath + " to target " + target + " failed!");
                }
            }
        }
    }

    /**
     * 下载脚本
     */
    protected class NetTask extends BaseTask {

        protected NetTask(ParsedUrl url, Callback callback, boolean forceDownload) {
            super(url, callback, forceDownload);
        }

        @Override
        protected void download() throws ScriptLoadException {
            MLSAdapterContainer.getHttpAdapter().downloadLuaFileSync(url.getUrlWithoutParams(), path, name, null, null, null, timeout);
        }
    }

    /**
     * 异步查找文件任务
     */
    protected abstract class BaseTask implements Runnable {
        protected final boolean forceDownload;
        protected final ParsedUrl url;
        protected String path;
        protected String name;
        protected final WeakReference<Callback> callbackRef;
        protected long startTime;

        protected BaseTask(ParsedUrl url, Callback callback, boolean forceDownload) {
            startTime = now();
            this.callbackRef = new WeakReference<>(callback);
            this.forceDownload = forceDownload;
            this.url = url;
            initPath();
        }

        @Override
        public void run() {
            if (callbackRef.get() == null || destroyed)
                return;

            if (callbackErrorIfTimeout()) {
                return;
            }
            before();
            if (callbackErrorIfTimeout()) {
                return;
            }

            try {
                download();
                if (callbackErrorIfTimeout()) {
                    return;
                }
                if (callbackRef.get() == null || destroyed)
                    return;
                callbackSuccess(callbackRef.get(), afterDownload());
            } catch (ScriptLoadException e) {
                callbackError(callbackRef.get(), url, e);
            }
            callbackRef.clear();
        }

        protected void initPath() {
            final String[] pn = getPathName(url);
            this.path = pn[0];
            this.name = pn[1];
        }

        protected void before() {
            if (forceDownload) {
                try {
                    FileUtil.delete(path);
                } catch (Throwable t) {
                    LogUtil.e(t);
                }
            }
        }

        /**
         * 执行耗时操作
         */
        protected abstract void download() throws ScriptLoadException;

        /**
         * 查找文件，并回调
         */
        protected ScriptBundle afterDownload() throws ScriptLoadException {
            if (isAssetsSingleLua(url)) {//assets目录.lua单文件。直接读取
                return parseAssetsToBundle(url);
            } else {
                final String file = checkFilePath(path, name);
                if (file == null)
                    throw new ScriptLoadException(ERROR.UNKNOWN_ERROR,
                            new IllegalStateException(String.format("can not find %s from path: %s", name, path)));
                return parseToBundle(url.toString(), file);
            }
        }

        protected boolean callbackErrorIfTimeout() {
            try {
                checkTimeout();
            } catch (ScriptLoadException e) {
                callbackError(callbackRef.get(), url, e);
                return true;
            }
            return false;
        }

        protected void checkTimeout() throws ScriptLoadException {
            if (timeout == 0)
                return;
            long time = now() - startTime;
            if (time > timeout) {
                throw new ScriptLoadException(ERROR.TIMEOUT, null);
            }
        }

        protected long now() {
            return System.currentTimeMillis();
        }
    }
    //</editor-fold>

    //<editor-fold desc="File and bundle">

    /**
     * 通过url获取本地文件，若本地文件存在，返回scriptBundle
     * 若不存在返回空
     */
    protected ScriptBundle check(final ParsedUrl url) throws ScriptLoadException {
        if (isAssetsSingleLua(url)) {//assets单lua文件
            return parseAssetsToBundle(url);
        } else {
            String[] pn = getPathName(url);
            String file = checkFilePath(pn[0], pn[1]);
            if (file == null)
                return null;
            return parseToBundle(url.toString(), file);
        }
    }

    /**
     * 生成{@link ScriptBundle}
     *
     * @param oldUrl    原始url
     * @param localPath 入口主文件的本地路径
     * @throws ScriptLoadException 文件不可读取
     */
    @SuppressLint("WrongConstant")
    protected ScriptBundle parseToBundle(String oldUrl, String localPath) throws ScriptLoadException {
        final File f = new File(localPath);
        ScriptBundle ret = new ScriptBundle(oldUrl, f.getParent());
        ScriptFile main = PreloadUtils.parseMainScript(f);
        ret.setMain(main);
        ret.addFlag(ScriptBundle.TYPE_FILE | ScriptBundle.SINGLE_FILE);
        return ret;
    }

    /**
     * 生成ASSETS文件的{@link ScriptBundle}
     *
     * @throws ScriptLoadException 文件不可读取
     */
    @SuppressLint("WrongConstant")
    protected ScriptBundle parseAssetsToBundle(ParsedUrl parsedUrl) throws ScriptLoadException {
        ScriptBundle ret = new ScriptBundle(parsedUrl.toString(),
                LuaUrlUtils.getParentPath(parsedUrl.getUrlWithoutParams()));
        ScriptFile main = PreloadUtils.parseAssetMainScript(parsedUrl);//asset解析scriptFile
        ret.setMain(main);
        ret.addFlag(ScriptBundle.TYPE_ASSETS | ScriptBundle.SINGLE_FILE);
        return ret;
    }

    /**
     * 检查本地文件是否存在
     * 不存在返回空
     */
    protected String checkFilePath(@NonNull String path, @NonNull String name) {
        if (!LoadTypeUtils.has(loadType, Constants.LT_NO_X64)) {
            X64PathAdapter adapter = MLSAdapterContainer.getX64PathAdapter();
            if (adapter != null)
                path = adapter.checkArm64(path);
        }

        File file = new File(path);
        if (!file.exists())
            return null;
        if (!TextUtils.isEmpty(name)) {
            if (name.endsWith(Constants.POSTFIX_LUA)) {
                file = new File(file, name);
                if (file.exists()) {
                    return file.getAbsolutePath();
                }
            }
            String nameWithDot = name;
            if (!name.contains(".")) {
                nameWithDot = name + ".";
            }
            String[] children = file.list();
            if (children == null || children.length == 0)
                return null;
            for (String n : children) {
                if (n != null && n.startsWith(nameWithDot)) {
                    file = new File(file, n);
                    break;
                }
            }
        }
        if (file.exists() && file.isFile())
            return file.getAbsolutePath();
        return null;
    }

    /**
     * 根据url，获取本地文件路径和文件名称
     *
     * @return {path, name}
     */
    protected @NonNull
    String[] getPathName(ParsedUrl url) {
        String path, name;
        if (url.isAssetsPath()) {
            path = new File(FileUtil.getLuaDir(), ASSETS + File.separator + FileUtil.getUrlPath(url.getUrlWithoutParams())).getAbsolutePath();
        } else if (url.isLocalPath()) {
            final String s = url.getUrlWithoutParams();
            File f = new File(s);
            return new String[] {f.getParent(), f.getName()};
        } else {
            path = new File(FileUtil.getLuaDir(), FileUtil.getUrlPath(url.getUrlWithoutParams())).getAbsolutePath();
        }
        int index = path.lastIndexOf(File.separatorChar);
        if (index >= 0) {
            name = path.substring(index + 1);
            path = path.substring(0, index);
        } else {
            name = path;
        }
        String ef = url.getEntryFile();
        if (!path.endsWith(name) || !nameEquals(ef, name)) {
            int dot = name.indexOf('.');
            if (dot > 0) {
                name = name.substring(0, dot);
            }
            path = path + File.separator + name;
        }
        name = ef;
        return new String[]{path, name};
    }

    /**
     * 不比较后缀，只比较名称是否相同
     */
    private static boolean nameEquals(String a, String b) {
        int index = a.lastIndexOf('.');
        if (index > 0) {
            a = a.substring(0, index);
        }
        index = b.lastIndexOf('.');
        if (index > 0) {
            b = b.substring(0, index);
        }
        return a.equals(b);
    }

    /**
     * 判断是assets目录.lua单文件
     */
    private static boolean isAssetsSingleLua(ParsedUrl url) {
        String assetsPath = url.getUrlWithoutParams();
        return url.isAssetsPath() && !TextUtils.isEmpty(assetsPath) && FileUtil.isSuffix(assetsPath, Constants.POSTFIX_LUA);
    }
    //</editor-fold>

    //<editor-fold desc="callback">

    /**
     * 回调错误信息
     */
    protected void callbackError(final Callback callback, ParsedUrl url, final ScriptLoadException e) {
        errorString = url.isNetworkType() ? "ScriptLoadException:Online" : "ScriptLoadException:Local";
        if (callback != null) {
            callback.onScriptLoadFailed(e);
        }
    }

    /**
     * 回调文件查找成功信息
     */
    protected void callbackSuccess(final Callback callback, ScriptBundle bundle) {
        if (callback != null) {
            callback.onScriptLoadSuccess(bundle);
        }
    }
    //</editor-fold>

    @Override
    public String getScriptVersion() {
        if (errorString == null) {
            return "0";
        }
        return errorString;
    }

    @Override
    public Object getTaskTag() {
        return tag;
    }

    @Override
    public void onDestroy() {
        destroyed = true;
    }
}