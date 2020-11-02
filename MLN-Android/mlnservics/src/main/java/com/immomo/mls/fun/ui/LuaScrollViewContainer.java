/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewGroup;

import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.view.UDScrollView;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.weight.BorderRadiusFrameLayout;
import com.immomo.mls.util.LuaViewUtil;

import androidx.annotation.NonNull;


/**
 * Created by zhang.ke
 * 圆角切割，引起ScrollView屏幕外部分，不显示。
 * 用FrameLayout包裹解决
 * on 2019/9/29
 */
public class LuaScrollViewContainer extends BorderRadiusFrameLayout implements IScrollView<UDScrollView> {
    private final UDScrollView userdata;
    private ViewLifeCycleCallback cycleCallback;
    private IScrollView iScrollView;

    public LuaScrollViewContainer(Context context, UDScrollView userdata, boolean vertical, boolean same, AttributeSet attributeSet) {
        super(context);
        this.userdata = userdata;

        if (vertical) {
            iScrollView = new LuaVerticalScrollView(getContext(), userdata, same, attributeSet);
        } else {
            iScrollView = new LuaHorizontalScrollView(getContext(), userdata, same);
        }
        setViewLifeCycleCallback(userdata);
        addView(iScrollView.getScrollView(), LuaViewUtil.createRelativeLayoutParamsMM());
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
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        getUserdata().measureOverLayout(widthMeasureSpec, heightMeasureSpec);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        getUserdata().layoutOverLayout(left, top, right, bottom);
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);
        getUserdata().drawOverLayout(canvas);
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
    public void setContentSize(Size size) {
        iScrollView.setContentSize(size);
    }

    @Override
    public ViewGroup getContentView() {
        return iScrollView.getContentView();
    }

    @Override
    public Size getContentSize() {
        return iScrollView.getContentSize();
    }

    @Override
    public ViewGroup getScrollView() {
        return iScrollView.getScrollView();
    }

    @Override
    public void setContentOffset(Point p) {
        iScrollView.setContentOffset(p);
    }

    @Override
    public void setScrollEnable(boolean scrollEnable) {
        iScrollView.setScrollEnable(scrollEnable);
    }

    @Override
    public void setOffsetWithAnim(Point p) {
        iScrollView.setOffsetWithAnim(p);
    }

    @Override
    public Point getContentOffset() {
        return iScrollView.getContentOffset();
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
    public void bringSubviewToFront(UDView child) {
        iScrollView.bringSubviewToFront(child);
    }

    @Override
    public void sendSubviewToBack(UDView child) {
        iScrollView.sendSubviewToBack(child);
    }

    @NonNull
    @Override
    public ViewGroup.LayoutParams applyLayoutParams(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        return iScrollView.applyLayoutParams(src,udLayoutParams);
    }

    @NonNull
    @Override
    public ViewGroup.LayoutParams applyChildCenter(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        return iScrollView.applyChildCenter(src,udLayoutParams);
    }

    @Override
    public void setFlingSpeed(float speed) {
        iScrollView.setFlingSpeed(speed);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        return isEnabled() && super.dispatchTouchEvent(ev);
    }
}