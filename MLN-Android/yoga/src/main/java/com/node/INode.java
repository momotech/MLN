/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package com.node;

import com.facebook.yoga.YogaMeasureFunction;

import androidx.annotation.Nullable;

/**
 * Node布局抽象接口,
 */
public interface INode<T extends INode> {

    void reset();

    int getChildCount();

    T getChildAt(int i);

    void addChildAt(T child, int i);

    T removeChildAt(int i);

    @Nullable
    T getOwner();

    int indexOf(T child);

    void calculateLayout(float width, float height);

    void dirty();

    boolean isDirty();

    void setWidth(float width);

    void setHeight(float height);

    float getLayoutX();

    float getLayoutY();

    float getLayoutWidth();

    float getLayoutHeight();

    void setMeasureFunction(YogaMeasureFunction measureFunction);

    void setData(Object data);

    @Nullable
    Object getData();

    void print();

    T cloneWithoutChildren();

    T cloneWithChildren();
}
