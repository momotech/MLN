package com.immomo.mmui.databinding;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.exception.InvokeError;

/**
 * Created by Xiong.Fangyu on 2020/11/17
 */
class DataBindingCallback extends LuaFunction {

    DataBindingCallback(long L_state, long stackIndex) {
        super(L_state, stackIndex);
    }

    public boolean fastInvoke_B(int a, int b) {
        try {
            if (!checkStatus())
                return false;
            boolean ret = BnativeInvokeII(globals.getL_State(), nativeGlobalKey(), a, b);
            afterFunctionInvoked();
            return ret;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
        return false;
    }

    private native boolean BnativeInvokeII(long L, long fun, int a, int b);
}
