/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.gesture;

import android.os.SystemClock;
import android.view.MotionEvent;
import android.view.View;

import com.immomo.mmui.ud.UDView;

public class ArgoTouchUtil {

    private final static int CUSTOM_CREATE = Integer.MIN_VALUE + 1;

    private static MotionEvent.PointerCoords[] gpc;
    private static MotionEvent.PointerProperties[] gpp;

    private static void initPointers(float x, float y, int count) {
        int os = gpc != null ? gpc.length : 0;
        if (os < count) {
            gpc = new MotionEvent.PointerCoords[count];
            gpp = new MotionEvent.PointerProperties[count];
        }
        for (int i = 0; i < count; i ++) {
            gpc[i] = new MotionEvent.PointerCoords();
            gpc[i].x = x;
            gpc[i].y = y;
            gpc[i].pressure = 1f;
            gpc[i].size = 1f;

            gpp[i] = new MotionEvent.PointerProperties();
            gpp[i].id = i;
        }
    }

    /**
     * 强制分发多指down事件
     */
    public static void createDownTouch(UDView ud, float x, float y, int count) {
        View v = ud.getView();
        long now = SystemClock.uptimeMillis();
        initPointers(x, y, count);
        MotionEvent obtain = MotionEvent.obtain(now, now, MotionEvent.ACTION_DOWN, count, gpp, gpc, 0, 0, 1f, 1f, 0, 0, CUSTOM_CREATE, 0);
        v.dispatchTouchEvent(obtain);
        MotionEvent temp = obtain;
        for (int i = 1; i < count; i ++) {
            obtain = MotionEvent.obtain(temp);
            obtain.setAction((i << MotionEvent.ACTION_POINTER_INDEX_SHIFT) | MotionEvent.ACTION_POINTER_DOWN);
            v.dispatchTouchEvent(obtain);
            obtain.recycle();
        }
        temp.recycle();;
    }

    /**
     * 重新生成事件流，寻找消费事件的view
     * @param udView ud
     * @param event 事件
     */
    public static void createNewDownTouch(UDView udView, MotionEvent event) {
        if (udView.isTouchChange()) {
            udView.setTouchChange(false);
            // 仅仅只在事件流过程中，进行更改事件流传递
            if (event.getAction() == MotionEvent.ACTION_MOVE) {
                // 重新下派新的ACTION_DOWN，来寻求处理事件的view
                MotionEvent obtain = MotionEvent.obtain(event);
                obtain.setAction(MotionEvent.ACTION_DOWN);
                udView.getView().dispatchTouchEvent(obtain);
                obtain.recycle();
            }
        }
    }

    /**
     * 重新下派Down，去寻找需要处理多指操作的子view
     *
     * @param udView ud
     * @param event  事件
     */
    public static void searchPointerView(UDView udView, MotionEvent event) {
        if (!udView.isChildFirstHandlePointers()) {
            return;
        }
        // 仅仅只在多指点击时，进行更改事件流传递
        if (event.getActionMasked() == MotionEvent.ACTION_POINTER_DOWN && !isCustomCreate(event)) {
            event.setSource(CUSTOM_CREATE);
            // 重新下派新的ACTION_DOWN，来寻求处理事件的view
            MotionEvent obtain = MotionEvent.obtain(event);
            obtain.setAction(MotionEvent.ACTION_DOWN);
            udView.getView().dispatchTouchEvent(obtain);
            udView.getView().dispatchTouchEvent(event);
            obtain.recycle();
        }
    }

    /**
     * 判断是否是用户自己生成的event
     */
    private static boolean isCustomCreate(MotionEvent event) {
        return event.getSource() == CUSTOM_CREATE;
    }
}
