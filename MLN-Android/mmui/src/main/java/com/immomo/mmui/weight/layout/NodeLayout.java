/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package com.immomo.mmui.weight.layout;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.yoga.FlexNode;
import com.facebook.yoga.YogaConstants;
import com.facebook.yoga.YogaEdge;
import com.facebook.yoga.YogaMeasureFunction;
import com.facebook.yoga.YogaMeasureMode;
import com.facebook.yoga.YogaMeasureOutput;
import com.facebook.yoga.YogaNodeFactory;
import com.facebook.yoga.YogaUnit;
import com.facebook.yoga.YogaValue;

import java.util.HashMap;
import java.util.Map;

/**
 *
 */
public class NodeLayout extends ViewGroup implements IFlexLayout {
    protected final Map<View, FlexNode> mNodes;
    protected final FlexNode mNode;


    public NodeLayout(Context context, boolean isVirtual) {
        super(context);
        mNode = YogaNodeFactory.create();
        mNodes = new HashMap<>();
        init(isVirtual);
    }

    private void init(boolean isVirtual) {
        if (isVirtual)
            return;

        mNode.setData(this);
        mNode.setMeasureFunction(new ViewMeasureFunction());
    }

    public FlexNode getFlexNode() {
        return mNode;
    }

    public FlexNode getYogaNodeForView(View view) {
        return mNodes.get(view);
    }

    @Override
    public void addView(View child, int index, ViewGroup.LayoutParams params) {
        // Internal nodes (which this is now) cannot have measure functions
        mNode.setMeasureFunction(null);

        //虚拟layout，将被平铺children
        if (child instanceof VirtualLayout && ((VirtualLayout) child).isVirtual()) {
            ((VirtualLayout) child).transferChildren(this);
            final FlexNode childNode = ((VirtualLayout) child).getFlexNode();

            mNode.addChildAt(childNode, mNode.getChildCount());

            return;
        }

        super.addView(child, index, params);

        FlexNode childNode;

        //检查 并 创建子View对应的Node
        if (child instanceof NodeLayout) {
            childNode = ((NodeLayout) child).getFlexNode();
            childNode.setData(child);
        } else {
            if (mNodes.containsKey(child)) {
                childNode = mNodes.get(child);
            } else {
                childNode = YogaNodeFactory.create();
            }

            childNode.setData(child);
            if (!childNode.isMeasureDefined()) {
                childNode.setMeasureFunction(new ViewMeasureFunction());
            }
        }

        if (childNode.getOwner() != null) {
            return;
        }

        mNodes.put(child, childNode);
        if (index < 0) {
            index = mNode.getChildCount();
        }
        mNode.addChildAt(childNode, index);
    }

    /**
     * 将子node缓存在map中，
     */
    public void addView(View child, FlexNode node) {
        mNodes.put(child, node);
        addView(child);
    }

    public void addView(View child, int index, FlexNode node) {
        mNodes.put(child, node);
        addView(child, index);
    }

    public void addView(View child, int index, ViewGroup.LayoutParams lp, FlexNode node) {
        mNodes.put(child, node);
        addView(child, index, lp);
    }


    @Override
    public void removeView(View view) {
        removeViewFromYogaTree(view, false);
        super.removeView(view);
    }

    @Override
    public void removeViewAt(int index) {
        removeViewFromYogaTree(getChildAt(index), false);
        super.removeViewAt(index);
    }

    @Override
    public void removeViewInLayout(View view) {
        removeViewFromYogaTree(view, true);
        super.removeViewInLayout(view);
    }

    @Override
    public void removeViews(int start, int count) {
        for (int i = start; i < start + count; i++) {
            removeViewFromYogaTree(getChildAt(i), false);
        }
        super.removeViews(start, count);
    }

    @Override
    public void removeViewsInLayout(int start, int count) {
        for (int i = start; i < start + count; i++) {
            removeViewFromYogaTree(getChildAt(i), true);
        }
        super.removeViewsInLayout(start, count);
    }

    @Override
    public void removeAllViews() {
        final int childCount = getChildCount();
        for (int i = 0; i < childCount; i++) {
            removeViewFromYogaTree(getChildAt(i), false);
        }
        //如果有虚拟布局，需要二次遍历,清空node缓存
        for (int i = mNode.getChildCount() - 1; i >= 0; i--) {
            FlexNode node = mNode.getChildAt(i);
            mNode.removeChildAt(i);
        }
        if (mNodes.size() > 0) {
            mNodes.clear();
        }
        super.removeAllViews();
    }

    @Override
    public void removeAllViewsInLayout() {
        final int childCount = getChildCount();
        for (int i = 0; i < childCount; i++) {
            removeViewFromYogaTree(getChildAt(i), true);
        }
        super.removeAllViewsInLayout();
    }

    /**
     * Marks a particular view as "dirty" and to be relaid out.  If the view is not a child of this
     * {@link NodeLayout}, the entire tree is traversed to find it.
     *
     * @param view the view to mark as dirty
     */
    public void invalidate(View view) {
        if (mNodes.containsKey(view)) {
            mNodes.get(view).dirty();
            return;
        }

        final int childCount = mNode.getChildCount();
        for (int i = 0; i < childCount; i++) {
            final FlexNode flexNode = mNode.getChildAt(i);
            if (flexNode.getData() instanceof NodeLayout) {
                ((NodeLayout) flexNode.getData()).invalidate(view);
            }
        }
        invalidate();
    }

    private void removeViewFromYogaTree(View view, boolean inLayout) {
        final FlexNode node = mNodes.get(view);
        if (node == null) {
            return;
        }

        final FlexNode owner = node.getOwner();

        if (owner != null) {
            for (int i = 0; i < owner.getChildCount(); i++) {
                if (owner.getChildAt(i).equals(node)) {
                    owner.removeChildAt(i);
                    break;
                }
            }
        }

        node.setData(null);
        mNodes.remove(view);

        if (inLayout) {
            mNode.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);
        }
    }

    final void justRemoveAllViews() {
        super.removeAllViewsInLayout();
        requestLayout();
        invalidate();
    }

    /**
     * 测了完毕，将测量结果，遍历Node树对应的View
     * 赋值并布局View树
     */
    private void applyLayoutRecursive(FlexNode node, float xOffset, float yOffset) {
        View view = (View) node.getData();

        if (view != null && view != this) {
            if (view.getVisibility() == GONE) {
                return;
            }
            int left = Math.round(xOffset + node.getLayoutX());
            int top = Math.round(yOffset + node.getLayoutY());
            view.measure(
                MeasureSpec.makeMeasureSpec(
                    Math.round(node.getLayoutWidth()),
                    MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(
                    Math.round(node.getLayoutHeight()),
                    MeasureSpec.EXACTLY));
            view.layout(left, top, left + view.getMeasuredWidth(), top + view.getMeasuredHeight());
        }

        final int childrenCount = node.getChildCount();
        for (int i = 0; i < childrenCount; i++) {
            if (this.equals(view)) {
                applyLayoutRecursive(node.getChildAt(i), xOffset, yOffset);
            } else if (view instanceof NodeLayout) {
                continue;
            } else {
                applyLayoutRecursive(
                    node.getChildAt(i),
                    xOffset + node.getLayoutX(),
                    yOffset + node.getLayoutY());
            }
        }
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        // Either we are a root of a tree, or this function is called by our owner's onLayout, in which
        // case our r-l and b-t are the size of our node.
        if (!(getParent() instanceof NodeLayout)) {
            createLayout(
                MeasureSpec.makeMeasureSpec(r - l, MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(b - t, MeasureSpec.EXACTLY));
        }

        applyLayoutRecursive(mNode, 0, 0);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if (!(getParent() instanceof NodeLayout)) {
            createLayout(widthMeasureSpec, heightMeasureSpec);
        }

        setMeasuredDimension(
            Math.round(mNode.getLayoutWidth()),
            Math.round(mNode.getLayoutHeight()));
    }

    private void createLayout(int widthMeasureSpec, int heightMeasureSpec) {
        final int widthSize = MeasureSpec.getSize(widthMeasureSpec);
        final int heightSize = MeasureSpec.getSize(heightMeasureSpec);
        final int widthMode = MeasureSpec.getMode(widthMeasureSpec);
        final int heightMode = MeasureSpec.getMode(heightMeasureSpec);

        if (heightMode == MeasureSpec.EXACTLY) {
            mNode.setHeight(heightSize);
        }
        if (widthMode == MeasureSpec.EXACTLY) {
            mNode.setWidth(widthSize);
        }
        if (heightMode == MeasureSpec.AT_MOST) {
            mNode.setMaxHeight(heightSize);
            mNode.setHeightAuto();
        }
        if (widthMode == MeasureSpec.AT_MOST) {
            mNode.setMaxWidth(widthSize);
            mNode.setWidthAuto();
        }
        if (heightMode == MeasureSpec.UNSPECIFIED) {
            mNode.setHeightAuto();
        }
        if (widthMode == MeasureSpec.UNSPECIFIED) {
            mNode.setWidthAuto();
        }
        mNode.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED);
    }


    @Override
    public ViewGroup.LayoutParams generateLayoutParams(AttributeSet attrs) {
        return new LayoutParams(getContext(), attrs);
    }

    @Override
    protected ViewGroup.LayoutParams generateDefaultLayoutParams() {
        return new LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    @Override
    protected ViewGroup.LayoutParams generateLayoutParams(ViewGroup.LayoutParams p) {
        return new LayoutParams(p);
    }

    @Override
    protected boolean checkLayoutParams(ViewGroup.LayoutParams p) {
        return p instanceof LayoutParams;
    }


    public static class LayoutParams extends ViewGroup.LayoutParams {
        public LayoutParams(ViewGroup.LayoutParams source) {
            super(source);
        }

        public LayoutParams(int width, int height) {
            super(width, height);
        }

        /**
         * Constructs a set of layout params, given attributes.  Grabs all the {@code yoga:*}
         * defined in {@code ALL_YOGA_ATTRIBUTES} and collects the ones that are set in {@code attrs}.
         *
         * @param context the application environment
         * @param attrs   the set of attributes from which to extract the yoga specific attributes
         */
        public LayoutParams(Context context, AttributeSet attrs) {
            super(context, attrs);
        }
    }

    /**
     * Wrapper around measure function for yoga leaves.
     */
    public static class ViewMeasureFunction implements YogaMeasureFunction {

        /**
         * A function to measure leaves of the Yoga tree.  Yoga needs some way to know how large
         * elements want to be.  This function passes that question directly through to the relevant
         * {@code View}'s measure function.
         *
         * @param node       The yoga node to measure
         * @param width      The suggested width from the owner
         * @param widthMode  The type of suggestion for the width
         * @param height     The suggested height from the owner
         * @param heightMode The type of suggestion for the height
         * @return A measurement output ({@code YogaMeasureOutput}) for the node
         */
        public long measure(
            FlexNode node,
            float width,
            YogaMeasureMode widthMode,
            float height,
            YogaMeasureMode heightMode) {
            final View view = (View) node.getData();
            if (view == null || view instanceof NodeLayout) {
                return YogaMeasureOutput.make(0, 0);
            }

            //flexNode给予的限制宽高，是父容器减去padding以后的长度，
            //防止子View测量时，限制宽高错误。这里加上padding
            YogaValue paddingL = node.getPadding(YogaEdge.LEFT);
            YogaValue paddingR = node.getPadding(YogaEdge.RIGHT);
            width += paddingL.unit == YogaUnit.POINT ? paddingL.value : 0;
            width += paddingR.unit == YogaUnit.POINT ? paddingR.value : 0;

            YogaValue paddingT = node.getPadding(YogaEdge.TOP);
            YogaValue paddingB = node.getPadding(YogaEdge.BOTTOM);
            height += paddingT.unit == YogaUnit.POINT ? paddingT.value : 0;
            height += paddingB.unit == YogaUnit.POINT ? paddingB.value : 0;

            final int widthMeasureSpec = MeasureSpec.makeMeasureSpec(
                (int) width,
                viewMeasureSpecFromYogaMeasureMode(widthMode));
            final int heightMeasureSpec = MeasureSpec.makeMeasureSpec(
                (int) height,
                viewMeasureSpecFromYogaMeasureMode(heightMode));

            view.measure(widthMeasureSpec, heightMeasureSpec);

            int realWidth;
            int realHeight;
            if (widthMode == YogaMeasureMode.AT_MOST || widthMode == YogaMeasureMode.UNDEFINED) {//自适应测量，原生padding会计入宽度，和yoga的padding重复。需要减去
                realWidth = view.getMeasuredWidth() - view.getPaddingLeft() - view.getPaddingRight();
            } else {
                realWidth = view.getMeasuredWidth();
            }
            if (heightMode == YogaMeasureMode.AT_MOST || heightMode == YogaMeasureMode.UNDEFINED) {
                realHeight = view.getMeasuredHeight() - view.getPaddingTop() - view.getPaddingBottom();
            } else {
                realHeight = view.getMeasuredHeight();
            }

            return YogaMeasureOutput.make(realWidth, realHeight);
        }

        private int viewMeasureSpecFromYogaMeasureMode(YogaMeasureMode mode) {
            if (mode == YogaMeasureMode.AT_MOST) {
                return MeasureSpec.AT_MOST;
            } else if (mode == YogaMeasureMode.EXACTLY) {
                return MeasureSpec.EXACTLY;
            } else {
                return MeasureSpec.UNSPECIFIED;
            }
        }
    }
}