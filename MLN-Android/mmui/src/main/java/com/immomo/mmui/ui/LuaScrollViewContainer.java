/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ui;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewGroup;

import com.immomo.mmui.gesture.ArgoTouchLink;
import com.immomo.mmui.gesture.ICompose;
import com.immomo.mmui.ud.UDScrollView;
import com.immomo.mmui.weight.BaseFrameLayout;
import com.immomo.mmui.weight.layout.NodeLayout;

/**
 * Created by zhang.ke
 * 圆角切割，引起ScrollView屏幕外部分，不显示。
 * 用FrameLayout包裹解决
 * on 2019/9/29
 */
public class LuaScrollViewContainer extends BaseFrameLayout
        implements IScrollView<UDScrollView>, ICompose {
    private final UDScrollView userdata;
    private ViewLifeCycleCallback cycleCallback;
    private IScrollView iScrollView;
    private ArgoTouchLink touchLink = new ArgoTouchLink();

    public LuaScrollViewContainer(Context context, UDScrollView userdata) {
        super(context);
        this.userdata = userdata;
        setViewLifeCycleCallback(userdata);
    }

    public void init(boolean vertical, boolean same, AttributeSet attributeSet) {
        if (vertical) {
            iScrollView = new LuaVerticalScrollView(getContext(), userdata, same, attributeSet);
        } else {
            iScrollView = new LuaHorizontalScrollView(getContext(), userdata, same);
        }
        addView(iScrollView.getScrollView(),
                new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT));
        // 处理组合控件
        touchLink.setHead(this);
        touchLink.addChild(iScrollView.getScrollView());
    }

    @Override
    public void setHorizontalScrollBarEnabled(boolean horizontalScrollBarEnabled) {
        super.setHorizontalScrollBarEnabled(horizontalScrollBarEnabled);
        iScrollView.setHorizontalScrollBarEnabled(horizontalScrollBarEnabled);
    }

    @Override
    public void setVerticalScrollBarEnabled(boolean verticalScrollBarEnabled) {
        super.setVerticalScrollBarEnabled(verticalScrollBarEnabled);
        iScrollView.setVerticalScrollBarEnabled(verticalScrollBarEnabled);
    }

    @Override
    public UDScrollView getUserdata() {
        return userdata;
    }

    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (cycleCallback != null) {
            cycleCallback.onAttached();
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (cycleCallback != null) {
            cycleCallback.onDetached();
        }
    }

    @Override
    public NodeLayout getContentView() {
        return iScrollView.getContentView();
    }

    @Override
    public ViewGroup getScrollView() {
        return iScrollView.getScrollView();
    }

    @Override
    public void scrollTo(int x, int y) {
        iScrollView.scrollTo(x, y);
    }

    @Override
    public void smoothScrollTo(int x, int y) {
        iScrollView.smoothScrollTo(x, y);
    }

    @Override
    public void setScrollEnable(boolean scrollEnable) {
        iScrollView.setScrollEnable(scrollEnable);
    }

    @Override
    public void setOnScrollListener(OnScrollListener l) {
        iScrollView.setOnScrollListener(l);
    }

    @Override
    public void setTouchActionListener(touchActionListener l) {
        iScrollView.setTouchActionListener(l);
    }

    @Override
    public void setFlingListener(FlingListener flingListener) {
        iScrollView.setFlingListener(flingListener);
    }

    @Override
    public void setFlingSpeed(float speed) {
        iScrollView.setFlingSpeed(speed);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        return isEnabled() && super.dispatchTouchEvent(ev);
    }

    @Override
    public ArgoTouchLink getTouchLink() {
        return touchLink;
    }
}