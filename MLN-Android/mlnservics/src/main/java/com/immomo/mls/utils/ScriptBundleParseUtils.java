package com.immomo.mls.utils;

import android.annotation.SuppressLint;

import com.immomo.mls.util.PreloadUtils;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptFile;

import java.io.File;

public class ScriptBundleParseUtils {

    private static volatile ScriptBundleParseUtils instance;
    private File file = null;

    public static ScriptBundleParseUtils getInstance() {
        if (instance == null) {
            synchronized (ScriptBundleParseUtils.class) {
                if (instance == null) {
                    instance = new ScriptBundleParseUtils();
                }
            }
        }
        return instance;
    }

    public File getFile(String path) {
        if (file == null || !file.getPath().equals(path)) {
            file = new File(path);
        }
        return file;
    }

    /**
     * 生成{@link ScriptBundle}
     *
     * @param oldUrl    原始url
     * @param localPath 入口主文件的本地路径
     * @throws ScriptLoadException 文件不可读取
     */
    @SuppressLint("WrongConstant")
    public ScriptBundle parseToBundle(String oldUrl, String localPath) throws ScriptLoadException {
        final File f = new File(localPath);
        ScriptBundle ret = new ScriptBundle(oldUrl, f.getParent());
        ScriptFile main = PreloadUtils.parseMainScript(f);
        ret.setMain(main);
        ret.addFlag(ScriptBundle.TYPE_FILE | ScriptBundle.SINGLE_FILE);
        return ret;
    }

    @SuppressLint("WrongConstant")
    public ScriptBundle parseCacheToBundle(byte[] data, String entryPath) throws ScriptLoadException {
        final File f = new File(entryPath);
        ScriptBundle ret = new ScriptBundle(entryPath, "");
        ScriptFile main = PreloadUtils.parseCacheMainScript(data, f);
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
    public ScriptBundle parseAssetsToBundle(ParsedUrl parsedUrl) throws ScriptLoadException {
        ScriptBundle ret = new ScriptBundle(parsedUrl.toString(),
                LuaUrlUtils.getParentPath(parsedUrl.getUrlWithoutParams()));
        ScriptFile main = PreloadUtils.parseAssetMainScript(parsedUrl);//asset解析scriptFile
        ret.setMain(main);
        ret.addFlag(ScriptBundle.TYPE_ASSETS | ScriptBundle.SINGLE_FILE);
        return ret;
    }
}
