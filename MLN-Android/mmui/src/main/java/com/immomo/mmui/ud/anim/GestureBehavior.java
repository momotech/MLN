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

/**
 * Created by Xiong.Fangyu on 2020/7/24
 */
public class GestureBehavior extends BaseGestureBehavior {
    /**
     * @see InteractiveDirection#X
     * @see InteractiveDirection#Y
     */
    private int direction;
    /**
     * 是否在2个方向上跟随手势
     */
    private boolean followAll = true;

    private float targetTranslationX;
    private float targetTranslationY;
    private float downX;
    private float downY;
    private float preX;
    private float preY;

    private float lastDistance = 0;

    private VelocityTracker vTracker;

    public int getDirection() {
        return direction;
    }

    public void setDirection(int direction) {
        this.direction = direction;
    }

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
                preX = downX = x;
                preY = downY = y;
                touchType = TouchType.BEGIN;
                if (vTracker != null) {
                    vTracker.clear();
                    vTracker.addMovement(event);
                }
                if (followEnable) {
                    targetTranslationX = targetView.getTranslationX();
                    targetTranslationY = targetView.getTranslationY();
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
                if (vTracker != null)
                    vTracker.recycle();
                vTracker = null;
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
            targetView.setTranslationX(transX);
            targetView.setTranslationY(transY);
        }
        if (callback != null) {
            callback.callback(touchType, DimenUtil.pxToDpi(delta), DimenUtil.pxToDpi(velocity));
        }
        if (!innerPercentBehaviors.isEmpty()) {
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
            update((float) (dis / endDistance));
            lastDistance = dis;
        }
        return true;
    }

    @Override
    public void setAnimation(UDBaseAnimation oa) {
        super.setAnimation(oa);
        followAll = followAll && !animatable.hasTranslate();
    }
}