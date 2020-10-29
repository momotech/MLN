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
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.exception.InvokeError;
import org.luaj.vm2.utils.CGenerate;

/**
 * Created by Xiong.Fangyu on 2020/9/25
 */
public class AdapterLuaFunction extends LuaFunction {

    public AdapterLuaFunction(Globals g, long stackIndex) {
        super(g.getL_State(), stackIndex);
    }

    public String fastInvoke_S(int a, int b) {
        try {
            if (!checkStatus())
                return null;
            String ret = SninvokeII(globals.getL_State(), nativeGlobalKey(), a, b);
            afterFunctionInvoked();
            return ret;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
        return null;
    }

    public boolean fastInvoke_Z() {
        try {
            if (!checkStatus())
                return false;
            boolean b = Zninvoke(globals.getL_State(), nativeGlobalKey());
            afterFunctionInvoked();
            return b;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
        return false;
    }

    public void fastInvoke(LuaValue t, int a, int b) {
        long key = 0;
        if (t != null) {
            if (!t.isTable() && !t.isNil())
                throw new IllegalArgumentException("必须传入LuaTable或Nil，当前类型:" + t);
            key = t.nativeGlobalKey();
        }
        try {
            if (!checkStatus())
                return;
            ninvokeJII(globals.getL_State(), nativeGlobalKey(), key, a, b);
            afterFunctionInvoked();
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    public int fastInvoke_I() {
        try {
            if (!checkStatus())
                return 0;
            int r = Ininvoke(globals.getL_State(), nativeGlobalKey());
            afterFunctionInvoked();
            return r;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
        return 0;
    }

    public int fastInvokeI_I(int a) {
        try {
            if (!checkStatus())
                return 0;
            int r = IninvokeI(globals.getL_State(), nativeGlobalKey(), a);
            afterFunctionInvoked();
            return r;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
        return 0;
    }

    public int fastInvokeII_I(int a, int b) {
        try {
            if (!checkStatus())
                return 0;
            int r = IninvokeII(globals.getL_State(), nativeGlobalKey(), a, b);
            afterFunctionInvoked();
            return r;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
        return 0;
    }

    public LuaUserdata<?> fastInvokeII_U(int a, int b) {
        try {
            if (!checkStatus())
                return null;
            LuaUserdata<?> r = UninvokeII(globals.getL_State(), nativeGlobalKey(), a, b);
            afterFunctionInvoked();
            return r;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
        return null;
    }

    private static native String SninvokeII(long g, long f, int s, int r);
    private static native boolean Zninvoke(long g, long f);
    @CGenerate(params = "00T")
    private static native void ninvokeJII(long g, long f, long t, int a, int b);
    private static native int Ininvoke(long g, long f);
    private static native int IninvokeI(long g, long f, int a);
    private static native int IninvokeII(long g, long f, int a, int b);
    private static native LuaUserdata UninvokeII(long g, long f, int a, int b);
}
