/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.globals;

import android.content.Context;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;

import com.immomo.mls.fun.ui.LuaViewGroup;
import com.immomo.mls.global.ScriptLoader;
import com.immomo.mls.utils.KeyboardUtil;
import com.immomo.mls.wrapper.ScriptBundle;

import java.util.Map;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class LuaView extends LuaViewGroup<UDLuaView> {

    private ViewTreeObserver.OnGlobalLayoutListener globalLayoutListener;

    public boolean sizeChangeEnable = false;

    //<editor-fold desc="创建方法">
    public LuaView(Context context, UDLuaView userdata) {
        super(context, userdata);
    }
    //</editor-fold>

    //<editor-fold desc="Public">

    public void putExtras(Map extra) {
        getUserdata().putExtras(extra);
    }

    public void sizeChangeEnable(boolean sizeChangeEnable) {
        this.sizeChangeEnable = sizeChangeEnable;
    }
    //</editor-fold>

    //<editor-fold desc="View">
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        if (w == oldw && h == oldh)
            return;
        if (userdata.callSizeChanged(w, h) || !sizeChangeEnable)
            return;
        int c = getChildCount();
        for (int i = 0; i < c; i++) {
            View child = getChildAt(i);
            boolean changed = false;
            if (child.getWidth() == oldw) {
                child.getLayoutParams().width = w;
                changed = true;
            }
            if (child.getHeight() == oldh) {
                child.getLayoutParams().height = h;
                changed = true;
            }
            if (changed) {
                child.requestLayout();
            }
        }
    }

    /**
     * 创建的时候调用
     */
    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
    }

    /**
     * 离开的时候调用
     */
    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeKeyboardChangeListener();
    }

    public void setKeyboardChangeListener() {
        if (globalLayoutListener == null) {
            globalLayoutListener = KeyboardUtil.attach(this, getUserdata());
        }
    }

    public void removeKeyboardChangeListener() {
        if (globalLayoutListener != null) {
            KeyboardUtil.detach(this, globalLayoutListener);
            globalLayoutListener = null;
        }
    }
    //</editor-fold>

    //<editor-fold desc="生命周期">
    public void onResume() {
        UDLuaView ud = getUserdata();
        if (ud != null) {
            ud.getGlobals().setRunning(true);
            ud.callbackAppear();
        }
    }

    public void onPause() {
        UDLuaView ud = getUserdata();
        if (ud != null) {
            ud.getGlobals().setRunning(false);
            ud.callbackDisappear();
        }
    }

    public void dispatchKeyEventSelf(KeyEvent event) {

        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
            UDLuaView ud = getUserdata();
            if (ud != null)
                ud.callBackKeyPressed();
        }
    }

    public boolean getBackKeyEnabled() {
        UDLuaView ud = getUserdata();
        if (ud != null)
            return ud.getBackKeyEnabled();

        return true;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        return super.dispatchTouchEvent(ev);
    }

    /**
     * 销毁的时候从外部调用，清空所有外部引用
     */
    public void onDestroy() {
        UDLuaView ud = getUserdata();
        if (ud != null)
            ud.callDestroy();
    }
    //</editor-fold>
}