package com.immomo.mls.lite.interceptor;

import android.view.View;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.lite.Exchange;
import com.immomo.mls.lite.LuaClient;
import com.immomo.mls.lite.RealInterceptorChain;
import com.immomo.mls.lite.data.LuaClientRecyclerViewPool;
import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.util.StopWatch;
import com.immomo.mls.wrapper.ScriptBundle;

public class ExecuteLuaInterceptor implements Interceptor {
    @Override
    public ScriptResult intercept(Chain chain) throws Exception {

        RealInterceptorChain realChain = (RealInterceptorChain) chain;
        Exchange exchange = realChain.exchange();
        ScriptBundle request = realChain.request();
        View luaView = exchange.createLuaView();
        luaView.setTag(LuaClientRecyclerViewPool.VIEW_TAG);
        ScriptResult response = exchange.loadScriptBundle(request)
                .luaRootView(luaView)
                .build();
        exchange.bridgingInvalidateFunc(response);
        return response;
    }
}
