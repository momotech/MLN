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
        if (isMatchParent(width)) {
            return ViewGroup.LayoutParams.MATCH_PARENT;
        }
        if (isWrapContent(width)) {
            return ViewGroup.LayoutParams.WRAP_CONTENT;
        }
        return DimenUtil.dpiToPx(width);
    }

    public int getHeightPx() {
        if (isMatchParent(height)) {
            return ViewGroup.LayoutParams.MATCH_PARENT;
        }
        if (isWrapContent(height)) {
            return ViewGroup.LayoutParams.WRAP_CONTENT;
        }
        return DimenUtil.dpiToPx(height);
    }

    public boolean isMatchOrWrapWidth() {
        return isMatchParent(width) || isWrapContent(width);
    }

    public boolean isMatchOrWrapHeight() {
        return isMatchParent(height) || isWrapContent(height);
    }

    private boolean isMatchParent(float s) {
        return s == MATCH_PARENT;
    }

    private boolean isWrapContent(float s) {
        return s == WRAP_CONTENT;
    }

    @Override
    public String toString() {
        return "Size{" +
                "width=" + width +
                ", height=" + height +
                '}';
    }
}