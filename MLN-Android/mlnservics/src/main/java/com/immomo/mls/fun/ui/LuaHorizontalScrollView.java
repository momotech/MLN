/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;

import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.fun.other.Point;
import com.immomo.mls.fun.other.Size;
import com.immomo.mls.fun.ud.view.UDLinearLayout;
import com.immomo.mls.fun.ud.view.UDScrollView;
import com.immomo.mls.fun.ud.view.UDView;
import com.immomo.mls.fun.ud.view.UDViewGroup;
import com.immomo.mls.fun.weight.LinearLayout;
import com.immomo.mls.util.DimenUtil;

import java.lang.ref.WeakReference;

import androidx.annotation.NonNull;

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
    private long mScrollEndTime =0;

    public LuaHorizontalScrollView(Context context, UDScrollView userdata, boolean same) {
        super(context);
        udScrollView = userdata;

        setHorizontalScrollBarEnabled(true);
        // 是否在里面默认添加相同方向的 LinearLayout 布局
        if (same)
            mILViewGroup = (ILViewGroup) new UDLinearLayout(userdata.getGlobals(), LinearLayout.HORIZONTAL).getView();
        else
            mILViewGroup = (ILViewGroup) new UDViewGroup(userdata.getGlobals()).getView();

        addView(getContentView(), new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
    }

    @Override
    public ViewGroup getContentView() {
        return (ViewGroup) mILViewGroup.getUserdata().getView();
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
    public void bringSubviewToFront(UDView child) {
        mILViewGroup.bringSubviewToFront(child);
    }

    @Override
    public void sendSubviewToBack(UDView child) {
        mILViewGroup.sendSubviewToBack(child);
    }

    @Override
    public ViewGroup.LayoutParams applyLayoutParams(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        return mILViewGroup.applyLayoutParams(src, udLayoutParams);
    }

    @NonNull
    @Override
    public ViewGroup.LayoutParams applyChildCenter(ViewGroup.LayoutParams src, UDView.UDLayoutParams udLayoutParams) {
        return mILViewGroup.applyChildCenter(src, udLayoutParams);
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
            final FrameLayout.LayoutParams lp = (LayoutParams) child.getLayoutParams();

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

        if(!beginScroll &&  onScrollListener != null){

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
        return super.onInterceptTouchEvent(ev);
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        if (!isEnabled())
            return false;
        switch (ev.getAction()) {
            case MotionEvent.ACTION_DOWN:
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
            if (scrollView!= null) {
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

    private void onScrollEnd(){
        if (onScrollListener != null) {
            onScrollListener.onScrollEnd();
            mScrollEndTime = System.currentTimeMillis();
        }
    }

    @Override
    public void setScrollEnable(final boolean scrollEnable) {
        setOnTouchListener(null);
        setOnTouchListener(new View.OnTouchListener() {
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