package com.immomo.mls.lite;

import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.lite.interceptor.Interceptor;
import com.immomo.mls.wrapper.ScriptBundle;

public class ConnectInterceptor implements Interceptor {
    @Override
    public ScriptResult intercept(Chain chain) throws Exception {
        RealInterceptorChain realChain = (RealInterceptorChain) chain;
        ScriptBundle request = realChain.request();
        Transmitter transmitter = realChain.transmitter();
        Exchange exchange = transmitter.newExchange(chain);
        return realChain.proceed(request, transmitter, exchange);
    }
}
