package com.immomo.mls.lite.interceptor;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.lite.LuaClient;
import com.immomo.mls.lite.RealInterceptorChain;
import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.util.StopWatch;

public class StopWatchInterceptor implements Interceptor {
    private static final String TAG = "StopWatchInterceptor";

    @Override
    public ScriptResult intercept(Chain chain) throws Exception {
        RealInterceptorChain realInterceptorChain = (RealInterceptorChain) chain;
        realInterceptorChain.transmitter().resourceProcessStart();
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();
        ScriptResult proceed = chain.proceed(chain.request());
        stopWatch.stop();
        MLSAdapterContainer.getConsoleLoggerAdapter().i(LuaClient.TAG, "lua from start to end cast %s", stopWatch.getNanoTime()/1000000.0);
        return proceed;
    }
}
