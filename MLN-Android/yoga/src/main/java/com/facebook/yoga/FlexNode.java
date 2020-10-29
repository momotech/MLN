/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package com.facebook.yoga;


import com.node.INode;


public abstract class FlexNode implements INode<FlexNode> {

    public abstract void addChildAt(FlexNode child, int i);

    public abstract void setIsReferenceBaseline(boolean isReferenceBaseline);

    public abstract boolean isReferenceBaseline();


    public abstract int indexOf(FlexNode child);


    public abstract boolean hasNewLayout();


    public abstract void copyStyle(FlexNode srcNode);

    public abstract void markLayoutSeen();

    public abstract YogaDirection getStyleDirection();

    public abstract void setDirection(YogaDirection direction);

    public abstract YogaFlexDirection getFlexDirection();

    public abstract void setFlexDirection(YogaFlexDirection flexDirection);

    public abstract YogaJustify getJustifyContent();

    public abstract void setJustifyContent(YogaJustify justifyContent);

    public abstract YogaAlign getAlignItems();

    public abstract void setAlignItems(YogaAlign alignItems);

    public abstract YogaAlign getAlignSelf();

    public abstract void setAlignSelf(YogaAlign alignSelf);

    public abstract YogaAlign getAlignContent();

    public abstract void setAlignContent(YogaAlign alignContent);

    public abstract YogaPositionType getPositionType();

    public abstract void setPositionType(YogaPositionType positionType);

    public abstract YogaWrap getWrap();

    public abstract void setWrap(YogaWrap flexWrap);

    public abstract YogaOverflow getOverflow();

    public abstract void setOverflow(YogaOverflow overflow);

    public abstract YogaDisplay getDisplay();

    public abstract void setDisplay(YogaDisplay display);

    public abstract float getFlex();

    public abstract void setFlex(float flex);

    public abstract float getFlexGrow();

    public abstract void setFlexGrow(float flexGrow);

    public abstract float getFlexShrink();

    public abstract void setFlexShrink(float flexShrink);

    public abstract YogaValue getFlexBasis();

    public abstract void setFlexBasis(float flexBasis);

    public abstract void setFlexBasisPercent(float percent);

    public abstract void setFlexBasisAuto();

    public abstract YogaValue getMargin(YogaEdge edge);

    public abstract void setMargin(YogaEdge edge, float margin);

    public abstract void setMarginPercent(YogaEdge edge, float percent);

    public abstract void setMarginAuto(YogaEdge edge);

    public abstract YogaValue getPadding(YogaEdge edge);

    public abstract void setPadding(YogaEdge edge, float padding);

    public abstract void setPaddingPercent(YogaEdge edge, float percent);

    public abstract float getBorder(YogaEdge edge);

    public abstract void setBorder(YogaEdge edge, float border);

    public abstract YogaValue getPosition(YogaEdge edge);

    public abstract void setPosition(YogaEdge edge, float position);

    public abstract void setPositionPercent(YogaEdge edge, float percent);

    public abstract YogaValue getWidth();


    public abstract void setWidthPercent(float percent);

    public abstract void setWidthAuto();

    public abstract YogaValue getHeight();


    public abstract void setHeightPercent(float percent);

    public abstract void setHeightAuto();

    public abstract YogaValue getMinWidth();

    public abstract void setMinWidth(float minWidth);

    public abstract void setMinWidthPercent(float percent);

    public abstract YogaValue getMinHeight();

    public abstract void setMinHeight(float minHeight);

    public abstract void setMinHeightPercent(float percent);

    public abstract YogaValue getMaxWidth();

    public abstract void setMaxWidth(float maxWidth);

    public abstract void setMaxWidthPercent(float percent);

    public abstract YogaValue getMaxHeight();

    public abstract void setMaxHeight(float maxheight);

    public abstract void setMaxHeightPercent(float percent);

    public abstract float getAspectRatio();

    public abstract void setAspectRatio(float aspectRatio);


    public abstract float getLayoutMargin(YogaEdge edge);

    public abstract float getLayoutPadding(YogaEdge edge);

    public abstract float getLayoutBorder(YogaEdge edge);

    public abstract YogaDirection getLayoutDirection();


    public abstract void setBaselineFunction(YogaBaselineFunction baselineFunction);

    public abstract boolean isMeasureDefined();

    public abstract boolean isBaselineDefined();
}
