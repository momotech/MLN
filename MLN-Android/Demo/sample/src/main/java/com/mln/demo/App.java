package com.mln.demo;

import android.app.Application;
import android.os.Environment;
import android.util.Log;

import com.google.zxing.OuterResultHandler;
import com.immomo.mls.MLSBuilder;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.lt.SIApplication;
import com.immomo.mls.global.LVConfigBuilder;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.wrapper.Register;
import com.mln.demo.anr.AnrWatchDog;
import com.mln.demo.common.GCTest;
import com.mln.demo.common.GlobalRefTest;
import com.mln.demo.common.LazyChild;
import com.mln.demo.common.LazyChild2;
import com.mln.demo.common.LazyParent;
import com.mln.demo.common.LazyRoot;
import com.mln.demo.common.MLSLoadViewAdapterImpl;
import com.mln.demo.common.NonlazyChild;
import com.mln.demo.common.demo.SBDemo;
import com.mln.demo.common.demo.SimpleSBDemo;
import com.mln.demo.common.TestLazyHttp;
import com.mln.demo.common.demo.UDDemo;
import com.mln.demo.common.demo.SimpleUDDemo;
import com.mln.demo.common.UDTest2;
import com.mln.demo.provider.GlideImageProvider;

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
        AnrWatchDog.startWatch();
        app = this;
        init();
        final boolean debug = true;
        log("scale Density: " + AndroidUtil.getScaleDensity(this));
        log("Density: " + AndroidUtil.getDensity(this));

        SIApplication.isColdBoot = true;

        registerActivityLifecycleCallbacks(new ActivityLifecycleMonitor());
        GlobalEventManager.getInstance().init(this);
        File cache = getCacheDir();
        File soFile = new File(cache.getParent(), "lib");
//        MLSEngine.setOpenDebugInfo(true);
        MLSEngine.init(this, debug)
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
                .setGlobalEventAdapter(new MLSGlobalEventImpl())
                .setImageProvider(new GlideImageProvider())
                .setGlobalStateListener(new GlobalStateListener())
                .setQrCaptureAdapter(new MLSQrCaptureImpl())
                .setLoadViewAdapter(new MLSLoadViewAdapterImpl())
                .setUseStandardSyntax(false)
                .setLazyFillCellData(false)
                .setReadScriptFileInJava(false)
                .setOpenSAES(true)
                .setGcOffset(0)
                .setMemoryMonitorOffset(5000)
                .setGlobalSoPath(soFile.getAbsolutePath() + "/lib?.so")
                .registerSC(
                        Register.newSHolder(SBDemo.LUA_CLASS_NAME, SBDemo.class, SBDemo.methods),
                        Register.newSHolderWithLuaClass(SimpleSBDemo.LUA_CLASS_NAME, SimpleSBDemo.class),
                        Register.newSHolderWithLuaClass("GRTest", GlobalRefTest.class)
                )
                .registerUD(
                        Register.newUDHolderWithLuaClass("SimpleUDDemo", SimpleUDDemo.class, true),
                        Register.newUDHolderWithLuaClass("UDTest2", UDTest2.class, true),
                        Register.newUDHolderWithLuaClass("LazyRoot", LazyRoot.class, true),
                        Register.newUDHolderWithLuaClass("LazyParent", LazyParent.class, true),
                        Register.newUDHolderWithLuaClass("LazyChild", LazyChild.class, true),
                        Register.newUDHolderWithLuaClass("NonlazyChild", NonlazyChild.class, false),
                        Register.newUDHolderWithLuaClass("LazyChild2", LazyChild2.class, true),
//                        Register.newUDHolderWithLuaClass(TestHttpExtends.LUA_CLASS_NAME, TestHttpExtends.class, false),
                        Register.newUDHolderWithLuaClass("LHttp", TestLazyHttp.class, true),
                        Register.newUDHolderWithLuaClass("GCTest", GCTest.class, true),
                        Register.newUDHolder("UDIndex", UDDemo.class, false)
                )
                .registerSingleInsance(new MLSBuilder.SIHolder(SINavigatorExtend.LUA_CLASS_NAME, SINavigatorExtend.class))
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
            SD_CARD_PATH += "LUAVIEW/";
        } catch (Exception e) {
        }
    }

    private static void log(String s) {
        Log.d("app", s);
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        MLSEngine.onTrimMemory(level);
    }
}
