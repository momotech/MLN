/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.utils;

import android.os.SystemClock;
import android.view.MotionEvent;
import android.view.View;

/**
 * Created by XiongFangyu on 2018/6/28.
 */
public class TouchMoveListener implements View.OnTouchListener {
    private static final long MIN_MOVE_TIME = 150;

    private float initX;
    private float initY;
    private float downX;
    private float downY;

    private long downTime;

    private boolean performClick;
    private View moveView;

    public TouchMoveListener() {}

    public TouchMoveListener(boolean performClick) {
        this.performClick = performClick;
    }

    public TouchMoveListener(View moveView) {
        this.moveView = moveView;
    }

    public TouchMoveListener(View moveView, boolean performClick) {
        this.moveView = moveView;
        this.performClick = performClick;
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                v = moveView == null ? v : moveView;
                initX = v.getTranslationX();
                initY = v.getTranslationY();
                downX = event.getRawX();
                downY = event.getRawY();
                downTime = now();
                break;
            case MotionEvent.ACTION_MOVE:
                v = moveView == null ? v : moveView;
                final float x = event.getRawX() - downX;
                final float y = event.getRawY() - downY;
                v.setTranslationX(x + initX);
                v.setTranslationY(y + initY);
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if (performClick) {
                    if (now() - downTime <= MIN_MOVE_TIME) {
                        v.performClick();
                    }
                }
                return false;
        }
        return true;
    }

    private long now() {
        return SystemClock.uptimeMillis();
    }
}