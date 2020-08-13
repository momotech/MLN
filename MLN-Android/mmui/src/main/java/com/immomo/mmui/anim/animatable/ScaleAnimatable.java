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


public class ScaleAnimatable extends Animatable {
    private static final float MAX = 3.4f;
    private static final float[] max = {
            MAX, MAX
    };
    /*private static final float[] min = {
            0, 0
    };*/

    @Override
    public void writeValue(final View view, final float[] upDateValues) {
        view.post(new Runnable() {
            @Override
            public void run() {
                view.setScaleX(Math.min(upDateValues[0], MAX));
                view.setScaleY(Math.min(upDateValues[1], MAX));
            }
        });
    }

    /**
     * 获取动画要求的最大值
     * @return null表示无限制 {@link Float#NaN}表示无限制
     *          null = {Float.NaN, Float.NaN ...}
     */
    public float[] getMaxValues() {
        return max;
    }

    /**
     * 获取动画要求的最小值
     * @return null表示无限制 {@link Float#NaN}表示无限制
     *          null = {Float.NaN, Float.NaN ...}
     */
    public float[] getMinValues() {
        return null;
    }

    @Override
    public void readValue(View view, float[] upDateValues) {
        upDateValues[0] = view.getScaleX();
        upDateValues[1] = view.getScaleY();
    }

    @Override
    public int getValuesCount() {
        return 2;
    }

    @Override
    public float getThreshold() {
        return AnimatableFactory.THRESHOLD_SCALE;
    }
}