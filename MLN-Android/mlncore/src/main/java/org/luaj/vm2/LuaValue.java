/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import androidx.annotation.IntDef;

import org.luaj.vm2.exception.InvokeError;
import org.luaj.vm2.exception.LuaTypeError;
import org.luaj.vm2.utils.LuaApiUsed;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by Xiong.Fangyu on 2019/2/21
 * <p>
 * Lua Java封装基类
 *
 * @see LuaNil      0
 * @see LuaBoolean  1
 * @see LuaNumber   3
 * @see LuaString   4
 * @see LuaTable    5
 * @see LuaFunction 6
 * @see LuaUserdata 7
 * @see LuaThread   8
 */
@LuaApiUsed
public abstract class LuaValue {
    public static final int ERR_GLOBAL_DESTROY = -2;
    public static final int ERR_FUNCTION_DESTROY = -1;
    public static final int ERR_CREATE_DIR = -3;
    public static final int ERR_FILE_NOT_FOUND = -404;
    public static final int ERR_WRITE_FILE_ERROR = -300;
    public static final int ERR_CLOSE_FILE_ERROR = -301;

    @IntDef({ERR_GLOBAL_DESTROY,
            ERR_FUNCTION_DESTROY,
            ERR_CREATE_DIR,
            ERR_FILE_NOT_FOUND,
            ERR_WRITE_FILE_ERROR,
            ERR_CLOSE_FILE_ERROR})
    @Retention(RetentionPolicy.SOURCE)
    public @interface ErrorCode {}

    final public static int LUA_TNONE = -1;
    final public static int LUA_TNIL = 0;
    final public static int LUA_TBOOLEAN = 1;
    final public static int LUA_TLIGHTUSERDATA = 2;
    final public static int LUA_TNUMBER = 3;
    final public static int LUA_TSTRING = 4;
    final public static int LUA_TTABLE = 5;
    final public static int LUA_TFUNCTION = 6;
    final public static int LUA_TUSERDATA = 7;
    final public static int LUA_TTHREAD = 8;

    static final String[] LUA_TYPE_NAME = {
            "nil",              //0
            "boolean",          //1
            "light_userdata",   //2
            "number",           //3
            "string",           //4
            "table",            //5
            "function",         //6
            "userdata",         //7
            "thread"            //8
    };
    /**
     * 标记在Java中是否不可用
     *
     * @see #isDestroyed()
     * @see #destroy()
     */
    protected volatile boolean destroyed;
    /**
     * 若相关数据保存到native GNV表中，则key不为空
     */
    @LuaApiUsed
    long nativeGlobalKey;

    //<editor-fold desc="static method">

    /**
     * 获取nil
     */
    public static LuaValue Nil() {
        return LuaNil.NIL();
    }

    /**
     * 获取true
     */
    public static LuaValue True() {
        return LuaBoolean.TRUE();
    }

    /**
     * 获取false
     */
    public static LuaValue False() {
        return LuaBoolean.FALSE();
    }

    /**
     * 简化代码使用
     */
    public static LuaValue[] varargsOf(LuaValue... values) {
        return values;
    }

    private static LuaValue[] _NIL;
    private static LuaValue[] _TRUE;
    private static LuaValue[] _FALSE;
    private static LuaValue[] _EMPTY;

    public static LuaValue[] empty() {
        if (_EMPTY == null)
            _EMPTY = new LuaValue[0];
        return _EMPTY;
    }

    public static LuaValue[] rNil() {
        if (_NIL == null)
            _NIL = new LuaValue[]{LuaNil.NIL()};
        return _NIL;
    }

    public static LuaValue[] rTrue() {
        if (_TRUE == null)
            _TRUE = new LuaValue[]{LuaBoolean.TRUE()};
        return _TRUE;
    }

    public static LuaValue[] rFalse() {
        if (_FALSE == null)
            _FALSE = new LuaValue[]{LuaBoolean.FALSE()};
        return _FALSE;
    }

    public static LuaValue[] rBoolean(boolean bool) {
        return bool ? rTrue() : rFalse();
    }

    public static LuaValue[] rNumber(double n) {
        return varargsOf(LuaNumber.valueOf(n));
    }

    public static LuaValue[] rString(String s) {
        return varargsOf(LuaString.valueOf(s));
    }

    public static void destroyAllParams(LuaValue[] params) {
        for (LuaValue v : params) {
            v.destroy();
        }
    }

    public static LuaValue[] sub(LuaValue[] v, int from) {
        int len = v.length - from;
        if (len <= 0)
            return null;
        LuaValue[] ret = new LuaValue[len];
        System.arraycopy(v, from, ret, 0, len);
        return ret;
    }
    //</editor-fold>

    //<editor-fold desc="判断类型">
    public boolean isNil() {
        return type() == LUA_TNIL;
    }

    public boolean isBoolean() {
        return type() == LUA_TBOOLEAN;
    }

    public boolean isNumber() {
        return type() == LUA_TNUMBER;
    }

    public boolean isInt() {
        return false;
    }

    public boolean isString() {
        return type() == LUA_TSTRING;
    }

    public boolean isFunction() {
        return type() == LUA_TFUNCTION;
    }

    public boolean isTable() {
        return type() == LUA_TTABLE;
    }

    public boolean isUserdata() {
        return type() == LUA_TUSERDATA || type() == LUA_TLIGHTUSERDATA;
    }

    public boolean isThread() {
        return type() == LUA_TTHREAD;
    }
    //</editor-fold>

    //<editor-fold desc="cast">
    public boolean toBoolean() {
        typeError(LUA_TYPE_NAME[LUA_TBOOLEAN]);
        return false;
    }

    public int toInt() {
        typeError(LUA_TYPE_NAME[LUA_TNUMBER]);
        return 0;
    }

    public double toDouble() {
        typeError(LUA_TYPE_NAME[LUA_TNUMBER]);
        return 0;
    }

    public long toLong() {
        return (long) toDouble();
    }

    public float toFloat() {
        return (float) toDouble();
    }

    public String toJavaString() {
        return toString();
    }

    public LuaFunction toLuaFunction() {
        typeError(LUA_TYPE_NAME[LUA_TFUNCTION]);
        return null;
    }

    public LuaTable toLuaTable() {
        typeError(LUA_TYPE_NAME[LUA_TTABLE]);
        return null;
    }

    public LuaUserdata toUserdata() {
        typeError(LUA_TYPE_NAME[LUA_TUSERDATA]);
        return null;
    }

    public LuaThread toLuaThread() {
        typeError(LUA_TYPE_NAME[LUA_TTHREAD]);
        return null;
    }
    //</editor-fold>

    //<editor-fold desc="get set">
    public void set(int index, LuaValue value) {
        toLuaTable().set(index, value);
    }

    public void set(int index, double num) {
        toLuaTable().set(index, num);
    }

    public void set(int index, boolean b) {
        toLuaTable().set(index, b);
    }

    public void set(int index, String s) {
        toLuaTable().set(index, s);
    }

    public void set(String name, LuaValue value) {
        toLuaTable().set(name, value);
    }

    public void set(String name, double num) {
        toLuaTable().set(name, num);
    }

    public void set(String name, boolean b) {
        toLuaTable().set(name, b);
    }

    public void set(String name, String s) {
        toLuaTable().set(name, s);
    }

    public LuaValue get(int index) {
        return toLuaTable().get(index);
    }

    public LuaValue get(String name) {
        return toLuaTable().get(name);
    }
    //</editor-fold>

    /**
     * 给当前对象设置metatable
     * @return 新metatable
     */
    public LuaTable setMetatable() {
        return setMetatalbe(null);
    }

    /**
     * 给当前对象设置metatable
     * @param t null: 在底层设置，并返回
     *          否则直接设置并返回
     * @return new table or t
     */
    public LuaTable setMetatalbe(LuaTable t) {
        return toLuaTable().setMetatalbe(t);
    }


    /**
     * 获取当前对象的metatable
     * @return metatable
     */
    public LuaTable getMetatable() {
        return toLuaTable().getMetatable();
    }



    //<editor-fold desc="Function">

    /**
     * 调用lua方法，且已知方法返回个数
     *
     * @param params      方法传入的参数，可为空
     * @param returnCount 方法返回参数个数
     * @return 返回参数，若returnCount为0，返回空
     */
    public LuaValue[] invoke(LuaValue[] params, int returnCount) throws InvokeError {
        return toLuaFunction().invoke(params, returnCount);
    }

    /**
     * 调用lua方法，方法返回参数个数未知
     *
     * @param params 方法传入的参数，可为空
     * @return 返回参数，可为空
     */
    public LuaValue[] invoke(LuaValue[] params) throws InvokeError {
        return toLuaFunction().invoke(params);
    }

    /**
     * 把函数dump成二进制数据，并保存到文件中
     * @param dest 文件路径
     * @return 0：成功
     * @see ErrorCode
     */
    public @ErrorCode int dump(String dest) {
        return toLuaFunction().dump(dest);
    }
    //</editor-fold>

    /**
     * 返回类型
     *
     * @see #LUA_TNIL
     * @see #LUA_TBOOLEAN
     * @see #LUA_TLIGHTUSERDATA
     * @see #LUA_TNUMBER
     * @see #LUA_TSTRING
     * @see #LUA_TTABLE
     * @see #LUA_TFUNCTION
     * @see #LUA_TUSERDATA
     * @see #LUA_TTHREAD
     */
    @LuaApiUsed
    public abstract int type();

    /**
     * 获取当前数据在native的 GNV 表中key
     * 非{@link NLuaValue}数据类型返回0
     */
    @LuaApiUsed
    public long nativeGlobalKey() {
        return nativeGlobalKey;
    }

    /**
     * 判断当前对象是否在GNV表里
     */
    boolean notInGlobalTable() {
        return nativeGlobalKey == 0 || nativeGlobalKey == Globals.GLOBALS_INDEX;
    }

    /**
     * 销毁当前数据，非{@link NLuaValue}无效
     *
     * @see NLuaValue#destroy()
     * @see Globals#destroy()
     * @see #isDestroyed()
     */
    public void destroy() {

    }

    /**
     * 判断当前类型是否可用
     */
    public boolean isDestroyed() {
        return destroyed;
    }

    void typeError(String wantType) {
        throw new LuaTypeError("This value type is " + LUA_TYPE_NAME[type()] + ", cannot be cast to " + wantType);
    }

    @Override
    public String toString() {
        return LUA_TYPE_NAME[type()] + "@" + hashCode();
    }
}