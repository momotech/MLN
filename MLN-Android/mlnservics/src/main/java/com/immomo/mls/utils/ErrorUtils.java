/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import com.immomo.mls.Environment;
import com.immomo.mls.MLSEngine;

import org.luaj.vm2.Globals;

public class ErrorUtils {

    public static void unsupportError(String msg) {
        throw new UnsupportedOperationException(msg);
    }

    /**
     * Debuging Error
     * 开发期，代码规范检查
     */
    public static void debugUnsupportError(String msg) {
        if (MLSEngine.DEBUG) {
            unsupportError(msg);
        }
    }

    public static void debugDeprecatedMethod(String s) {
        if (MLSEngine.DEBUG) {
            unsupportError("The method '" + s + "' is deprecated!");
        }
    }

    public static void debugIllegalStateError(String msg) {
        if (MLSEngine.DEBUG) {
            throw new IllegalStateException(msg);
        }
    }

    //<editor-fold desc="不中断后续代码">
    public static void debugDeprecatedSetter(String s, Globals globals) {
        if (MLSEngine.DEBUG) {
            Environment.error(new UnsupportedOperationException("The setter of '" + s + "' method is deprecated!"), globals);
        }
    }

    public static void debugDeprecatedMethodHook(String method, Globals globals) {
        if (MLSEngine.DEBUG) {
            Environment.hook(new UnsupportedOperationException("The method '" + method + "' is deprecated!"), globals);
        }
    }

    public static void debugDeprecatedGetter(String s, Globals globals) {
        if (MLSEngine.DEBUG) {
            Environment.error(new UnsupportedOperationException("The getter of '" + s + "' method is deprecated!"), globals);
        }
    }

    /**
     * 抛出强提醒，不抛出异常，不影响之后的代码逻辑
     */
    public static void debugLuaError(String msg, Globals g) {
        if (MLSEngine.DEBUG) {
            Environment.error(AlertForDebug.showInDebug(msg), g);
        }
    }
    //</editor-fold>

    /**
     * 开发阶段报错
     */
    public static void debugEnvironmentError(String msg, Globals globals) {
        if (MLSEngine.DEBUG) {
            IllegalStateException e = new IllegalStateException(msg);
            if (!Environment.hook(e, globals)) {
                throw e;
            }
        }
    }
}