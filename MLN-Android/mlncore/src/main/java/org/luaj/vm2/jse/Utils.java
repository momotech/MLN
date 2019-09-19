/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package org.luaj.vm2.jse;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.List;
import java.util.Map;

/**
 * Created by Xiong.Fangyu on 2019-07-01
 */
class Utils {

    static LuaValue toLuaValue(Globals g, Object o) {
        if (o instanceof Class) {
            return JavaClass.forClass(g, (Class) o);
        }
        return new JavaInstance(g, o);
    }

    public static Object[] toNativeArray(LuaTable t, Class need) {
        int len = t == null ? 0 : t.getn();
        if (len == 0) return null;
        Object[] ret = new Object[len];
        for (int i = 0; i < len; i ++) {
            ret[i] = toNativeValue(t.get(i + 1), need);
        }
        return ret;
    }

    static Object toNativeValue(LuaValue v, Class need) {
        if (v == null || v.isNil() || need == null) return null;
        if (need == String.class) return v.toJavaString();

        if (need.isPrimitive()) {
            return toPrimitive(v, need);
        }
        if (Character.class == need) {
            need = char.class;
        } else if (Boolean.class == need) {
            need = boolean.class;
        } else if (need == Byte.class) {
            need = byte.class;
        } else if (need == Short.class) {
            need = short.class;
        } else if (need == Integer.class) {
            need = int.class;
        } else if (need == Float.class) {
            need = float.class;
        } else if (need == Long.class) {
            need = long.class;
        } else if (need == Double.class) {
            need = double.class;
        }
        if (need.isPrimitive()) {
            return toPrimitive(v, need);
        }
        return null;
    }

    static Method findBestMethod(List<Method> methods, LuaValue[] args) {
        int score = Integer.MAX_VALUE;
        Method best = null;
        for (Method m : methods) {
            int s = score(args, m.getParameterTypes());
            if (s == 0) return m;
            if (s < score) {
                score = s;
                best = m;
            }
        }
        return best;
    }

    static Constructor findBestConstructor(List<Constructor> cs, LuaValue[] args) {
        int score = Integer.MAX_VALUE;
        Constructor best = null;
        for (Constructor m : cs) {
            int s = score(args, m.getParameterTypes());
            if (s == 0) return m;
            if (s < score) {
                score = s;
                best = m;
            }
        }
        return best;
    }

    static Object[] toNativeValue(LuaValue[] args, Class[] paramTypes) {
        int len = paramTypes.length;
        int al = args.length;
        Object[] result = new Object[len];
        for (int i = 0; i < len && i < al; i++) {
            result[i] = toNativeValue(args[i], paramTypes[i]);
        }
        return result;
    }

    private static Object toPrimitive(LuaValue v, Class need) {
        if (need == boolean.class) return v.toBoolean();
        if (need == byte.class) return (byte) v.toInt();
        if (need == char.class) return (char) v.toInt();
        if (need == short.class) return (short) v.toInt();
        if (need == int.class) return v.toInt();
        if (need == float.class) return v.toFloat();
        if (need == long.class) return (long) v.toDouble();
        return v.toDouble();
    }

    /**
     * 计算lua参数和函数参数的符合度
     *
     * @param args       lua参数
     * @param paramTypes 函数或构造函数参数
     * @return 分数越小越吻合，0表示完全吻合
     */
    static int score(LuaValue[] args, Class[] paramTypes) {
        int na = args != null ? args.length : 0;
        int np = paramTypes != null ? paramTypes.length : 0;
        int s = na > np ? 0x100 * (na - np) : 0;
        for (int i = 0; i < na && i < np; i++) {
            s += score(args[i], paramTypes[i]);
        }
        return s;
    }

    static int score(LuaValue val, Class clz) {
        if (clz.isPrimitive()) {
            if (clz == boolean.class) return val.isBoolean() ? 0 : 1;
            return val.isNumber() ? 0 : 1;
        }
        if (val.isNil()) return 0;
        if (val.getClass() == clz) return 0;
        if (clz == Boolean.class) return val.isBoolean() ? 0 : 1;
        if (Number.class.isAssignableFrom(clz) || Character.class == clz)
            return val.isNumber() ? 0 : 1;
        if (clz == String.class) return val.isString() ? 0 : 1;
        if (val instanceof LuaUserdata)
            return clz.isInstance(((LuaUserdata) val).getJavaUserdata()) ? 0 : 1;
        if (val.isTable())
            return Map.class.isAssignableFrom(clz)
                    || List.class.isAssignableFrom(clz) ? 0 : 1;
        return 1;
    }
}