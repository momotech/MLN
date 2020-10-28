/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo;

import android.app.Application;
import android.os.Environment;
import android.util.Log;

import com.google.zxing.OuterResultHandler;
import com.immomo.demo.provider.GlideImageProvider;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.lt.SIApplication;
import com.immomo.mls.global.LVConfigBuilder;
import com.immomo.mmui.MMUIEngine;

import org.luaj.vm2.Globals;

/**
 * Created by XiongFangyu on 2018/6/19.
 */
public class App extends Application {
    public String SD_CARD_PATH;
    private static App app;

    @Override
    public void onCreate() {
        super.onCreate();
        app = this;
        init();

        /// -----------配合 Application 使用------------
        SIApplication.isColdBoot = true;
        registerActivityLifecycleCallbacks(new ActivityLifecycleMonitor());
        /// ---------------------END-------------------

        MLSEngine.init(this, true)//BuildConfig.DEBUG)
                .setLVConfig(new LVConfigBuilder(this)
                        .setRootDir(SD_CARD_PATH)
                        .setCacheDir(SD_CARD_PATH + "cache")
                        .setImageDir(SD_CARD_PATH + "image")
                        .setGlobalResourceDir(SD_CARD_PATH + "g_res")
                        .build())
                .setImageProvider(new GlideImageProvider())             //设置图片加载器，若不设置，则不能显示图片
                .setGlobalStateListener(new GlobalStateListener())      //设置全局脚本加载监听，可不设置
                .setQrCaptureAdapter(new MLSQrCaptureImpl())            //设置二维码工具，可不设置
                .setDefaultLazyLoadImage(false)
                ///注册静态Bridge
                .registerSC(
                )
                ///注册Userdata
                .registerUD(
                )
                ///注册单例
                .registerSingleInsance(
                )
                .build(true);
        /// 设置二维码扫描结果处理工具
        OuterResultHandler.registerResultHandler(new QRResultHandler());
        MMUIEngine.init(this);
        MMUIEngine.preInit(1);
        log("onCreate: " + Globals.isInit() + " " + Globals.isIs32bit());
    }

    public static App getApp() {
        return app;
    }

    public static String getPackageNameImpl() {
        String sPackageName = app.getPackageName();
        if (sPackageName.contains(":")) {
            sPackageName = sPackageName.substring(0, sPackageName.lastIndexOf(":"));
        }
        return sPackageName;
    }

    private void init() {
        try {
            SD_CARD_PATH = Environment.getExternalStorageDirectory().getAbsolutePath();
            if (!SD_CARD_PATH.endsWith("/")) {
                SD_CARD_PATH += "/";
            }
            SD_CARD_PATH += "MLN_Android/";
        } catch (Exception e) {
        }
    }

    private static void log(String s) {
        Log.d("app", s);
    }
}