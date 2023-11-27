package com.immomo.mls.lite;

import com.immomo.mls.fun.globals.LuaView;
import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.lite.interceptor.DefaultUserDataInjectInterceptor;
import com.immomo.mls.lite.interceptor.ExecuteLuaInterceptor;
import com.immomo.mls.lite.interceptor.Interceptor;
import com.immomo.mls.wrapper.ScriptBundle;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

/**
 * 真实的一次加载lua视图请求
 */
public final class RealCall implements Call {
    final LuaClient client;
    final ScriptBundle originalRequest;
    private Transmitter transmitter;
    private WeakReference<LuaView> window;

    public RealCall(LuaClient client, ScriptBundle originalRequest) {
        this.client = client;
        this.originalRequest = originalRequest;
    }

    public static RealCall newRealCall(LuaClient client, ScriptBundle originalRequest) {
        RealCall realCall = new RealCall(client, originalRequest);
        realCall.transmitter = new Transmitter(client, realCall);
        return realCall;
    }

    /**
     * @return originalRequest 在执行完recycle() 会被回收
     */
    @Override
    public ScriptBundle request() {
        return originalRequest;
    }

    @Override
    public WeakReference<LuaView> window() {
        return window;
    }

    @Override
    public ScriptResult execute() {
        transmitter.callStart();
        client.dispatcher().executed(this);
        ScriptResult response = getResultWithInterceptorChain();
        if (response != null && response.luaRootView() instanceof LuaView) {
            window = new WeakReference<LuaView>((LuaView) response.luaRootView());
            LuaViewAttachListener listener = new LuaViewAttachListener();
            client.lifecycleOwner.getLifecycle().addObserver(listener);
            window().get().addOnAttachStateChangeListener(listener);
        }
        transmitter.callEnd();
        return response;
    }

    @Override
    public void recycle() {
        transmitter.recycle();
        originalRequest.clear();//避免内存泄露
    }

    ScriptResult getResultWithInterceptorChain() {
        // Build a full stack of interceptors.
        List<Interceptor> interceptors = new ArrayList<>();
        interceptors.add(client.errorViewInterceptor());
        interceptors.addAll(client.errorCatchInterceptors());
        interceptors.addAll(client.preProcessorInterceptors());
        interceptors.addAll(client.resourceProcessorInterceptors());
        interceptors.addAll(client.middlewareInterceptors());
        interceptors.add(new ConnectInterceptor());//创建exchange
        interceptors.add(new DefaultUserDataInjectInterceptor());
        interceptors.addAll(client.customUserdataInjectInterceptors());
        interceptors.add(new ExecuteLuaInterceptor());
        Interceptor.Chain chain = new RealInterceptorChain(interceptors, 0, transmitter, null,
                originalRequest, this);
        try {
            return chain.proceed(originalRequest);
        } catch (Exception e) {
            return new ScriptResult.Builder().request(originalRequest).build();
        }
    }
}
