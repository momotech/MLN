/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.gesture;

import android.view.MotionEvent;

import com.immomo.mmui.ud.UDView;

public class ArgoTouchUtil {

    private final static int CUSTOM_CREATE = Integer.MIN_VALUE + 1;

    /**
     * 重新生成事件流，寻找消费事件的view
     *
     * @param udView ud
     * @param event  事件
     */
    public static void resetTouchTarget(UDView udView, MotionEvent event) {
        resetTouchConfig(udView, event);
        if (udView.isTouchChange()) {
            if (udView.getDispatchDelay() == DispatchDelay.MultiFinger) {
                // 仅仅只在多指点击时，进行更改事件流传递
                if (event.getActionMasked() == MotionEvent.ACTION_POINTER_DOWN && !isCustomCreate(event)) {
                    udView.setTouchChange(false);
                    // 重新下派新的ACTION_DOWN，来寻求处理事件的view
                    MotionEvent obtain = MotionEvent.obtain(event);
                    obtain.setAction(MotionEvent.ACTION_DOWN);
                    obtain.setSource(CUSTOM_CREATE);
                    udView.getView().dispatchTouchEvent(obtain);
                    obtain.recycle();
                    // 要触发缩放，还要重新下派新的ACTION_POINTER_DOWN
                    MotionEvent pointer = MotionEvent.obtain(event);
                    pointer.setSource(CUSTOM_CREATE);
                    udView.getView().dispatchTouchEvent(pointer);
                    pointer.recycle();
                }
            } else {
                udView.setTouchChange(false);
                // 仅仅只在事件流过程中，进行更改事件流传递
                if (event.getActionMasked() == MotionEvent.ACTION_MOVE && !isCustomCreate(event)) {
                    // 重新下派新的ACTION_DOWN，来寻求处理事件的view
                    MotionEvent obtain = MotionEvent.obtain(event);
                    obtain.setAction(MotionEvent.ACTION_DOWN);
                    obtain.setSource(CUSTOM_CREATE);
                    udView.getView().dispatchTouchEvent(obtain);
                    obtain.recycle();
                    int count = event.getPointerCount();
                    for (int i = 1; i < count; i++) {
                        MotionEvent pointer = MotionEvent.obtain(event);
                        pointer.setAction((event.getPointerId(i) << MotionEvent.ACTION_POINTER_INDEX_SHIFT) | MotionEvent.ACTION_POINTER_DOWN);
                        pointer.setSource(CUSTOM_CREATE); // 目前没有重新设置每个POINTER的坐标
                        udView.getView().dispatchTouchEvent(pointer);
                        pointer.recycle();
                    }
                }
            }
        }
    }

    /**
     * 判断是否是用户自己生成的event
     */
    public static boolean isCustomCreate(MotionEvent event) {
        return event.getSource() == CUSTOM_CREATE;
    }

    /**
     * 重置事件流控制相关变量
     */
    private static void resetTouchConfig(UDView udView, MotionEvent event) {
        // 当遇到系统下派的down事件，重置事件流控制相关变量
        if (event.getActionMasked() == MotionEvent.ACTION_DOWN && !isCustomCreate(event)) {
            udView.setTouchChange(false);
            udView.setDispatchDelay(DispatchDelay.Default);
        }
    }
}
