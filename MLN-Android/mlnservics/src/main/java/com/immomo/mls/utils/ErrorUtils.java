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
import com.immomo.mls.log.ErrorType;

import org.luaj.vm2.Globals;

/**
 * 异常使用规范：
 * 1、lua调用不符合规范，造成错误不可控，使用{@link #debugLuaError(String, Globals)}
 * 2、lua调用了不支持的方法，使用{@link #debugUnsupportError(String)}
 * 3、lua调用弃用方法，使用{@link #debugDeprecatedGetter(String, Globals)} {@link #debugDeprecatedMethod(String, Globals)} {@link #debugDeprecatedMethodHook(String, Globals)} {@link #debugDeprecatedSetter(String, Globals)}
 * 4、抛出警告，使用{@link #debugAlert(String, Globals)}
 */
public class ErrorUtils {
    //<editor-fold desc="中断代码">
    public static void unsupportError(String msg) {
        throw new UnsupportedOperationException(msg);
    }

    /**
     * Debugging Error
     * 不支持强提醒
     */
    public static void debugUnsupportError(String msg) {
        if (MLSEngine.DEBUG) {
            unsupportError(msg);
        }
    }

    /**
     * lua调用错误，或不符合规范，造成错误不可控
     */
    public static void debugLuaError(String msg, Globals g) {
        if (MLSEngine.DEBUG) {
            if (g.isInLuaFunction()) {
                throw AlertForDebug.showInDebug(msg);
            }
            Environment.error(AlertForDebug.showInDebug(msg), g);
        } else {
            Environment.callbackError(AlertForDebug.showInDebug(msg), g);
        }
    }

    public static void debugIllegalStateError(String msg) {
        if (MLSEngine.DEBUG) {
            throw new IllegalStateException(msg);
        }
    }
    //</editor-fold>
    //<editor-fold desc="deprecated">
    public static void debugDeprecatedMethod(String s, Globals g) {
        if (MLSEngine.DEBUG) {
            Environment.errorWithType(ErrorType.WARNING, AlertForDebug.showInDebug(s), g);
        } else {
            Environment.callbackError(AlertForDebug.showInDebug(s), g);
        }
    }

    public static void debugDeprecatedSetter(String s, Globals globals) {
        Throwable t = new UnsupportedOperationException("The setter of '" + s + "' method is deprecated!");
        if (MLSEngine.DEBUG) {
            Environment.errorWithType(ErrorType.WARNING, t, globals);
        } else {
            Environment.callbackError(t, globals);
        }
    }

    public static void debugDeprecatedMethodHook(String method, Globals globals) {
        Throwable t = new UnsupportedOperationException("The method '" + method + "' is deprecated!");
        if (MLSEngine.DEBUG) {
            Environment.errorWithType(ErrorType.WARNING, t, globals);
        } else {
            Environment.callbackError(t, globals);
        }
    }

    public static void debugDeprecateMethod(String old, String newMethod, Globals globals) {
        Throwable t = new UnsupportedOperationException("The method '" + old + "' is deprecated, use " + newMethod + " instead!");
        if (MLSEngine.DEBUG) {
            Environment.errorWithType(ErrorType.WARNING, t, globals);
        } else {
            Environment.callbackError(t, globals);
        }
    }

    public static void debugDeprecatedGetter(String s, Globals globals) {
        Throwable t = new UnsupportedOperationException("The getter of '" + s + "' method is deprecated!");
        if (MLSEngine.DEBUG) {
            Environment.errorWithType(ErrorType.WARNING, t, globals);
        } else {
            Environment.callbackError(t, globals);
        }
    }
    //</editor-fold>

    /**
     * 抛出警告
     */
    public static void debugAlert(String msg, Globals g) {
        if (MLSEngine.DEBUG) {
            Environment.errorWithType(ErrorType.WARNING, AlertForDebug.showInDebug("DEBUG⚠️: " + msg), g);
        }
    }
}