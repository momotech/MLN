/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019/1/11
 * Time         :   下午3:01
 * Description  :   通知 lua 层 整个APP是否被压入后台，比如按 HOME 键操作
 */

@LuaClass
public class SIApplication {
    public static final String LUA_CLASS_NAME = "Application";

    private static LuaFunction mAppearFunction;
    private static LuaFunction mDisappearFunction;

    public static boolean isColdBoot = false;

    public void __onLuaGc() {
        if (mAppearFunction != null) {
            mAppearFunction.destroy();
        }
        mAppearFunction = null;
        if (mDisappearFunction != null) {
            mDisappearFunction.destroy();
        }
        mDisappearFunction = null;
    }

    @LuaBridge
    public void setForeground2BackgroundCallback(LuaFunction fun) {
        if (mDisappearFunction != null)
            mDisappearFunction.destroy();
        mDisappearFunction = fun;
    }

    @LuaBridge
    public void setBackground2ForegroundCallback(LuaFunction fun) {
        if (mAppearFunction != null)
            mAppearFunction.destroy();
        mAppearFunction = fun;
    }

    // 文档 WIKI 上暂时没写这个方法，后续可能会加上
    @LuaBridge
    public boolean isColdBoot() {
       return isColdBoot;
    }

    public static void enterForeGround() {
        if (mAppearFunction != null)
            mAppearFunction.invoke(null);

    }

    public static void enterBackGround() {
        if (mDisappearFunction != null)
            mDisappearFunction.invoke(null);
    }

    @Override
    public String toString() {
        return LUA_CLASS_NAME +
                " { setForeground2BackgroundCallback, setBackground2ForegroundCallback, isColdBoot}";
    }
}