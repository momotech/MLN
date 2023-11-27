/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ui;

import android.content.Context;
import android.database.DataSetObserver;
import android.os.Handler;
import android.os.Message;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;

import com.immomo.mls.MLSEngine;
import com.immomo.mls.fun.ud.view.UDViewPager;
import com.immomo.mls.fun.ud.view.viewpager.ViewPagerAdapter;
import com.immomo.mls.fun.weight.BorderRadiusViewPager;
import com.immomo.mls.fun.weight.LinearLayout;
import com.immomo.mls.util.LogUtil;
import com.immomo.mls.utils.AppearUtils;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

/**
 * Created by fanqiang on 2018/8/30.
 */
public class LuaViewPager extends BorderRadiusViewPager implements IViewPager<UDViewPager> {
    public static final String TAG = LuaViewPager.class.getSimpleName();

    private static final int SCROLL_TO_NEXT = 1;

    private final UDViewPager userdata;

    private boolean autoScroll = false;
    private boolean repeat = false;
    private float frameInterval = 2000;
    private PageIndicator pageIndicator;
    private List<Callback> callbacks;
    private @NonNull
    final AnimHelper animHelper;
    private ViewLifeCycleCallback cycleCallback;
    public boolean mFirstAttach = true;

    //是否可以左右滑动？true 可以，像Android原生ViewPager一样。
    // false 禁止ViewPager左右滑动。
    private boolean scrollable = true;

    public LuaViewPager(@NonNull Context context, UDViewPager udViewPager) {
        super(context);
        userdata = udViewPager;
        setViewLifeCycleCallback(udViewPager);
        addOnPageChangeListener(onPageChangeListener);
        animHelper = new AnimHelper();

        // setViewPagerScroller();
    }

    //<editor-fold desc="ILView">
    @Override
    public UDViewPager getUserdata() {
        return userdata;
    }

    @Override
    public void setViewLifeCycleCallback(ViewLifeCycleCallback cycleCallback) {
        this.cycleCallback = cycleCallback;
    }

    //</editor-fold>

    //<editor-fold desc="VIEW">
    public void callOnAttachedToWindow() {
        super.onAttachedToWindow();
        if (pageIndicator != null) {
            addIndicatorToParent();
        }
        // animHelper.startIfNeed();
        if (cycleCallback != null) {
            cycleCallback.onAttached();
        }
    }

    public void firstAttachAppearZeroPosition() {
        if (mFirstAttach) {
            userdata.callbackCellWillAppear(0);
        }
    }

    public void callOnDetachedFromWindow() {
        super.onDetachedFromWindow();
        // animHelper.stopAnim();
        if (cycleCallback != null) {
            cycleCallback.onDetached();
        }

        if (onlyOneItem())
            userdata.callbackCellDidDisAppear(0);
    }

    private boolean onlyOneItem() {
        if (getAdapter() == null)
            return true;

        return ((ViewPagerAdapter) getAdapter()).getRealCount() <= 1;
    }

    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        // animHelper.stopAnim();
        if (cycleCallback != null) {
            cycleCallback.onDetached();
        }

        if (onlyOneItem())
            userdata.callbackCellDidDisAppear(0);
    }

    @Override
    protected void onVisibilityChanged(@NonNull View changedView, int visibility) {
        if (visibility == View.VISIBLE) {
            animHelper.startIfNeed();
        } else {
            animHelper.stopAnim();
        }
    }

    @Override
    public void setAdapter(PagerAdapter adapter) {
        if (getAdapter() != null) {
            getAdapter().unregisterDataSetObserver(dataSetObserver);
        }
        super.setAdapter(adapter);
        if (adapter != null) {
            bindIndicator();
            animHelper.startIfNeed();
            adapter.registerDataSetObserver(dataSetObserver);
        }
    }
    //</editor-fold>

    //<editor-fold desc="IViewPager for ud">

    @Override
    public LuaViewPager getViewPager() {
        return this;
    }

    public boolean isAutoScroll() {
        return autoScroll;
    }

    public void setAutoScroll(boolean autoScroll) {
        this.autoScroll = autoScroll;

        if (!autoScroll)
            animHelper.stopAnim();

        if (getAdapter() != null)
            animHelper.startIfNeed();
    }

    public boolean isRepeat() {
        return repeat;
    }

    public void setRepeat(boolean repeat) {
        this.repeat = repeat;
    }

    public float getFrameInterval() {
        return frameInterval / 1000f;
    }

    public void setFrameInterval(float frameInterval) {
        this.frameInterval = frameInterval * 1000;
    }

    public void setPageIndicator(PageIndicator pageIndicator) {
        if (pageIndicator != null) {
            this.pageIndicator = pageIndicator;
            addIndicatorToParent();
            bindIndicator();
            this.pageIndicator.setCurrentItem(getCurrentItem());
        } else if (this.pageIndicator != null) {
            this.pageIndicator.removeFromSuper();
            this.pageIndicator = null;
        }
    }

    boolean mRelatedTabLayout = false;

    public boolean isRelatedTabLayout() {
        return mRelatedTabLayout;
    }

    public void setRelatedTabLayout(boolean relatedTabLayout) {
        mRelatedTabLayout = relatedTabLayout;
    }

    @Override
    public PageIndicator getPageIndicator() {
        return pageIndicator;
    }

    @Override
    public void addCallback(Callback c) {
        if (callbacks == null) {
            callbacks = new ArrayList<>();
        }
        callbacks.add(c);
    }

    @Override
    public void removeCallback(Callback c) {
        if (callbacks != null) {
            callbacks.remove(c);
        }
    }
    //</editor-fold>

    private final DataSetObserver dataSetObserver = new DataSetObserver() {
        @Override
        public void onChanged() {
            if (autoScroll) {
                animHelper.stopAnim();

                if (onlyOneItem()) {
                    return;
                }

                animHelper.startIfNeed();
            }
        }
    };

    private final class AnimHelper extends Handler {
        boolean running = false;

        @Override
        public void handleMessage(Message msg) {
            removeMessages(SCROLL_TO_NEXT);
            if (!running)
                return;
            if (msg.what == SCROLL_TO_NEXT) {
                if (showNextItem()) {
                    this.sendEmptyMessageDelayed(SCROLL_TO_NEXT, (int) frameInterval);
                } else {
                    running = false;
                }
            }
        }

        void startImmediatly() {
            running = true;
            sendEmptyMessage(SCROLL_TO_NEXT);
        }

        void startIfNeed() {
            if (running || onlyOneItem())
                return;

            if (autoScroll) {
                startAnim();
            }
        }

        void startAnim() {
            running = true;
            sendEmptyMessageDelayed(SCROLL_TO_NEXT, (int) frameInterval);
        }

        void stopAnim() {
            running = false;
            removeMessages(SCROLL_TO_NEXT);
        }
    }

    private int lastPosition = getCurrentItem();

    public void setLastPosition(int lastPosition) {
        if (lastPosition >= 0 && lastPosition < getAdapter().getCount())
            this.lastPosition = lastPosition;
    }


    private ViewPager.OnPageChangeListener onPageChangeListener = new ViewPager.SimpleOnPageChangeListener() {
        private float lastValue = -1;
        private boolean doCallback = false;

        @Override
        public void onPageScrollStateChanged(int state) {
            if (MLSEngine.DEBUG)
                LogUtil.d(TAG, "state =  " + state);

            if (state == ViewPager.SCROLL_STATE_DRAGGING || state == ViewPager.SCROLL_STATE_SETTLING) {
                animHelper.stopAnim();
            } else {
                animHelper.startIfNeed();
                lastValue = -1;
                lastScrollingValue = -1;
            }
                doCallback = false;
        }

        @Override
        public void onPageScrolled(int position,float positionOffset, int positionOffsetPixels) {
            if (MLSEngine.DEBUG)
                LogUtil.d(TAG, "scrolling   position =  " + position +"  offset = " + positionOffset +"   pixels = "+ positionOffsetPixels);

            tabProgressCallback(position,positionOffset, positionOffsetPixels);

            if (lastValue == -1) {
                if (positionOffset == 0) {
                    return;
                }
                lastValue = positionOffset;
                return;
            }
            if (callbacks != null) {
                if (positionOffset != 0) {
                    if (doCallback)
                        return;
                    if (lastValue > positionOffset) {
                        doCallback = true;
                        for (Callback callback : callbacks) {
                            callback.callbackStartDrag(position);
                        }
                    } else {
                        int count = getAdapter().getCount();
                        int targetPosition = position + 1;
                        targetPosition = targetPosition >= count ? count - 1 : targetPosition;
                        doCallback = true;
                        for (Callback callback : callbacks) {
                            callback.callbackStartDrag(targetPosition);
                        }
                    }
                } else {
                    doCallback = false;
                    if (lastPosition != position) {
                        for (Callback callback : callbacks) {
                            callback.callbackStartDrag(position);
                            callback.callbackEndDrag(position);
                        }
                    }
                }
                lastValue = positionOffset;
            }

        }

        @Override
        public void onPageSelected(int position) {
            if (MLSEngine.DEBUG)
                LogUtil.d(TAG, " selected   = " + position);

            position = userdata.getRecurrencePosition(position);

            userdata.pageSelectedCallback(position);

            if (callbacks != null) {
                for (Callback callback : callbacks) {
                    if (!doCallback)
                        callback.callbackStartDrag(position);
                    callback.callbackEndDrag(position);
                }
            }
            if (lastValue == 0) {
                doCallback = false;
            }

            userdata.callbackCellDidDisAppear(lastPosition);
            userdata.callbackCellWillAppear(position);

            AppearUtils.appearOrDisappearMiddlePosition(userdata,lastPosition,position,autoScroll);
            lastPosition = position;
        }
    };

    @Override
    public void setCurrentItem(int item) {
        super.setCurrentItem(item);
    }

    @Override
    public void setCurrentItem(int item, boolean smoothScroll) {
        if (smoothScroll)
            AppearUtils.sAnimatedToPage = true;

        super.setCurrentItem(item, smoothScroll);
    }

    private boolean showNextItem() {
        PagerAdapter adapter = getAdapter();
        if (adapter == null) {
            return false;
        }
        int c = adapter.getCount();

        int cc = getCurrentItem();
        if (autoScroll && cc >= c - 1) {
            setCurrentItem(0, true);
        } else {
            setCurrentItem(cc + 1, true);
        }
        return true;
    }

    private void bindIndicator() {
        if (pageIndicator == null || getAdapter() == null)
            return;
        pageIndicator.setViewPager(this);

        setPageIndicatorScrollEnable(scrollable);
    }

    private void addIndicatorToParent() {
        View v = (View) pageIndicator;

        // 代表已经添加过了
        if (v.getParent() != null)
            return;

        ViewParent vp = getParent();

        if (vp instanceof LinearLayout) {
            LinearLayout parent = (LinearLayout) vp;
            int index = parent.indexOfChild(this);
            parent.removeView(this);

            FrameLayout frameLayout = new FrameLayout(getContext());
            ViewGroup.LayoutParams source = getLayoutParams();
            frameLayout.addView(this, new ViewGroup.MarginLayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            frameLayout.addView(v);
            parent.addView(frameLayout, index, source);
        } else if (vp instanceof ViewGroup) {
            ((ViewGroup) vp).addView(v);
        }
    }

    public void setScrollable(boolean scrollable) {
        this.scrollable = scrollable;

        setPageIndicatorScrollEnable(scrollable);
    }

    private void setPageIndicatorScrollEnable(boolean scrollable) {
        if (pageIndicator instanceof DefaultPageIndicator)
            ((DefaultPageIndicator) pageIndicator).setScrollable(scrollable);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        try {
            return scrollable && super.onInterceptTouchEvent(ev);
        } catch (IllegalArgumentException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        try {
            return scrollable && super.onTouchEvent(ev);
        } catch (IllegalArgumentException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // ViewPager嵌套时，当子Viewpager不可以滚动后，滑动子Viewpager 相当于滑动父ViewPager
    @Override
    public boolean canScrollHorizontally(int direction) {
        if (!scrollable)
            return false;

        return super.canScrollHorizontally(direction);
    }

    @Override
    public boolean canScrollVertically(int direction) {
        if (!scrollable)
            return false;

        return super.canScrollVertically(direction);
    }

    private void setViewPagerScroller() {
        try {
            Field scrollerField = ViewPager.class.getDeclaredField("mScroller");
            scrollerField.setAccessible(true);
            Field interpolator = ViewPager.class.getDeclaredField("sInterpolator");
            interpolator.setAccessible(true);

            ViewPagerSpeedScroller SpeedScroller = new ViewPagerSpeedScroller(getContext(), new LinearInterpolator());
            SpeedScroller.setmDuration(400);

            scrollerField.set(this, SpeedScroller);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 滚动进度 回调 开始 ------

    // 防止回调回去多次 1 的情况
    boolean isReturnOne = false;
    private float lastScrollingValue = -1;

    // 滚动过程中，回调给Lua 滚动进度，值在 0 到 1
    private void tabProgressCallback(int position, float positionOffset, int positionOffsetPixels) {
        if (lastScrollingValue == -1) {
            lastScrollingValue = positionOffsetPixels;
            isReturnOne = false;
        }

        if (isReturnOne)
            return;

        float finalProgress = 0;
        int fromIndex = 0, toIndex = 0;

        if (positionOffset != 0) {
            if (lastScrollingValue > positionOffsetPixels) {   //左滑
                finalProgress = 1 - positionOffset;
                fromIndex = position + 1;
                toIndex = fromIndex - 1;
                if (MLSEngine.DEBUG)
                    LogUtil.d(TAG, "//左滑   position =  " + position);
            } else if (lastScrollingValue < positionOffsetPixels) {  //右滑
                finalProgress = positionOffset;
                fromIndex = position;
                toIndex = fromIndex + 1;
                if (MLSEngine.DEBUG)
                    LogUtil.d(TAG, "//右滑   position =  " + position);
            }




            if (finalProgress >= 0.99)
                finalProgress = 1;

            if (finalProgress != 0)
                userdata.callTabScrollProgress(finalProgress, fromIndex, toIndex);
            if (finalProgress == 1)
                isReturnOne = true;
        }
        lastScrollingValue = positionOffsetPixels;
    }
    // 滚动进度 回调 结束  ------


    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        if (userdata.getDefaultPageIndicator() != null)
            userdata.getDefaultPageIndicator().changeLayoutParams();
    }
}