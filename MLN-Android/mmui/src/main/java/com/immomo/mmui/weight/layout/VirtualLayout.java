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
            mNode.setData(null);
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

    @Override
    public void addView(View child, FlexNode node) {
        if (!isVirtual) {
            super.addView(child, node);
            return;
        }
        mChildren.add(child);
        mNodes.put(child, node);
    }

    protected void transferChildren(NodeLayout parent) {
        for (View child : mChildren) {
            parent.addView(child, mNodes.get(child));
        }
        mChildren.clear();
    }

    /**
     * 虚拟View已经在视图上，在添加子View，直接向parent传递
     * @param node
     */
    protected void transferToOwnerIfNeed(FlexNode node) {
        FlexNode owner = node.getOwner();
        if (owner != null) {//已经被添加了，直接转移到parent
            if (owner.getData() != null) {//parent为真实view
                transferChildren((VirtualLayout) owner.getData());
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