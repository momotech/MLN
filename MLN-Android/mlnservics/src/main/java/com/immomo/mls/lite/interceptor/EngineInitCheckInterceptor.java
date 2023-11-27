package com.immomo.mls.lite.interceptor;

import android.view.View;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.adapter.MLSEmptyViewAdapter;
import com.immomo.mls.global.LuaViewConfig;
import com.immomo.mls.lite.RealInterceptorChain;
import com.immomo.mls.lite.data.ScriptResult;

import org.luaj.vm2.Globals;

public class EngineInitCheckInterceptor implements Interceptor {
    @Override
    public ScriptResult intercept(Chain chain) throws Exception {
        if (isInit()) {
            return chain.proceed(chain.request());
        } else {
            RealInterceptorChain realInterceptorChain = (RealInterceptorChain) chain;
            realInterceptorChain.transmitter()
                    .callFailed(chain.call(), new Exception("MLN引擎初始化失败"));
            MLSEmptyViewAdapter.EmptyView emptyView = MLSAdapterContainer.getEmptyViewAdapter()
                    .createEmptyView(chain.request().getContext());
            emptyView.setTitle("加载失败");
            emptyView.setMessage("");
            return new ScriptResult.Builder()
                    .request(chain.request())
                    .luaRootView((View) emptyView)
                    .build();
        }
    }

    private boolean isInit() {
        if (!Globals.isInit() || !LuaViewConfig.isInit()
                || MLSEngine.singleRegister == null || !MLSEngine.singleRegister.isInit())
            return false;
        MLSEngine.singleRegister.preInstall();
        return MLSEngine.singleRegister.isPreInstall();
    }
}
