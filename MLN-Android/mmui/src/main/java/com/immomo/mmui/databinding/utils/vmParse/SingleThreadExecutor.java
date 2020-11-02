package com.immomo.mmui.databinding.utils.vmParse;

import android.os.Handler;
import android.os.HandlerThread;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.util.LogUtil;
import com.immomo.mmui.PreGlobalInitUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.exception.UndumpError;

/**
 * Created by wang.yang on 2020/8/19.
 */
public class SingleThreadExecutor {

    private static volatile Handler handler;
    /**
     * 与该单线程绑定的虚拟机，创建 {@link #getGlobals()}
     * 注意，调用时需要再Runnable中，即在 {@link #execute(Runnable runnable)}方法中调用
     */
    private static volatile Globals globals;
    private final static String TAG = "HandlerThread@SingleThreadExecutor";

    private static Handler getHandler() {
        if (handler == null) {
            synchronized (SingleThreadExecutor.class) {
                if (handler == null) {
                    HandlerThread thread = new HandlerThread(TAG);
                    thread.start();
                    handler = new Handler(thread.getLooper());
                }
            }
        }
        return handler;
    }

    public static void execute(Runnable runnable) {
        if (runnable == null) {
            throw new IllegalArgumentException("runnable is null");
        }
        getHandler().post(runnable);
    }

    /**
     * 与该单线程绑定的虚拟机
     * 注意，调用时需要再Runnable中，即在 {@link #execute(Runnable runnable)}方法中调用
     */
    public static Globals getGlobals() {
        if (globals == null) {
            synchronized (SingleThreadExecutor.class) {
                if (globals == null) {
                    globals = Globals.createLState(MLSEngine.isOpenDebugger());
                    PreGlobalInitUtils.setupGlobals(globals);
                    preloadScriptsSimple(globals);
                }
            }
        }
        return globals;
    }

    /**
     * 虚拟机预加载的lua文件
     */
    private static final String[] PreloadScriptName = {
            "BindMeta",
    };

    private static void preloadScriptsSimple(Globals g) {
        for (String script : PreloadScriptName) {
            try {
                g.require(PreGlobalInitUtils.SCRIPT_VERSION + script);
            } catch (UndumpError e) {
                if (MLSEngine.DEBUG)
                    LogUtil.e(e, "preload script " + script + " from assets failed!");
            }
        }
    }

    public interface ExecuteCallback {
        void onComplete();
        void onError(RuntimeException e);
    }
}
