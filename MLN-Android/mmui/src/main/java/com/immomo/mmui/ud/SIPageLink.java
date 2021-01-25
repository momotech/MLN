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
import com.immomo.mls.fun.constants.NavigatorAnimType;
import com.immomo.mls.util.RelativePathUtils;
import com.immomo.mls.utils.convert.SmartTableConvert;
import com.immomo.mmui.MMUILinkRegister;

import org.luaj.vm2.LuaFunction;
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaUserdata;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

import java.io.File;
import java.io.Serializable;

import static com.immomo.mls.Constants.ASSETS_PREFIX;

/**
 * Description:
 * Author: xuejingfei
 * E-mail: xue.jingfei@immomo.com
 * Date: 2020-06-07 17:11
 */
@LuaApiUsed
public class SIPageLink extends LuaUserdata<Object> {
    public static final String LUA_CLASS_NAME = "__Link";
    private final String LUA_SUFFIX = ".lua";
    private final String HTTP_PREFIX = "http";

    private int requestCode = 0;

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    public SIPageLink(long L) {
        super(L, null);
    }

    //<editor-fold desc="native method">
    /**
     * 初始化方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>

    //<editor-fold desc="api">
    @LuaApiUsed
    public void link(String key, LuaValue params) {
        Intent intent = parseIntent(key, params);
        if (intent == null)
            return;
        Activity cur = getActivity();
        if (cur == null)
            return;
        cur.startActivity(intent);
        cur.overridePendingTransition(parseInAnim(NavigatorAnimType.RightToLeft),
                parseOutAnim(NavigatorAnimType.RightToLeft));
    }

    @LuaApiUsed
    public void link(String key, LuaValue params, int animType) {
        link(key, params, animType, null);
    }

    /**
     * 跳转原生页面（纯原生，MLN—UI页面）
     *
     * @param key      activity 对应的key值
     * @param params   参数
     * @param animType 动画效果
     * @param callback 页面finish 回调
     */
    @LuaApiUsed
    public void link(String key, LuaValue params, int animType, LuaFunction callback) {
        Intent intent = parseIntent(key, params);
        if (intent == null)
            return;
        Activity cur = getActivity();
        if (cur == null)
            return;
        if (callback != null) {
            OnActivityResultListener l = new DefaultOnActivityResultListener(callback);
            int requestCode = generateRequestCode();
            saveListener(requestCode, l);
            cur.startActivityForResult(intent, requestCode);
        } else {
            cur.startActivity(intent);
        }
        cur.overridePendingTransition(parseInAnim(animType), parseOutAnim(animType));
    }

    @LuaApiUsed
    public void close() {
        Activity a = getActivity();
        if (a == null)
            return;
        a.finish();
        a.overridePendingTransition(0, parseOutAnim(NavigatorAnimType.LeftToRight));
    }

    @LuaApiUsed
    public void close(int animType) {
        close(animType, null);
    }

    /**
     * 关闭页面
     *
     * @param animType 动画效果
     */
    @LuaApiUsed
    public void close(int animType, LuaValue params) {
        Activity a = getActivity();
        if (a == null)
            return;

        if (params != null) {
            Intent intent = new Intent();
            Bundle bundle = parseBundle(params);
            intent.putExtras(bundle);
            a.setResult(Activity.RESULT_OK, intent);
        }

        a.finish();
        a.overridePendingTransition(0, parseOutAnim(animType));
    }

    /**
     * 跳转lua页面
     *
     * @param action   lua文件
     * @param params   参数
     * @param animType 动画效果
     */
    @LuaApiUsed
    public void linkLua(String action, LuaValue params, int animType, final LuaFunction callback) {
        if (TextUtils.isEmpty(action)) {
            return;
        }
        Activity currentActivity = getActivity();
        if (currentActivity == null)
            return;
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
        if (callback != null) {
            OnActivityResultListener l = new DefaultOnActivityResultListener(callback);
            int requestCode = generateRequestCode();
            saveListener(requestCode, l);
            gotoLuaPageForResult(action, params, requestCode);
        } else {
            gotoLuaPage(action, params);
        }
        currentActivity.overridePendingTransition(parseInAnim(animType), parseOutAnim(animType));
    }

    // 测试使用，保证热重载不会报错
    @LuaApiUsed
    public void register(String key, String path) {

    }

    // 测试使用，保证热重载不会报错
    @LuaApiUsed
    public LuaValue getParams() {
        return null;
    }
    //</editor-fold>

    protected Intent parseIntent(String key, LuaValue params) {
        if (TextUtils.isEmpty(key))
            return null;
        Context c = getContext();
        if (c == null)
            return null;
        Intent intent = new Intent(c, MMUILinkRegister.findActivity(key));
        Bundle bundle = parseBundle(params);
        if (bundle != null) {
            intent.putExtras(bundle);
        }
        return intent;
    }

    protected int generateRequestCode() {
        return ++requestCode;
    }

    /**
     * 保存监听
     *
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

    protected void gotoLuaPage(String action, LuaValue params) {

    }


    protected void gotoLuaPageForResult(String action, LuaValue params, int resultCode) {

    }

    /**
     * 解析打开动画
     *
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
     *
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

    protected @Nullable
    Context getContext() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        return m != null ? m.context : null;
    }

    protected @Nullable
    Activity getActivity() {
        LuaViewManager m = (LuaViewManager) globals.getJavaUserdata();
        Context c = m != null ? m.context : null;
        return c instanceof Activity ? (Activity) c : null;
    }

    protected Bundle parseBundle(LuaValue table) {
        if (table == null || table.isNil())
            return null;
        LuaTable t = table.toLuaTable();
        if (!t.startTraverseTable()) {
            return null;
        }
        Bundle ret = new Bundle();
        LuaValue[] nexts;
        while ((nexts = t.next()) != null) {
            String k = nexts[0].toJavaString();
            LuaValue v = nexts[1];
            if (v.isNil())
                continue;
            if (v.isBoolean()) {
                ret.putBoolean(k, v.toBoolean());
            } else if (v.isNumber()) {
                double d = v.toDouble();
                if (d == (int) d) {
                    ret.putInt(k, (int) d);
                } else if (d == (long) d) {
                    ret.putLong(k, (long) d);
                } else if (d == (float) d) {
                    ret.putFloat(k, (float) d);
                } else {
                    ret.putDouble(k, d);
                }
            } else if (v.isString()) {
                ret.putString(k, v.toJavaString());
            } else if (v.isTable()) {
                LuaTable vt = v.toLuaTable();
                if (vt.getn() > 0) {
                    ret.putSerializable(k, (Serializable) SmartTableConvert.toList(vt));
                } else if (!vt.isEmpty()) {
                    ret.putSerializable(k, (Serializable) SmartTableConvert.toMap(vt));
                } else {
                    vt.destroy();
                }
            } else if (v.isUserdata()) {
                Object ud = v.toUserdata().getJavaUserdata();
                if (ud instanceof Parcelable) {
                    ret.putParcelable(k, (Parcelable) ud);
                } else if (ud instanceof Serializable) {
                    ret.putSerializable(k, (Serializable) ud);
                }
            }
        }
        return ret;
    }
}