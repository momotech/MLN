/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.weight.flex;


import android.view.Gravity;
import android.view.View;
import android.view.View.MeasureSpec;
import android.view.ViewGroup;

import com.immomo.mls.fun.constants.WrapType;
import com.immomo.mls.fun.weight.ILimitSizeView;
import com.immomo.mls.fun.weight.newui.BaseRowColumn;
import com.immomo.mls.fun.weight.newui.BaseRowColumn.LayoutParams;
import com.immomo.mls.fun.weight.newui.CrossAxisAlignment;
import com.immomo.mls.fun.weight.newui.ISpacer;
import com.immomo.mls.fun.weight.newui.MainAxisAlignment;

import static android.view.View.GONE;

/**
 * Created by zhang.ke
 * on 2020-04-08
 */
public abstract class FlexLayoutHelper implements IFlexLayoutHelper {
    protected final BaseRowColumn view;

    private int mUsedLenght;

    FlexLayoutHelper(BaseRowColumn baseRowColumn) {
        this.view = baseRowColumn;
    }

    @Override
    public void measureVertical(int widthMeasureSpec, int heightMeasureSpec) {
        mUsedLenght = 0;
        final int widthMode = MeasureSpec.getMode(widthMeasureSpec);
        final int mPaddingTop = view.getPaddingTop();
        final int mPaddingBottom = view.getPaddingBottom();
        final int mPaddingLeft = view.getPaddingLeft();
        final int mPaddingRight = view.getPaddingRight();
        int maxWidth = 0;
        int childState = 0;

        int totalWeight = 0;
        int weightViewLen = 0;
        int nonWeightViewHeight = 0;
        int maxChildWidth;

        final int count = view.getChildCount();
        for (int i = 0; i < count; ++i) {
            final View child = view.getPriorityChildAt(i);
            if (child == null || child.getVisibility() == View.GONE
                || (child instanceof ISpacer && ((ISpacer) child).isVerExpand())) {//扩展Spacer，不参与测量
                continue;
            }

            final LayoutParams lp = (LayoutParams) child.getLayoutParams();
            view.measureChildBeforeLayout(child, i, widthMeasureSpec, 0,
                heightMeasureSpec, mUsedLenght);
            final int childHeight = child.getMeasuredHeight();
            mUsedLenght = Math.max(mUsedLenght, childHeight + mUsedLenght + lp.topMargin + lp.bottomMargin);

            final int margin = lp.leftMargin + lp.rightMargin;
            final int measuredWidth = child.getMeasuredWidth() + margin;
            maxWidth = Math.max(maxWidth, measuredWidth);

            childState = View.combineMeasuredStates(childState, child.getMeasuredState());

            nonWeightViewHeight += lp.topMargin + lp.bottomMargin;
            if (lp.weight > 0 && lp.height < 0) {
                totalWeight += lp.weight;
                weightViewLen++;
            } else {
                nonWeightViewHeight += childHeight;
            }
        }

        mUsedLenght += mPaddingTop + mPaddingBottom;
        mUsedLenght = Math.max(mUsedLenght, view.getSuggestedMinimumHeight());

        maxChildWidth = maxWidth;
        maxWidth += mPaddingLeft + mPaddingRight;
        maxWidth = Math.max(maxWidth, view.getSuggestedMinimumWidth());

        int measuredHeight = View.resolveSizeAndState(mUsedLenght, heightMeasureSpec, 0);
        view.setMeasuredDimensionX(View.resolveSizeAndState(maxWidth, widthMeasureSpec, childState), measuredHeight);

        if (weightViewLen > 0) {
            int mh = view.getMeasuredHeight() - nonWeightViewHeight - mPaddingTop - mPaddingBottom;
            if (mh > 0) {
                float piece = ((float) mh) / totalWeight;
                for (int i = 0; i < count; i++) {
                    final View child = view.getPriorityChildAt(i);
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
                        child.measure(ViewGroup.getChildMeasureSpec(widthMeasureSpec, mPaddingLeft + mPaddingRight + lp.leftMargin + lp.rightMargin, lp.width),
                            MeasureSpec.makeMeasureSpec(h, MeasureSpec.EXACTLY));
                        maxChildWidth = Math.max(maxChildWidth, child.getMeasuredWidth() + lp.leftMargin + lp.rightMargin);
                    }
                }
                maxChildWidth += mPaddingLeft + mPaddingRight;
                view.setMeasuredDimensionX(View.resolveSizeAndState(maxChildWidth, widthMeasureSpec, 0), measuredHeight);
            }
        }

    }

    @Override
    public void measureHorizontal(int widthMeasureSpec, int heightMeasureSpec) {
        mUsedLenght = 0;
        final int heightMode = MeasureSpec.getMode(heightMeasureSpec);
        final int mPaddingTop = view.getPaddingTop();
        final int mPaddingBottom = view.getPaddingBottom();
        final int mPaddingLeft = view.getPaddingLeft();
        final int mPaddingRight = view.getPaddingRight();
        int maxHeight = 0;
        int childState = 0;

        int totalWeight = 0;
        int weightViewLen = 0;
        int nonWeightViewWidth = 0;
        int maxChildHeight;

        final int count = view.getChildCount();
        for (int i = 0; i < count; ++i) {
            final View child = view.getPriorityChildAt(i);
            if (child == null || child.getVisibility() == View.GONE
                || (child instanceof ISpacer && ((ISpacer) child).isHorExpand())) {//扩展Spacer，不参与测量
                continue;
            }

            final LayoutParams lp = (LayoutParams) child.getLayoutParams();
            view.measureChildBeforeLayout(child, i, widthMeasureSpec, mUsedLenght,
                heightMeasureSpec, 0);
            final int childWidth = child.getMeasuredWidth();
            mUsedLenght = Math.max(mUsedLenght, childWidth + mUsedLenght + lp.leftMargin + lp.rightMargin);

            final int margin = lp.topMargin + lp.bottomMargin;
            final int measuredHeight = child.getMeasuredHeight() + margin;
            maxHeight = Math.max(maxHeight, measuredHeight);

            childState = View.combineMeasuredStates(childState, child.getMeasuredState());
            nonWeightViewWidth += lp.leftMargin + lp.rightMargin;
            if (lp.weight > 0 && lp.width < 0) {
                totalWeight += lp.weight;
                weightViewLen++;
            } else {
                nonWeightViewWidth += childWidth;
            }
        }

        mUsedLenght += mPaddingLeft + mPaddingRight;
        mUsedLenght = Math.max(mUsedLenght, view.getSuggestedMinimumWidth());

        maxChildHeight = maxHeight;
        maxHeight += mPaddingTop + mPaddingBottom;
        maxHeight = Math.max(maxHeight, view.getSuggestedMinimumHeight());

        int measuredWidth = View.resolveSizeAndState(mUsedLenght, widthMeasureSpec, 0);
        view.setMeasuredDimensionX(measuredWidth, View.resolveSizeAndState(maxHeight, heightMeasureSpec, childState));
        if (weightViewLen > 0) {
            int mw = view.getMeasuredWidth() - nonWeightViewWidth - mPaddingLeft - mPaddingRight;
            if (mw > 0) {
                float piece = ((float) mw) / totalWeight;
                for (int i = 0; i < count; i++) {
                    final View child = view.getPriorityChildAt(i);
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
                            ViewGroup.getChildMeasureSpec(heightMeasureSpec,
                                mPaddingTop + mPaddingBottom + lp.topMargin + lp.bottomMargin, lp.height));
                        maxChildHeight = Math.max(maxChildHeight, child.getMeasuredHeight() + lp.topMargin + lp.bottomMargin);
                    }
                }
                maxChildHeight += mPaddingTop + mPaddingBottom;
                view.setMeasuredDimensionX(measuredWidth, View.resolveSizeAndState(maxChildHeight, heightMeasureSpec, 0));
            }
        }

    }

    @Override
    public void layoutVertical(int left, int top, int right, int bottom) {
        final int paddingLeft = view.getPaddingLeft();
        int mPaddingTop = view.getPaddingTop();
        final int mPaddingBottom = view.getPaddingBottom();
        final int mPaddingRight = view.getPaddingRight();
        final int minorGravity;

        int usedHeight = mPaddingTop;
        boolean useSpace = false;//使用Space枚举
        int expandSpacerCount = 0;//子View中有扩展Spacer组件数量

        float childTop;
        float childLeft;

        final int width = right - left;
        int childRight = width - mPaddingRight;

        int childSpace = width - paddingLeft - mPaddingRight;

        final int count = view.getChildCount();

        switch (view.getMainAxisAlignment()) {
            case MainAxisAlignment.END:
                // mTotalLength contains the padding already
                childTop = mPaddingTop + bottom - top - mUsedLenght;
                break;

            // mTotalLength contains the padding already
            case MainAxisAlignment.CENTER:
                childTop = mPaddingTop + (bottom - top - mUsedLenght) / 2f;
                break;
            case MainAxisAlignment.SPACE_BETWEEN://中间平分
            case MainAxisAlignment.SPACE_AROUND://两边1/2，中间平分
            case MainAxisAlignment.SPACE_EVENLY://两边平分
                childTop = mPaddingTop;
                useSpace = true;
                break;
            case MainAxisAlignment.START:
            default:
                childTop = mPaddingTop;
                break;
        }

        switch (view.getCrossAxisAlignment()) {//主轴和交叉轴概念，和gravity有差异。根据方向转换为Gravity
            case CrossAxisAlignment.END:
                minorGravity = Gravity.RIGHT;//下面判断用的是Right
                break;
            case CrossAxisAlignment.CENTER:
                minorGravity = Gravity.CENTER_HORIZONTAL;
                break;

            case CrossAxisAlignment.START:
            default:
                minorGravity = Gravity.LEFT;//下面判断用的是Left
                break;
        }

        for (int i = 0; i < count; i++) {
            final View child = view.getChildAt(i);
            if (child instanceof ISpacer && ((ISpacer) child).isVerExpand()) {//扩展Spacer，不参与第一次布局
                ++expandSpacerCount;
                continue;
            }

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
                        childLeft = paddingLeft + ((childSpace - childWidth) / 2f)
                            + lp.leftMargin - lp.rightMargin;
                        break;
                    case Gravity.RIGHT:
                        childLeft = childRight - childWidth - lp.rightMargin;
                        break;
                    case Gravity.LEFT:
                        childLeft = paddingLeft + lp.leftMargin;
                        break;
                    default:
                        final int absoluteMinorGravity = Gravity.getAbsoluteGravity(minorGravity, 0);
                        switch (absoluteMinorGravity & Gravity.HORIZONTAL_GRAVITY_MASK) {
                            case Gravity.CENTER_HORIZONTAL:
                                childLeft = paddingLeft + ((childSpace - childWidth) / 2f)
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
                        break;
                }

                childTop += lp.topMargin;
                setChildFrame(child, (int) Math.ceil(childLeft), (int) Math.ceil(childTop), childWidth, childHeight);
                childTop += childHeight + lp.bottomMargin;
                //记录使用高度
                usedHeight += lp.topMargin + childHeight + lp.bottomMargin;
            }
        }

        if (!useSpace && expandSpacerCount == 0 || count <= 0)
            return;

        int measuredHeight = view.getMeasuredHeight();
        int totalSpace = measuredHeight - usedHeight - mPaddingBottom;

        if (totalSpace > 0) {//有剩余区域
            childTop = mPaddingTop;//重制childTop
            if (expandSpacerCount > 0) {//扩展的Spacer，和SPACE_XXX枚举冲突
                layoutVerSpacer(childTop, totalSpace, expandSpacerCount, 0, count);
            } else {
                layoutVerSpaceType(childTop, totalSpace, 0, count);
            }
        }
    }

    //处理Spacer布局
    void layoutVerSpacer(float childTop, float totalSpace, int expandSpacerCount, int start, int count) {
        float spacerHeight = totalSpace / expandSpacerCount;


        for (int i = start; i < count; i++) {//重新布局，加入space
            final View child = view.getChildAt(i);
            if (child != null && child.getVisibility() != GONE) {
                final int childWidth = child.getMeasuredWidth();
                float childHeight = child.getMeasuredHeight();
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                childTop += lp.topMargin;

                if (child instanceof ISpacer && ((ISpacer) child).isVerExpand() && notWrap()) {//wrap下，spacer不生效
                    childHeight = spacerHeight;
                }

                setChildFrame(child, child.getLeft(), (int) Math.ceil(childTop), childWidth, (int) Math.ceil(childHeight));
                childTop += childHeight + lp.bottomMargin;
            }
        }
    }

    //处理SPACE_XXX系列枚举布局
    void layoutVerSpaceType(float childTop, float totalSpace, int start, int end) {
        float edgeSpace = 0;
        float betweenSpace = 0;
        final int count = end - start;

        switch (view.getMainAxisAlignment()) {
            case MainAxisAlignment.SPACE_BETWEEN://中间平分
                if (count > 1)
                    betweenSpace = totalSpace / (count - 1);
                break;
            case MainAxisAlignment.SPACE_AROUND://两边1/2，中间平分
                if (count > 1) {
                    betweenSpace = totalSpace / count;
                    edgeSpace = betweenSpace / 2f;
                } else {
                    edgeSpace = totalSpace / 2f;
                }
                break;
            case MainAxisAlignment.SPACE_EVENLY://两边平分
                edgeSpace = betweenSpace = totalSpace / (count + 1);
                break;
        }


        final int realCount = view.getChildCount();
        for (int i = start; i < end && end <= realCount; i++) {//重新布局，加入space
            final View child = view.getChildAt(i);
            if (child != null && child.getVisibility() != GONE) {
                final int childWidth = child.getMeasuredWidth();
                final int childHeight = child.getMeasuredHeight();
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();


                if (i == start) {
                    childTop += lp.topMargin + edgeSpace;
                } else {
                    childTop += lp.topMargin + betweenSpace;
                }

                setChildFrame(child, child.getLeft(), (int) Math.ceil(childTop), childWidth, childHeight);
                childTop += childHeight + lp.bottomMargin;
            }
        }
    }

    @Override
    public void layoutHorizontal(int left, int top, int right, int bottom) {
        final boolean isEllipsize = view.isEllipsize();
        View ellipsizeView = null;
        int ellipsizeViewWidth = 0;
        LayoutParams ellipsizeLP = null;
        if (isEllipsize) {
            ellipsizeView = view.getEllipsizeView();
            ellipsizeViewWidth = ellipsizeView != null ? ellipsizeView.getMeasuredWidth() : 0;
            ellipsizeLP = ellipsizeView != null ? (LayoutParams) ellipsizeView.getLayoutParams() : null;
        }

        int measuredWidth = view.getMeasuredWidth();
        final int mPaddingBottom = view.getPaddingBottom();
        final int paddingTop = view.getPaddingTop();
        int mPaddingLeft = view.getPaddingLeft();
        final int mPaddingRight = view.getPaddingRight();
        int minorGravity;

        int usedWidth = mPaddingLeft;
        boolean useSpace = false;
        int expandSpacerCount = 0;//子View中有扩展Spacer组件数量

        float childTop;
        float childLeft;

        final int height = bottom - top;
        int childBottom = height - mPaddingBottom;

        int childSpace = height - paddingTop - mPaddingBottom;

        switch (view.getMainAxisAlignment()) {
            case MainAxisAlignment.END:
                // mTotalLength contains the padding already
                childLeft = mPaddingLeft + right - left - mUsedLenght;
                break;

            case MainAxisAlignment.CENTER:
                // mTotalLength contains the padding already
                childLeft = mPaddingLeft + (right - left - mUsedLenght) / 2f;
                break;
            case MainAxisAlignment.SPACE_BETWEEN://中间平分
            case MainAxisAlignment.SPACE_AROUND://两边1/2，中间平分
            case MainAxisAlignment.SPACE_EVENLY://两边平分
                childLeft = mPaddingLeft;
                useSpace = true;
                break;
            case MainAxisAlignment.START:
            default:
                childLeft = mPaddingLeft;
                break;
        }

        switch (view.getCrossAxisAlignment()) {//主轴和交叉轴概念，和gravity有差异。根据方向转换为Gravity
            case CrossAxisAlignment.END:
                minorGravity = Gravity.BOTTOM;
                break;
            case CrossAxisAlignment.CENTER:
                minorGravity = Gravity.CENTER_VERTICAL;
                break;

            case CrossAxisAlignment.START:
            default:
                minorGravity = Gravity.TOP;
                break;
        }

        boolean hasOpenEllip = false;
        float ellipChildTop = 0;

        final int count = view.getChildCount();
        for (int i = 0; i < count; i++) {
            final View child = view.getChildAt(i);
            if (child instanceof ISpacer && ((ISpacer) child).isHorExpand()) { //伸展的Spacer，不参与第一次布局
                ++expandSpacerCount;
                continue;
            }

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
                        childTop = paddingTop + ((childSpace - childHeight) / 2f)
                            + lp.topMargin - lp.bottomMargin;
                        break;

                    case Gravity.BOTTOM:
                        childTop = childBottom - childHeight - lp.bottomMargin;
                        break;
                    default:
                        switch (minorGravity & Gravity.VERTICAL_GRAVITY_MASK) {
                            case Gravity.TOP:
                                childTop = paddingTop + lp.topMargin;
                                break;
                            case Gravity.CENTER_VERTICAL:
                                childTop = paddingTop + ((childSpace - childHeight) / 2f)
                                    + lp.topMargin - lp.bottomMargin;
                                break;

                            case Gravity.BOTTOM:
                                childTop = childBottom - childHeight - lp.bottomMargin;
                                break;
                            default:
                                childTop = paddingTop;
                                break;
                        }
                        break;
                }

                if (isEllipsize && ellipsizeView != null) {
                    if (child == ellipsizeView && (i < (count - 1))) {//ellipsizeView不参与布局
                        ellipChildTop = childTop;
                        setChildFrame(child, 0, 0, 0, 0);
                        continue;
                    } else if (hasOpenEllip || notWrap() &&
                            (usedWidth + lp.leftMargin + childWidth + lp.rightMargin) > (measuredWidth - (ellipsizeViewWidth + ellipsizeLP.leftMargin + ellipsizeLP.rightMargin))) {

                        if (i == (count - 1)) {//最后一个view 放置ellipsizeView
                            childLeft += ellipsizeLP.leftMargin;
                            setChildFrame(ellipsizeView, (int) Math.ceil(childLeft), (int) Math.ceil(ellipChildTop), ellipsizeViewWidth, ellipsizeView.getMeasuredHeight());
                            childLeft += ellipsizeViewWidth + ellipsizeLP.rightMargin;

                            //记录使用宽度
                            usedWidth += ellipsizeLP.leftMargin + ellipsizeViewWidth + ellipsizeLP.rightMargin;
                        } else {//其他view 不布局
                            setChildFrame(child, 0, 0, 0, 0);
                        }
                        hasOpenEllip = true;
                        continue;
                    }
                }

                childLeft += lp.leftMargin;
                setChildFrame(child, (int) Math.ceil(childLeft), (int) Math.ceil(childTop), childWidth, childHeight);
                childLeft += childWidth + lp.rightMargin;
                //记录使用宽度
                usedWidth += lp.leftMargin + childWidth + lp.rightMargin;
            }
        }

        if (isEllipsize) {
            return;
        }

        if (!useSpace && expandSpacerCount == 0 || count <= 0)
            return;

        int totalSpace = measuredWidth - usedWidth - mPaddingRight;

        if (totalSpace > 0) {//有剩余区域
            childLeft = mPaddingLeft;//重制childLeft
            if (expandSpacerCount > 0) {//扩展的Spacer，和SPACE_XXX枚举冲突
                layoutHorSpacer(childLeft, totalSpace, expandSpacerCount, 0, count);
            } else {
                layoutHorSpaceType(childLeft, totalSpace, 0, count);
            }
        }
    }

    //处理Spacer布局
    void layoutHorSpacer(float childLeft, float totalSpace, int expandSpacerCount, int start, int count) {
        float spacerWidth = totalSpace / expandSpacerCount;

        for (int i = start; i < count; i++) {//重新布局，加入space
            final View child = view.getChildAt(i);
            if (child != null && child.getVisibility() != GONE) {
                float childWidth = child.getMeasuredWidth();
                final int childHeight = child.getMeasuredHeight();
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                childLeft += lp.leftMargin;

                if (child instanceof ISpacer && ((ISpacer) child).isHorExpand() && notWrap()) {//wrap下，spacer不生效
                    childWidth = spacerWidth;
                }

                setChildFrame(child, (int) Math.ceil(childLeft), child.getTop(), (int) Math.ceil(childWidth), childHeight);
                childLeft += childWidth + lp.rightMargin;
            }
        }
    }

    //处理SPACE_XXX系列枚举布局
    void layoutHorSpaceType(float childLeft, float totalSpace, int start, int end) {
        float edgeSpace = 0;
        float betweenSpace = 0;
        final int count = end - start;

        switch (view.getMainAxisAlignment()) {
            case MainAxisAlignment.SPACE_BETWEEN://中间平分
                if (count > 1)
                    betweenSpace = totalSpace / (count - 1);
                break;
            case MainAxisAlignment.SPACE_AROUND://两边1/2，中间平分
                if (count > 1) {
                    betweenSpace = totalSpace / count;
                    edgeSpace = betweenSpace / 2f;
                } else {
                    edgeSpace = totalSpace / 2f;
                }
                break;
            case MainAxisAlignment.SPACE_EVENLY://两边平分
                edgeSpace = betweenSpace = totalSpace / (count + 1);
                break;
        }

        final int realCount = view.getChildCount();
        for (int i = start; i < end && end <= realCount; i++) {
            final View child = view.getChildAt(i);
            if (child != null && child.getVisibility() != GONE) {
                final int childWidth = child.getMeasuredWidth();
                final int childHeight = child.getMeasuredHeight();
                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                if (i == start) {
                    childLeft += lp.leftMargin + edgeSpace;
                } else {
                    childLeft += lp.leftMargin + betweenSpace;
                }

                setChildFrame(child, (int) (Math.ceil(childLeft)), child.getTop(), childWidth, childHeight);
                childLeft += childWidth + lp.rightMargin;
            }
        }
    }


    boolean notWrap() {
        return view.getWrap() == WrapType.NOT_WRAP;
    }

    void setChildFrame(View child, int left, int top, int width, int height) {
        child.layout(left, top, left + width, top + height);
    }
}
