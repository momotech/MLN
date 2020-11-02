/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.ud;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.exception.InvokeError;

/**
 * Created by Xiong.Fangyu on 2020/9/23
 */
public class RecyclerLuaFunction extends LuaFunction {

    public RecyclerLuaFunction(Globals g, long stackIndex) {
        super(g.getL_State(), stackIndex);
    }

    public void fastInvoke(float x, float y, float z) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeFFF(globals.getL_State(), nativeGlobalKey(), x, y, z);
            afterFunctionInvoked();
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    public void fastInvoke(float a, float b, float c, float d) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeFFFF(globals.getL_State(), nativeGlobalKey(), a, b, c, d);
            afterFunctionInvoked();
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    public void fastInvoke(float a, float b, boolean c) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeFFB(globals.getL_State(), nativeGlobalKey(), a, b, c);
            afterFunctionInvoked();
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    private native void nativeInvokeFFF(long L, long fun, float x, float y, float z);
    private native void nativeInvokeFFFF(long L, long fun, float a, float b, float c, float d);
    private native void nativeInvokeFFB(long L, long fun, float x, float y, boolean z);
}
