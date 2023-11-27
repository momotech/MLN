/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.other;

import androidx.annotation.NonNull;
import android.view.ViewGroup;

import com.immomo.mls.fun.constants.MeasurementType;
import com.immomo.mls.util.DimenUtil;

/**
 * Created by XiongFangyu on 2018/7/19.
 */
public class Size {
    public static final float MATCH_PARENT = Float.MIN_VALUE;
    public static final float WRAP_CONTENT = Float.MIN_VALUE * 2f;
    private float width;
    private float height;

    public Size() {

    }

    public Size(float w, float h) {
        this.width = w;
        this.height = h;
    }

    public Size(@NonNull Size src) {
        setSize(src);
    }

    public void setSize(@NonNull Size src) {
        this.width = src.width;
        this.height = src.height;
    }

    public float getWidth() {
        return width;
    }

    public void setWidth(float width) {
        this.width = width;
    }

    public float getHeight() {
        return height;
    }

    public void setHeight(float height) {
        this.height = height;
    }

    public int getWidthPx() {
        return toPx(width);
    }

    public int getHeightPx() {
        return toPx(height);
    }

    public boolean isMatchOrWrapWidth() {
        return width == MATCH_PARENT || width == WRAP_CONTENT;
    }

    public boolean isMatchOrWrapHeight() {
        return height == MATCH_PARENT || height == WRAP_CONTENT;
    }

    public static int toPx(float v) {
        if (v == MATCH_PARENT) {
            return ViewGroup.LayoutParams.MATCH_PARENT;
        }
        if (v == WRAP_CONTENT) {
            return ViewGroup.LayoutParams.WRAP_CONTENT;
        }
        return DimenUtil.dpiToPx(v);
    }

    public static float toSize(float v) {
        if (v == MeasurementType.MATCH_PARENT) {
            v = Size.MATCH_PARENT;
        } else if (v == MeasurementType.WRAP_CONTENT) {
            v = Size.WRAP_CONTENT;
        }
        return v;
    }

    @Override
    public String toString() {
        return "Size{" +
                "width=" + width +
                ", height=" + height +
                '}';
    }
}