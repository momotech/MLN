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

/**
 * 用于通过百分比驱动的动画
 * Created by wang.yang on 2020-07-20
 */
public class PercentBehavior {
    /**
     * 是否可越过边界
     */
    private boolean overBoundary;
    /**
     * function(TouchType type,number distance,numer velocity)
     */
    private View targetView;

    private Animatable animatable;

    private float[] fromValues;
    private float[] toValues;
    private float[] values;

    //</editor-fold>

    public void targetView(View view) {
        this.targetView = view;
    }

    public void setAnimation(ObjectAnimation oa) {
        ((ValueAnimation) oa).fullAnimationParams();
        animatable = oa.getAnimatable();
        values = new float[animatable.getValuesCount()];
        fromValues = oa.getFromValue();
        toValues = oa.getToValue();
    }

    public void update(float percent) {
        fullValues(percent);
        animatable.writeValue(targetView, values);
    }

    private void fullValues(float f) {
        if (!overBoundary) {
            f = f < 0 ? 0 : f;
            f = f > 1 ? 1 : f;
        }
        for (int l = values.length, i = 0; i < l; i++) {
            values[i] = f * (toValues[i] - fromValues[i]) + fromValues[i];
        }
    }

    public void setOverBoundary(boolean overBoundary) {
        this.overBoundary = overBoundary;
    }
}
