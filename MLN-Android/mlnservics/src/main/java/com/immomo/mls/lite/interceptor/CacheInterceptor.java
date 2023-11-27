package com.immomo.mls.lite.interceptor;

import com.immomo.mls.lite.LightScriptReader;
import com.immomo.mls.lite.RealInterceptorChain;
import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.wrapper.ScriptBundle;

public class CacheInterceptor implements Interceptor {
    @Override
    public ScriptResult intercept(Chain chain) throws Exception {
        ScriptBundle bundle;

        RealInterceptorChain realChain = (RealInterceptorChain) chain;
        ScriptBundle request = realChain.request();
        LightScriptReader reader = new LightScriptReader();
        realChain.transmitter().resourceProcessStart();

        if (request.hasChildren()) {
            bundle = reader.loadScriptByCache(request.getMain().getSourceData(), request.getParsedUrl().getUrlWithoutParams());//内存缓存
        } else {
            bundle = reader.loadScript(request.getParsedUrl(), request.getLocalFile());//磁盘文件
        }
        request.setMain(bundle.getMain());
        request.setBasePath(bundle.getBasePath());

        realChain.transmitter().resourceProcessEnd();

        return realChain.proceed(request);
    }
}
