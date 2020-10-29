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
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.exception.InvokeError;
import org.luaj.vm2.utils.CGenerate;

/**
 * Created by wang.yang on 2020/10/16
 */
public class TouchLuaFunction extends LuaFunction {

    public TouchLuaFunction(Globals g, long stackIndex) {
        super(g.getL_State(), stackIndex);
    }

    public void fastInvoke(float a, float b, float c, float d, LuaUserdata<?> e, long f) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeFFFFUL(globals.getL_State(), nativeGlobalKey(), a, b, c, d, e.nativeGlobalKey(), f);
            afterFunctionInvoked();
        } catch (InvokeError err) {
            functionInvokeError(err);
        }
    }

    public void fastInvoke(float a, float b, float c, float d, float e, float f) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeFFFFFF(globals.getL_State(), nativeGlobalKey(), a, b, c, d, e, f);
            afterFunctionInvoked();
        } catch (InvokeError err) {
            functionInvokeError(err);
        }
    }

    @CGenerate(params = "000000U")
    private native void nativeInvokeFFFFUL(long L, long fun, float a, float b, float c, float d, long e, long f);
    private native void nativeInvokeFFFFFF(long L, long fun, float a, float b, float c, float d, float e, float f);
}
