/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.jse;

import com.immomo.mls.fun.ud.view.UDLabel;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.exception.InvokeError;
import org.luaj.vm2.utils.LuaApiUsed;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.List;

/**
 * Created by Xiong.Fangyu on 2019-06-28
 */
@LuaApiUsed(ignore = true)
public class Luajava {
    public static final String NAME = "luajava";

    public static LuaValue[] __index(long L, String name, LuaValue[] params) {
        try {
            LuaValue ret = null;
            switch (name) {
                case "bindClass":   /*clz = luajava.bindClass(string)*/
                    ret = bindClass(Globals.getGlobalsByLState(L), params[0].toJavaString());
                    break;
                case "newInstance": /*obj = luajava.newInstance(string, ...)*/
                    ret = newInstance(Globals.getGlobalsByLState(L), params[0].toJavaString(), params);
                    break;
                case "new":         /*obj = luajava.new(clz, ...)*/
                    ret = _new(Globals.getGlobalsByLState(L), ((JavaClass) params[0]).getJavaUserdata(), params);
                    break;
                case "createProxy": /*obj = luajava.createProxy(string..., table)*/
                    ret = createProxy(Globals.getGlobalsByLState(L), params);
                    break;
                case "loadLib":     /*obj = luajava.loadLib(string, string)*/
                    ret = loadLib(Globals.getGlobalsByLState(L), params[0].toJavaString(), params[1].toJavaString());
                    break;
                default:
                    throw new InvokeError("not support " + name + " yet!");
            }
            if (ret != null) return LuaValue.varargsOf(ret);
        } catch (InvokeError ie) {
            throw ie;
        } catch (Exception e) {
            throw new InvokeError("call " + NAME + "." + name + " failed!", e);
        }
        return null;
    }

    private static LuaValue bindClass(Globals g, String clzName) throws ClassNotFoundException {
        return JavaClass.forClass(g, classForName(clzName));
    }

    private static LuaValue newInstance(Globals g, String clzName, LuaValue[] params) throws ClassNotFoundException, IllegalAccessException, InstantiationException, InvocationTargetException {
        return _new(g, classForName(clzName), params);
    }

    private static LuaValue _new(Globals g, Class c, LuaValue[] params) throws InstantiationException, IllegalAccessException, InvocationTargetException {
        JavaClass javaClass = JavaClass.forClass(g, c);
        List<Constructor> constructors = javaClass.getConstructor();
        int len = params.length;
        if (len == 1) {
            Object obj = c.newInstance();
            return Utils.toLuaValue(g, obj);
        }
        LuaValue[] sub = new LuaValue[len - 1];
        System.arraycopy(params, 1, sub, 0, len - 1);
        Constructor constructor = Utils.findBestConstructor(constructors, sub);
        Object[] nps = Utils.toNativeValue(params, constructor.getParameterTypes());
        Object obj = constructor.newInstance(nps);
        return Utils.toLuaValue(g, obj);
    }

    /**
     * obj = luajava.createProxy(string..., table)
     * 为接口创建代理对象
     *
     * @param g      虚拟机
     * @param params 最后一个参数必须为table，前面至少有一个string表示接口名
     * @return 代理对象
     */
    private static LuaValue createProxy(Globals g, LuaValue[] params) throws ClassNotFoundException {
        int len = params.length;
        if (len <= 1) throw new InvokeError("no interface");
        LuaTable table = params[len - 1].toLuaTable();

        final Class[] ifaces = new Class[len - 1];
        for (int i = 0; i < len - 1; i++)
            ifaces[i] = classForName(params[i].toJavaString());
        // create the invocation handler
        InvocationHandler handler = new ProxyInvocationHandler(table);

        // create the proxy object
        Object proxy = Proxy.newProxyInstance(Luajava.class.getClassLoader(), ifaces, handler);

        // return the proxy
        return new JavaInstance(g, proxy);
    }

    private static LuaValue loadLib(Globals g, String clzName, String methodName) throws ClassNotFoundException, NoSuchMethodException, InvocationTargetException, IllegalAccessException {
        Class clazz = classForName(clzName);
        Method method = clazz.getMethod(methodName);
        Object result = method.invoke(clazz);
        if (result instanceof LuaValue) return (LuaValue) result;
        return LuaValue.Nil();
    }

    private static Class classForName(String name) throws ClassNotFoundException {
        return Class.forName(name/*, true, ClassLoader.getSystemClassLoader()*/);
    }

    private static final class ProxyInvocationHandler implements InvocationHandler {
        private final LuaTable table;

        private ProxyInvocationHandler(LuaTable table) {
            this.table = table;
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            String name = method.getName();
            LuaValue func = table.get(name);
            if (!func.isFunction())
                return null;
            int n = args != null ? args.length : 0;
            final LuaValue[] v;
            if (n > 0) {
                v = new LuaValue[n];
                for (int i = 0; i < n; i++)
                    v[i] = Utils.toLuaValue(table.getGlobals(), args[i]);
            } else {
                v = LuaValue.empty();
            }

            LuaValue[] result = func.invoke(v);
            if (result == null) return null;
            return Utils.toNativeValue(result[0], method.getReturnType());
        }
    }
}