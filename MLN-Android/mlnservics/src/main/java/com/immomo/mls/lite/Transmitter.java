package com.immomo.mls.lite;

import android.text.TextUtils;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.PreGlobalInitUtils;
import com.immomo.mls.adapter.dependence.DepInfo;
import com.immomo.mls.lite.data.UserdataType;
import com.immomo.mls.lite.interceptor.Interceptor;
import com.immomo.mls.wrapper.AssetsResourceFinder;
import com.immomo.mls.wrapper.CacheResourceFinder;
import com.immomo.mls.wrapper.DepResourceFinder;
import com.immomo.mls.wrapper.ScriptBundle;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.PathResourceFinder;

/**
 * client 和 exchange 的桥接层
 */
public class Transmitter {

    private final LuaClient client;
    private final Call call;
    private final EventListener eventListener;
    private Exchange exchange;

    public Transmitter(LuaClient client, Call call) {
        this.client = client;
        this.call = call;
        this.eventListener = client.eventListenerFactory().create(call);
    }

    public void callStart() {
        eventListener.callStart(call);
    }

    public void callEnd() {
        eventListener.callEnd(call);
    }

    public void scriptLoadFailed(Call call, Exception e) {
        eventListener.scriptLoadFailed(call, e);
    }

    public void callFailed(Call call, Exception e) {
        eventListener.callFailed(call, e);
    }

    public void resourceProcessStart() {
        eventListener.resourceProcessStart(call);
    }

    public void resourceProcessEnd() {
        eventListener.resourceProcessEnd(call);
    }

    Exchange newExchange(Interceptor.Chain chain) {
        Globals globals = newGlobal(chain.request());
        exchange = new Exchange(this, call, globals, eventListener);
        return exchange;
    }

    Globals newGlobal(ScriptBundle request) {
        eventListener.engineInitStart(call);
        Globals globals = null;
        if (client != null && client.userdataType() != UserdataType.ONLY_LIGHT) {
            if (MLSEngine.DEBUG && client.userdataType() == UserdataType.FULL_THEN_LIGHT) {
                //测试模式下优先轻量注册 避免遗漏桥注册
                globals = null;
            } else {
                globals = PreGlobalInitUtils.take();
            }
        }
        if (globals == null) {
            globals = Globals.createLState(MLSEngine.isOpenDebugger());
            if (client == null || client.userdataType() == UserdataType.ONLY_FULL) {
                PreGlobalInitUtils.setupGlobals(globals);//全量注册
            } else {
                PreGlobalInitUtils.realSetupLightGlobals(globals);//轻量级注册
            }
            globals.setRegisterLightUserdata(true);
        }
        globals.setBasePath(request.getBasePath(), false);
        globals.setResourceFinder(new CacheResourceFinder(request));
        globals.addResourceFinder(new AssetsResourceFinder(request.getContext()));
        if (!TextUtils.isEmpty(request.getBasePath())){
            globals.addResourceFinder(new PathResourceFinder(request.getBasePath()));
        }
        DepInfo dependenceInfo = request.getDependenceInfo();
        if (dependenceInfo != null) {
            globals.addResourceFinder(new DepResourceFinder(dependenceInfo));
        }

        eventListener.engineInitEnd(call);
        return globals;
    }

    public void recycle() {
        if (exchange != null) {
            exchange.recycle();
            exchange = null;
        }
    }
}
