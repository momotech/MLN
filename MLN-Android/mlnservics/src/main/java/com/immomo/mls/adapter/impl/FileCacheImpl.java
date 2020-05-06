package com.immomo.mls.adapter.impl;

import android.text.TextUtils;

import com.immomo.mls.adapter.IFileCache;
import com.immomo.mls.util.FileUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;

/**
 * Created by Xiong.Fangyu on 2020-01-16
 */
public class FileCacheImpl implements IFileCache {

    private File cacheFile;
    private JSONObject memCache;

    @Override
    public void save(String key, String value) {
        initCacheFile();
        try {
            if (!TextUtils.equals(memCache.optString(key, null), value)) {
                memCache.put(key, value);
                FileUtil.fastSave(cacheFile, memCache.toString().getBytes());
            }
        } catch (JSONException ignore) {
        }
    }

    @Override
    public String get(String key, String defaultValue) {
        initCacheFile();
        return memCache.optString(key, defaultValue);
    }

    private void initCacheFile() {
        if (cacheFile == null) {
            File dir = FileUtil.getCacheDir();
            cacheFile = new File(dir, "lua-kv-cache");
            if (!cacheFile.exists()) {
                try {
                    cacheFile.createNewFile();
                } catch (IOException ignore) {
                }
            } else {
                byte[] data = FileUtil.fastReadBytes(cacheFile);
                if (data != null && data.length > 0) {
                    try {
                        memCache = new JSONObject(new String(data));
                    } catch (JSONException ignore) {
                    }
                }
            }
        }
        if (memCache == null) {
            memCache = new JSONObject();
        }
    }
}
