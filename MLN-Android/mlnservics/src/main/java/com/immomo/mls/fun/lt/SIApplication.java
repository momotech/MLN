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

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;

import java.util.HashMap;
import java.util.Map;

/**
 * Author       :   wu.tianlong@immomo.com
 * Date         :   2019/1/11
 * Time         :   下午3:01
 * Description  :   通知 lua 层 整个APP是否被压入后台，比如按 HOME 键操作
 */

@LuaClass(name = "Application", isSingleton = true)
public class SIApplication implements Globals.OnDestroyListener {
    public static final String LUA_CLASS_NAME = "Application";

    public static boolean isColdBoot = false;

    private static final Map<Globals, SIApplication> instance = new HashMap<>();

    private LuaFunction mAppearFunction;
    private LuaFunction mDisappearFunction;
    private Globals globals;

    public SIApplication(Globals g) {
        globals = g;
    }

    @Override
    public void onDestroy(Globals g) {
        instance.remove(g);
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Function0.class, typeArgs = {Unit.class})
            })
    })
    public void setForeground2BackgroundCallback(LuaFunction fun) {
        if (mDisappearFunction != null)
            mDisappearFunction.destroy();
        mDisappearFunction = fun;
        if (fun != null) {
            instance.put(globals, this);
            globals.removeOnDestroyListener(this);
            globals.addOnDestroyListener(this);
        }
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Function0.class, typeArgs = {Unit.class})
            })
    })
    public void setBackground2ForegroundCallback(LuaFunction fun) {
        if (mAppearFunction != null)
            mAppearFunction.destroy();
        mAppearFunction = fun;
        if (fun != null) {
            instance.put(globals, this);
            globals.removeOnDestroyListener(this);
            globals.addOnDestroyListener(this);
        }
    }

    // 文档 WIKI 上暂时没写这个方法，后续可能会加上
    @LuaBridge
    public boolean isColdBoot() {
       return isColdBoot;
    }

    public void enterForeGround() {
        if (mAppearFunction != null)
            mAppearFunction.invoke(null);
    }

    public void enterBackGround() {
        if (mDisappearFunction != null)
            mDisappearFunction.invoke(null);
    }

    public static void setIsForeground(boolean isForeground) {
        for (SIApplication i : instance.values()) {
            if (isForeground) {
                i.enterForeGround();
            } else {
                i.enterBackGround();
            }
        }
        if (!isForeground)
            isColdBoot = false;
    }

    @Override
    public String toString() {
        return LUA_CLASS_NAME +
                " { setForeground2BackgroundCallback, setBackground2ForegroundCallback, isColdBoot}";
    }
}