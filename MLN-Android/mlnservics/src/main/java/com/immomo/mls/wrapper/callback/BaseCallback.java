/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.wrapper.callback;

import com.immomo.mls.base.exceptions.CalledFromWrongThreadException;
import com.immomo.mls.wrapper.GlobalsContainer;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-12-04
 */
public class BaseCallback implements Destroyable, ICheckDestroy, GlobalsContainer {

    protected LuaFunction function;
    protected Thread myThread;

    public BaseCallback(LuaFunction function) {
        this.function = function;
        myThread = Thread.currentThread();
    }

    protected LuaValue[] invoke(Object... params) {
        checkThread();
        Utils.check(function);
        return Utils.invoke(function, params);
    }

    @Override
    public void destroy() {
        if (function != null)
            function.destroy();
        function = null;
    }

    @Override
    public boolean isDestroy() {
        checkThread();
        return function == null || function.isDestroyed();
    }

    @Override
    public Globals getGlobals() {
        return function != null ? function.getGlobals() : null;
    }

    protected void checkThread() {
        if (myThread != Thread.currentThread())
            throw new CalledFromWrongThreadException(
                    "Only the original thread that created lua stack can touch its stack.");
    }
}
