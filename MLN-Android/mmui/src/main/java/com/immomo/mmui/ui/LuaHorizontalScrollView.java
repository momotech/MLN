/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ui;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.HorizontalScrollView;


import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mmui.ILViewGroup;
import com.immomo.mmui.gesture.ArgoTouchLink;
import com.immomo.mmui.gesture.ArgoTouchUtil;
import com.immomo.mmui.gesture.ICompose;
import com.immomo.mmui.ud.UDHStack;
import com.immomo.mmui.ud.UDScrollView;
import com.immomo.mmui.weight.layout.NodeLayout;

import java.lang.ref.WeakReference;

/**
 * Created by XiongFangyu on 2018/8/3.
 */
public class LuaHorizontalScrollView extends HorizontalScrollView implements IScrollView<UDScrollView> {

    private ILViewGroup mILViewGroup;

    private UDScrollView udScrollView;
    private OnScrollListener onScrollListener;
    private touchActionListener mTouchActionListener;
    private FlingListener mFlingListener;
    private ViewLifeCycleCallback cycleCallback;
    public static final int HANDLER_DELAY_TIME = 16;
    private long mScrollEndTime = 0;

    public LuaHorizontalScrollView(Context context, UDScrollView userdata, boolean same) {
        super(context);
        udScrollView = userdata;

        setHorizontalScrollBarEnabled(true);
        setFillViewport(true);
        // 是否在里面默认添加相同方向的 LinearLayout 布局
        mILViewGroup = new UDHStack(userdata.getGlobals()).getView();

        addView(getContentView(), new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        // 处理组合控件
        ArgoTouchLink touchLink = ((ICompose) udScrollView.getView()).getTouchLink();
        touchLink.addChild(getContentView());
        touchLink.setTarget(this);
    }

    @Override
    public NodeLayout getContentView() {
        return (NodeLayout) mILViewGroup.getUserdata().getView();
    }

    //<editor-fold desc="ILViewGroup">
    @Override
    public UDScrollView getUserdata() {
        return udScrollView;
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
        scrollEndHandler.removeCallbacksAndMessages(null);
    }

    @Override
    public void setContentSize(Size size) {
        if (size.getWidthPx() == 0 || size.getHeightPx() == 0)
            return;

        ViewGroup.LayoutParams params = getContentView().getLayoutParams();
        params.width = size.getWidthPx();
        params.height = size.getHeightPx();
        getContentView().setLayoutParams(params);
    }


    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        if (getChildCount() > 0) {

            final View child = getChildAt(0);
            final LayoutParams lp = (LayoutParams) child.getLayoutParams();

            if (lp != null && lp.width > getMeasuredWidth()) {

                final int childWidthMeasureSpec = MeasureSpec.makeMeasureSpec(
                    lp.width, MeasureSpec.EXACTLY);

                final int childHeightMeasureSpec = MeasureSpec.makeMeasureSpec(
                    heightMeasureSpec, MeasureSpec.AT_MOST);

                child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
            }
        }

        ViewParent parent = getParent();
        if (parent != null && !((ViewGroup) parent).getClipChildren()) {
            ((ViewGroup) parent).setClipChildren(true);
        }
    }

    @Override
    public Size getContentSize() {
        return new Size((int) DimenUtil.pxToDpi(getContentView().getWidth()), (int) DimenUtil.pxToDpi(getContentView().getHeight()));
    }

    @Override
    public ViewGroup getScrollView() {
        return this;
    }

    @Override
    public void setContentOffset(Point p) {
        scrollTo((int) p.getXPx(), (int) p.getYPx());
    }

    @Override
    public void setOffsetWithAnim(Point p) {
        smoothScrollTo((int) p.getXPx(), (int) p.getYPx());
    }

    @Override
    public Point getContentOffset() {
        return new Point(DimenUtil.pxToDpi(getScrollX()), DimenUtil.pxToDpi(getScrollY()));
    }

    @Override
    public void setOnScrollListener(OnScrollListener l) {
        onScrollListener = l;
    }


    public void setTouchActionListener(touchActionListener touchActionListener) {
        mTouchActionListener = touchActionListener;
    }

    @Override
    public void setFlingListener(FlingListener flingListener) {
        mFlingListener = flingListener;
    }

    //</editor-fold>

    //<editor-fold desc="View">
    @Override
    protected void onScrollChanged(int l, int t, int oldl, int oldt) {
        super.onScrollChanged(l, t, oldl, oldt);

        if (l == oldl && t == oldt)
            return;

        if (!beginScroll && onScrollListener != null) {

            // 修复：某些机型横向滚动 多回调一次 问题，需要关注是否影响性能，纵向目前没有发现此问题
            if (System.currentTimeMillis() - mScrollEndTime <= 200) {
                mScrollEndTime = System.currentTimeMillis();
                return;
            }

            onScrollListener.onBeginScroll();
            beginScroll = true;
        }

        if (onScrollListener != null)
            onScrollListener.onScrolling();

        sendDelayMsg();
    }

    private void sendDelayMsg() {
        scrollEndHandler.removeMessages(InnerHandler.touchEventId);
        scrollEndHandler.sendMessageDelayed(scrollEndHandler.obtainMessage(InnerHandler.touchEventId, this), HANDLER_DELAY_TIME);
    }

    boolean beginScroll = false;

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        switch (ev.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if (mTouchActionListener != null)
                    mTouchActionListener.onTouchDown();
                break;
        }
        // 组合控件的事件拦截，交个组合控件的根节点进行。由于要重写onInterceptTouchEvent，无法统一。
        Boolean notDispatch = udScrollView.isNotDispatch();
        if (notDispatch == null) { // 默认由控件自己处理
            return super.onInterceptTouchEvent(ev);
        } else {
            return notDispatch;
        }
    }

    // 无论自己的事件流还是子view的事件流均会走此方法，因此可以在此处进行事件流控制
    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        ArgoTouchUtil.createNewDownTouch(udScrollView, ev);
        return super.dispatchTouchEvent(ev);
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        if (!isEnabled())
            return false;
        switch (ev.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                break;
            case MotionEvent.ACTION_POINTER_DOWN:
                ArgoTouchUtil.searchPointerView(udScrollView, ev);
                break;
            case MotionEvent.ACTION_MOVE:
                if (onScrollListener != null)
                    onScrollListener.onScrolling();
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:

                if (mTouchActionListener != null)
                    mTouchActionListener.onActionUp();
                break;
        }
        return super.onTouchEvent(ev);
    }

    //</editor-fold>

    private WeakReference<LuaHorizontalScrollView> mScrollViewWeakReference = new WeakReference<>(this);

    private final Handler scrollEndHandler = new InnerHandler(mScrollViewWeakReference);

    private static class InnerHandler extends Handler {
        WeakReference<LuaHorizontalScrollView> scrollViewWeakRef;

        int lastX = 0;
        static final int touchEventId = -9983761;

        InnerHandler(WeakReference<LuaHorizontalScrollView> activityWeakReference) {
            this.scrollViewWeakRef = activityWeakReference;
        }

        public void handleMessage(Message msg) {
            LuaHorizontalScrollView scrollView = scrollViewWeakRef.get();
            if (scrollView != null) {
                super.handleMessage(msg);

                View scroller = (View) msg.obj;

                if (msg.what == touchEventId) {
                    if (lastX == scroller.getScrollX()) {
                        scrollView.onScrollEnd();
                        this.scrollViewWeakRef.get().beginScroll = false;
                    } else {
                        this.scrollViewWeakRef.get().sendDelayMsg();
                        lastX = scroller.getScrollX();
                    }
                }
            }
        }
    }

    private void onScrollEnd() {
        if (onScrollListener != null) {
            onScrollListener.onScrollEnd();
            mScrollEndTime = System.currentTimeMillis();
        }
    }

    @Override
    public void setScrollEnable(final boolean scrollEnable) {
        setOnTouchListener(null);
        setOnTouchListener(new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                // return true     HorizontalScrollView不能滑动
                return !scrollEnable;
            }
        });
    }

    float mFlingSpeed = 1;

    @Override
    public void setFlingSpeed(float speed) {
        mFlingSpeed = speed;
    }

    @Override
    public void fling(int velocityX) {
        super.fling((int) (velocityX * mFlingSpeed));
        if (mFlingListener != null)
            mFlingListener.onFling();
    }
}