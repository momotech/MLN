/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.weight.layout;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import com.facebook.yoga.FlexNode;
import com.facebook.yoga.YogaNodeFactory;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mmui.ui.LuaNodeLayout;
import com.immomo.mmui.util.VirtualViewUtil;

import java.util.LinkedList;
import java.util.List;

/**
 * 虚拟布局，开启以后，会将子View传递给父容器，
 * 只保留它的Node，参与位置计算。用于减少视图层级。
 * 虚拟布局 不存在与布局中，需要背景、交互时，要将其转化为真实布局。
 */
@SuppressLint("ViewConstructor")
public class VirtualLayout extends NodeLayout implements IVirtualLayout {
    private boolean isVirtual;

    protected List<View> mChildren = new LinkedList<>();

    public VirtualLayout(Context context, boolean isVirtual) {
        super(context, isVirtual);
        this.isVirtual = isVirtual;
    }

    @Override
    public boolean isVirtual() {
        return isVirtual;
    }

    /**
     * Virtual转换为real
     */
    @Override
    public void changeToVirtual() {
        if (!isVirtual) {
            isVirtual = true;
            for (int i = 0; i < getChildCount(); i++) {
                mChildren.add(getChildAt(i));
            }

            justRemoveAllViews();
//            mNode.setData(null);
            mNode.setMeasureFunction(null);
        }
    }

    @Override
    public void addView(View child, int index, ViewGroup.LayoutParams params) {
        if (!isVirtual) {
            super.addView(child, index, params);
            return;
        }

        //虚拟layout，将被平铺children
        if (child instanceof VirtualLayout && ((VirtualLayout) child).isVirtual) {
            ((VirtualLayout) child).transferChildren(this);

            final FlexNode childNode = ((VirtualLayout) child).getFlexNode();
            mNode.addChildAt(childNode, mNode.getChildCount());

            transferToOwnerIfNeed(mNode);
            return;
        }

        FlexNode childNode;

        //检查 并 创建子View对应的Node
        if (child instanceof NodeLayout) {
            childNode = ((NodeLayout) child).getFlexNode();
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

        mChildren.add(child);

        transferToOwnerIfNeed(mNode);
    }

    /**
     * 虚拟布局被移除后，要把transfer的子view也从上层移除。
     */
    public void onVirtualRemoved() {
        for (int i = 0; i < mNode.getChildCount(); i++) {
            FlexNode childNode = mNode.getChildAt(i);
            Object view = childNode.getData();
            if (view != null && VirtualViewUtil.isNotVirtualView(view)) {//非虚拟 或 普通view
                LuaViewUtil.removeFromParent((View) view);
            }else if (view instanceof LuaNodeLayout) {
                ((LuaNodeLayout) view).onVirtualRemoved();
            }
        }
    }

    protected void removeViewFromYogaTree(View view, boolean inLayout) {
        super.removeViewFromYogaTree(view, inLayout);
    }

    protected void transferChildren(NodeLayout parent) {
        for (int i = 0; i < mNode.getChildCount(); i++) {
            FlexNode childNode = mNode.getChildAt(i);
            Object view = childNode.getData();
            if (view != null) {
                if (VirtualViewUtil.isNotVirtualView(view)) {//非虚拟，直接转移
                    parent.addView(LuaViewUtil.removeFromParent((View) view), mNodes.get(view));
                } else if (view instanceof LuaNodeLayout) {//虚拟的，用过取实际View，向上转移
                    LuaNodeLayout nodeView = (LuaNodeLayout) view;
                    nodeView.transferChildren(parent);
                }
            }
        }
    }

    /**
     * 虚拟View已经在视图上，在添加子View，直接向parent传递
     *
     * @param node
     */
    protected void transferToOwnerIfNeed(FlexNode node) {
        FlexNode owner = node.getOwner();
        if (owner != null) {//已经+被添加了，直接转移到parent
            Object view = owner.getData();
            if (view != null && VirtualViewUtil.isNotVirtualView(view)) {//parent为真实view
                transferChildren((NodeLayout) view);
            } else {//parent为虚拟view，向上遍历
                transferToOwnerIfNeed(owner);
            }
        }
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        if (!isVirtual) {
            super.onLayout(changed, l, t, r, b);
            return;
        }

        throw new RuntimeException("Attempting to layout a VirtualLayout");
    }
}