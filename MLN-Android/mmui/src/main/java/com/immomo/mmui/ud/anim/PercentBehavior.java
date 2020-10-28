/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.ud.anim;

import android.view.View;

import com.immomo.mmui.anim.animatable.Animatable;
import com.immomo.mmui.anim.animations.ObjectAnimation;
import com.immomo.mmui.anim.animations.ValueAnimation;
import com.immomo.mmui.anim.base.Animation;

/**
 * 用于通过百分比驱动的动画
 * Created by wang.yang on 2020-07-20
 */
public class PercentBehavior {
    /**
     * 是否可越过边界
     */
    public boolean overBoundary;
    /**
     * 作用动画的view
     */
    protected View targetView;

    protected Animatable animatable;

    protected float[] fromValues;
    protected float[] toValues;
    protected float[] values;
    protected float minPercent = Float.NaN;
    protected float maxPercent = Float.NaN;
    protected float minDistance = Float.NaN;
    protected float maxDistance = Float.NaN;
    protected boolean[] absValues = null;

    public void setAnimation(UDBaseAnimation ud) {
        ValueAnimation oa = (ValueAnimation) ud.getJavaUserdata();
        ((ValueAnimation) oa).fullAnimationParams();
        animatable = oa.getAnimatable();
        targetView = oa.getTarget();
        values = new float[animatable.getValuesCount()];
        fromValues = oa.getFromValue();
        toValues = oa.getToValue();
        initLimit();
    }

    protected void initLimit() {
        if (animatable == null || fromValues == null || toValues == null)
            return;
        float[] values = animatable.getMaxValues();
        if (values != null) {
            for (int l = values.length, i = 0; i < l; i++) {
                float v = values[i];
                if (Float.isNaN(v))
                    continue;
                float p = (v - fromValues[i]) / (toValues[i] - fromValues[i]);
                if (Float.isNaN(maxPercent))
                    maxPercent = p;
                else
                    maxPercent = p > maxPercent ? p : maxPercent;
            }
        }

        values = animatable.getMinValues();
        if (values != null) {
            for (int l = values.length, i = 0; i < l; i++) {
                float v = values[i];
                if (Float.isNaN(v))
                    continue;
                float p = (v - fromValues[i]) / (toValues[i] - fromValues[i]);
                if (Float.isNaN(minPercent))
                    minPercent = p;
                else
                    minPercent = p < minPercent ? p : minPercent;
            }
        }
        absValues = animatable.absValues();
        if (Float.isNaN(minPercent))
            minPercent = Float.MIN_VALUE;
        if (Float.isNaN(maxPercent))
            maxPercent = Float.MAX_VALUE;
    }

    public void update(float percent) {
        fullValues(percent);
        animatable.writeValue(targetView, values);
    }

    protected void fullValues(float f) {
        float min = minPercent, max = maxPercent;
        if (!overBoundary) {
            min = min < 0 ? 0 : min;
            max = max > 1 ? 1 : max;
        }
        f = f < min ? min : f;
        f = f > max ? max : f;
        if (absValues != null) {
            for (int l = values.length, i = 0; i < l;i ++) {
                values[i] = f * (toValues[i] - fromValues[i]) + fromValues[i];
                if (absValues[i]) {
                    values[i] = Math.abs(values[i]);
                }
            }
        } else {
            for (int l = values.length, i = 0; i < l;i ++) {
                values[i] = f * (toValues[i] - fromValues[i]) + fromValues[i];
            }
        }
    }
}
