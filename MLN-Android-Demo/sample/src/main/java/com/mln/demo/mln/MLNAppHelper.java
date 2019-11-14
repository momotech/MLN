package com.mln.demo.mln;

import android.os.Environment;
import android.util.Log;

import com.google.zxing.OuterResultHandler;
import com.immomo.mls.MLSBuilder;
import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.lt.SIApplication;
import com.immomo.mls.global.LVConfigBuilder;
import com.immomo.mls.util.AndroidUtil;
import com.immomo.mls.wrapper.Register;
import com.mln.demo.App;
import com.mln.demo.BuildConfig;
import com.mln.demo.mln.anr.AnrWatchDog;
import com.mln.demo.mln.common.LTFileExtends;
import com.mln.demo.mln.common.MLSLoadViewAdapterImpl;
import com.mln.demo.mln.provider.GlideImageProvider;

import org.luaj.vm2.Globals;

import java.io.File;

import static com.immomo.mls.util.FileUtil.getCacheDir;

/**
 * Created by zhang.ke
 * on 2019-11-12
 */
public class MLNAppHelper {
    public String SD_CARD_PATH;


    public void onCreate(App app) {

        AnrWatchDog.startWatch();
        init();

        final boolean debug = BuildConfig.DEBUG;

        log("scale Density: " + AndroidUtil.getScaleDensity(app));
        log("Density: " + AndroidUtil.getDensity(app));

        SIApplication.isColdBoot = true;

        app.registerActivityLifecycleCallbacks(new ActivityLifecycleMonitor());
        GlobalEventManager.getInstance().init(app);
        File cache = app.getCacheDir();
        File soFile = new File(cache.getParent(), "lib");
//        MLSEngine.setOpenDebugInfo(true);
        MLSEngine.init(app, debug)
                .setLVConfig(new LVConfigBuilder(app)
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
                .setPreGlobals(1)
                .setOpenSAES(true)
                .setGcOffset(0)
                .setMemoryMonitorOffset(5000)
                .setGlobalSoPath(soFile.getAbsolutePath() + "/lib?.so")
                .registerSC(
                        Register.newSHolderWithLuaClass(LTFileExtends.LUA_CLASS_NAME, LTFileExtends.class)
                )
                .registerUD(
                )
                .registerSingleInsance()
//                .clearAll()
                .build(true);
        MLSEngine.setDebugIp("172.16.39.13");
        OuterResultHandler.registerResultHandler(new QRResultHandler());
        Log.d("App", "onCreate: " + Globals.isInit() + " " + Globals.isIs32bit());
    }

    public void onDestroy(){
    }


    private void init() {
        try {
            SD_CARD_PATH = Environment.getExternalStorageDirectory().getAbsolutePath();
            if (!SD_CARD_PATH.endsWith("/")) {
                SD_CARD_PATH += "/";
            }
            SD_CARD_PATH += "LUAVIEW_meilishuo/";
        } catch (Exception e) {
        }
    }

    private static void log(String s) {
        Log.d("app", s);
    }

    public void onTrimMemory(int level) {
        MLSEngine.onTrimMemory(level);
    }
}
