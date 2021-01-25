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
import android.content.Intent;
import android.content.res.TypedArray;
import android.os.Bundle;
import android.os.Parcelable;
import android.text.TextUtils;

import com.immomo.mls.Constants;
import com.immomo.mls.DefaultOnActivityResultListener;
import com.immomo.mls.InitData;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.MLSBundleUtils;
import com.immomo.mls.OnActivityResultListener;
import com.immomo.mls.R;
import com.immomo.mls.activity.LuaViewActivity;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.constants.NavigatorAnimType;
import com.immomo.mls.util.FileUtil;
import com.immomo.mls.util.RelativePathUtils;
import com.immomo.mls.wrapper.callback.IVoidCallback;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaValue;

import java.io.File;
import java.io.Serializable;
import java.util.HashMap;
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

    protected Globals globals;
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
        internalGotoPage(action, params, animType);
    }

    @LuaBridge
    public void gotoAndCloseSelf(String action, Map params, @AnimType int animType) {
        closeSelf(animType);
        internalGotoPage(action, params, animType);
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
    public void gotoAndGetResult(String action, Map params, @AnimType int animType, LuaFunction callback) {
        OnActivityResultListener l = new DefaultOnActivityResultListener(callback);
        int requestCode = generateRequestCode();
        saveListener(requestCode, l);
        internalGotoPage(action, parseBundle(params), animType, requestCode);
    }
    //</editor-fold>

    protected void internalGotoPage(String action, Bundle bundle, @AnimType int at) {

    }

    protected void internalGotoPage(String action, Map params, @AnimType int animType) {
        if (TextUtils.isEmpty(action)) {
            return;
        }
        if (!action.endsWith(Constants.POSTFIX_LUA)) {
            action = action + Constants.POSTFIX_LUA;
        }
        if (RelativePathUtils.isLocalUrl(action)) {//相对路径转化
            if (!action.startsWith(Constants.ASSETS_PREFIX)) {//Android的asset目录，不作为相对路径
                action = RelativePathUtils.getAbsoluteUrl(action);
            }
        } else if (RelativePathUtils.isAssetUrl(action)) {
            action = Constants.ASSETS_PREFIX + RelativePathUtils.getAbsoluteAssetUrl(action);
        } else if (!action.startsWith("http")) {//绝对路径、单文件名，判断后缀
            String localUrl = ((LuaViewManager) globals.getJavaUserdata()).baseFilePath;
            File entryFile = new File(localUrl, action);//入口文件路径
            if (entryFile.exists()) {
                action = entryFile.getAbsolutePath();
            }
        }

        Activity a = getActivity();
        Intent intent = new Intent(a, LuaViewActivity.class);
        InitData initData = MLSBundleUtils.createInitData(action);
        if (initData.extras == null) {
            initData.extras = new HashMap();
        }
        initData.extras.putAll(params);
        intent.putExtras(MLSBundleUtils.createBundle(initData));
        if (a != null) {
            a.startActivity(intent);
            a.overridePendingTransition(parseInAnim(animType), parseOutAnim(animType));
        }
    }

    protected void internalGotoPage(String action, Bundle bundle, @AnimType int at, int requestCode) {
    }

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

    protected int getActivityOpenExitAnimation() {
        Activity a = getActivity();
        if (a == null)
            return 0;
        TypedArray ta = a.obtainStyledAttributes(new int[] {android.R.attr.activityOpenExitAnimation});
        int out = ta.getResourceId(0, 0);
        ta.recycle();
        return out;
    }

    protected int parseInAnim(int type) {
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

    protected int parseOutAnim(int type) {
        switch (type) {
            case LeftToRight:
                return R.anim.lv_slide_out_right;
            case RightToLeft:
                return R.anim.lv_slide_out_left;
            case TopToBottom:
                return R.anim.lv_slide_out_bottom;
            case BottomToTop:
                return R.anim.lv_slide_out_top;
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