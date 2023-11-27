/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.adapter.impl;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.adapter.MLSHttpAdapter;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.IOUtil;
import com.immomo.mls.utils.ERROR;
import com.immomo.mls.utils.ScriptLoadException;

import java.io.File;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/6/27.
 */
public class DefaultHttpAdapter implements MLSHttpAdapter {
    private static final String POSTFIX_LV_ZIP = ".zip";

    /**
     * 下载lua相关文件，若是压缩包需要解压
     *
     * @param url  下载地址
     * @param path 文件路径
     * @param name 文件名，可为空
     * @throws ScriptLoadException
     */
    @Override
    public void downloadLuaFileSync(@NonNull String url, @NonNull String path, @Nullable String name,
                                    @Nullable Map<String, String> header,
                                    @Nullable Map<String, String> params,
                                    @Nullable String sessionType,
                                    long timeout) throws ScriptLoadException {
        try {
            InputStream is = getInputStream(url, timeout);
            if (FileUtil.isSuffix(url, POSTFIX_LV_ZIP)) {
                FileUtil.unzip(path, is);
            } else {
                saveFile(path, name, is);
            }
        } catch (Exception e) {
            if (e instanceof ScriptLoadException)
                throw (ScriptLoadException) e;
            throw new ScriptLoadException(ERROR.UNKNOWN_ERROR, e);
        }
    }

    protected static InputStream getInputStream(String url, long timeout) throws Exception {
        final URL uri = new URL(url);
        HttpURLConnection connection = (HttpURLConnection) uri.openConnection();
        if (timeout != 0) {
            connection.setConnectTimeout((int) timeout);
            connection.setReadTimeout((int) timeout);
        }
        connection.connect();

        int code = connection.getResponseCode();
        if (code == HttpURLConnection.HTTP_OK) {
            return connection.getInputStream();
        }
        throw new ScriptLoadException(code, "resopnse code is not 200", new IllegalStateException());
    }

    private static void saveFile(@NonNull String path, @Nullable String name, InputStream is) throws Exception {
        File file = null;
        if (TextUtils.isEmpty(name)) {
            file = new File(path);
        } else {
            file = new File(path, name);
        }
        File parent = file.getParentFile();
        if (!parent.exists()) {
            parent.mkdirs();
        }
        try {
            FileUtil.writeFile(file, is);
        } finally {
            IOUtil.closeQuietly(is);
        }
    }

}