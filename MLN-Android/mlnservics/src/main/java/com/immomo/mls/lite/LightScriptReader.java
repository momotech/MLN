package com.immomo.mls.lite;

import androidx.annotation.Nullable;

import com.immomo.mls.utils.ParsedUrl;
import com.immomo.mls.utils.ScriptBundleParseUtils;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;

/**
 * 加载容器
 */
public class LightScriptReader {

    @Nullable
    public ScriptBundle loadScript(ParsedUrl parsedUrl,String localFile) {
        try {
            return ScriptBundleParseUtils.getInstance().parseToBundle(parsedUrl.getUrlWithoutParams(), localFile);
        } catch (ScriptLoadException e) {
            return null;
        }
    }

    @Nullable
    public ScriptBundle loadScriptByCache(byte[] data,String entryPath) {
        try {
            return ScriptBundleParseUtils.getInstance().parseCacheToBundle(data,entryPath);
        } catch (ScriptLoadException e) {
            return null;
        }
    }

}
