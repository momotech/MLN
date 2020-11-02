/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.globals;

import android.content.Context;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;

import com.facebook.yoga.YogaFlexDirection;
import com.immomo.mmui.keyboard.MMUIKeyboardUtil;
import com.immomo.mmui.ud.UDView;
import com.immomo.mmui.ui.LuaNodeLayout;

import java.util.HashSet;
import java.util.Map;

/**
 * Created by XiongFangyu on 2018/8/1.
 */
public class LuaView extends LuaNodeLayout<UDLuaView> {

    private ViewTreeObserver.OnGlobalLayoutListener globalLayoutListener;

    public boolean sizeChangeEnable = false;
    public boolean needRequstLayout;

    //<editor-fold desc="创建方法">


    public LuaView(Context context, UDLuaView userdata) {
        super(context, userdata);
        getFlexNode().setFlexDirection(YogaFlexDirection.COLUMN);
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
            globalLayoutListener = MMUIKeyboardUtil.attach(this, getUserdata());
        }
    }

    public void removeKeyboardChangeListener() {
        if (globalLayoutListener != null) {
            MMUIKeyboardUtil.detach(this, globalLayoutListener);
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

            if(needRequstLayout){
                requestLayout();
                needRequstLayout=false;
            }
        }
    }

    public void onPause() {
        UDLuaView ud = getUserdata();
        if (ud != null) {
            ud.getGlobals().setRunning(false);
            ud.callbackDisappear();

            if(globalLayoutListener!=null && ud.getKeyboardViewCache()!=null){
                needRequstLayout = true;
            }
        }
    }

    public void dispatchKeyEventSelf(KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
            if (event.getAction() == KeyEvent.ACTION_UP) {
                UDLuaView ud = getUserdata();
                if (ud != null)
                    ud.callBackKeyPressed();
            }
        }
    }

    public boolean getBackKeyEnabled() {
        UDLuaView ud = getUserdata();
        if (ud != null)
            return ud.isBackKeyEnabled();

        return true;
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        HashSet<UDView> cacheSet = getUserdata().getKeyboardViewCache();
        if (getUserdata().isKeyboardShowing() && cacheSet != null) {
            for (UDView view : cacheSet) {
                final int actionIndex = ev.getActionIndex(); // always 0 for down
                final float x = ev.getX(actionIndex);
                final float y = ev.getY(actionIndex);

                final int[] offsetIntWindow = getTempPoint();
                boolean inView = pointInViewAndGetOffset(view.getView(), x, y, offsetIntWindow);
                if (inView) {//判断触摸，是否在view上
                    //获取了view，相对window的位置。方法ev前，设置offset
                    final float offsetX = getScrollX() - offsetIntWindow[0];
                    final float offsetY = getScrollY() - offsetIntWindow[1];
                    ev.offsetLocation(offsetX, offsetY);

                    boolean handled = view.getView().dispatchTouchEvent(ev);
                    //恢复ev的offset
                    ev.offsetLocation(-offsetX, -offsetY);
                    if (handled) {//如果消费了，就return
                        return handled;
                    }
                }
            }
        }

        return super.dispatchTouchEvent(ev);
    }

    // Lazily-created holder for point computations.


    private int[] mTempPoint;

    private int[] getTempPoint() {
        if (mTempPoint == null) {
            mTempPoint = new int[2];
        }
        return mTempPoint;
    }

    /**
     * @return 坐标点是否在view范围内
     * @paramview 目标view
     * @parampoints 坐标点(x, y)
     */
    /**
     * @return 坐标点是否在view范围内
     * @paramview 目标view
     * @parampoints 坐标点(x, y)
     */
    private boolean pointInViewAndGetOffset(View view, float x, float y, final int[] pointsInt) {
        getLocationInWindow(pointsInt);
        int winowLeft = pointsInt[0];
        int winowTop = pointsInt[1];

        view.getLocationInWindow(pointsInt);
        int left = pointsInt[0];
        int top = pointsInt[1];

        // 把view，相对window的offset，缓存在pointsInt, 返回给外层处理
        pointsInt[0] = left - winowLeft;
        pointsInt[1] = top - winowTop;

        // 像ViewGroup那样，先对齐一下Left和Top
        float localX = x - pointsInt[0];
        float localy = y - pointsInt[1];

        //判断坐标点是否在view范围内
        return localX >= 0 && localy >= 0 && localX < view.getWidth() && localy < view.getHeight();
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