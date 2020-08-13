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

import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.TouchableView;
import com.immomo.mmui.anim.animatable.Animatable;
import com.immomo.mmui.anim.animations.ObjectAnimation;

/**
 * Created by Xiong.Fangyu on 2020/7/24
 */
public class GestureBehavior implements View.OnTouchListener {
    /**
     * @see InteractiveDirection#X
     * @see InteractiveDirection#Y
     */
    public int direction;
    /**
     * 截止距离
     */
    private double endDistance;
    /**
     * 是否可越过边界
     */
    public boolean overBoundary;
    /**
     * 交互是否可被触发
     */
    public boolean enable;
    /**
     * targetView是否跟随手势,可用来实现跟手
     */
    public boolean followEnable;
    /**
     * function(TouchType type,number distance,numer velocity)
     */
    public InteractiveBehaviorCallback callback;

    private TouchableView targetView;

    private Animatable animatable;
    /**
     * 是否在2个方向上跟随手势
     */
    private boolean followAll = true;

    private float[] fromValues;
    private float[] toValues;
    private float[] values;
    private float lastDistance = 0;
    private float minPercent = Float.NaN;
    private float maxPercent = Float.NaN;
    private float minDistance = Float.NaN;
    private float maxDistance = Float.NaN;

    private VelocityTracker vTracker;

    //<editor-fold desc="Bridge API">
    public void targetView(TouchableView view) {
        this.targetView = view;
        view.addOnTouchListener(this);
    }

    public double getEndDistance() {
        return endDistance;
    }

    public void setEndDistance(double endDistance) {
        this.endDistance = endDistance;
        if (!Float.isNaN(minPercent)) {
            minDistance = (float) (minPercent * endDistance);
        }
        if (!Float.isNaN(maxPercent)) {
            maxDistance = (float) (maxPercent * endDistance);
        }
    }
    //</editor-fold>

    private float targetTranslationX;
    private float targetTranslationY;
    private float downX;
    private float downY;
    private float preX;
    private float preY;

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
        float delta = 0;
        float velocity = 0;

        int action = event.getAction();
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                lastDistance = 0;
                preX = downX = x;
                preY = downY = y;
                touchType = TouchType.BEGIN;
                if (vTracker != null) {
                    vTracker.clear();
                    vTracker.addMovement(event);
                }
                if (followEnable) {
                    targetTranslationX = v.getTranslationX();
                    targetTranslationY = v.getTranslationY();
                }
                break;
            case MotionEvent.ACTION_MOVE:
                if (vTracker != null) {
                    vTracker.addMovement(event);
                }
                touchType = TouchType.MOVE;
                if (direction == InteractiveDirection.X) {
                    delta = x - preX;
                    velocity = 0;
                } else {
                    delta = y - preY;
                    velocity = 0;
                }
                preX = x;
                preY = y;
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if (vTracker != null) {
                    vTracker.addMovement(event);
                    vTracker.computeCurrentVelocity(1000);
                }
                touchType = TouchType.END;
                if (direction == InteractiveDirection.X) {
                    delta = x - preX;
                    velocity = vTracker != null ? vTracker.getXVelocity() : 0;
                } else {
                    delta = y - preY;
                    velocity = vTracker != null ? vTracker.getYVelocity() : 0;
                }
                break;
        }
        if (followEnable) {
            float transX, transY;
            transX = x - downX + targetTranslationX;
            transY = y - downY + targetTranslationY;
            if (!followAll) {
                if (direction == InteractiveDirection.X) {
                    transX = targetTranslationX;
                } else {
                    transY = targetTranslationY;
                }
            }
            v.setTranslationX(transX);
            v.setTranslationY(transY);
        }
        if (callback != null) {
            callback.callback(touchType, DimenUtil.pxToDpi(delta), DimenUtil.pxToDpi(velocity));
        }
        if (animatable != null) {
            float dis = lastDistance + delta;
            if (!Float.isNaN(minDistance)) {
                dis = dis < minDistance ? minDistance : dis;
            }
            if (!Float.isNaN(maxDistance)) {
                dis = dis > maxDistance ? maxDistance : dis;
            }
            if (!overBoundary) {
                dis = dis < 0 ? 0 : dis;
                dis = dis > endDistance ? (float) endDistance : dis;
            }
            fullValues((float) (dis / endDistance));
            animatable.writeValue(v, values);
            lastDistance = dis;
        }
        return true;
    }

    public void setAnimation(ObjectAnimation oa) {
        animatable = oa.getAnimatable();
        followAll = !animatable.hasTranslate();
        values = new float[animatable.getValuesCount()];
        fromValues = oa.getFromValue();
        toValues = oa.getToValue();
        initLimit();
    }

    private void initLimit() {
        if (animatable == null || fromValues == null || toValues == null)
            return;
        float[] values = animatable.getMaxValues();
        if (values != null) {
            for (int l = values.length, i = 0; i < l; i++) {
                float v = values[i];
                if (Float.isNaN(v))
                    continue;
                float p = (v - fromValues[i]) / (toValues[i] - fromValues[i]);
                if (Float.isNaN(maxPercent))
                    maxPercent = p;
                else
                    maxPercent = p > maxPercent ? p : maxPercent;
            }
        }

        values = animatable.getMinValues();
        if (values != null) {
            for (int l = values.length, i = 0; i < l; i++) {
                float v = values[i];
                if (Float.isNaN(v))
                    continue;
                float p = (v - fromValues[i]) / (toValues[i] - fromValues[i]);
                if (Float.isNaN(minPercent))
                    minPercent = p;
                else
                    minPercent = p < minPercent ? p : minPercent;
            }
        }

        if (endDistance != 0) {
            setEndDistance(endDistance);
        }
    }

    private void fullValues(float f) {
        for (int l = values.length, i = 0; i < l;i ++) {
            values[i] = f * (toValues[i] - fromValues[i]) + fromValues[i];
        }
    }
    /**
     * Lua GC当前对象时调用，可不实现
     */
    public void __onLuaGc() {
        targetView.removeOnTouchListener(this);
    }
}