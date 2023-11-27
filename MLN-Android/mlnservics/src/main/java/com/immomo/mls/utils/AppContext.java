package com.immomo.mls.utils;

import android.app.ActivityManager;
import android.content.ContentResolver;
import android.content.Context;
import android.os.Looper;
import android.text.TextUtils;

import java.io.FileInputStream;
import java.util.List;
import java.util.Locale;

/**
 * Created by wangduanqing on 2017/4/7.
 */

public class AppContext {
    public static Context sContext;
    public static boolean DEBUGGABLE;
    public static boolean sExecutorSwitch = false;

    public static void init(Context context) {
        sContext = context;
    }

    private static String sPackageName = null;
    private static ContentResolver sContentResolver = null;

    public static Context getContext() {
        return sContext;
    }

    public static void openDebug() {
        DEBUGGABLE = true;
    }

    public static void switchExecutorType(boolean openNewExecutor) {
        sExecutorSwitch = openNewExecutor;
    }

    private static String currentProcessName;

    public static String getCurrentProcessName() {
        if (sContext == null) {
            return null;
        }
        if (!TextUtils.isEmpty(currentProcessName)) {
            return currentProcessName;
        }
        int myPid = android.os.Process.myPid();
        if (myPid <= 0) {
            return "";
        }

        ActivityManager.RunningAppProcessInfo myProcess = null;
        ActivityManager activityManager = (ActivityManager) getContext().getSystemService(Context.ACTIVITY_SERVICE);

        try {
            for (ActivityManager.RunningAppProcessInfo process : activityManager.getRunningAppProcesses()) {
                if (process.pid == myPid) {
                    myProcess = process;
                    break;
                }
            }
        } catch (Exception e) {
        }

        if (myProcess != null) {
            return myProcess.processName;
        }

        byte[] b = new byte[128];
        FileInputStream in = null;
        try {
            in = new FileInputStream("/proc/" + myPid + "/cmdline");
            int len = in.read(b);
            if (len > 0) {
                for (int i = 0; i < len; i++) {
                    if (b[i] > 128 || b[i] <= 0) {
                        len = i;
                        break;
                    }
                }
                return new String(b, 0, len);
            }

        } catch (Exception e) {
        } finally {
            IOUtils.closeQuietly(in);
        }

        return "";
    }

    /**
     * 应用是否在前台  此方法已经在oppoR5手机上测试，耗时6ms左右
     *
     * @return
     */
    public static boolean isAppOnForeground() {
        if (null == sContext) {
            return false;
        }
        try {
            //https://fabric.io/momo6/android/apps/com.immomo.momo/issues/570a17f6ffcdc0425095363d  LETV X500在getRunningAppProcesses方法内部会抛出空指针异常！
            ActivityManager activityManager = (ActivityManager) sContext.getSystemService(Context.ACTIVITY_SERVICE);
            List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
            if (appProcesses == null) {
                return false;
            }
            int myPid = android.os.Process.myPid();
            for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
                if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND && appProcess.pid == myPid) {
                    return true;
                }
            }
        } catch (Exception e) {
        }
        return false;
    }

    public static boolean isRunningInMainProcess() {
        String processName = getCurrentProcessName();
        if (!TextUtils.isEmpty(processName) && processName.equals(sContext.getPackageName())) {
            return true;
        }
        return false;
    }

    public static boolean isRunningInMainThread() {
        Looper myLooper = Looper.myLooper();
        Looper mainLooper = Looper.getMainLooper();
        return myLooper == mainLooper;
    }

    public static String getPackageName() {
        if (sContext == null) {
            return null;
        }
        if (sPackageName == null) {
            sPackageName = sContext.getPackageName();
            if (sPackageName.indexOf(":") >= 0) {
                sPackageName = sPackageName.substring(0, sPackageName.lastIndexOf(":"));
            }
        }

        return sPackageName;
    }

    public static ContentResolver getContentResolver() {
        if (sContentResolver == null) {
            sContentResolver = getContext().getContentResolver();
        }
        return sContentResolver;
    }

    /**
     * 获取当前系统的国家代号字符串 *
     */
    public static String getSystemCountry() {
        return Locale.getDefault().getCountry();
    }

    /**
     * 获取当前系统的语言代号字符串 *
     */
    public static String getSystemLanguage() {
        return Locale.getDefault().getLanguage();
    }
}
