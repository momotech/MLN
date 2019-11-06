package com.immomo.mls.adapter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.utils.ScriptLoadException;

import java.util.Map;

/**
 * Created by XiongFangyu on 2018/6/26.
 */
public interface MLSHttpAdapter {
    /**
     * 下载lua相关文件，若是压缩包需要解压
     *
     * @param url  下载地址
     * @param path 文件路径
     * @param name 文件名，可为空
     * @throws ScriptLoadException
     */
    void downloadLuaFileSync(@NonNull String url, @NonNull String path, @Nullable String name,
                             @Nullable Map<String, String> header,
                             @Nullable Map<String, String> params,
                             @Nullable String sessionType,
                             long timeout) throws ScriptLoadException;
}
