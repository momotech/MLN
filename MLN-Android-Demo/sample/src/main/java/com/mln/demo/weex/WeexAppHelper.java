package com.mln.demo.weex;


import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.alibaba.android.bindingx.plugin.weex.BindingX;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.mln.demo.App;
import com.mln.demo.BuildConfig;
import com.mln.demo.weex.adapter.InterceptWXHttpAdapter;
import com.mln.demo.weex.bridge.WXFile;
import com.mln.demo.weex.commons.adapter.DefaultWebSocketAdapterFactory;
import com.mln.demo.weex.commons.adapter.ImageAdapter;
import com.mln.demo.weex.commons.adapter.JSExceptionAdapter;
import com.mln.demo.weex.commons.adapter.PicassoBasedDrawableLoader;
import com.taobao.weex.InitConfig;
import com.taobao.weex.WXEnvironment;
import com.taobao.weex.WXSDKEngine;
import com.taobao.weex.WXSDKManager;
import com.taobao.weex.bridge.WXBridgeManager;
import com.taobao.weex.common.WXException;
import com.taobao.weex.performance.WXAnalyzerDataTransfer;

import java.lang.reflect.Method;

import androidx.multidex.MultiDex;


/**
 * Created by zhang.ke
 * on 2019-11-12
 */
public class WeexAppHelper {


    public void onCreate(App app) {
        MultiDex.install(app);
        /**
         * Set up for fresco usage.
         * Set<RequestListener> requestListeners = new HashSet<>();
         * requestListeners.add(new RequestLoggingListener());
         * ImagePipelineConfig config = ImagePipelineConfig.newBuilder(this)
         *     .setRequestListeners(requestListeners)
         *     .build();
         * Fresco.initialize(this,config);
         **/
//    initDebugEnvironment(true, false, "DEBUG_SERVER_HOST");
        WXBridgeManager.updateGlobalConfig("wson_on");
        WXEnvironment.setOpenDebugLog(true);
        WXEnvironment.setApkDebugable(true);
        WXSDKEngine.addCustomOptions("appName", "WXSample");
        WXSDKEngine.addCustomOptions("appGroup", "WXApp");
        InitConfig.Builder builder = new InitConfig.Builder()
                //.setImgAdapter(new FrescoImageAdapter())// use fresco adapter
                .setImgAdapter(new ImageAdapter())
                //.setImgAdapter(new GlideImageAdapter())   // setSupportActionBar 不能混用
                .setDrawableLoader(new PicassoBasedDrawableLoader(app.getApplicationContext()))
                .setWebSocketAdapterFactory(new DefaultWebSocketAdapterFactory())
                .setJSExceptionAdapter(new JSExceptionAdapter())
                .setHttpAdapter(new InterceptWXHttpAdapter());
        //.setApmGenerater(new ApmGenerator());

        if (!TextUtils.isEmpty(BuildConfig.externalLibraryName)) {
            builder.addNativeLibrary(BuildConfig.externalLibraryName);
        }
        WXSDKEngine.initialize(app, builder.build());
        WXAnalyzerDataTransfer.isOpenPerformance = false;

        try {
            Fresco.initialize(app);

            BindingX.register();

            /**
             * override default image tag
             * WXSDKEngine.registerComponent("image", FrescoImageComponent.class);
             */
            WXSDKEngine.registerModule("dataModel", WXFile.class);

            //Typeface nativeFont = Typeface.createFromAsset(getAssets(), "font/native_font.ttf");
            //WXEnvironment.setGlobalFontFamily("bolezhusun", nativeFont);

            startHeron(app);

        } catch (WXException e) {
            e.printStackTrace();
        }

        app.registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(Activity activity, Bundle bundle) {

            }

            @Override
            public void onActivityStarted(Activity activity) {

            }

            @Override
            public void onActivityResumed(Activity activity) {

            }

            @Override
            public void onActivityPaused(Activity activity) {

            }

            @Override
            public void onActivityStopped(Activity activity) {

            }

            @Override
            public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {

            }

            @Override
            public void onActivityDestroyed(Activity activity) {
                // The demo code of calling 'notifyTrimMemory()'
                if (false) {
                    // We assume that the application is on an idle time.
                    WXSDKManager.getInstance().notifyTrimMemory();
                }
                // The demo code of calling 'notifySerializeCodeCache()'
                if (false) {
                    WXSDKManager.getInstance().notifySerializeCodeCache();
                }
            }
        });
    }

    private void initDebugEnvironment(boolean connectable, boolean debuggable, String host) {
        if (!"DEBUG_SERVER_HOST".equals(host)) {
            WXEnvironment.sDebugServerConnectable = connectable;
            WXEnvironment.sRemoteDebugMode = debuggable;
            WXEnvironment.sRemoteDebugProxyUrl = "ws://" + host + ":8088/debugProxy/native";
        }
    }

    private void startHeron(App app) {
        try {
            Class<?> heronInitClass = app.getClassLoader().loadClass("com/taobao/weex/heron/picasso/RenderPicassoInit");
            Method method = heronInitClass.getMethod("initApplication", Application.class);
            method.setAccessible(true);
            method.invoke(null, this);
            Log.e("Weex", "Weex Heron Render Init Success");
        } catch (Exception e) {
            Log.e("Weex", "Weex Heron Render Mode Not Found", e);
        }
    }

    public void onDestroy() {
    }

}
