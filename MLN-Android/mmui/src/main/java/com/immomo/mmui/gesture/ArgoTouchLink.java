/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.gesture;

import android.view.View;

import java.util.LinkedList;
import java.util.List;

/**
 * 组合控件的子控件的事件传递链
 */
public class ArgoTouchLink {

    // 控件的子控件的事件传递链
    private LinkedList<View> touchLink = new LinkedList<>();
    private View target; // 消费事件的view
    private View.OnTouchListener touchListener; // 触摸监听

    public void setTarget(View target) {
        this.target = target;
    }

    public void setTouchListener(View.OnTouchListener touchListener) {
        this.touchListener = touchListener;
        resetTouchListener();
    }

    /**
     * 重置组合控件中的需要touchListener
     * 指定组合控件中的消费事件，设置null，则默认组合事件中的叶子节点消费事件
     */
    public void resetTouchListener() {
        if (target == null) {
            View last = touchLink.getLast();
            last.setOnTouchListener(touchListener);
        } else {
            for (View child : touchLink) {
                child.setOnTouchListener(null);
            }
            target.setOnTouchListener(touchListener);
        }
    }

    public void setHead(View head) {
        touchLink.addFirst(head);
    }

    public void addChild(View child) {
        touchLink.add(child);
    }

    public void addChildAll(List<View> childs){
        touchLink.addAll(childs);
    }
}
