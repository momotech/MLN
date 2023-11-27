/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.jse;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.exception.InvokeError;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * luaj helper
 * 未注册java对象
 */
@LuaApiUsed(ignore = true)
public class JavaInstance<T> extends LuaUserdata {
    public static final String LUA_CLASS_NAME = "__JavaInstance";

    JavaClass jclass;

    JavaInstance(Globals g, Object jud) {
        super(g, jud);
    }

    /**
     * lua中，所有方法会走到这里
     * eg:
     * obj:get(1)
     * name: get
     * params: {1}
     *
     * @param name   方法名称
     * @param params 参数
     */
    @LuaApiUsed
    protected final LuaValue[] __index(String name, LuaValue[] params) {
        if (jclass == null)
            jclass = JavaClass.forClass(globals, javaUserdata.getClass());
        Field f = jclass.getField(name);
        if (f != null) {
            try {
                Object obj = f.get(javaUserdata);
                return toLua(obj);
            } catch (Exception ignore) {
            }
        }

        Method m = Utils.findBestMethod(jclass.getMethod(name), params);
        if (m != null) {
            Object[] nps = Utils.toNativeValue(params, m.getParameterTypes());
            try {
                Object obj = m.invoke(javaUserdata, nps);
                return toLua(obj);
            } catch (Exception ignore) {
            }
        }

        Class c = jclass.getInnerClass(name);
        if (c != null)
            return varargsOf(JavaClass.forClass(globals, c));
        return rNil();
    }

    private LuaValue[] toLua(Object obj) {
        if (obj == null) return rNil();
        LuaValue ret = Utils.toLuaValue(globals, obj);
        return varargsOf(ret);
    }

    /**
     * lua代码 a[name] = xxx
     * 会执行到这里
     *
     * @param name 参数名称
     * @param val  复制参数
     */
    @LuaApiUsed
    protected final void __newindex(String name, LuaValue val) {
        if (jclass == null)
            jclass = JavaClass.forClass(globals, javaUserdata.getClass());
        Field f = jclass.getField(name);
        if (f != null) {
            try {
                f.set(javaUserdata, Utils.toNativeValue(val, f.getType()));
            } catch (Exception ignore) {
            }
        } else {
            throw new InvokeError("no field in " + javaUserdata.getClass().getName() + " named " + name);
        }
    }

    @LuaApiUsed
    protected void __onLuaGc() {
        if (globals.isDestroyed()) {
            javaUserdata = null;
            jclass = null;
        }
        super.__onLuaGc();
    }

    @Override
    public final T getJavaUserdata() {
        return (T) javaUserdata;
    }

    @Override
    protected String initLuaClassName(Globals g) {
        return LUA_CLASS_NAME;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (javaUserdata != null) return javaUserdata.equals(((JavaInstance)o).javaUserdata);
        return ((JavaInstance)o).javaUserdata == null;
    }
}