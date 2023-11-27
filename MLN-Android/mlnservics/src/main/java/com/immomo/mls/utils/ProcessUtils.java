package com.immomo.mls.utils;

import android.app.ActivityManager;
import android.content.Context;
import android.text.TextUtils;

import java.io.FileInputStream;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class ProcessUtils {
    private static volatile String packageName = null;
    private static volatile String  processName = null;

    private static AtomicBoolean isMainProcess = null;

    /**
     * 判断当前进程是否为主进程，检测异常失败返回false
     * @param context
     * @return
     */
    public static boolean isRunningInMainProcess(Context context, boolean defaultValue) {
        if (isMainProcess != null) {
            return isMainProcess.get();
        }
        if (packageName == null) {
            packageName = context.getPackageName();
        }
        String processName = getCurrentProcessName(context);

        if (TextUtils.isEmpty(processName) || TextUtils.isEmpty(packageName)) {
            return defaultValue; // unknown null fallback defaultValue;
        }

        isMainProcess = new AtomicBoolean(processName.equals(packageName));

        return isMainProcess.get();
    }


    /**
     * 获取当前进程的后缀
     *
     * @return main主进程，否则返回子进程
     */
    public static String getCurrentProcessSuffix(Context context) {
        String processName = getCurrentProcessName(context);
        if (TextUtils.equals(processName, context.getPackageName())) {
            return "main";
        } else if (processName != null && processName.contains(":")) {
            int index = processName.indexOf(":");
            if (index > 0) {
                return processName.substring(processName.indexOf(":") + 1);
            }
        }
        return "";
    }

    public static String getCurrentProcessName(Context context) {
        if (!TextUtils.isEmpty(processName)) {
            return processName;
        }

        int myPid = android.os.Process.myPid();

        if (context == null || myPid <= 0) {
            return "";
        }

        byte[] b = new byte[128];
        FileInputStream in = null;
        try {
            in = new FileInputStream("/proc/" + myPid + "/cmdline");
            int len = in.read(b);
            if (len > 0) {
                for (int i = 0; i < len; i++) { // lots of '0' in tail , remove them
                    if ((((int) b[i]) & 0xFF) > 128 || b[i] <= 0) {
                        len = i;
                        break;
                    }
                }
                processName = new String(b, 0, len);
                return processName;
            }

        } catch (Exception e) {
        } finally {
            try {
                if (in != null) {
                    in.close();
                }
            } catch (Exception e) {
            }
        }

        ActivityManager.RunningAppProcessInfo myProcess = null;
        ActivityManager activityManager =
                (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);

        if (activityManager != null) {
            List<ActivityManager.RunningAppProcessInfo> appProcessList = activityManager
                    .getRunningAppProcesses();

            if (appProcessList != null) {
                try {
                    for (ActivityManager.RunningAppProcessInfo process : appProcessList) {
                        if (process.pid == myPid) {
                            myProcess = process;
                            break;
                        }
                    }
                } catch (Exception e) {
                }

                if (myProcess != null && !TextUtils.isEmpty(myProcess.processName)) {
                    processName = myProcess.processName;
                    return processName;
                }
            }
        }

        return "";
    }

    /**
     * 判断服务是否后台运行
     *
     * @param mContext  Context
     * @param className 判断的服务名字
     * @return true 在运行 false 不在运行
     */
    public static boolean isServiceRun(Context mContext, String className) {
        boolean isRun = false;
        ActivityManager activityManager = (ActivityManager) mContext
                .getSystemService(Context.ACTIVITY_SERVICE);
        if (activityManager == null) {
            return false;
        }
        List<ActivityManager.RunningServiceInfo> serviceList = null;
        try {
            serviceList = activityManager.getRunningServices(1000);
        } catch (Throwable e) {
            e.printStackTrace();
        }
        if (serviceList == null) {
            return false;
        }
        int size = serviceList.size();
        for (int i = 0; i < size; i++) {
            if (serviceList.get(i).service.getClassName().equals(className) && serviceList.get(i).service.getPackageName().equals(AppContext.getPackageName())) {
                isRun = true;
                break;
            }
        }
        return isRun;
    }

}
