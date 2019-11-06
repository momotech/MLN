package com.mln.demo;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import com.immomo.mls.fun.lt.SIApplication;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019/1/10
 * Time         :   下午4:59
 * Description  :
 */
public class ActivityLifecycleMonitor  implements Application.ActivityLifecycleCallbacks {

    private int mCount = 0;


    @Override
    public void onActivityCreated(Activity activity, Bundle bundle) {
        method();
    }

    @Override
    public void onActivityStarted(Activity activity) {
        mCount++;
        if (mCount == 1) {
            SIApplication.setIsForeground(true);
        }

    }

    @Override
    public void onActivityResumed(Activity activity) {
        method();
    }

    @Override
    public void onActivityPaused(Activity activity) {
        method();
    }

    @Override
    public void onActivityStopped(Activity activity) {

        mCount--;
        if (mCount == 0) {
            SIApplication.setIsForeground(false);
        }

    }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {

    }

    @Override
    public void onActivityDestroyed(Activity activity) {

    }

    private void method(){
        System.out.print("aa");
    }

}
