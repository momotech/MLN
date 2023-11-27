package com.immomo.mls.lite.interceptor;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSBuilder;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.lite.Exchange;
import com.immomo.mls.lite.RealInterceptorChain;
import com.immomo.mls.lite.data.DefaultUserData;
import com.immomo.mls.lite.data.ScriptResult;
import com.immomo.mls.wrapper.Register;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.Translator;

/**
 * 向global中注入默认桥接
 */
public class DefaultUserDataInjectInterceptor implements Interceptor {
    public static Register register = new Register();
    public static Translator singleTranslator = new Translator();

    /**
     * 首次类加载时 执行静态方法 耗时10ms左右
     */
    static {
        for (Register.UDHolder h : DefaultUserData.registerLuaView) {
            register.registerUserdata(h);
        }
        for (Register.UDHolder h : DefaultUserData.registerTools) {
            register.registerUserdata(h);
        }
        for (Register.NewUDHolder h : DefaultUserData.registerNewUD) {
            register.registerNewUserdata(h);
        }

        for (Register.SHolder h : DefaultUserData.registerStaticClass) {
            register.registerStaticBridge(h);
        }
        for (Class c : DefaultUserData.registerConstants) {
            register.registerEnum(c);
        }
        for (MLSBuilder.SIHolder h : DefaultUserData.registerSingleInstance) {
            register.registerSingleInstance(h.luaClassName, h.clz);
        }

        for (MLSBuilder.CHolder h : DefaultUserData.registerCovert) {
            if (h.defaultL2J) {
                singleTranslator.registerL2JAuto(h.clz);
            } else if (h.l2j != null) {
                singleTranslator.registerL2J(h.clz, h.l2j);
            }
            if (h.defaultJ2L) {
                singleTranslator.registerJ2LAuto(h.clz);
            } else if (h.j2l != null) {
                singleTranslator.registerJ2L(h.clz, h.j2l);
            }
        }
    }

    @Override
    public ScriptResult intercept(Chain chain) throws Exception {
        ScriptBundle request = chain.request();
        //引擎初始成功的情况下 都会使用全局的convert
        LuaViewManager luaViewManager =
                new LuaViewManager(request.getContext(), MLSEngine.singleTranslator == null ? singleTranslator : MLSEngine.singleTranslator);
        luaViewManager.url = request.getUrl();
        RealInterceptorChain realChain = (RealInterceptorChain) chain;
        Exchange exchange = realChain.exchange();
        exchange.bridgeRegisterStart(chain.call());
        exchange.getGlobals().setJavaUserdata(luaViewManager);
        if (exchange.getGlobals().isRegisterLightUserdata()) {
            register.createSingleInstance(exchange.getGlobals());//createSingleInstance之前需要setJavaUserdata
        } else {
            MLSEngine.singleRegister.createSingleInstance(exchange.getGlobals());
        }
        exchange.bridgeRegisterEnd(chain.call());
        return chain.proceed(request);
    }
}
