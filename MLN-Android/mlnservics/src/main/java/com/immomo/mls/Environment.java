/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls;

import com.immomo.mls.log.ErrorPrintStream;
import com.immomo.mls.log.ErrorType;
import com.immomo.mls.util.LogUtil;

import org.luaj.vm2.Globals;
import org.luaj.vm2.exception.InvokeError;

import java.io.PrintStream;

/**
 * Created by Xiong.Fangyu on 2019/3/25
 */
public class Environment {
    public static boolean DEBUG = false;
    public static final String LUA_ERROR = "[LUA_ERROR] ";

    public static UncatchExceptionListener uncatchExceptionListener = new UncatchExceptionListener() {
        @Override
        public boolean onUncatch(boolean fatal, Globals globals, Throwable e) {
            e.printStackTrace();
            return true;
        }
    };
    public static boolean hook(Throwable t, Globals globals) {
        if (globals.getState() == Globals.LUA_CALLING)
            return false;
        if (t instanceof InvokeError) {
            InvokeError te = (InvokeError) t;
            if (te.getType() != 0)
                return true;
        }
        if (DEBUG) {
            error(t, globals);
        }
        if (uncatchExceptionListener != null) {
            return uncatchExceptionListener.onUncatch(true, globals, t);
        }
        return false;
    }

    public static void error(Throwable t, Globals globals) {
        String error = getErrorMsg(t);
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        if (m != null && m.STDOUT != null) {
            PrintStream ps = m.STDOUT;
            if (ps instanceof ErrorPrintStream) {
                ((ErrorPrintStream) ps).error(LUA_ERROR + error);
            } else {
                ps.print(LUA_ERROR + error);
                ps.println();
            }
            m.showPrinterIfNot();
        } else {
            LogUtil.e(t);
        }
    }

    public static void errorWithType(ErrorType errorType, Throwable throwable, Globals globals) {
        String errorMsg = throwable != null ? throwable.getMessage() : "";

        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        if (m != null && m.STDOUT != null) {
            PrintStream ps = m.STDOUT;
            if (ps instanceof ErrorPrintStream) {
                ((ErrorPrintStream) ps).error(errorType.getErrorPrefix() + errorMsg, errorType);
            } else {
                ps.print(errorType.getErrorPrefix() + errorMsg);
                ps.println();
            }
            m.showPrinterIfNot();
        }
    }

    public static boolean callbackError(Throwable t, Globals g) {
        if (uncatchExceptionListener != null) {
            return uncatchExceptionListener.onUncatch(false, g, t);
        }
        return false;
    }

    public static interface UncatchExceptionListener {
        /**
         * called when some throwable is not caught in lua sdk
         *
         * @param e
         * @return true to handle uncatch throwable, false otherwise.
         */
        boolean onUncatch(boolean fatal, Globals globals, Throwable e);
    }

    private static String getErrorMsg(Throwable t) {
        Throwable temp = t != null ? t.getCause() : null;
        if (temp != null) {
            t = temp;
        }
        return t != null ? t.getMessage() : "";
    }
}