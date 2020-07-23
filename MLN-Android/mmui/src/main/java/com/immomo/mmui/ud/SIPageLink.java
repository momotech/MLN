/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Parcelable;
import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.immomo.mls.DefaultOnActivityResultListener;
import com.immomo.mls.LuaViewManager;
import com.immomo.mls.OnActivityResultListener;
import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.fun.constants.NavigatorAnimType;
import com.immomo.mls.util.RelativePathUtils;
import com.immomo.mls.wrapper.callback.IVoidCallback;
import com.immomo.mmui.MMUILinkRegister;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;

import java.io.File;
import java.io.Serializable;
import java.util.Map;
import java.util.Set;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-06-07 17:11
 */
@LuaClass
public class SIPageLink {
    public static final String LUA_CLASS_NAME = "Link";
    private final String ASSETS_PREFIX = "file://android_asset/";
    private final String LUA_SUFFIX = ".lua";
    private final String HTTP_PREFIX = "http";

    protected Globals globals;

    private int requestCode = Integer.MAX_VALUE;

    public SIPageLink(Globals g, LuaValue[] init) {
        globals = g;
    }

    /**
     * 跳转原生页面（纯原生，MLN—UI页面）
     * @param key activity 对应的key值
     * @param params 参数
     * @param animType 动画效果
     * @param callback 页面finish 回调
     */
    @LuaBridge
    public void link(String key, Map params, Integer animType, IVoidCallback callback) {
        if(!TextUtils.isEmpty(key)) {
            Intent intent = new Intent(getContext(), MMUILinkRegister.findActivity(key));
            Bundle bundle = parseBundle(params);
            if(bundle !=null) {
                intent.putExtras(bundle);
            }

            Activity currentActivity = getActivity();
            if(callback !=null) {
                OnActivityResultListener l = new DefaultOnActivityResultListener(callback);
                int requestCode = generateRequestCode();
                saveListener(requestCode, l);
                currentActivity.startActivityForResult(intent,requestCode);
            } else {
                currentActivity.startActivity(intent);
            }
            if(animType !=null) {
                currentActivity.overridePendingTransition(parseInAnim(animType), parseOutAnim(animType));
            } else {
                currentActivity.overridePendingTransition(parseInAnim(NavigatorAnimType.RightToLeft), parseOutAnim(NavigatorAnimType.RightToLeft));
            }
        }
    }

    protected int generateRequestCode() {
        return --requestCode;
    }


    /**
     * 保存监听
     * @param c
     * @param l
     * @return
     */
    protected boolean saveListener(int c, OnActivityResultListener l) {
        LuaViewManager lvm = (LuaViewManager) globals.getJavaUserdata();
        if (lvm != null) {
            lvm.putOnActivityResultListener(c, l);
            return true;
        }
        return false;
    }


    /**
     * 关闭页面
     * @param animType 动画效果
     */
    @LuaBridge
    public void close(Integer animType, Map params) {
        Activity a = getActivity();
        if (a == null)
            return;

        if(params !=null) {
            Intent intent = new Intent();
            Bundle bundle = parseBundle(params);
            intent.putExtras(bundle);
            a.setResult(Activity.RESULT_OK,intent);
        }

        a.finish();

        if(animType !=null) {
            a.overridePendingTransition(0, parseOutAnim(animType));
        } else {
            a.overridePendingTransition(0,parseOutAnim(NavigatorAnimType.LeftToRight));
        }

    }


    /**
     * 跳转lua页面
     * @param action lua文件
     * @param params 参数
     * @param animType 动画效果
     */
    @LuaBridge
    public void linkLua(String action, Map params, @NavigatorAnimType.AnimType int animType,final IVoidCallback callback) {
        if (TextUtils.isEmpty(action)) {
            return;
        }
        if (RelativePathUtils.isLocalUrl(action)) {//相对路径转化
            if (!action.endsWith(LUA_SUFFIX)) {
                action = action + LUA_SUFFIX;
            }
            if (!action.startsWith(ASSETS_PREFIX)) {//Android的asset目录，不作为相对路径
                action = RelativePathUtils.getAbsoluteUrl(action);
            }
        } else if (!action.startsWith(HTTP_PREFIX)) {//绝对路径、单文件名，判断后缀
            if (!action.endsWith(LUA_SUFFIX)) {
                action = action + LUA_SUFFIX;
            }
            String localUrl = ((LuaViewManager) globals.getJavaUserdata()).baseFilePath;
            File entryFile = new File(localUrl, action);
            if (entryFile.exists()) {
                action = entryFile.getAbsolutePath();
            }
        }
        Activity currentActivity = getActivity();

        if(callback !=null) {
            OnActivityResultListener l = new DefaultOnActivityResultListener(callback);
            int requestCode = generateRequestCode();
            saveListener(requestCode, l);
            gotoLuaPageForResult(action,params,requestCode);
        } else {
            gotoLuaPage(action,params);
        }

        currentActivity.overridePendingTransition(parseInAnim(animType), parseOutAnim(animType));

    }

    protected void gotoLuaPage(String action, Map params) {

    }


    protected void gotoLuaPageForResult(String action, Map params,int resultCode) {

    }


    // 测试使用，保证热重载不会报错
    @LuaBridge
    public void register(String key,String path) {

    }

    // 测试使用，保证热重载不会报错
    @LuaBridge
    public Map getParams() {
        return null;
    }

    /**
     * 解析打开动画
     * @param type
     * @return
     */
    protected int parseInAnim(int type) {
        switch (type) {
            case NavigatorAnimType.LeftToRight:
                return com.immomo.mls.R.anim.lv_slide_in_left;
            case NavigatorAnimType.RightToLeft:
                return com.immomo.mls.R.anim.lv_slide_in_right;
            case NavigatorAnimType.TopToBottom:
                return com.immomo.mls.R.anim.lv_slide_in_top;
            case NavigatorAnimType.BottomToTop:
                return com.immomo.mls.R.anim.lv_slide_in_bottom;
            case NavigatorAnimType.Scale:
                return com.immomo.mls.R.anim.lv_scale_in;
            case NavigatorAnimType.Fade:
                return com.immomo.mls.R.anim.lv_fade_in;
            default:
                return 0;
        }
    }

    /**
     * 解析关闭动画
     * @param type
     * @return
     */
    protected int parseOutAnim(int type) {
        switch (type) {
            case NavigatorAnimType.LeftToRight:
                return com.immomo.mls.R.anim.lv_slide_out_right;
            case NavigatorAnimType.RightToLeft:
                return com.immomo.mls.R.anim.lv_slide_out_left;
            case NavigatorAnimType.TopToBottom:
                return com.immomo.mls.R.anim.lv_slide_out_bottom;
            case NavigatorAnimType.BottomToTop:
                return com.immomo.mls.R.anim.lv_slide_out_top;
            case NavigatorAnimType.Scale:
                return com.immomo.mls.R.anim.lv_scale_out;
            case NavigatorAnimType.Fade:
                return com.immomo.mls.R.anim.lv_fade_out;
            default:
                return 0;
        }
    }

    protected @Nullable Context getContext() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }

    protected @Nullable Activity getActivity() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        Context c = m != null ? m.context : null;
        return c instanceof Activity ? (Activity) c : null;
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