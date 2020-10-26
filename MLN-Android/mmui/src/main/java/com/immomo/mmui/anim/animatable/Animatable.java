/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.animatable;

import android.view.View;

import com.immomo.mmui.anim.base.AnimatableFactory;


public abstract class Animatable {
    protected float pivotX;
    protected float pivotY;

    private static final int VALUES_COUNT = 1;

    public int getValuesCount() {
        return VALUES_COUNT;
    }

    public float getThreshold() {
        return AnimatableFactory.THRESHOLD_POINT;
    }

    /**
     * 获取动画要求的最大值
     * @return null表示无限制 {@link Float#NaN}表示无限制
     *          null = {Float.NaN, Float.NaN ...}
     */
    public float[] getMaxValues() {
        return null;
    }

    /**
     * 获取动画要求的最小值
     * @return null表示无限制 {@link Float#NaN}表示无限制
     *          null = {Float.NaN, Float.NaN ...}
     */
    public float[] getMinValues() {
        return null;
    }

    /**
     * 动画要求只能是0或正整数，和{@link #getMinValues()}不冲突
     * @return null表示不使用绝对值函数
     *          null= {false, false ...}
     */
    public boolean[] absValues() {
        return null;
    }

    public void beforeDoValue(View view) {
        pivotX = view.getPivotX();
        pivotY = view.getPivotY();

    }

    public abstract void writeValue(View view, float[] upDateValues);

    public abstract void readValue(View view, float[] upDateValues);


    public void afterDoValue(View view) {

    }

    /**
     * 是否是位移动画
     */
    public boolean hasTranslate() {
        return false;
    }
}