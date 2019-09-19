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
import com.immomo.mls.BuildConfig;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.lt.SIApplication;
import com.immomo.mls.global.LVConfigBuilder;
import com.immomo.mls.util.AndroidUtil;

import org.luaj.vm2.Globals;

import java.io.File;

/**
 * Created by XiongFangyu on 2018/6/19.
 */
@SuppressWarnings("ALL")
public class App extends Application {
    public String SD_CARD_PATH;
    private static App app;

    @Override
    public void onCreate() {
        super.onCreate();
        app = this;
        init();
        log("scale Density: " + AndroidUtil.getScaleDensity(this));
        log("Density: " + AndroidUtil.getDensity(this));
        File soFile = new File(getDataDir(), "lib");

        SIApplication.isColdBoot = true;

//        MLSEngine.setOpenDebugInfo(true);
        MLSEngine.init(this, BuildConfig.DEBUG)
                .setLVConfig(new LVConfigBuilder(this)
                        .setRootDir(SD_CARD_PATH)
                        .setCacheDir(SD_CARD_PATH + "cache")
                        .setImageDir(SD_CARD_PATH + "image")
                        .setGlobalResourceDir(SD_CARD_PATH + "g_res")
                        .build())
                .setUncatchExceptionListener(new com.immomo.mls.Environment.UncatchExceptionListener() {
                    @Override
                    public boolean onUncatch(Globals globals, Throwable e) {
                        e.printStackTrace();
                        return true;
                    }
                })
//                .setHttpAdapter(new HttpAdapterImpl())
                .setImageProvider(new GlideImageProvider())
                .setGlobalStateListener(new GlobalStateListener())
                .setQrCaptureAdapter(new MLSQrCaptureImpl())
                .setLoadViewAdapter(new MLSLoadViewAdapterImpl())
                .setUseStandardSyntax(false)
                .setLazyFillCellData(false)
                .setReadScriptFileInJava(false)
                .setOpenSAES(true)
                .setPreGlobals(0)
                .setGcOffset(0)
                .setMemoryMonitorOffset(5000)
                .setGlobalSoPath(soFile.getAbsolutePath() + "/lib?.so")
                .registerSC(
                )
                .registerUD(
                )
                .registerSingleInsance(
                )
//                .clearAll()
                .build(true);
        MLSEngine.setDebugIp("172.16.39.13");
        OuterResultHandler.registerResultHandler(new QRResultHandler());
        Log.d("App", "onCreate: " + Globals.isInit() + " " + Globals.isIs32bit());
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