/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/*
 * Copyright (C) 2011 Patrik Akerfeldt
 * Copyright (C) 2011 Jake Wharton
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.immomo.mls.fun.ui;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.os.Build;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

import com.immomo.mls.fun.ud.view.viewpager.ViewPagerAdapter;
import com.immomo.mls.util.DimenUtil;
import com.immomo.mls.util.LuaViewUtil;

import androidx.core.view.MotionEventCompat;
import androidx.core.view.ViewConfigurationCompat;
import androidx.viewpager.widget.ViewPager;

import static android.graphics.Paint.ANTI_ALIAS_FLAG;
import static android.widget.LinearLayout.HORIZONTAL;
import static android.widget.LinearLayout.VERTICAL;

/**
 * Draws circles (one for each view). The current view position is filled and
 * others are only stroked.
 */
public class DefaultPageIndicator extends View implements PageIndicator {
    private static final int INVALID_POINTER = -1;
    public static final int SELECTED_COLOR = 0xffffffff;
    public static final int DEFAULT_COLOR = 0x19ffffff;

    protected float mRadius;
    protected final Paint mPaintPageFill = new Paint(ANTI_ALIAS_FLAG);
    protected final Paint mPaintStroke = new Paint(ANTI_ALIAS_FLAG);
    protected final Paint mPaintFill = new Paint(ANTI_ALIAS_FLAG);
    protected ViewPager mViewPager;
    protected int mCurrentPage;
    protected int mSnapPage;
    protected float mPageOffset;
    protected int mScrollState;
    protected int mOrientation;
    protected boolean mCentered;
    protected boolean mSnap;

    protected int mTouchSlop;
    protected float mLastMotionX = -1;
    protected int mActivePointerId = INVALID_POINTER;
    protected boolean mIsDragging;
    protected float mRadiuspadding = 0;

    private boolean scrollable = true;

    public DefaultPageIndicator(Context context) {
        this(context, null);
    }

    public DefaultPageIndicator(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public DefaultPageIndicator(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

        mCentered = true;
        mOrientation = HORIZONTAL;
        mPaintPageFill.setStyle(Style.FILL);
        mPaintPageFill.setColor(DEFAULT_COLOR);
        mPaintStroke.setStyle(Style.STROKE);
//        mPaintStroke.setColor(0xffff0000);
        int dp = DimenUtil.dpiToPx(4);
//        mPaintStroke.setStrokeWidth(dp);
        mPaintFill.setStyle(Style.FILL);
        mPaintFill.setColor(SELECTED_COLOR);
        mRadius = dp;
        mSnap = true;

        final ViewConfiguration configuration = ViewConfiguration.get(context);
        mTouchSlop = ViewConfigurationCompat.getScaledPagingTouchSlop(configuration);
    }

    public void setCentered(boolean centered) {
        mCentered = centered;
        invalidate();
    }

    public boolean isCentered() {
        return mCentered;
    }

    // 选中颜色
    public void setPageColor(int pageColor) {
        mPaintPageFill.setColor(pageColor);
        invalidate();
    }

    public int getPageColor() {
        return mPaintPageFill.getColor();
    }

    // 默认颜色
    public void setFillColor(int fillColor) {
        mPaintFill.setColor(fillColor);
        invalidate();
    }

    public int getFillColor() {
        return mPaintFill.getColor();
    }

    public void setOrientation(int orientation) {
        switch (orientation) {
            case HORIZONTAL:
            case VERTICAL:
                mOrientation = orientation;
                requestLayout();
                break;

            default:
                throw new IllegalArgumentException("Orientation must be either HORIZONTAL or VERTICAL.");
        }
    }

    public int getOrientation() {
        return mOrientation;
    }

    public void setStrokeColor(int strokeColor) {
        mPaintStroke.setColor(strokeColor);
        invalidate();
    }

    public int getStrokeColor() {
        return mPaintStroke.getColor();
    }

    public void setStrokeWidth(float strokeWidth) {
        mPaintStroke.setStrokeWidth(strokeWidth);
        invalidate();
    }

    public float getStrokeWidth() {
        return mPaintStroke.getStrokeWidth();
    }

    public void setRadius(float radius) {
        mRadius = radius;
        invalidate();
    }

    public float getRadius() {
        return mRadius;
    }

    public void setSnap(boolean snap) {
        mSnap = snap;
        invalidate();
    }

    public void setRadiusPadding(float padding) {
        // 减去默认的padding
        this.mRadiuspadding = padding - mRadius;
    }


    public boolean isSnap() {
        return mSnap;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        drawIndicator(canvas);
    }


    protected void drawIndicator(Canvas canvas){
        if (mViewPager == null) {
            return;
        }

        int count = mViewPager.getAdapter().getCount();

        ViewPagerAdapter viewPagerAdapter = ((ViewPagerAdapter) mViewPager.getAdapter());

        if (viewPagerAdapter != null && viewPagerAdapter.recurrenceRepeat())
            count = viewPagerAdapter.getRealCount();

        if (count == 0) {
            return;
        }

       /* if (mCurrentPage >= count) {
            setCurrentItem(count - 1);
            return;
        }*/

        int longSize;
        int longPaddingBefore;
        int longPaddingAfter;
        int shortPaddingBefore;
        if (mOrientation == HORIZONTAL) {
            longSize = getWidth();
            longPaddingBefore = getPaddingLeft();
            longPaddingAfter = getPaddingRight();
            shortPaddingBefore = getPaddingTop();
        } else {
            longSize = getHeight();
            longPaddingBefore = getPaddingTop();
            longPaddingAfter = getPaddingBottom();
            shortPaddingBefore = getPaddingLeft();
        }

        final float threeRadius = mRadius * 3;
        final float shortOffset = shortPaddingBefore + mRadius;
        float longOffset = longPaddingBefore + mRadius;
        if (mCentered) {
            longOffset += ((longSize - longPaddingBefore - longPaddingAfter) / 2.0f) - ((count * threeRadius) / 2.0f);
        }

        float dX;
        float dY;

        float FirstdX = 0;
        float LastdX = 0;

        float FirstdY = 0;
        float LastdY = 0;


        float pageFillRadius = mRadius;
        if (mPaintStroke.getStrokeWidth() > 0) {
            pageFillRadius -= mPaintStroke.getStrokeWidth() / 2.0f;
        }

        //Draw stroked circles
        for (int iLoop = 0; iLoop < count; iLoop++) {
            float drawLong = longOffset + (iLoop * (threeRadius + mRadiuspadding));

            if (mOrientation == HORIZONTAL) {
                dX = drawLong;
                dY = shortOffset;

                if (iLoop == 0 )
                    FirstdX = dX;

                if (iLoop == count -1)
                    LastdX = dX;

            } else {
                dX = shortOffset;
                dY = drawLong;

                if (iLoop == 0 )
                    FirstdY = dY;

                if (iLoop == count -1)
                    LastdY = dY;

            }

            // Only paint fill if not completely transparent
            if (mPaintPageFill.getAlpha() > 0) {
                canvas.drawCircle(dX, dY, pageFillRadius, mPaintPageFill);
            }

            // Only paint stroke if a stroke width was non-zero
            if (pageFillRadius != mRadius) {
                canvas.drawCircle(dX, dY, mRadius, mPaintStroke);
            }
        }

        //Draw the filled circle according to the current scroll
        float cx = (mSnap ? mSnapPage : mCurrentPage) * (threeRadius + mRadiuspadding);
        if (!mSnap) {
            cx += mPageOffset * threeRadius;
        }
        if (mOrientation == HORIZONTAL) {
            dX = longOffset + cx;
            dY = shortOffset;

            if (dX > LastdX)
                dX = FirstdX;

        } else {
            dX = shortOffset;
            dY = longOffset + cx;

            if (dY > LastdY)
                dY = FirstdY;
        }

        canvas.drawCircle(dX, dY, mRadius, mPaintFill);
    }

    public boolean onTouchEvent(android.view.MotionEvent ev) {
        try {
            if (super.onTouchEvent(ev)) {
                return true;
            }
            if ((mViewPager == null) || (mViewPager.getAdapter().getCount() == 0)  || !scrollable) {
                return false;
            }

            final int action = ev.getAction() & MotionEventCompat.ACTION_MASK;
            switch (action) {
                case MotionEvent.ACTION_DOWN:
                    mActivePointerId = MotionEventCompat.getPointerId(ev, 0);
                    mLastMotionX = ev.getX();
                    break;

                case MotionEvent.ACTION_MOVE: {
                    final int activePointerIndex = MotionEventCompat.findPointerIndex(ev, mActivePointerId);
                    final float x = MotionEventCompat.getX(ev, activePointerIndex);
                    final float deltaX = x - mLastMotionX;

                    if (!mIsDragging) {
                        if (Math.abs(deltaX) > mTouchSlop) {
                            mIsDragging = true;
                        }
                    }

                    if (mIsDragging) {
                        mLastMotionX = x;
                        if (mViewPager.isFakeDragging() || mViewPager.beginFakeDrag()) {
                            mViewPager.fakeDragBy(deltaX);
                        }
                    }

                    break;
                }

                case MotionEvent.ACTION_CANCEL:
                case MotionEvent.ACTION_UP:
                    if (!mIsDragging) {
                        final int count = mViewPager.getAdapter().getCount();
                        final int width = getWidth();
                        final float halfWidth = width / 2f;
                        final float sixthWidth = width / 6f;

                        if ((mCurrentPage > 0) && (ev.getX() < halfWidth - sixthWidth)) {
                            if (action != MotionEvent.ACTION_CANCEL) {
                                mViewPager.setCurrentItem(mCurrentPage - 1);
                            }
                            return true;
                        } else if ((mCurrentPage < count - 1) && (ev.getX() > halfWidth + sixthWidth)) {
                            if (action != MotionEvent.ACTION_CANCEL) {
                                mViewPager.setCurrentItem(mCurrentPage + 1);
                            }
                            return true;
                        }
                    }

                    mIsDragging = false;
                    mActivePointerId = INVALID_POINTER;
                    if (mViewPager.isFakeDragging()) mViewPager.endFakeDrag();
                    break;

                case MotionEventCompat.ACTION_POINTER_DOWN: {
                    final int index = MotionEventCompat.getActionIndex(ev);
                    mLastMotionX = MotionEventCompat.getX(ev, index);
                    mActivePointerId = MotionEventCompat.getPointerId(ev, index);
                    break;
                }

                case MotionEventCompat.ACTION_POINTER_UP:
                    final int pointerIndex = MotionEventCompat.getActionIndex(ev);
                    final int pointerId = MotionEventCompat.getPointerId(ev, pointerIndex);
                    if (pointerId == mActivePointerId) {
                        final int newPointerIndex = pointerIndex == 0 ? 1 : 0;
                        mActivePointerId = MotionEventCompat.getPointerId(ev, newPointerIndex);
                    }
                    mLastMotionX = MotionEventCompat.getX(ev, MotionEventCompat.findPointerIndex(ev, mActivePointerId));
                    break;
            }

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public void setScrollable(boolean scrollable) {
        this.scrollable = scrollable;
    }

    @Override
    public void setViewPager(ViewPager view) {
        if (mViewPager == view) {
            return;
        }
        if (view.getAdapter() == null) {
            throw new IllegalStateException("ViewPager does not have adapter instance.");
        }
        mViewPager = view;
        if (mViewPager.getHeight() == 0) {
            mViewPager.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
                @Override
                public void onGlobalLayout() {
                    if (mViewPager.getHeight() != 0) {
                        changeLayoutParams();
                        mViewPager.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                    }
                }
            });
        } else {
            changeLayoutParams();
        }
        mViewPager.addOnPageChangeListener(this);
        invalidate();
    }

    @Override
    public void setCurrentItem(int item) {
        if (mViewPager == null) {
            return;
            // throw new IllegalStateException("ViewPager has not been bound.");
        }

        mViewPager.setCurrentItem(item);
        mCurrentPage = item;
        mSnapPage = populateCurrentPosition(item);
        invalidate();
    }

    @Override
    public void notifyDataSetChanged() {
        invalidate();
    }

    @Override
    public void removeFromSuper() {
        if (mViewPager != null)
            mViewPager.removeOnPageChangeListener(this);
        if (getParent() instanceof ViewGroup) {
            LuaViewUtil.removeView((ViewGroup) getParent(), this);
        }
    }

    @Override
    public void onPageScrollStateChanged(int state) {
        mScrollState = state;
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

        position = populateCurrentPosition(position);

        mCurrentPage = position;
        mPageOffset = positionOffset;
        invalidate();
    }

    private int populateCurrentPosition(int position) {
        ViewPagerAdapter viewPagerAdapter = ((ViewPagerAdapter) mViewPager.getAdapter());

        if (viewPagerAdapter != null && viewPagerAdapter.recurrenceRepeat() && viewPagerAdapter.getRealCount() != 0)
            position = position % viewPagerAdapter.getRealCount();

        return position;
    }

    @Override
    public void onPageSelected(int position) {
        if (mSnap || mScrollState == ViewPager.SCROLL_STATE_IDLE) {

            position = populateCurrentPosition(position);

            mCurrentPage = position;
            mSnapPage = position;
            invalidate();
        }
    }

    /*
     * (non-Javadoc)
     *
     * @see android.view.View#onMeasure(int, int)
     */
    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if (mOrientation == HORIZONTAL) {
            setMeasuredDimension(measureLong(widthMeasureSpec), measureShort(heightMeasureSpec));
        } else {
            setMeasuredDimension(measureShort(widthMeasureSpec), measureLong(heightMeasureSpec));
        }
    }

    /**
     * Determines the width of this view
     *
     * @param measureSpec A measureSpec packed into an int
     * @return The width of the view, honoring constraints from measureSpec
     */
    private int measureLong(int measureSpec) {
        int result;
        int specMode = MeasureSpec.getMode(measureSpec);
        int specSize = MeasureSpec.getSize(measureSpec);

        if ((specMode == MeasureSpec.EXACTLY) || (mViewPager == null)) {
            //We were told how big to be
            result = specSize;
        } else {
            //Calculate the width according the views count
            final int count = mViewPager.getAdapter().getCount();
            result = (int) (getPaddingLeft() + getPaddingRight()
                    + (count * 2 * mRadius) + (count - 1) * mRadius + 1);
            //Respect AT_MOST value if that was what is called for by measureSpec
            if (specMode == MeasureSpec.AT_MOST) {
                result = Math.min(result, specSize);
            }
        }
        return result;
    }

    /**
     * Determines the height of this view
     *
     * @param measureSpec A measureSpec packed into an int
     * @return The height of the view, honoring constraints from measureSpec
     */
    private int measureShort(int measureSpec) {
        int result;
        int specMode = MeasureSpec.getMode(measureSpec);
        int specSize = MeasureSpec.getSize(measureSpec);

        if (specMode == MeasureSpec.EXACTLY) {
            //We were told how big to be
            result = specSize;
        } else {
            //Measure the height
            result = (int) (2 * mRadius + getPaddingTop() + getPaddingBottom() + 1);
            //Respect AT_MOST value if that was what is called for by measureSpec
            if (specMode == MeasureSpec.AT_MOST) {
                result = Math.min(result, specSize);
            }
        }
        return result;
    }

    @Override
    public void onRestoreInstanceState(Parcelable state) {
        SavedState savedState = (SavedState) state;
        super.onRestoreInstanceState(savedState.getSuperState());
        mCurrentPage = savedState.currentPage;
        mSnapPage = savedState.currentPage;
        requestLayout();
    }

    @Override
    public Parcelable onSaveInstanceState() {
        Parcelable superState = super.onSaveInstanceState();
        SavedState savedState = new SavedState(superState);
        savedState.currentPage = mCurrentPage;
        return savedState;
    }

    static class SavedState extends BaseSavedState {
        int currentPage;

        public SavedState(Parcelable superState) {
            super(superState);
        }

        private SavedState(Parcel in) {
            super(in);
            currentPage = in.readInt();
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            super.writeToParcel(dest, flags);
            dest.writeInt(currentPage);
        }

        @SuppressWarnings("UnusedDeclaration")
        public static final Parcelable.Creator<SavedState> CREATOR = new Parcelable.Creator<SavedState>() {
            @Override
            public SavedState createFromParcel(Parcel in) {
                return new SavedState(in);
            }

            @Override
            public SavedState[] newArray(int size) {
                return new SavedState[size];
            }
        };
    }

    public void changeLayoutParams() {
        ViewGroup.LayoutParams p = getLayoutParams();

        if (p == null) {
            p = newIndicatorParams();
            setLayoutParams(p);
            return;
        }

        setMarginAndWidth((ViewGroup.MarginLayoutParams) p);

        requestLayout();
    }


    private ViewGroup.LayoutParams newIndicatorParams() {
        ViewGroup.MarginLayoutParams ret = new ViewGroup.MarginLayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        setMarginAndWidth(ret);

        return ret;
    }


    private void setMarginAndWidth(ViewGroup.MarginLayoutParams p) {
        ViewGroup.MarginLayoutParams marginLayoutParams = (ViewGroup.MarginLayoutParams) mViewPager.getLayoutParams();

        p.setMargins(marginLayoutParams.leftMargin, mViewPager.getHeight() - DimenUtil.dpiToPx(20) + marginLayoutParams.topMargin, marginLayoutParams.rightMargin, marginLayoutParams.bottomMargin);

        if (mViewPager.getMeasuredWidth() > 0)
            p.width = mViewPager.getMeasuredWidth();
    }
}