/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.demo;

import android.util.Log;

import com.immomo.mls.utils.DebugLog;
import com.immomo.mls.utils.GlobalStateSDKListener;

import org.luaj.vm2.Globals;

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
            Globals.notifyStatisticsCallback();
        }
    }
}