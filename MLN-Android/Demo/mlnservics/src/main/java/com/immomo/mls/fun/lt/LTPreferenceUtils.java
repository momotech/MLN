package com.immomo.mls.fun.lt;

import android.content.Context;
import android.content.SharedPreferences;

import com.immomo.mls.LuaViewManager;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;

/**
 * Created by XiongFangyu on 2018/8/21.
 */
@LuaClass(isStatic = true)
public class LTPreferenceUtils {
    public static final String LUA_CLASS_NAME = "PreferenceUtils";
    protected static final String PREFERENCE_NAME = "MLS_PREFERENCE";

    //<editor-fold desc="API">
    @LuaBridge
    public static void save(Globals g, String key, String value) {
        savePreference(g, key, value);
    }

    @LuaBridge
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
