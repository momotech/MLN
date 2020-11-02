/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.global;

import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.immomo.mls.fun.globals.UDLuaView;
import com.immomo.mls.util.CompileUtils;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.GlobalStateUtils;
import com.immomo.mls.utils.ScriptLoadException;
import com.immomo.mls.wrapper.ScriptBundle;
import com.immomo.mls.wrapper.ScriptFile;

import org.luaj.vm2.Globals;

/**
 * Created by Xiong.Fangyu on 2018/11/13
 */
public class ScriptLoader {
    private static final String TAG = "ScriptLoader";

    private ScriptLoader() {
    }

    private static boolean isInMainThread() {
        return Looper.getMainLooper() == Looper.myLooper();
    }

    public static void loadScriptBundle(@NonNull final ScriptBundle scriptBundle,
                                        @NonNull final Globals globals,
                                        @Nullable final Callback callback) {
        AssertUtils.assertNullForce(scriptBundle);
        AssertUtils.assertNullForce(globals);
        final ScriptFile scriptFile = scriptBundle.getMain();
        AssertUtils.assertNullForce(scriptFile);
        try {
            CompileUtils.compile(scriptBundle, globals);
        } catch (ScriptLoadException e) {
            callbackExecuted(callback, Callback.COMPILE_FAILED, e.getMsg());
            return;
        }
        GlobalStateUtils.onScriptCompiled(scriptBundle.getUrl());
        execute(scriptBundle, globals, callback);
    }

    private static void execute(@NonNull ScriptBundle scriptBundle,
                                @NonNull Globals globals,
                                @Nullable Callback callback) {
        if (globals.isDestroyed())
            return;
        GlobalStateUtils.onScriptPrepared(scriptBundle.getUrl());
        if (globals.callLoadedData()) {
            callbackExecuted(callback, Callback.SUCCESS, null);
        } else {
            String em = globals.getErrorMsg();
            callbackExecuted(callback, Callback.EXE_FAILED, em);
        }
    }

    private static void callbackExecuted(@Nullable Callback callback, int code, final String msg) {
        if (callback != null) {
            callback.onScriptExecuted(code, msg);
        }
    }

    public static interface Callback {
        int SUCCESS = 0;
        int COMPILE_FAILED = 1;
        int EXE_FAILED = 2;

        /**
         * 脚本执行完成，参数表示是否执行成功，保证一定被调用到
         */
        void onScriptExecuted(int code, @Nullable String msg);
    }
}