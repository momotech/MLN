/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud.anim;

import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;

import androidx.annotation.NonNull;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.wrapper.callback.IVoidCallback;
import com.immomo.mmui.anim.animatable.Animatable;
import com.immomo.mmui.anim.animations.ObjectAnimation;
import com.immomo.mmui.ud.UDView;

import org.luaj.vm2.LuaValue;

/**
 * Created by MLN Template
 * 注册方法:
 * Register.newUDHolderWithLuaClass(UDInteractiveBehavior.LUA_CLASS_NAME, UDInteractiveBehavior.class, true)
 */
@LuaClass
public class UDInteractiveBehavior implements View.OnTouchListener {
    /**
     * Lua类型，Lua可由此创建对象:
     * local obj = InteractiveBehavior()
     */
    public static final String LUA_CLASS_NAME = "InteractiveBehavior";

    private int type = InteractiveType.GESTURE;

    @LuaBridge
    int direction;
    /**
     * 截止距离
     */
    @LuaBridge
    double endDistance;
    /**
     * 是否可越过边界
     */
    @LuaBridge
    boolean overBoundary;
    /**
     * 交互是否可被触发
     */
    @LuaBridge
    boolean enable;
    /**
     * targetView是否跟随手势,可用来实现跟手
     */
    @LuaBridge
    boolean followEnable;
    /**
     * function(TouchType type,number distance,numer velocity)
     */
    private IVoidCallback callback;

    private UDView targetView;

    private Animatable animatable;

    private float[] fromValues;
    private float[] toValues;
    private float[] values;

    private VelocityTracker vTracker;

    /**
     * Lua构造函数，不需要虚拟机及上下文环境
     * @param init 初始化参数
     */
    public UDInteractiveBehavior(@NonNull LuaValue[] init) {
        this.type = init[0].toInt();
    }

    //<editor-fold desc="Bridge API">
    @LuaBridge
    public void touchBlock(IVoidCallback callback) {
        this.callback = callback;
    }

    @LuaBridge
    public void targetView(UDView view) {
        this.targetView = view;
        view.addOnTouchListener(this);
    }
    //</editor-fold>

    private float targetTranslationX;
    private float targetTranslationY;
    private float downX;
    private float downY;

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        if (!enable)
            return false;
        if (endDistance == 0)
            return false;
        if (vTracker == null && callback != null)
            vTracker = VelocityTracker.obtain();

        float x = event.getRawX();
        float y = event.getRawY();
        int touchType = TouchType.BEGIN;
        float distance = 0;
        float velocity = 0;

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                downX = x;
                downY = y;
                touchType = TouchType.BEGIN;
                if (vTracker != null) {
                    vTracker.clear();
                    vTracker.addMovement(event);
                }
                if (followEnable) {
                    if (direction == InteractiveDirection.X)
                        targetTranslationY = targetView.getView().getTranslationY();
                    else
                        targetTranslationX = targetView.getView().getTranslationX();
                }
                break;
            case MotionEvent.ACTION_MOVE:
                if (vTracker != null) {
                    vTracker.addMovement(event);
                }
                touchType = TouchType.MOVE;
                if (direction == InteractiveDirection.X) {
                    distance = x - downX;
                    velocity = 0;
                    if (followEnable) {
                        targetView.getView().setTranslationY(y - downY + targetTranslationY);
                    }
                } else {
                    distance = y - downY;
                    velocity = 0;
                    if (followEnable) {
                        targetView.getView().setTranslationX(x - downX + targetTranslationX);
                    }
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if (vTracker != null) {
                    vTracker.addMovement(event);
                    vTracker.computeCurrentVelocity(1000);
                }
                touchType = TouchType.END;
                if (direction == InteractiveDirection.X) {
                    distance = x - downX;
                    velocity = vTracker != null ? vTracker.getXVelocity() : 0;
                    if (followEnable) {
                        targetView.getView().setTranslationY(y - downY + targetTranslationY);
                    }
                } else {
                    distance = y - downY;
                    velocity = vTracker != null ? vTracker.getYVelocity() : 0;
                    if (followEnable) {
                        targetView.getView().setTranslationX(x - downX + targetTranslationX);
                    }
                }
                break;
        }
        if (callback != null) {
            callback.callback(touchType, DimenUtil.pxToDpi(distance), DimenUtil.pxToDpi(velocity));
        }
        if (animatable != null) {
            fullValues(distance / DimenUtil.dpiToPx(endDistance));
            animatable.writeValue(targetView.getView(), values);
        }
        return true;
    }

    public void setAnimation(ObjectAnimation oa) {
        animatable = oa.getAnimatable();
        values = new float[animatable.getValuesCount()];
        fromValues = oa.getFromValue();
        toValues = oa.getToValue();
    }

    private void fullValues(float f) {
        if (!overBoundary) {
            f = f < 0 ? 0 : f;
            f = f > 1 ? 1 : f;
        }
        for (int l = values.length, i = 0; i < l;i ++) {
            values[i] = f * (toValues[i] - fromValues[i]) + fromValues[i];
        }
    }
    /**
     * Lua GC当前对象时调用，可不实现
     */
    void __onLuaGc() {
        targetView.removeOnTouchListener(this);
    }
}