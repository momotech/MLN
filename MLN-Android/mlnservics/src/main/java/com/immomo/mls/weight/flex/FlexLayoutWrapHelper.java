/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.weight.flex;


import android.util.SparseIntArray;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.fun.weight.ILimitSizeView;
import com.immomo.mls.fun.weight.newui.BaseRowColumn;
import com.immomo.mls.fun.weight.newui.CrossAxisAlignment;
import com.immomo.mls.fun.weight.newui.ISpacer;
import com.immomo.mls.fun.weight.newui.MainAxisAlignment;

import com.immomo.mls.fun.weight.newui.BaseRowColumn.LayoutParams;

import static android.view.View.GONE;


/**
 * Created by zhang.ke
 * on 2020-04-08
 */
public class FlexLayoutWrapHelper extends FlexLayoutHelper {
    protected SparseIntArray lines;//子view每一行的start、usedLenght
    private int maxTotalUsedLength;


    public FlexLayoutWrapHelper(BaseRowColumn view) {
        super(view);
    }

    @Override
    public void measureVertical(int widthMeasureSpec, int heightMeasureSpec) {
        if (notWrap()) {
            super.measureVertical(widthMeasureSpec, heightMeasureSpec);
            return;
        }

        final int count = view.getChildCount();

        if (lines == null) {//初始化行数记录
            lines = new SparseIntArray();
        } else
            lines.clear();

        final int mPaddingTop = view.getPaddingTop();
        final int mPaddingBottom = view.getPaddingBottom();
        final int mPaddingLeft = view.getPaddingLeft();
        final int mPaddingRight = view.getPaddingRight();
        final int mPaddingTB = mPaddingTop + mPaddingBottom;
        maxTotalUsedLength = 0;//记录每一行的最大高度
        int childState = 0;

        int totalWeight = 0;
        int weightViewLen = 0;
        int nonWeightViewHeight = 0;
        int maxChildWidth;

        //计算非Wrap_content
        int measuredHeight = View.resolveSizeAndState(0, heightMeasureSpec, 0);

        int maxChildHeight = 0;//wrap_content时，一列只有一个。高为最大的一个child高度
        int lineMaxWidth = 0;//记录每一行的最大宽度
        int lineUsedLength = 0;//每行使用高度
        int nextLineStart = 0;

        for (int i = 0; i < count; ++i) {
            final View child = view.getPriorityChildAt(i);
            if (child == null || child.getVisibility() == GONE) {
                continue;
            }

            final LayoutParams lp = (LayoutParams) child.getLayoutParams();
            view.measureChildBeforeLayout(child, i, widthMeasureSpec, 0,
                heightMeasureSpec, 0);

            final int childHeight;
            if (child instanceof ISpacer && ((ISpacer) child).isVerExpand()) {
                childHeight = 0;//扩展Spacer，不参与测量主轴
            } else {
                childHeight = child.getMeasuredHeight();
            }
            lineUsedLength = Math.max(lineUsedLength, childHeight + lineUsedLength + lp.topMargin + lp.bottomMargin);
            maxChildHeight = Math.max(maxChildHeight, childHeight + lp.topMargin + lp.bottomMargin);//记录最大宽度的子View宽度

            final int margin = lp.leftMargin + lp.rightMargin;
            final int measuredWidth = child.getMeasuredWidth() + margin;

            childState = View.combineMeasuredStates(childState, child.getMeasuredState());
            nonWeightViewHeight += lp.topMargin + lp.bottomMargin;
            if (lp.weight > 0 && lp.height < 0) {
                totalWeight += lp.weight;
                weightViewLen++;
            } else {
                nonWeightViewHeight += childHeight;
            }

            if ((lineUsedLength + mPaddingTB) > measuredHeight) {//每一行宽+ paddingTB> 容器宽，就换行

                int endPos = nextLineStart < i ? (i - 1) : nextLineStart;

                boolean samePos = nextLineStart == i;
                if (samePos) {//start和当前一致，表示一个View占了一行。无需减去此行
                    maxTotalUsedLength += measuredWidth;//计算容器最大宽度
                    lines.put(makeLineSpec(nextLineStart, lineUsedLength), makeLineSpec(endPos, measuredWidth));

                    ++nextLineStart;
                    lineMaxWidth = 0;
                    lineUsedLength = 0;
                } else {
                    maxTotalUsedLength += lineMaxWidth;//计算容器最大高度

                    lineUsedLength = lineUsedLength - (childHeight + lp.topMargin + lp.bottomMargin);
                    lines.put(makeLineSpec(nextLineStart, lineUsedLength), makeLineSpec(endPos, lineMaxWidth));

                    nextLineStart = i;//换行后，更新下一行起始pos
                    lineMaxWidth = measuredWidth;//重制新的一行，最大宽度
                    lineUsedLength = childHeight + lp.topMargin + lp.bottomMargin;//重制新的一行，高度

                    if (i == count - 1) {//最后一行超出，特殊处理
                        maxTotalUsedLength += lineMaxWidth;
                        lines.put(makeLineSpec(nextLineStart, lineUsedLength), makeLineSpec(nextLineStart, lineMaxWidth));
                    }
                }
            } else if (i == count - 1) {//最后一行，未超出屏幕
                maxTotalUsedLength += lineMaxWidth;//计算容器最大宽度
                lineMaxWidth = Math.max(lineMaxWidth, measuredWidth);
                lines.put(makeLineSpec(nextLineStart, lineUsedLength), makeLineSpec(i, lineMaxWidth));
            } else {
                lineMaxWidth = Math.max(lineMaxWidth, measuredWidth);//算每一行，最大宽度
            }
        }

        maxChildHeight = Math.max(maxChildHeight, view.getSuggestedMinimumWidth());

        maxChildWidth = maxTotalUsedLength;
        maxTotalUsedLength += mPaddingLeft + mPaddingRight;
        maxTotalUsedLength = Math.max(maxTotalUsedLength, view.getSuggestedMinimumWidth());

        measuredHeight = View.resolveSizeAndState(maxChildHeight, heightMeasureSpec, 0);

        view.setMeasuredDimensionX(View.resolveSizeAndState(maxTotalUsedLength, widthMeasureSpec, childState), measuredHeight);

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
                            View.MeasureSpec.makeMeasureSpec(h, View.MeasureSpec.EXACTLY));
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
        if (notWrap()) {
            super.measureHorizontal(widthMeasureSpec, heightMeasureSpec);
            return;
        }

        final int count = view.getChildCount();

        if (lines == null) {//初始化行数记录
            lines = new SparseIntArray();
        } else
            lines.clear();

        final int mPaddingTop = view.getPaddingTop();
        final int mPaddingBottom = view.getPaddingBottom();
        final int mPaddingLeft = view.getPaddingLeft();
        final int mPaddingRight = view.getPaddingRight();
        final int mPaddingRL = mPaddingLeft + mPaddingRight;
        maxTotalUsedLength = 0;//记录每一行的最大高度
        int childState = 0;

        int totalWeight = 0;
        int weightViewLen = 0;
        int nonWeightViewWidth = 0;
        int maxChildHeight;

        //计算非Wrap_content
        int measuredWidth = View.resolveSizeAndState(0, widthMeasureSpec, 0);

        int maxChildWidth = 0;//wrap_content时，一行只有一个。宽为最大的一个child宽度
        int lineMaxHength = 0;//记录每一行的最大高度
        int lineUsedLength = 0;//每行使用宽度
        int nextLineStart = 0;

        for (int i = 0; i < count; ++i) {
            final View child = view.getPriorityChildAt(i);
            if (child == null || child.getVisibility() == GONE) {
                continue;
            }

            final LayoutParams lp = (LayoutParams) child.getLayoutParams();
            view.measureChildBeforeLayout(child, i, widthMeasureSpec, 0,
                heightMeasureSpec, 0);

            final int childWidth;
            if (child instanceof ISpacer && ((ISpacer) child).isHorExpand()) {
                childWidth = 0;//扩展Spacer，不参与测量主轴
            } else {
                childWidth = child.getMeasuredWidth();
            }
            lineUsedLength = Math.max(lineUsedLength, childWidth + lineUsedLength + lp.leftMargin + lp.rightMargin);
            maxChildWidth = Math.max(maxChildWidth, childWidth + lp.leftMargin + lp.rightMargin);//记录最大宽度的子View宽度

            final int margin = lp.topMargin + lp.bottomMargin;
            final int measuredHeigth = child.getMeasuredHeight() + margin;


            childState = View.combineMeasuredStates(childState, View.combineMeasuredStates(childState, child.getMeasuredState()));
            nonWeightViewWidth += lp.leftMargin + lp.rightMargin;
            if (lp.weight > 0 && lp.width < 0) {
                totalWeight += lp.weight;
                weightViewLen++;
            } else {
                nonWeightViewWidth += childWidth;
            }

            if ((lineUsedLength + mPaddingRL) > measuredWidth) {//每一行宽 + paddingLR > 容器宽，就换行

                int endPos = nextLineStart < i ? (i - 1) : nextLineStart;

                boolean samePos = nextLineStart == i;
                if (samePos) {//start和当前一致，表示一个View占了一行。无需减去此行
                    maxTotalUsedLength += measuredHeigth;//计算容器最大高度
                    lines.put(makeLineSpec(nextLineStart, lineUsedLength), makeLineSpec(endPos, measuredHeigth));

                    ++nextLineStart;
                    lineMaxHength = 0;
                    lineUsedLength = 0;
                } else {
                    maxTotalUsedLength += lineMaxHength;//计算容器最大高度

                    lineUsedLength = lineUsedLength - (childWidth + lp.leftMargin + lp.rightMargin);
                    lines.put(makeLineSpec(nextLineStart, lineUsedLength), makeLineSpec(endPos, lineMaxHength));

                    nextLineStart = i;//换行后，更新下一行起始pos
                    lineMaxHength = measuredHeigth;//重制新的一行，最大高度
                    lineUsedLength = childWidth + lp.leftMargin + lp.rightMargin;//重制新的一行，宽度

                    if (i == count - 1) {//最后一行超出，特殊处理
                        maxTotalUsedLength += lineMaxHength;//计算容器最大高度
                        lines.put(makeLineSpec(nextLineStart, lineUsedLength), makeLineSpec(nextLineStart, lineMaxHength));
                    }
                }

            } else if (i == count - 1) {//最后一行，未超出屏幕
                maxTotalUsedLength += lineMaxHength;//计算容器最大高度
                lineMaxHength = Math.max(lineMaxHength, measuredHeigth);
                lines.put(makeLineSpec(nextLineStart, lineUsedLength), makeLineSpec(i, lineMaxHength));
            } else {
                lineMaxHength = Math.max(lineMaxHength, measuredHeigth);//算每一行，最大高度
            }
        }

        maxChildWidth = Math.max(maxChildWidth, view.getSuggestedMinimumWidth());

        maxChildHeight = maxTotalUsedLength;
        maxTotalUsedLength += mPaddingTop + mPaddingBottom;
        maxTotalUsedLength = Math.max(maxTotalUsedLength, view.getSuggestedMinimumHeight());

        measuredWidth = View.resolveSizeAndState(maxChildWidth, widthMeasureSpec, 0);//重新计算容器宽度

        view.setMeasuredDimensionX(measuredWidth, View.resolveSizeAndState(maxTotalUsedLength, heightMeasureSpec, childState));
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
                        child.measure(View.MeasureSpec.makeMeasureSpec(w, View.MeasureSpec.EXACTLY),
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
        if (notWrap()) {
            super.layoutVertical(left, top, right, bottom);
            return;
        }

        final int paddingLeft = view.getPaddingLeft();
        final int paddingRight = view.getPaddingRight();
        final int width = right - left;
        float currentLineLeft = paddingLeft;
        int viewSpace = width - paddingLeft - paddingRight;
        int childRight = width - paddingRight;
        int minorGravity;

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

        if (maxTotalUsedLength < viewSpace) {
            final int absoluteminorGravity = Gravity.getAbsoluteGravity(minorGravity, 0);
            switch (absoluteminorGravity & Gravity.HORIZONTAL_GRAVITY_MASK) {
                case Gravity.CENTER_HORIZONTAL:
                    currentLineLeft = paddingLeft + ((viewSpace - maxTotalUsedLength) / 2f);
                    break;
                case Gravity.RIGHT:
                    currentLineLeft = childRight - maxTotalUsedLength;
                    break;
                case Gravity.LEFT:
                default:
                    currentLineLeft = paddingLeft;
                    break;
            }
        }


        for (int i = 0; i < lines.size(); i++) {
            int startAndMainLength = lines.keyAt(i);
            int endAndCrossLength = lines.valueAt(i);
            layoutLineVertical(top, currentLineLeft, bottom, startAndMainLength, endAndCrossLength);

            int readCrossLenght = readLength(endAndCrossLength);
            currentLineLeft += readCrossLenght;
        }
        lines.clear();
    }

    @Override
    public void layoutHorizontal(int left, int top, int right, int bottom) {
        if (notWrap()) {
            super.layoutHorizontal(left, top, right, bottom);
            return;
        }

        final int paddingBottom = view.getPaddingBottom();
        final int paddingTop = view.getPaddingTop();
        float currentLineTop = paddingTop;
        final int height = bottom - top;
        int viewSpace = height - paddingTop - paddingBottom;
        int childBottom = height - paddingBottom;
        int minorGravity;


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

        if (maxTotalUsedLength < viewSpace) {
            switch (minorGravity & Gravity.VERTICAL_GRAVITY_MASK) {
                case Gravity.CENTER_VERTICAL:
                    currentLineTop = paddingTop + ((viewSpace - maxTotalUsedLength) / 2f);
                    break;

                case Gravity.BOTTOM:
                    currentLineTop = childBottom - maxTotalUsedLength;
                    break;
                case Gravity.TOP:
                default:
                    currentLineTop = paddingTop;
                    break;
            }
        }

        for (int i = 0; i < lines.size(); i++) {
            int startAndUsedLength = lines.keyAt(i);
            int endAndCrossLength = lines.valueAt(i);
            layoutLineHorizontal(left, currentLineTop, right, startAndUsedLength, endAndCrossLength);

            int readCrossLenght = readLength(endAndCrossLength);
            currentLineTop += readCrossLenght;
        }
        lines.clear();
    }


    private void layoutLineVertical(int top, float lineLeft, int bottom, int startAndUsedLength, int endAndCrossLength) {
        int start = readIndex(startAndUsedLength);
        int end = readIndex(endAndCrossLength);
        int usedLenght = readLength(startAndUsedLength);
        int lineWidth, childRight;
        lineWidth = childRight = readLength(endAndCrossLength);


        final int mPaddingTop = view.getPaddingTop();

        int usedHeight = mPaddingTop;
        boolean useSpace = false;//使用Space枚举
        int expandSpacerCount = 0;//子View中有扩展Spacer组件数量

        float childTop;
        float childLeft;

        switch (view.getMainAxisAlignment()) {
            case MainAxisAlignment.END:
                // mTotalLength contains the padding already
                childTop = mPaddingTop + bottom - top - usedLenght;
                break;


            case MainAxisAlignment.CENTER:
                // mTotalLength contains the padding already
                childTop = mPaddingTop + (bottom - top - usedLenght) / 2f;
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

        final int count = view.getChildCount();
        for (int i = start; i <= end && end < count; i++) {
            final View child = view.getChildAt(i);
            if (child instanceof ISpacer && ((ISpacer) child).isVerExpand()//扩展Spacer，不参与第一次布局
                && notWrap()) {//wrap下，spacer不生效
                ++expandSpacerCount;
                continue;
            }

            if (child != null && child.getVisibility() != GONE) {
                final int childWidth = child.getMeasuredWidth();
                final int childHeight = child.getMeasuredHeight();

                int childSpace = lineWidth - childWidth;

                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                int gravity = lp.gravity;
                if (gravity < 0) {
                    gravity = Gravity.LEFT | Gravity.TOP;
                }

                final int absoluteGravity = Gravity.getAbsoluteGravity(gravity, 0);
                switch (absoluteGravity & Gravity.HORIZONTAL_GRAVITY_MASK) {
                    case Gravity.CENTER_HORIZONTAL:
                        childLeft = (childSpace / 2f) + lp.leftMargin - lp.rightMargin;
                        break;
                    case Gravity.RIGHT:
                        childLeft = childRight - childWidth - lp.rightMargin;
                        break;
                    case Gravity.LEFT:
                    default:
                        childLeft = lp.leftMargin;
                        break;
                }

                childLeft += lineLeft;
                childTop += lp.topMargin;
                setChildFrame(child, Math.round(childLeft), (int) Math.ceil(childTop), childWidth, childHeight);
                childTop += childHeight + lp.bottomMargin;
                //记录使用高度
                usedHeight += lp.topMargin + childHeight + lp.bottomMargin;
            }
        }

        if (!useSpace && expandSpacerCount == 0 || end <= 0)
            return;

        int measuredHeight = view.getMeasuredHeight();
        int totalSpace = measuredHeight - usedHeight;

        if (totalSpace > 0) {//有剩余区域
            childTop = mPaddingTop;//重制childTop
            if (expandSpacerCount > 0) {//扩展的Spacer，和SPACE_XXX枚举冲突
                layoutVerSpacer(childTop, totalSpace, expandSpacerCount, start, end + 1);
            } else {
                layoutVerSpaceType(childTop, totalSpace, start, end + 1);
            }
        }
    }

    private void layoutLineHorizontal(int left, float lineTop, int right, int startAndUsedLength, int endAndCrossLength) {
        int start = readIndex(startAndUsedLength);
        int end = readIndex(endAndCrossLength);
        int usedLenght = readLength(startAndUsedLength);
        int lineHeight, childBottom;
        lineHeight = childBottom = readLength(endAndCrossLength);

        final int mPaddingLeft = view.getPaddingLeft();

        int usedWidth = mPaddingLeft;
        boolean useSpace = false;
        int expandSpacerCount = 0;//子View中有扩展Spacer组件数量

        float childTop;
        float childLeft;

        switch (view.getMainAxisAlignment()) {
            case MainAxisAlignment.END:
                // mTotalLength contains the padding already
                childLeft = mPaddingLeft + right - left - usedLenght;
                break;

            case MainAxisAlignment.CENTER:
                // mTotalLength contains the padding already
                childLeft = mPaddingLeft + (right - left - usedLenght) / 2f;
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


        final int count = view.getChildCount();
        for (int i = start; i <= end && end < count; i++) {
            final View child = view.getChildAt(i);
            if (child instanceof ISpacer && ((ISpacer) child).isHorExpand()//伸展的Spacer，不参与第一次布局
                && notWrap()) {//wrap下，spacer不生效
                ++expandSpacerCount;
                continue;
            }

            if (child != null && child.getVisibility() != GONE) {
                final int childWidth = child.getMeasuredWidth();
                final int childHeight = child.getMeasuredHeight();

                int childSpace = lineHeight - childHeight;

                final LayoutParams lp = (LayoutParams) child.getLayoutParams();

                int gravity = lp.gravity;
                if (gravity < 0) {
                    gravity = Gravity.LEFT | Gravity.TOP;
                }

                switch (gravity & Gravity.VERTICAL_GRAVITY_MASK) {
                    case Gravity.TOP:
                        childTop = lp.topMargin;
                        break;
                    case Gravity.CENTER_VERTICAL:
                        childTop = (childSpace / 2f) + lp.topMargin - lp.bottomMargin;
                        break;

                    case Gravity.BOTTOM:
                        childTop = childBottom - childHeight - lp.bottomMargin;
                        break;
                    default:
                        childTop = 0;
                        break;
                }

                childTop += lineTop;
                childLeft += lp.leftMargin;
                setChildFrame(child, (int) Math.ceil(childLeft), Math.round(childTop), childWidth, childHeight);
                childLeft += childWidth + lp.rightMargin;
                //记录使用宽度
                usedWidth += lp.leftMargin + childWidth + lp.rightMargin;
            }
        }


        if (!useSpace && expandSpacerCount == 0 || end <= 0)
            return;

        int measuredWidth = view.getMeasuredWidth();
        int totalSpace = measuredWidth - usedWidth;

        if (totalSpace > 0) {//有剩余区域
            childLeft = mPaddingLeft;//重制childLeft
            if (expandSpacerCount > 0) {//扩展的Spacer，和SPACE_XXX枚举冲突
                layoutHorSpacer(childLeft, totalSpace, expandSpacerCount, start, end + 1);
            } else {
                layoutHorSpaceType(childLeft, totalSpace, start, end + 1);
            }
        }
    }

    //前12位保存 index，后20位保存长度
    private int makeLineSpec(int index, int length) {
        return (index << 24) | length;
    }

    //0000 0000 0000 0000 0000 0000 0000 0000
    private int readLength(int value) {
        return (value) & 0xFFFFF;
    }

    private int readIndex(int value) {
        return (value >> 24) & 0xFFF;
    }


}
