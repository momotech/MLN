/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.ud.anim;

import com.immomo.mlncore.MLNCore;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.exception.InvokeError;

/**
 * Created by Xiong.Fangyu on 2020/7/24
 */
class InteractiveBehaviorCallback extends LuaFunction {
    /**
     * Called by native method.
     * see luajapi.c
     */
    protected InteractiveBehaviorCallback(long L_state, long stackIndex) {
        super(L_state, stackIndex);
    }

    public void callback(int type, float distance, float velocity) {
        try {
            if (!checkStatus())
                return;
            beforeFunctionInvoke();
            nativeCallback(globals.getL_State(), nativeGlobalKey(), type, distance, velocity);
            afterFunctionInvoked();
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    private native void nativeCallback(long L, long fun, int type, float dis, float v);
}
