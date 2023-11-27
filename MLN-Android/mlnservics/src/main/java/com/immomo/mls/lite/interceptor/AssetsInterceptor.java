package com.immomo.mls.lite.interceptor;

import com.immomo.mls.lite.RealInterceptorChain;
import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.utils.ParsedUrl;
import com.immomo.mls.utils.ScriptBundleParseUtils;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;

import java.io.FileNotFoundException;

public class AssetsInterceptor implements Interceptor {
    public int anInt;

    @Override
    public ScriptResult intercept(Chain chain) throws Exception {
        if (chain.request().isForceLoadAssetResource()) {
            RealInterceptorChain realChain = (RealInterceptorChain) chain;
            ScriptBundle request = realChain.request();
            ScriptBundle newRequest = request.newBuilder()
                    .parsedUrl(new ParsedUrl(request.getUrl()))
                    .build();
            ScriptBundle bundle = ScriptBundleParseUtils.getInstance().parseAssetsToBundle(newRequest.getParsedUrl());
            newRequest.setMain(bundle.getMain());
            newRequest.setBasePath(bundle.getBasePath());
            return chain.proceed(newRequest);
        } else
            return chain.proceed(chain.request());
    }
}
