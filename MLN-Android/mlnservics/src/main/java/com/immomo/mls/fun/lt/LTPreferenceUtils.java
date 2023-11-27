/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import android.content.Context;
import android.content.SharedPreferences;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import kotlin.Unit;
import kotlin.jvm.functions.Function0;
import org.luaj.vm2.Globals;

import java.util.Map;

/**
 * Created by XiongFangyu on 2018/8/21.
 */
@LuaClass(isStatic = true, isSingleton = true)
public class LTPreferenceUtils {
    public static final String LUA_CLASS_NAME = "PreferenceUtils";
    protected static final String PREFERENCE_NAME = "MLS_PREFERENCE";

    //<editor-fold desc="API">
    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(name = "action", value = String.class),
                    @LuaBridge.Type(name = "key", value = String.class),
                    })
    })
    public static void save(Globals g, String key, String value) {
        savePreference(g, key, value);
    }

    @LuaBridge(value = {
            @LuaBridge.Func(name = "get", params = {
                    @LuaBridge.Type(name = "key", value = String.class),
                    @LuaBridge.Type(name = "devaultValue", value = String.class),
            }, returns = @LuaBridge.Type(String.class))
    })
    public static String get(Globals g, String key, String devaultValue) {
        return getPreference(g, key, devaultValue);
    }
    //</editor-fold>

    private static void savePreference(Globals g, String k, String v) {
        SharedPreferences.Editor e = getEditor(g);
        e.putString(k, v);
        e.apply();
    }

    private static String getPreference(Globals g, String k, String dv) {
        return getPreferences(g).getString(k, dv);
    }

    private static SharedPreferences getPreferences(Globals g) {
        return ((LuaViewManager) g.getJavaUserdata()).context.getSharedPreferences(PREFERENCE_NAME, Context.MODE_PRIVATE);
    }

    private static SharedPreferences.Editor getEditor(Globals g) {
        return getPreferences(g).edit();
    }
}