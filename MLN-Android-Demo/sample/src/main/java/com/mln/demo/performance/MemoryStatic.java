package com.mln.demo.performance;

import com.immomo.mls.MLSAdapterContainer;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2018/12/17
 * Time         :   上午11:31
 * Description  :
 */
public class MemoryStatic {
    private static final String TAG_ = MemoryStatic.class.getSimpleName();

    public static void logMemoryStats(String info) {


        StringBuilder text = new StringBuilder();

       /* text.append( "\nLoadedClassCount=" + toMib(android.os.Debug.getLoadedClassCount())) ;
        text.append( "\nGlobalAllocSize=" + toMib(android.os.Debug.getGlobalAllocSize()));
        text.append( "\nGlobalFreedSize=" + toMib(android.os.Debug.getGlobalFreedSize()));
        text.append( "\nGlobalExternalAllocSize=" + toMib(android.os.Debug.getGlobalExternalAllocSize()));
        text.append( "\nGlobalExternalFreedSize=" + toMib(android.os.Debug.getGlobalExternalFreedSize()));
        text.append( "\nNativeHeapSize=" + toMib(android.os.Debug.getNativeHeapSize()));
        text.append( "\nNativeHeapFree=" + toMib(android.os.Debug.getNativeHeapFreeSize()));
        text.append( "\nNativeHeapAllocSize=" + toMib(android.os.Debug.getNativeHeapAllocatedSize()));
        text.append( "\nThreadAllocSize=" + toMib(android.os.Debug.getThreadAllocSize()));

        text.append( "\nmaxMemory()=" + toMib(Runtime.getRuntime().maxMemory()));
        text.append( "\nfreeMemory()=" + toMib(Runtime.getRuntime().freeMemory()));

        android.app.ActivityManager.MemoryInfo mi1 = new android.app.ActivityManager.MemoryInfo();
        ActivityManager am = (ActivityManager) MLSEngine.getContext().getSystemService(Context.ACTIVITY_SERVICE);
        am.getMemoryInfo(mi1);
        text.append( "\napp.mi.availMem=" + toMib(mi1.availMem));
        text.append( "\napp.mi.threshold=" + toMib(mi1.threshold));
        text.append ("\napp.mi.lowMemory=" + mi1.lowMemory);

        android.os.Debug.MemoryInfo mi2 = new android.os.Debug.MemoryInfo();
        Debug.getMemoryInfo(mi2);

        text.append( "\ndbg.mi.dalvikPrivateDirty=" + toMib(mi2.dalvikPrivateDirty));
        text.append( "\ndbg.mi.dalvikPss=" + toMib(mi2.dalvikPss));
        text.append( "\ndbg.mi.dalvikSharedDirty=" + toMib(mi2.dalvikSharedDirty));
        text.append( "\ndbg.mi.nativePrivateDirty=" + toMib(mi2.nativePrivateDirty));
        text.append( "\ndbg.mi.nativePss=" + toMib(mi2.nativePss));
        text.append( "\ndbg.mi.nativeSharedDirty=" + toMib(mi2.nativeSharedDirty));
        text.append( "\ndbg.mi.otherPrivateDirty=" + toMib(mi2.otherPrivateDirty));
        text.append( "\ndbg.mi.otherPss" + toMib(mi2.otherPss));
        text.append( "\ndbg.mi.otherSharedDirty=" + toMib(mi2.otherSharedDirty));

        text.append( "\n \n \n \n \n \n"); */

        text.append("\n " + info + " totalMemory()=" + toMib(Runtime.getRuntime().totalMemory()));

        MLSAdapterContainer.getConsoleLoggerAdapter().d(TAG_, text.toString());

    }

    private static long toMib(long value) {
        // return value / 1024 / 1024;
        return value;

    }


}
