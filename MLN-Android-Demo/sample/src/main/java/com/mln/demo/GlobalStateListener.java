package com.mln.demo;

import android.util.Log;

import com.immomo.mls.utils.DebugLog;
import com.immomo.mls.utils.GlobalStateSDKListener;

import java.io.PrintStream;

/**
 * Created by XiongFangyu on 2018/8/8.
 */

public class GlobalStateListener extends GlobalStateSDKListener {
    private static final String TAG = "GlobalStateListener";

    protected DebugLog newLog() {
        return new D();
    }

    protected static class D extends DebugLog {
        protected void log(String s, PrintStream ps) {
            super.log(s, ps);
            Log.d(TAG,s);
        }
    }
}
