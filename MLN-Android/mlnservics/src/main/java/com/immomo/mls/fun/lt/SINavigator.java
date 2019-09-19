/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.lt;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Parcelable;

import com.immomo.mls.Constants;
import com.immomo.mls.DefaultOnActivityResultListener;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.OnActivityResultListener;
import com.immomo.mls.R;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.constants.NavigatorAnimType;
import com.immomo.mls.wrapper.callback.IVoidCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.IGlobalsUserdata;

import java.io.File;
import java.io.Serializable;
import java.util.Map;
import java.util.Set;

import androidx.annotation.Nullable;

/**
 * Created by XiongFangyu on 2018/8/13.
 */
@LuaClass
public class SINavigator implements NavigatorAnimType {
    public static final String LUA_CLASS_NAME = "Navigator";

    private int requestCode = Integer.MAX_VALUE;

    private Globals globals;
    public SINavigator(Globals g, LuaValue[] init) {
        globals = g;
    }

    //<editor-fold desc="API">

    /**
     * 跳转当前url的新页面，测试用，iOS未同步
     */
    @LuaBridge
    public void gotoCurrentPage(String entryFile, Map params, @AnimType int at) {
        LuaViewManager lm = (LuaViewManager) globals.getJavaUserdata();
        if (lm == null) return;

        File f = new File(lm.baseFilePath, entryFile + Constants.POSTFIX_LUA);
        internalGotoPage(f.getAbsolutePath(), parseBundle(params), at);
    }

    @LuaBridge
    public void gotoPage(String action, Map params, @AnimType int animType) {
        internalGotoPage(action, parseBundle(params), animType);
    }

    @LuaBridge
    public void gotoAndCloseSelf(String action, Map params, @AnimType int animType) {
        closeSelf(animType);
        internalGotoPage(action, parseBundle(params), animType);
    }

    @LuaBridge
    public void closeSelf(@AnimType int animType) {
        Activity a = getActivity();
        if (a == null)
            return;
        a.finish();
        int anim = parseOutAnim(animType);
        if (anim != Default) {
            a.overridePendingTransition(0, anim);
        }
    }

    /**
     * Android 测试接口
     * 进入新页面，并获取结果
     */
    @LuaBridge
    public void gotoAndGetResult(String action, Map params, @AnimType int animType, IVoidCallback callback) {
        OnActivityResultListener l = new DefaultOnActivityResultListener(callback);
        int requestCode = generateRequestCode();
        saveListener(requestCode, l);
        internalGotoPage(action, parseBundle(params), animType, requestCode);
    }
    //</editor-fold>

    protected void internalGotoPage(String action, Bundle bundle, @AnimType int at) {}

    protected void internalGotoPage(String action, Bundle bundle, @AnimType int at, int requestCode) { }

    protected int generateRequestCode() {
        return --requestCode;
    }

    protected boolean saveListener(int c, OnActivityResultListener l) {
        LuaViewManager lvm = (LuaViewManager) globals.getJavaUserdata();
        if (lvm != null) {
            lvm.putOnActivityResultListener(c, l);
            return true;
        }
        return false;
    }

    protected Bundle parseBundle(Map map) {
        if (map == null)
            return null;
        Set<Map.Entry> entrySet = map.entrySet();
        Bundle ret = new Bundle();
        for (Map.Entry e : entrySet) {
            Object k = e.getKey();
            if (k == null)
                continue;
            Object v = e.getValue();
            if (v == null)
                continue;
            putObject(ret, k.toString(), v);
        }
        return ret;
    }

    protected @Nullable Context getContext() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }

    protected @Nullable
    Activity getActivity() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        Context c = m != null ? m.context : null;
        return c instanceof Activity ? (Activity) c : null;
    }

    protected static int parseInAnim(int type) {
        switch (type) {
            case LeftToRight:
                return R.anim.lv_slide_in_left;
            case RightToLeft:
                return R.anim.lv_slide_in_right;
            case TopToBottom:
                return R.anim.lv_slide_in_top;
            case BottomToTop:
                return R.anim.lv_slide_in_bottom;
            case Scale:
                return R.anim.lv_scale_in;
            case Fade:
                return R.anim.lv_fade_in;
            default:
                return 0;
        }
    }

    protected static int parseOutAnim(int type) {
        switch (type) {
            case LeftToRight:
                return R.anim.lv_slide_out_left;
            case RightToLeft:
                return R.anim.lv_slide_out_right;
            case TopToBottom:
                return R.anim.lv_slide_out_top;
            case BottomToTop:
                return R.anim.lv_slide_out_bottom;
            case Scale:
                return R.anim.lv_scale_out;
            case Fade:
                return R.anim.lv_fade_out;
            default:
                return 0;
        }
    }

    private static void putObject(Bundle bundle, String key, Object value) {
        if (value instanceof Integer) {
            bundle.putInt(key, (Integer) value);
        } else if (value instanceof Long) {
            bundle.putLong(key, (Long) value);
        } else if (value instanceof Float) {
            bundle.putFloat(key, (Float) value);
        } else if (value instanceof Double) {
            bundle.putDouble(key, (Double) value);
        } else if (value instanceof String) {
            bundle.putString(key, value.toString());
        } else if (value instanceof Parcelable) {
            bundle.putParcelable(key, (Parcelable) value);
        } else if (value instanceof Serializable) {
            bundle.putSerializable(key, (Serializable) value);
        }
    }
}