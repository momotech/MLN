/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2;

import androidx.annotation.CallSuper;

import org.luaj.vm2.utils.LuaApiUsed;
import org.luaj.vm2.utils.SizeOfUtils;

/**
 * Created by Xiong.Fangyu on 2019/2/22
 * <p>
 * Lua Userdata
 *
 * 若想让Java层管理内存，继承{@link JavaUserdata}
 *
 * 如果想实现未注册bridge的效果:
 * <code>
 *  /// 实现未注册的方法，如 u:name(a,b,c)
 *  @LuaApiUsed
 *  protect LuaValue[] __index(String name, LuaValue[] params) {}
 *
 *  /// 实现设置方法，如u['name'] = 1
 *  /// 一般不用
 *  @LuaApiUsed
 *  protect void __newindex(String name, LuaValue val) {}
 * </code>
 */
@LuaApiUsed
public class LuaUserdata<T> extends NLuaValue {
    /**
     * 由Native读取
     */
    @LuaApiUsed
    private String luaclassName;
    /**
     * 单虚拟机中独一无二的id
     * 提供给native读取
     * @see UserdataCache
     */
    @LuaApiUsed
    long id;
    /**
     * 在java中保存的对象
     */
    protected T javaUserdata;
    /**
     * Native引用计数
     */
    private long refCount;
    /**
     * Java引用计数
     */
    private long javaRefCount;
    /**
     * {@link #javaUserdata}消耗内存
     */
    protected long memoryCastCache = 0;

    /**
     * 由java层创建
     * @param g         虚拟机信息
     * @param jud       java中保存的对象，可为空
     * @see #javaUserdata
     */
    public LuaUserdata(Globals g, T jud) {
        super(g, g.globalsIndex());
        luaclassName = initLuaClassName(g);
        javaUserdata = jud;
        g.userdataCache.put(this);
        /// 由Java层创建，无Native引用
        refCount = 0;
    }

    /**
     * 必须有传入long和LuaValue[]的构造方法，且不可混淆
     * 由native创建
     *
     * 子类可在此构造函数中初始化{@link #javaUserdata}
     *
     * 必须有此构造方法！！！！！！！！
     *
     * @param L 虚拟机地址
     * @param v lua脚本传入的构造参数
     */
    @LuaApiUsed
    protected LuaUserdata(long L, LuaValue[] v) {
        super(L, 0);
        globals.userdataCache.put(this);
        /// 由Native创建，引用计数为1
        refCount = 1;
    }

    /**
     * 由Native调用，表示该对象将被虚拟机引用
     */
    @LuaApiUsed
    private void addRef() {
        refCount ++;
    }

    /**
     * 由java持有对象
     * 防止只在java层有引用，但被lua释放了
     * @see #__onLuaGc()
     */
    public void onJavaRef() {
        javaRefCount ++;
    }

    /**
     * java不持有
     */
    public void onJavaRecycle() {
        javaRefCount --;
        if (refCount > 0 || globals.isDestroyed()) {
            return;
        }
        if (javaRefCount <= 0)
            globals.userdataCache.onUserdataGc(this, false);
    }

    /**
     * 初始化{@link #luaclassName}
     * 默认从虚拟机中注册表中获取
     * 若没继承，子类需要自己实现
     * @param g 虚拟机
     */
    protected String initLuaClassName(Globals g) {
        return g.getLuaClassName(getClass());
    }

    /**
     * 此对象被Lua GC时会调用
     */
    @CallSuper
    @LuaApiUsed
    protected void __onLuaGc() {
        refCount --;
        if (javaRefCount > 0 || globals.isDestroyed())
            return;
        if (refCount <= 0)
            globals.userdataCache.onUserdataGc(this, false);
    }

    /**
     * Lua中调用 == 时会调用
     */
    @LuaApiUsed
    protected boolean __onLuaEq(Object other) {
        return equals(other);
    }

    /**
     * 由Native创建
     */
    @LuaApiUsed
    private LuaUserdata(long L_state, long stackIndex) {
        super(L_state, stackIndex);
    }

    /**
     * 给底层获取当前userdata消耗的内存
     * @return 内存 Byte
     */
    @LuaApiUsed
    protected long memoryCast() {
        if (memoryCastCache == 0) {
            if (javaUserdata != null) {
                memoryCastCache = SizeOfUtils.sizeof(javaUserdata.getClass());
            }
            if (memoryCastCache == 0)
                memoryCastCache = 8;
        }
        return memoryCastCache;
    }

    @Override
    public final int type() {
        return LUA_TUSERDATA;
    }

    @Override
    public final LuaUserdata toUserdata() {
        return this;
    }

    /**
     * 返回java中保存的对象
     * @return Nullable
     */
    public T getJavaUserdata() {
        return javaUserdata;
    }

    @Override
    public int hashCode() {
        if (javaUserdata != null)
            return javaUserdata.hashCode();
        return super.hashCode();
    }

    /**
     * 对象走到finalize阶段，认为userdata在java层和lua层都无引用了，直接从cache中移除
     */
    @Override
    protected void finalize() throws Throwable {
        javaRefCount = 0;
        refCount = 0;
        if (globals != null)
            globals.userdataCache.onUserdataGc(this, true);
        super.finalize();
    }

    @Override
    public void destroy() {
        if (this instanceof JavaUserdata)
            super.destroy();
    }
}