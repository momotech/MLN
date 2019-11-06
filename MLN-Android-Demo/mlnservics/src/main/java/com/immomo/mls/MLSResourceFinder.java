package com.immomo.mls;

import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.IOUtil;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.LuaUrlUtils;
import com.immomo.mls.utils.ParsedUrl;

import org.luaj.vm2.utils.ResourceFinder;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

/**
 * Created by XiongFangyu on 2018/8/6.
 */
public class MLSResourceFinder implements ResourceFinder {
    protected String path;
    protected String assetsPath;
    protected String src;
    protected ParsedUrl parsedUrl;

    public MLSResourceFinder(String src, ParsedUrl url) {
        this.src = src;
        this.parsedUrl = url;
        path = LuaUrlUtils.getUrlPath(url.toString());
        if (!path.endsWith(File.separator)) {
            path += File.separator;
        }
        if (url.isAssetsPath()) {
            assetsPath = url.getAssetsPath();
            int index = assetsPath.lastIndexOf(File.separator);
            if (index >= 0) {
                String n = assetsPath.substring(index + 1);
                if (n.indexOf('.') > 0) {
                    assetsPath = assetsPath.substring(0, index + 1);
                }
            }
        }
    }

    protected byte[] getAssetsData(String name) {
        InputStream is = null;
        try {
            is = openAssetsByName(name);
            if (is != null) {
                byte[] data = new byte[is.available()];
                if (is.read(data) == data.length)
                    return data;
            }
        } catch (Throwable t) {
            if (MLSEngine.DEBUG)
                LogUtil.e(t);
        } finally {
            IOUtil.closeQuietly(is);
        }
        return null;
    }

    private InputStream openAssetsByName(String name) {
        if (assetsPath != null) {
            return openAssets(FileUtil.dealRelativePath(assetsPath, name));
        }
        return null;
    }

    private static InputStream openAssets(String filename) {
        try {
            return MLSEngine.getContext().getAssets().open(filename);
        } catch (IOException e) {
            if (MLSEngine.DEBUG)
                LogUtil.e(e);
        }
        return null;
    }

    @Override
    public String preCompress(String name) {
        if (name.endsWith(".lua"))
            name = name.substring(0, name.length() - 4);
        if (!name.contains(".."))
            return name.replaceAll("\\.", File.separator) + ".lua";
        return name + ".lua";
    }

    @Override
    public String findPath(String name) {
        name = path + name;
        File f = new File(name);
        if (f.exists()) {
            return name;
        }
        return null;
    }

    @Override
    public byte[] getContent(String name) {
        return getAssetsData(name);
    }

    @Override
    public void afterContentUse(String name) {

    }
}
