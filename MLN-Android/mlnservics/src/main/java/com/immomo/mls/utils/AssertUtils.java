/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import com.immomo.mls.Environment;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;

/**
 * Created by XiongFangyu on 2018/9/28.
 */
public class AssertUtils {

    public static void assetTrue(boolean b) {
        if (!b)
            throw new IllegalStateException();
    }

    public static void assertNullForce(Object obj) {
        if (obj == null) {
            throw new NullPointerException();
        }
    }

    public static boolean assertNull(Object obj, String msg, Globals globals) {
        if (obj == null) {
            NullPointerException exception = new NullPointerException(msg);
            if (!Environment.hook(exception, globals)) {
                throw exception;
            }
            return false;
        }
        return true;
    }

    public static boolean assertNil(LuaValue a, LuaFunction caller, Globals globals) {
        if (a == null || a.isNil()) {
            ReturnError error = new ReturnError(" return nil in caller " + caller);
            throwError(error, globals);
            return false;
        }
        return true;
    }

    public static boolean assertNumber(LuaValue v, LuaFunction caller, Globals globals) {
        if (v == null || !v.isNumber()) {
            ReturnError error = new ReturnError(" return type invalid! need number instead of " + v + " in caller " + caller);
            throwError(error, globals);
            return false;
        }
        return true;
    }

    public static boolean assertString(LuaValue v, LuaFunction caller, Globals globals) {
        if (v == null || !v.isString()) {
            ReturnError error = new ReturnError(" return type invalid! need string instead of " + v + " in caller " + caller);
            throwError(error, globals);
            return false;
        }
        return true;
    }

    public static boolean assertBoolean(LuaValue v, LuaFunction caller, Globals globals) {
        if (v == null || !v.isBoolean()) {
            ReturnError error = new ReturnError(" return type invalid! need boolean instead of " + v + " in caller " + caller);
            throwError(error, globals);
            return false;
        }
        return true;
    }

    public static boolean assertUserData(LuaValue v, Class<? extends LuaUserdata> need, LuaFunction caller, Globals globals) {
        if (v == null || !need.isInstance(v)) {
            ReturnError error = new ReturnError(" return type invalid! need " + getUDName(need) + " instead of " + v + " in caller " + caller);
            throwError(error, globals);
            return false;
        }
        return true;
    }

    public static boolean assertUserData(LuaValue v, Class<? extends LuaUserdata> need, String caller, Globals globals) {
        if (v == null || !need.isInstance(v)) {
            ReturnError error = new ReturnError(" setter type invalid! need " + getUDName(need) + " instead of " + v + " in caller " + caller);
            throwError(error, globals);
            return false;
        }
        return true;
    }

    public static boolean assertFunction(LuaValue v, String msg, Globals globals) {
        if (v == null || !v.isFunction()) {
            ReturnError error = new ReturnError(msg);
            if (!Environment.hook(error, globals)) {
                throw error;
            }
            return false;
        }
        return true;
    }

    private static String getUDName(Class<? extends LuaUserdata> clz) {
        return clz.getSimpleName();
    }

    private static void throwError(ReturnError error, Globals globals) {
        if (!Environment.hook(error, globals)) {
            throw error;
        }
    }

    public static final class ReturnError extends RuntimeException {

        public ReturnError(Throwable cause) {
            super(cause);
        }

        public ReturnError(String message) {
            super(message);
        }
    }
}