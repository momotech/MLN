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

import java.io.File;

/**
 * Created by Xiong.Fangyu on 2019/2/22
 * <p>
 * Lua函数封装类
 * 可使用{@link #invoke(LuaValue[])} {@link #invoke(LuaValue[], int)}调用
 * <p>
 * 通过注册静态Bridge代替
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
    public LuaFunction(long L_state, long stackIndex) {
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
            LuaValue[] ret = LuaCApi._invoke(globals.L_State, nativeGlobalKey, params, returnCount);
            globals.calledFunction --;
            return ret;
        } catch (InvokeError e) {
            functionInvokeError(e);
            return empty();
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

    /**
     * 把函数dump成二进制数据，并保存到文件中
     * @param dest 文件路径
     * @return 0：成功
     * @see ErrorCode
     */
    public final @ErrorCode int dump(String dest) {
        if (globals.isDestroyed()) {
            return ERR_GLOBAL_DESTROY;
        }
        File parent = new File(dest).getParentFile();
        if (!parent.exists()) {
            if (!parent.mkdirs())
                return ERR_CREATE_DIR;
        }
        return LuaCApi._dumpFunction(globals.L_State, nativeGlobalKey, dest);
    }

    //<editor-fold desc="fast invoke">

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaValue)
     */
    public final void fastInvoke() {
        try {
            if (!checkStatus())
                return;
            nativeInvokeV(globals.L_State, nativeGlobalKey);
            globals.calledFunction --;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaValue)
     */
    public final void fastInvoke(boolean b) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeB(globals.L_State, nativeGlobalKey, b);
            globals.calledFunction --;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaValue)
     */
    public final void fastInvoke(double number) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeN(globals.L_State, nativeGlobalKey, number);
            globals.calledFunction --;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaValue)
     */
    public final void fastInvoke(String s) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeS(globals.L_State, nativeGlobalKey, s);
            globals.calledFunction --;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    /**
     * 无返回值快速调用，比普通调用方式性能提高1倍以上
     * @see #fastInvoke()
     * @see #fastInvoke(boolean)
     * @see #fastInvoke(double)
     * @see #fastInvoke(String)
     * @see #fastInvoke(LuaValue)
     */
    public final void fastInvoke(LuaValue t) {
        checkParams(t);
        try {
            if (!checkStatus())
                return;
            if (t.isNil() || t.isTable()) {
                nativeInvokeT(globals.L_State, nativeGlobalKey, t.nativeGlobalKey);
            } else if (t.nativeGlobalKey == Globals.GLOBALS_INDEX) {
                nativeInvokeUD(globals.L_State, nativeGlobalKey, t.toUserdata());
            } else {
                nativeInvokeU(globals.L_State, nativeGlobalKey, t.nativeGlobalKey);
            }
            globals.calledFunction --;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    public void fastInvoke(boolean b1, boolean b2) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeBB(globals.L_State, nativeGlobalKey, b1, b2);
            globals.calledFunction --;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    public void fastInvoke(double num1, double num2) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeNN(globals.L_State, nativeGlobalKey, num1, num2);
            globals.calledFunction --;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    public void fastInvoke(String s1, String s2) {
        try {
            if (!checkStatus())
                return;
            nativeInvokeSS(globals.L_State, nativeGlobalKey, s1, s2);
            globals.calledFunction --;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    public void fastInvoke(LuaValue t1, LuaValue t2) {
        checkParams(t1, t2);
        try {
            if (!checkStatus())
                return;
            if (t1.isTable() || t2.isTable() || (t1.isNil() && t2.isNil())) {
                nativeInvokeTT(globals.L_State, nativeGlobalKey, t1.nativeGlobalKey, t2.nativeGlobalKey);
            } else if (t1.nativeGlobalKey == Globals.GLOBALS_INDEX && t2.nativeGlobalKey == Globals.GLOBALS_INDEX) {
                nativeInvokeUDUD(globals.L_State, nativeGlobalKey, t1.toUserdata(), t2.toUserdata());
            } else if (t1.nativeGlobalKey == Globals.GLOBALS_INDEX) {
                nativeInvokeUDU(globals.L_State, nativeGlobalKey, t1.toUserdata(), t2.nativeGlobalKey);
            } else if (t2.nativeGlobalKey == Globals.GLOBALS_INDEX) {
                nativeInvokeUUD(globals.L_State, nativeGlobalKey, t1.nativeGlobalKey, t2.toUserdata());
            } else {
                nativeInvokeUU(globals.L_State, nativeGlobalKey, t1.nativeGlobalKey, t2.nativeGlobalKey);
            }
            globals.calledFunction --;
        } catch (InvokeError e) {
            functionInvokeError(e);
        }
    }

    private void checkParams(LuaValue v) {
        if (v.isNil() || v.isTable() || v.isUserdata())
            return;
        throw new IllegalArgumentException("只能传入table、userdata或nil，当前为:"+ v);
    }

    private void checkParams(LuaValue v1, LuaValue v2) {
        int t1 = v1.type();
        int t2 = v2.type();
        if (t1 == t2)
            return;
        if (t1 == LUA_TNIL && (t2 == LUA_TTABLE || t2 == LUA_TUSERDATA))
            return;
        if (t2 == LUA_TNIL && (t1 == LUA_TTABLE || t1 == LUA_TUSERDATA))
            return;
        throw new IllegalArgumentException("两个参数只能传入table、userdata或nil，且类型必须相同");
    }

    protected native void nativeInvokeV(long L, long function);
    protected native void nativeInvokeB(long L, long function, boolean b);
    protected native void nativeInvokeN(long L, long function, double number);
    protected native void nativeInvokeS(long L, long function, String s);
    protected native void nativeInvokeT(long L, long function, long table);
    protected native void nativeInvokeU(long L, long function, long userdata);
    protected native void nativeInvokeUD(long L, long function, LuaUserdata<?> u);
    protected native void nativeInvokeBB(long L, long function, boolean b1, boolean b2);
    protected native void nativeInvokeNN(long L, long function, double num1, double num2);
    protected native void nativeInvokeSS(long L, long function, String s1, String s2);
    protected native void nativeInvokeTT(long L, long function, long table, long table2);
    protected native void nativeInvokeUU(long L, long function, long u1, long u2);
    protected native void nativeInvokeUUD(long L, long function, long u1, LuaUserdata<?> u2);
    protected native void nativeInvokeUDU(long L, long function, LuaUserdata<?> u1, long u2);
    protected native void nativeInvokeUDUD(long L, long function, LuaUserdata<?> u1, LuaUserdata<?> u2);
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
        invokeError = null;
        globals.calledFunction ++;
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
        invokeError = null;
        globals.calledFunction ++;
    }

    protected final void afterFunctionInvoked() {
        globals.calledFunction --;
    }

    protected final void functionInvokeError(InvokeError e) {
        invokeError = e;
        globals.calledFunction --;
        if (globals.getState() != Globals.LUA_CALLING && MLNCore.hookLuaError(e, globals))
            return;
        throw e;
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