package com.mln.demo;

import android.app.Application;
import android.util.Log;

import com.mln.demo.mln.MLNAppHelper;
import com.mln.demo.weex.WeexAppHelper;

/**
 * Created by XiongFangyu on 2018/6/19.
 */
public class App extends Application {
    private static App app;
    private MLNAppHelper mlnAppHelper;
    private WeexAppHelper weexAppHelper;

    @Override
    public void onCreate() {
        super.onCreate();
        app = this;
        if ("weex".equals(BuildConfig.sdkType)) {
            initWeex();
        } else if ("mln".equals(BuildConfig.sdkType)) {
            initMLN();
        }
    }

    public static App getApp() {
        return app;
    }

    public void initWeex() {
        if (weexAppHelper == null) {
            long start = System.currentTimeMillis();
            weexAppHelper = new WeexAppHelper();
            weexAppHelper.onCreate(app);
            Log.d("App", "onCreate: init time = " + (System.currentTimeMillis() - start));
        }
    }

    public void initMLN() {
        if (mlnAppHelper == null) {
            long start = System.currentTimeMillis();
            mlnAppHelper = new MLNAppHelper();
            mlnAppHelper.onCreate(app);
            Log.d("App", "onCreate: init time = " + (System.currentTimeMillis() - start));
        }
    }

    public static String getPackageNameImpl() {
        String sPackageName = app.getPackageName();
        if (sPackageName.contains(":")) {
            sPackageName = sPackageName.substring(0, sPackageName.lastIndexOf(":"));
        }
        return sPackageName;
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        if (mlnAppHelper != null) {
            mlnAppHelper.onTrimMemory(level);
        }
    }
}
