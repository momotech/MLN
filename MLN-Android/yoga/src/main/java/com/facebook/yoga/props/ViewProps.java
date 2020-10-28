/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.facebook.yoga.props;

import com.facebook.yoga.YogaAlign;
import com.facebook.yoga.YogaDirection;
import com.facebook.yoga.YogaEdge;
import com.facebook.yoga.YogaPositionType;

import androidx.annotation.Nullable;

public interface ViewProps {
    void width(int width);

    void widthPercent(float percent);

    void minWidth(int minWidth);

    void maxWidth(int maxWidth);

    void minWidthPercent(float percent);

    void maxWidthPercent(float percent);

    void height(int height);

    void heightPercent(float percent);

    void minHeight(int minHeight);

    void maxHeight(int maxHeight);

    void minHeightPercent(float percent);

    void maxHeightPercent(float percent);

    void layoutDirection(YogaDirection direction);

    void alignSelf(YogaAlign alignSelf);

    void flex(float flex);

    void flexGrow(float flexGrow);

    void flexShrink(float flexShrink);

    void flexBasis(int flexBasis);

    void flexBasisPercent(float percent);

    void aspectRatio(float aspectRatio);

    void positionType(@Nullable YogaPositionType positionType);

    void position(YogaEdge edge, int position);

    void positionPercent(YogaEdge edge, float percent);

    void padding(YogaEdge edge, int padding);

    void paddingPercent(YogaEdge edge, float percent);

    void margin(YogaEdge edge, int margin);

    void marginPercent(YogaEdge edge, float percent);

    void marginAuto(YogaEdge edge);

    void isReferenceBaseline(boolean isReferenceBaseline);

    void useHeightAsBaseline(boolean useHeightAsBaseline);
} 
