/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.weight.newui;

import android.content.Context;

import androidx.annotation.IntDef;

import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.fun.constants.WrapType;
import com.immomo.mls.fun.weight.ILimitSizeView;
import com.immomo.mls.fun.weight.IPriorityObserver;
import com.immomo.mls.weight.flex.FlexLayoutWrapHelper;
import com.immomo.mls.weight.flex.IFlexLayoutHelper;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;


/**
 * Created by zhang.ke on 2020/3/11
 */
public abstract class BaseRowColumn extends ViewGroup implements ILimitSizeView, IPriorityObserver {
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

    private int crossAxisAlignment = CrossAxisAlignment.START;
    private int mainAxisAlignment = MainAxisAlignment.START;
    private int wrap = WrapType.NOT_WRAP; //排列方式：单行不换行（默认）、自动换行
    private boolean ellipsize = false;//省略排列
    private View ellipsizeView;//自定义省略view

    private IFlexLayoutHelper flexLayoutHelper;

    private int mUsedLenght;

    public BaseRowColumn(Context context) {
        super(context);
        init();
    }

    public BaseRowColumn(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public BaseRowColumn(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        flexLayoutHelper = new FlexLayoutWrapHelper(this);
    }

    public int getCrossAxisAlignment() {
        return crossAxisAlignment;
    }

    public void setCrossAxisAlignment(int crossAxisAlignment) {
        this.crossAxisAlignment = crossAxisAlignment;
    }

    public int getMainAxisAlignment() {
        return mainAxisAlignment;
    }

    public void setMainAxisAlignment(int mainAxisAlignment) {
        this.mainAxisAlignment = mainAxisAlignment;
    }

    public void setWrap(int wrap) {
        this.wrap = wrap;
    }

    public int getWrap() {
        return wrap;
    }

    public void ellipsize(boolean enable, View ellipsizeView) {
        this.ellipsize = enable;
        this.ellipsizeView = ellipsizeView;
    }

    public boolean isEllipsize() {
        return ellipsize;
    }

    public View getEllipsizeView() {
        return ellipsizeView;
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

    public View getPriorityChildAt(int index) {
        return childCount > index ? children[index] : null;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        widthMeasureSpec = getSpec(widthMeasureSpec, (int) mMaxWidth);
        heightMeasureSpec = getSpec(heightMeasureSpec, (int) mMaxHeight);
        if (mOrientation == VERTICAL) {
            flexLayoutHelper.measureVertical(widthMeasureSpec, heightMeasureSpec);
        } else {
            flexLayoutHelper.measureHorizontal(widthMeasureSpec, heightMeasureSpec);
        }
    }

    public void measureChildBeforeLayout(View child, int childIndex,
                                         int widthMeasureSpec, int totalWidth, int heightMeasureSpec,
                                         int totalHeight) {
        measureChildWithMargins(child, widthMeasureSpec, totalWidth,
            heightMeasureSpec, totalHeight);
    }

    @Override
    public int getSuggestedMinimumHeight() {
        return super.getSuggestedMinimumHeight();
    }

    @Override
    public int getSuggestedMinimumWidth() {
        return super.getSuggestedMinimumWidth();
    }

    public void setMeasuredDimensionX(int measuredWidth, int measuredHeight) {
        super.setMeasuredDimension(measuredWidth, measuredHeight);
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
            flexLayoutHelper.layoutVertical(l, t, r, b);
        } else {
            flexLayoutHelper.layoutHorizontal(l, t, r, b);
        }
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
        return p instanceof BaseRowColumn.LayoutParams;
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
