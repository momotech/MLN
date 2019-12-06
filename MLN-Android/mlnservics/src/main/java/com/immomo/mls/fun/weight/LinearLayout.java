/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.weight;

import android.content.Context;

import androidx.annotation.IntDef;

import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Created by Xiong.Fangyu on 2018/10/26
 */
public class LinearLayout extends ViewGroup implements ILimitSizeView, IPriorityObserver {
    private static final float DEFAULT_LOAD_FACTOR = 0.75f;

    @IntDef({HORIZONTAL, VERTICAL})
    @Retention(RetentionPolicy.SOURCE)
    public @interface OrientationMode {
    }

    public static final int HORIZONTAL = 0;
    public static final int VERTICAL = 1;

    private @OrientationMode
    int mOrientation = HORIZONTAL;

    private int mMaxWidth = Integer.MAX_VALUE;
    private int mMaxHeight = Integer.MAX_VALUE;

    private View[] children = new View[10];
    private int childCount = 0;

    public LinearLayout(Context context) {
        super(context);
    }

    public void setOrientation(@OrientationMode int orientation) {
        if (mOrientation != orientation) {
            mOrientation = orientation;
            requestLayout();
        }
    }

    @OrientationMode
    public int getOrientation() {
        return mOrientation;
    }

    @Override
    public void setMaxWidth(int mMaxWidth) {
        this.mMaxWidth = mMaxWidth;
    }

    @Override
    public void setMaxHeight(int mMaxHeight) {
        this.mMaxHeight = mMaxHeight;
    }

    @Override
    public int getMaxWidth() {
        return mMaxWidth;
    }

    @Override
    public int getMaxHeight() {
        return mMaxHeight;
    }

    @Override
    public void addView(View child, int index, ViewGroup.LayoutParams params) {
        if (!(params instanceof LayoutParams)) {
            params = generateLayoutParams(params);
        }
        LayoutParams lp = (LayoutParams) params;
        lp.index = childCount;
        addViewToArray(child, lp);
        super.addView(child, index, params);
    }

    @Override
    public void removeView(View child) {
        removeViewFromArray(child);
        super.removeView(child);
    }

    @Override
    public void removeViewInLayout(View v) {
        removeViewFromArray(v);
        super.removeViewInLayout(v);
    }

    @Override
    public void removeAllViews() {
        removeAllViewFromArray();
        super.removeAllViews();
    }

    @Override
    public void onViewPriorityChanged(View child, int oldPriority, int newPriority) {
        int oldIndex = -1;
        for (int i = 0; i < childCount; i++) {
            if (children[i] == child) {
                oldIndex = i;
                break;
            }
        }
        if (oldIndex == -1) {
            throw new IllegalStateException("Is the child added in this layout?");
        }
        if (newPriority > oldPriority) {
            if (oldIndex == 0)
                return;
            boolean inserted = false;
            for (int i = oldIndex - 1; i >= 0; i--) {
                View pre = children[i];
                int prePriority = ((LayoutParams) pre.getLayoutParams()).priority;
                if (prePriority >= newPriority) {
                    children[i + 1] = child;
                    inserted = true;
                    break;
                }
                children[i + 1] = pre;
            }
            if (!inserted) {
                children[0] = child;
            }
        } else {
            if (oldIndex == childCount - 1)
                return;
            boolean inserted = false;
            for (int i = oldIndex + 1; i < childCount; i++) {
                View after = children[i];
                int afterPriority = ((LayoutParams) after.getLayoutParams()).priority;
                if (afterPriority < newPriority) {
                    children[i - 1] = child;
                    inserted = true;
                    break;
                }
                children[i - 1] = after;
            }
            if (!inserted) {
                children[childCount - 1] = child;
            }
        }
    }

    private void addViewToArray(View child, LayoutParams params) {
        if (childCount == children.length) {
            resizeChildrenArray();
        }
        final int priority = params.priority;
        int insertIndex = childCount - 1;
        for (; insertIndex >= 0; insertIndex--) {
            LayoutParams cp = (LayoutParams) children[insertIndex].getLayoutParams();
            if (cp.priority >= priority) {
                break;
            }
        }
        insertIndex++;
        System.arraycopy(children, insertIndex, children, insertIndex + 1, childCount - insertIndex);
        children[insertIndex] = child;
        childCount++;
    }

    private void removeViewFromArray(View child) {
        boolean find = false;
        int index;
        for (index = 0; index < childCount; index++) {
            if (!find && children[index] == child) {
                find = true;
            } else if (find) {
                children[index - 1] = children[index];
            }
        }
        children[childCount - 1] = null;
        childCount--;
    }

    private void removeAllViewFromArray() {
        for (int index = 0; index < childCount; index++) {
            children[index] = null;
        }
        childCount = 0;
    }

    private void resizeChildrenArray() {
        int old = children.length;
        int newlen = (int) (old * DEFAULT_LOAD_FACTOR) + old;
        View[] temp = new View[newlen];
        System.arraycopy(children, 0, temp, 0, old);
        children = temp;
    }

    protected View getPriorityChildAt(int index) {
        return childCount > index ? children[index] : null;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        widthMeasureSpec = getSpec(widthMeasureSpec, (int) mMaxWidth);
        heightMeasureSpec = getSpec(heightMeasureSpec, (int) mMaxHeight);
        if (mOrientation == VERTICAL) {
            measureVertical(widthMeasureSpec, heightMeasureSpec);
        } else {
            measureHorizontal(widthMeasureSpec, heightMeasureSpec);
        }
    }

    private void measureVertical(int widthMeasureSpec, int heightMeasureSpec) {
        int usedHeight = 0;
        final int widthMode = MeasureSpec.getMode(widthMeasureSpec);
        final int mPaddingTop = getPaddingTop();
        final int mPaddingBottom = getPaddingBottom();
        final int mPaddingLeft = getPaddingLeft();
        final int mPaddingRight = getPaddingRight();
        int maxWidth = 0;
        int childState = 0;
        boolean matchWidth = false;

        int totalWeight = 0;
        int weightViewLen = 0;
        int nonWeightViewHeight = 0;
        int maxChildWidth;

        final int count = childCount;
        for (int i = 0; i < count; ++i) {
            final View child = getPriorityChildAt(i);
            if (child == null || child.getVisibility() == View.GONE) {
                continue;
            }

            final LayoutParams lp = (LayoutParams) child.getLayoutParams();
            measureChildBeforeLayout(child, i, widthMeasureSpec, 0,
                    heightMeasureSpec, usedHeight);
            final int childHeight = child.getMeasuredHeight();
            usedHeight = Math.max(usedHeight, childHeight + usedHeight + lp.topMargin + lp.bottomMargin);

            final int margin = lp.leftMargin + lp.rightMargin;
            final int measuredWidth = child.getMeasuredWidth() + margin;
            maxWidth = Math.max(maxWidth, measuredWidth);

            childState = combineMeasuredStates(childState, child.getMeasuredState());

            nonWeightViewHeight += lp.topMargin + lp.bottomMargin;
            if (lp.weight > 0 && lp.height < 0) {
                totalWeight += lp.weight;
                weightViewLen++;
            } else {
                nonWeightViewHeight += childHeight;
            }
            matchWidth = matchWidth || (widthMode != MeasureSpec.EXACTLY && lp.width == LayoutParams.MATCH_PARENT);
        }

        usedHeight += mPaddingTop + mPaddingBottom;
        usedHeight = Math.max(usedHeight, getSuggestedMinimumHeight());

        maxChildWidth = maxWidth;
        maxWidth += mPaddingLeft + mPaddingRight;
        maxWidth = Math.max(maxWidth, getSuggestedMinimumWidth());

        int measuredHeight = resolveSizeAndState(usedHeight, heightMeasureSpec, 0);
        setMeasuredDimension(resolveSizeAndState(maxWidth, widthMeasureSpec, childState), measuredHeight);

        if (weightViewLen > 0) {
            int mh = getMeasuredHeight() - nonWeightViewHeight - mPaddingTop - mPaddingBottom;
            if (mh > 0) {
                float piece = ((float) mh) / totalWeight;
                for (int i = 0; i < count; i++) {
                    final View child = getPriorityChildAt(i);
                    if (child == null || child.getVisibility() == View.GONE) {
                        continue;
                    }
                    final LayoutParams lp = (LayoutParams) child.getLayoutParams();
                    if (lp.weight > 0 && lp.height < 0) {
                        int h = (int) (piece * lp.weight);
                        h = Math.max(h, child.getMinimumHeight());
                        if (child instanceof ILimitSizeView) {
                            h = Math.min(h, ((ILimitSizeView) child).getMaxHeight());
                        }
                        child.measure(getChildMeasureSpec(widthMeasureSpec, mPaddingLeft + mPaddingRight + lp.leftMargin + lp.rightMargin, lp.width),
                                MeasureSpec.makeMeasureSpec(h, MeasureSpec.EXACTLY));
                        maxChildWidth = Math.max(maxChildWidth, child.getMeasuredWidth() + lp.leftMargin + lp.rightMargin);
                    }
                }
                maxChildWidth += mPaddingLeft + mPaddingRight;
                setMeasuredDimension(resolveSizeAndState(maxChildWidth, widthMeasureSpec, 0), measuredHeight);
            }
        }

        if (matchWidth) {
            forceUniformWidth(childCount, heightMeasureSpec);
        }
    }

    private void forceUniformWidth(int count, int heightMeasureSpec) {
        int uniformMeasureSpec = MeasureSpec.makeMeasureSpec(getMeasuredWidth(),
                MeasureSpec.EXACTLY);
        for (int i = 0; i < count; ++i) {
            final View child = getPriorityChildAt(i);
            if (child != null && child.getVisibility() != GONE) {
                LinearLayout.LayoutParams lp = ((LinearLayout.LayoutParams) child.getLayoutParams());

                if (lp.width == LayoutParams.MATCH_PARENT) {
                    int oldHeight = lp.height;
                    lp.height = child.getMeasuredHeight();

                    // Remeasue with new dimensions
                    measureChildWithMargins(child, uniformMeasureSpec, 0, heightMeasureSpec, 0);
                    lp.height = oldHeight;
                }
            }
        }
    }

    private void measureHorizontal(int widthMeasureSpec, int heightMeasureSpec) {
        int usedWidth = 0;
        final int heightMode = MeasureSpec.getMode(heightMeasureSpec);
        final int mPaddingTop = getPaddingTop();
        final int mPaddingBottom = getPaddingBottom();
        final int mPaddingLeft = getPaddingLeft();
        final int mPaddingRight = getPaddingRight();
        int maxHeight = 0;
        int childState = 0;
        boolean matchHeight = false;

        int totalWeight = 0;
        int weightViewLen = 0;
        int nonWeightViewWidth = 0;
        int maxChildHeight;

        final int count = childCount;
        for (int i = 0; i < count; ++i) {
            final View child = getPriorityChildAt(i);
            if (child == null || child.getVisibility() == View.GONE) {
                continue;
            }

            final LayoutParams lp = (LayoutParams) child.getLayoutParams();
            measureChildBeforeLayout(child, i, widthMeasureSpec, usedWidth,
                    heightMeasureSpec, 0);
            final int childWidth = child.getMeasuredWidth();
            usedWidth = Math.max(usedWidth, childWidth + usedWidth + lp.leftMargin + lp.rightMargin);

            final int margin = lp.topMargin + lp.bottomMargin;
            final int measuredHeight = child.getMeasuredHeight() + margin;
            maxHeight = Math.max(maxHeight, measuredHeight);

            childState = combineMeasuredStates(childState, child.getMeasuredState());
            nonWeightViewWidth += lp.leftMargin + lp.rightMargin;
            if (lp.weight > 0 && lp.width < 0) {
                totalWeight += lp.weight;
                weightViewLen++;
            } else {
                nonWeightViewWidth += childWidth;
            }
            matchHeight = matchHeight || (heightMode != MeasureSpec.EXACTLY && lp.height == LayoutParams.MATCH_PARENT);
        }

        usedWidth += mPaddingLeft + mPaddingRight;
        usedWidth = Math.max(usedWidth, getSuggestedMinimumWidth());

        maxChildHeight = maxHeight;
        maxHeight += mPaddingTop + mPaddingBottom;
        maxHeight = Math.max(maxHeight, getSuggestedMinimumHeight());

        int measuredWidth = resolveSizeAndState(usedWidth, widthMeasureSpec, 0);
        setMeasuredDimension(measuredWidth, resolveSizeAndState(maxHeight, heightMeasureSpec, childState));
        if (weightViewLen > 0) {
            int mw = getMeasuredWidth() - nonWeightViewWidth - mPaddingLeft - mPaddingRight;
            if (mw > 0) {
                float piece = ((float) mw) / totalWeight;
                for (int i = 0; i < count; i++) {
                    final View child = getPriorityChildAt(i);
                    if (child == null || child.getVisibility() == View.GONE) {
                        continue;
                    }
                    final LayoutParams lp = (LayoutParams) child.getLayoutParams();
                    if (lp.weight > 0 && lp.width < 0) {
                        int w = (int) (piece * lp.weight);
                        w = Math.max(w, child.getMinimumWidth());
                        if (child instanceof ILimitSizeView) {
                            w = Math.min(w, ((ILimitSizeView) child).getMaxWidth());
                        }
                        child.measure(MeasureSpec.makeMeasureSpec(w, MeasureSpec.EXACTLY),
                                getChildMeasureSpec(heightMeasureSpec,
                                        mPaddingTop + mPaddingBottom + lp.topMargin + lp.bottomMargin, lp.height));
                        maxChildHeight = Math.max(maxChildHeight, child.getMeasuredHeight() + lp.topMargin + lp.bottomMargin);
                    }
                }
                maxChildHeight += mPaddingTop + mPaddingBottom;
                setMeasuredDimension(measuredWidth, resolveSizeAndState(maxChildHeight, heightMeasureSpec, 0));
            }
        }

        if (matchHeight) {
            forceUniformHeight(childCount, widthMeasureSpec);
        }
    }

    private void forceUniformHeight(int count, int widthMeasureSpec) {
        int uniformMeasureSpec = MeasureSpec.makeMeasureSpec(getMeasuredHeight(),
                MeasureSpec.EXACTLY);
        for (int i = 0; i < count; ++i) {
            final View child = getPriorityChildAt(i);
            if (child != null && child.getVisibility() != GONE) {
                LinearLayout.LayoutParams lp = (LinearLayout.LayoutParams) child.getLayoutParams();

                if (lp.height == LayoutParams.MATCH_PARENT) {
                    int oldWidth = lp.width;
                    lp.width = child.getMeasuredWidth();

                    // Remeasure with new dimensions
                    measureChildWithMargins(child, widthMeasureSpec, 0, uniformMeasureSpec, 0);
                    lp.width = oldWidth;
                }
            }
        }
    }

    void measureChildBeforeLayout(View child, int childIndex,
                                  int widthMeasureSpec, int totalWidth, int heightMeasureSpec,
                                  int totalHeight) {
        measureChildWithMargins(child, widthMeasureSpec, totalWidth,
                heightMeasureSpec, totalHeight);
    }

    private int getSpec(int src, int max) {
        int mode = MeasureSpec.getMode(src);
        if (mode == MeasureSpec.EXACTLY)
            return src;
        int size = MeasureSpec.getSize(src);
        if (size > max) {
            return MeasureSpec.makeMeasureSpec(max, mode);
        }
        return src;
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        if (mOrientation == VERTICAL) {
            layoutVertical(l, t, r, b);
        } else {
            layoutHorizontal(l, t, r, b);
        }
    }

    void layoutVertical(int left, int top, int right, int bottom) {
        final int paddingLeft = getPaddingLeft();
        final int mPaddingRight = getPaddingRight();
        final int minorGravity = Gravity.TOP | Gravity.LEFT;

        int childTop = getPaddingTop();
        int childLeft;

        final int width = right - left;
        int childRight = width - mPaddingRight;

        int childSpace = width - paddingLeft - mPaddingRight;

        final int count = getChildCount();
        for (int i = 0; i < count; i++) {
            final View child = getChildAt(i);
            if (child != null && child.getVisibility() != GONE) {
                final int childWidth = child.getMeasuredWidth();
                final int childHeight = child.getMeasuredHeight();

                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                int gravity = lp.gravity;
                if (gravity < 0) {
                    gravity = minorGravity;
                }

                final int absoluteGravity = Gravity.getAbsoluteGravity(gravity, 0);
                switch (absoluteGravity & Gravity.HORIZONTAL_GRAVITY_MASK) {
                    case Gravity.CENTER_HORIZONTAL:
                        childLeft = paddingLeft + ((childSpace - childWidth) / 2)
                                + lp.leftMargin - lp.rightMargin;
                        break;
                    case Gravity.RIGHT:
                        childLeft = childRight - childWidth - lp.rightMargin;
                        break;
                    case Gravity.LEFT:
                    default:
                        childLeft = paddingLeft + lp.leftMargin;
                        break;
                }

                childTop += lp.topMargin;
                setChildFrame(child, childLeft, childTop, childWidth, childHeight);
                childTop += childHeight + lp.bottomMargin;
            }
        }
    }

    void layoutHorizontal(int left, int top, int right, int bottom) {
        final int mPaddingBottom = getPaddingBottom();
        final int paddingTop = getPaddingTop();
        final int minorGravity = Gravity.TOP | Gravity.LEFT;

        int childTop;
        int childLeft = getPaddingLeft();

        final int height = bottom - top;
        int childBottom = height - mPaddingBottom;

        int childSpace = height - paddingTop - mPaddingBottom;

        final int count = getChildCount();
        for (int i = 0; i < count; i++) {
            final View child = getChildAt(i);
            if (child != null && child.getVisibility() != GONE) {
                final int childWidth = child.getMeasuredWidth();
                final int childHeight = child.getMeasuredHeight();

                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                int gravity = lp.gravity;
                if (gravity < 0) {
                    gravity = minorGravity;
                }

                switch (gravity & Gravity.VERTICAL_GRAVITY_MASK) {
                    case Gravity.TOP:
                        childTop = paddingTop + lp.topMargin;
                        break;
                    case Gravity.CENTER_VERTICAL:
                        childTop = paddingTop + ((childSpace - childHeight) / 2)
                                + lp.topMargin - lp.bottomMargin;
                        break;

                    case Gravity.BOTTOM:
                        childTop = childBottom - childHeight - lp.bottomMargin;
                        break;
                    default:
                        childTop = paddingTop;
                        break;
                }

                childLeft += lp.leftMargin;
                setChildFrame(child, childLeft, childTop, childWidth, childHeight);
                childLeft += childWidth + lp.rightMargin;
            }
        }
    }

    private void setChildFrame(View child, int left, int top, int width, int height) {
        child.layout(left, top, left + width, top + height);
    }

    //<editor-fold desc="LayoutParams">
    @Override
    protected LayoutParams generateDefaultLayoutParams() {
        if (mOrientation == HORIZONTAL) {
            return new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        } else if (mOrientation == VERTICAL) {
            return new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        }
        return null;
    }

    @Override
    protected LayoutParams generateLayoutParams(ViewGroup.LayoutParams lp) {
        if (lp instanceof LayoutParams) {
            return new LayoutParams((LayoutParams) lp);
        } else if (lp instanceof MarginLayoutParams) {
            return new LayoutParams((MarginLayoutParams) lp);
        }
        return new LayoutParams(lp);
    }

    @Override
    protected boolean checkLayoutParams(ViewGroup.LayoutParams p) {
        return p instanceof LinearLayout.LayoutParams;
    }

    public static class LayoutParams extends ViewGroup.MarginLayoutParams {
        /**
         * 计算时的优先级
         */
        public int priority = 0;
        /**
         * 原始index
         */
        protected int index;
        /**
         * 占比
         */
        public int weight = 0;

        /**
         * Gravity for the view associated with these LayoutParams.
         *
         * @see android.view.Gravity
         */
        public int gravity = -1;

        /**
         * {@inheritDoc}
         */
        public LayoutParams(int width, int height) {
            super(width, height);
            priority = 0;
            weight = 0;
        }

        /**
         * Creates a new set of layout parameters with the specified width, height
         * and weight.
         *
         * @param width    the width, either {@link #MATCH_PARENT},
         *                 {@link #WRAP_CONTENT} or a fixed size in pixels
         * @param height   the height, either {@link #MATCH_PARENT},
         *                 {@link #WRAP_CONTENT} or a fixed size in pixels
         * @param priority the weight
         */
        public LayoutParams(int width, int height, int priority, int weight) {
            super(width, height);
            this.priority = priority;
            this.weight = weight;
        }

        /**
         * {@inheritDoc}
         */
        public LayoutParams(ViewGroup.LayoutParams p) {
            super(p);
        }

        /**
         * {@inheritDoc}
         */
        public LayoutParams(ViewGroup.MarginLayoutParams source) {
            super(source);
        }

        /**
         * Copy constructor. Clones the width, height, margin values, weight,
         * and gravity of the source.
         *
         * @param source The layout params to copy from.
         */
        public LayoutParams(LayoutParams source) {
            super(source);

            this.priority = source.priority;
            this.gravity = source.gravity;
            this.weight = source.weight;
        }
    }
    //</editor-fold>
}