/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by Xiong.Fangyu on 2019/2/25
 * <p>
 * 含有Lua栈位置信息的类型
 *
 * 使用完成及时调用{@link #destroy()}方法
 *
 * @see LuaTable
 * @see LuaFunction
 * @see LuaUserdata
 * @see LuaThread
 */
@LuaApiUsed
abstract class NLuaValue extends LuaValue {
    /**
     * 虚拟机
     */
    protected Globals globals;
    /**
     * 此对象是否已经调用过destroy
     */
    volatile boolean calledDestroy = false;

    /**
     * 创建Table or UserData时使用
     * @see LuaTable#create
     * @see LuaUserdata
     */
    NLuaValue(Globals globals, long nativeGlobalKey) {
        if (globals == null)
            throw new NullPointerException();
        this.globals = globals;
        this.nativeGlobalKey = nativeGlobalKey;
    }

    /**
     * For Globals
     * @see Globals
     */
    NLuaValue(long nativeGlobalKey) {
        this.nativeGlobalKey = nativeGlobalKey;
    }

    /**
     * Called by native method.
     */
    @LuaApiUsed
    NLuaValue(long L_state, long nativeGlobalKey) {
        this(nativeGlobalKey);
        this.globals = Globals.getGlobalsByLState(L_state);
        if (globals == null)
            throw new NullPointerException(
                    "no Globals object for pointer " + Long.toHexString(L_state) +
                    "\n" + Globals.debugGlobalsPointers());
    }

    /**
     * 销毁native状态
     * table、function、userdata将从GVN表中移除
     * globals将销毁虚拟机
     *
     * 由于{@link #finalize()}会调用此方法，所以此方法线程不安全
     * 不希望destroy调用多次，所以增加{@link #calledDestroy}判断
     * @see Globals#destroy()
     * @see Globals#removeStack(LuaValue)
     */
    public void destroy() {
        synchronized (this) {
            if (calledDestroy)
                return;
            calledDestroy = true;
        }
        if (notInGlobalTable() || destroyed || globals.isDestroyed())
            return;
        destroyed = globals.removeStack(this);
    }

    /**
     * 检查GNV表中是否有相应对象
     * 必须保证 {@link #globals} 没有销毁
     * 且 {@link #nativeGlobalKey} 大于0
     */
    boolean checkStateByNative() {
        destroyed = !LuaCApi._hasNativeValue(globals.L_State, nativeGlobalKey, type());
        return !destroyed;
    }

    /**
     * 获取虚拟机信息
     */
    public final Globals getGlobals() {
        return globals;
    }

    @Override
    @LuaApiUsed
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        NLuaValue luaValue = (NLuaValue) o;
        if (!notInGlobalTable()) {
            return nativeGlobalKey == luaValue.nativeGlobalKey;
        } else {//nativeGlobalKey == 0 的情况，由Java层创建，或Lua层创建，但未加入到GNV表中
            return super.equals(o);
        }
    }

    @Override
    public int hashCode() {
        if (!notInGlobalTable()) {
            return (int)(nativeGlobalKey ^ (nativeGlobalKey >>> 32));
        }
        return super.hashCode();
    }

    @LuaApiUsed
    @Override
    public String toString() {
        return LUA_TYPE_NAME[type()] + "#(" + Long.toHexString(nativeGlobalKey) + ")";
    }

    @Override
    protected void finalize() throws Throwable {
        if (this instanceof Globals) {
            super.finalize();
            return;
        }
        try {
            destroy();
        } finally {
            super.finalize();
        }
    }
}