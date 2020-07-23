/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.databinding;

import com.immomo.mlncore.MLNCore;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.exception.InvokeError;

/**
 * Created by Xiong.Fangyu on 2020/7/20
 */
class DataBindingCallback extends LuaFunction {

    public DataBindingCallback(long L_state, long stackIndex) {
        super(L_state, stackIndex);
    }

    void fastInvoke(boolean b1, boolean b2) {
        try {
            if (!checkStatus())
                return;
            invokeError = null;
            beforeFunctionInvoke();
            nativeInvokeB(globals.getL_State(), nativeGlobalKey(), b1, b2);
            afterFunctionInvoked();
        } catch (InvokeError e) {
            invokeError = e;
            afterFunctionInvoked();
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return;
            throw e;
        }
    }

    void fastInvoke(double num1, double num2) {
        try {
            if (!checkStatus())
                return;
            invokeError = null;
            beforeFunctionInvoke();
            nativeInvokeN(globals.getL_State(), nativeGlobalKey(), num1, num2);
            afterFunctionInvoked();
        } catch (InvokeError e) {
            invokeError = e;
            afterFunctionInvoked();
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return;
            throw e;
        }
    }

    void fastInvoke(String s1, String s2) {
        try {
            if (!checkStatus())
                return;
            invokeError = null;
            beforeFunctionInvoke();
            nativeInvokeS(globals.getL_State(), nativeGlobalKey(), s1, s2);
            afterFunctionInvoked();
        } catch (InvokeError e) {
            invokeError = e;
            afterFunctionInvoked();
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return;
            throw e;
        }
    }

    void fastInvoke(long table, long table2) {
        try {
            if (!checkStatus())
                return;
            invokeError = null;
            beforeFunctionInvoke();
            nativeInvokeT(globals.getL_State(), nativeGlobalKey(), table, table2);
            afterFunctionInvoked();
        } catch (InvokeError e) {
            invokeError = e;
            afterFunctionInvoked();
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return;
            throw e;
        }
    }

    private native void nativeInvokeB(long L, long function, boolean b1, boolean b2);
    private native void nativeInvokeN(long L, long function, double num1, double num2);
    private native void nativeInvokeS(long L, long function, String s1, String s2);
    private native void nativeInvokeT(long L, long function, long table, long table2);
}