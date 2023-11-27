package com.immomo.mls.lite.interceptor;


import android.view.View;

import com.immomo.mls.MLSAdapterContainer;
import com.immomo.mls.adapter.MLSEmptyViewAdapter;
import com.immomo.mls.lite.RealInterceptorChain;
import com.immomo.mls.lite.data.ScriptResult;


public class ExceptionInterceptor implements Interceptor {
    private static final String TAG = "ExceptionInterceptor";

    @Override
    public ScriptResult intercept(Chain chain) throws Exception {
        try {
            return chain.proceed(chain.request());
        } catch (Exception e) {
            RealInterceptorChain realInterceptorChain = (RealInterceptorChain) chain;
            realInterceptorChain.transmitter().callFailed(chain.call(), e);
            MLSEmptyViewAdapter.EmptyView emptyView = MLSAdapterContainer.getEmptyViewAdapter()
                    .createEmptyView(chain.request().getContext());
            emptyView.setTitle("加载异常");
            return new ScriptResult.Builder()
                    .request(chain.request())
                    .luaRootView((View) emptyView)
                    .build();
        }
    }
}
