/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import com.immomo.mlncore.MLNCore;

import org.luaj.vm2.exception.InvokeError;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2019/2/22
 * <p>
 * Lua函数封装类
 * 可使用{@link #invoke(LuaValue[])} {@link #invoke(LuaValue[], int)}调用
 * <p>
 * 通过注册静态Bridge代替
 *
 * @see Globals#registerStaticBridgeSimple
 */
@LuaApiUsed
public class LuaFunction extends NLuaValue {
    // Lua返回可变参数个数
    private static final int LUA_MULTRET = -1;
    /**
     * 执行函数错误信息
     */
    protected InvokeError invokeError;

    /**
     * Called by native method.
     * see luajapi.c
     */
    @LuaApiUsed
    protected LuaFunction(long L_state, long stackIndex) {
        super(L_state, stackIndex);
    }

    @Override
    public final int type() {
        return LUA_TFUNCTION;
    }

    @Override
    public final LuaFunction toLuaFunction() {
        return this;
    }

    /**
     * 调用lua方法，且已知方法返回个数
     *
     * @param params      方法传入的参数，可为空
     * @param returnCount 方法返回参数个数
     * @return 返回参数，若returnCount为0，返回空
     */
    public final LuaValue[] invoke(LuaValue[] params, int returnCount) throws InvokeError {
        try {
            if (!checkStatus())
                return empty();
            invokeError = null;
            globals.calledFunction ++;
            LuaValue[] ret = LuaCApi._invoke(globals.L_State, nativeGlobalKey, params, returnCount);
            globals.calledFunction --;
            return ret;
        } catch (InvokeError e) {
            invokeError = e;
            globals.calledFunction --;
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return empty();
            throw e;
        }
    }

    /**
     * 调用lua方法，方法返回参数个数未知
     *
     * @param params 方法传入的参数，可为空
     * @return 返回参数，可为空
     */
    public final LuaValue[] invoke(LuaValue[] params) throws InvokeError {
        return invoke(params, LUA_MULTRET);
    }

    //<editor-fold desc="fast invoke">

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaTable)
     */
    public final void fastInvoke() {
        try {
            if (!checkStatus())
                return;
            invokeError = null;
            globals.calledFunction ++;
            nativeInvokeV(globals.L_State, nativeGlobalKey);
            globals.calledFunction --;
        } catch (InvokeError e) {
            invokeError = e;
            globals.calledFunction --;
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return;
            throw e;
        }
    }

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaTable)
     */
    public final void fastInvoke(boolean b) {
        try {
            if (!checkStatus())
                return;
            invokeError = null;
            globals.calledFunction ++;
            nativeInvokeB(globals.L_State, nativeGlobalKey, b);
            globals.calledFunction --;
        } catch (InvokeError e) {
            invokeError = e;
            globals.calledFunction --;
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return;
            throw e;
        }
    }

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaTable)
     */
    public final void fastInvoke(double number) {
        try {
            if (!checkStatus())
                return;
            invokeError = null;
            globals.calledFunction ++;
            nativeInvokeN(globals.L_State, nativeGlobalKey, number);
            globals.calledFunction --;
        } catch (InvokeError e) {
            invokeError = e;
            globals.calledFunction --;
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return;
            throw e;
        }
    }

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaTable)
     */
    public final void fastInvoke(String s) {
        try {
            if (!checkStatus())
                return;
            invokeError = null;
            globals.calledFunction ++;
            nativeInvokeS(globals.L_State, nativeGlobalKey, s);
            globals.calledFunction --;
        } catch (InvokeError e) {
            invokeError = e;
            globals.calledFunction --;
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return;
            throw e;
        }
    }

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaTable)
     */
    public final void fastInvoke(LuaTable t) {
        try {
            if (!checkStatus())
                return;
            invokeError = null;
            globals.calledFunction ++;
            nativeInvokeT(globals.L_State, nativeGlobalKey, t.nativeGlobalKey);
            globals.calledFunction --;
        } catch (InvokeError e) {
            invokeError = e;
            globals.calledFunction --;
            if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
                return;
            throw e;
        }
    }

    protected native void nativeInvokeV(long L, long function);
    protected native void nativeInvokeB(long L, long function, boolean b);
    protected native void nativeInvokeN(long L, long function, double number);
    protected native void nativeInvokeS(long L, long function, String s);
    protected native void nativeInvokeT(long L, long function, long table);
    //</editor-fold>

    /**
     * 检查function的状态，若在debug状态中，或在加载主脚本的状态，则抛出异常
     * @return true: 可正常执行
     */
    protected boolean checkStatus() {
        if (globals.isDestroyed()) {
            invokeError = new InvokeError("globals is destroyed.", 2);
            if (MLNCore.DEBUG || globals.getState() == Globals.LUA_CALLING)
                throw invokeError;
            return false;
        }
        if (!checkStateByNative()) {
            invokeError = new InvokeError("function is destroyed.", 1);
            if (MLNCore.DEBUG || globals.getState() == Globals.LUA_CALLING)
                throw invokeError;
            return false;
        }
        globals.checkMainThread();
        return true;
    }

    @Override
    public final boolean isDestroyed() {
        return globals.isDestroyed() || !checkStateByNative();
    }

    public final InvokeError getInvokeError() {
        return invokeError;
    }

    protected final void beforeFunctionInvoke() {
        globals.calledFunction ++;
    }

    protected final void afterFunctionInvoked() {
        globals.calledFunction --;
    }

    public String getSource() {
        if (isDestroyed())
            return null;
        return LuaCApi._getFunctionSource(globals.L_State, nativeGlobalKey);
    }

    @Override
    public String toString() {
        if (MLNCore.DEBUG) {
            return super.toString() + "--" + getSource();
        }
        return super.toString();
    }
}