/**
 * Created by MomoLuaNative.
 * Copyright (c) 2020, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mmui.anim.animatable;

import android.graphics.Color;
import android.view.View;
import android.widget.TextView;

import com.immomo.mmui.anim.base.AnimatableFactory;
import com.immomo.mmui.anim.utils.ColorUtil;


public class TextColorAnimatable extends Animatable {

    @Override
    public int getValuesCount() {
        return 4;
    }

    @Override
    public void writeValue(final View view, float[] upDateValues) {
        if (upDateValues.length == 4) {
            final int a = (int) upDateValues[0];
            final int r = (int) upDateValues[1];
            final int g = (int) upDateValues[2];
            final int b = (int) upDateValues[3];

            view.post(new Runnable() {
                @Override
                public void run() {
                    if (view instanceof TextView) {
                        ((TextView) view).setTextColor(Color.argb(a, r, g, b));
                    }
                }
            });
        }


    }

    @Override
    public void readValue(View view, float[] upDateValues) {
        if (view instanceof TextView) {
            int color = ((TextView) view).getTextColors().getDefaultColor();
            ColorUtil.colorToArray(upDateValues, color);
        } else {
            ColorUtil.colorToArray(upDateValues, -1);
        }
    }

    @Override
    public float getThreshold() {
        return AnimatableFactory.THRESHOLD_COLOR;
    }

}