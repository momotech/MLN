package com.immomo.mls.lite;

import androidx.annotation.Nullable;

import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.lite.interceptor.Interceptor;
import com.immomo.mls.wrapper.ScriptBundle;

import java.util.List;

public class RealInterceptorChain implements Interceptor.Chain {

    private final List<Interceptor> interceptors;
    private final int index;
    private final ScriptBundle request;
    private final Call call;
    private final Transmitter transmitter;
    private final Exchange exchange;

    public RealInterceptorChain(List<Interceptor> interceptors, int index, Transmitter transmitter, Exchange exchange, ScriptBundle request, Call call) {
        this.interceptors = interceptors;
        this.index = index;
        this.transmitter = transmitter;
        this.exchange = exchange;
        this.request = request;
        this.call = call;
    }

    @Override
    public ScriptBundle request() {
        return request;
    }

    @Override
    public Call call() {
        return call;
    }

    public Transmitter transmitter() {
        return transmitter;
    }

    public Exchange exchange() {
        if (exchange == null) throw new IllegalStateException();
        return exchange;
    }

    @Override public ScriptResult proceed(ScriptBundle request) throws Exception {
        return proceed(request, transmitter, exchange);
    }

    public ScriptResult proceed(ScriptBundle request, Transmitter transmitter, @Nullable Exchange exchange) throws Exception {
        if (index >= interceptors.size()) throw new AssertionError();
        // Call the next interceptor in the chain.
        RealInterceptorChain next = new RealInterceptorChain(interceptors,
                index + 1, transmitter, exchange, request, call);
        Interceptor interceptor = interceptors.get(index);
        ScriptResult response = interceptor.intercept(next);

        // Confirm that the intercepted response isn't null.
        if (response == null) {
            throw new NullPointerException("interceptor " + interceptor + " returned null");
        }

        if (response.luaRootView() == null) {
            throw new IllegalStateException(
                    "interceptor " + interceptor + " returned a LuaScriptResult with no RootView");
        }
        return response;
    }

}
