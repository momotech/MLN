/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.animatable;

import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;

import com.immomo.mmui.anim.base.PropertyName;
import com.immomo.mmui.anim.utils.ColorUtil;


public class BgColorAnimatable extends Animatable {

    @Override
    public int getValuesCount() {
        return 4;
    }

    public BgColorAnimatable(String propertyName) {
        super(propertyName);
    }

    @Override
    public void writeValue(final View view, float[] upDateValues) {
        if (upDateValues.length == 4) {
            final int v = (int) upDateValues[0];
            final int v1 = (int) upDateValues[1];
            final int v2 = (int) upDateValues[2];
            final int v3 = (int) upDateValues[3];

            view.post(new Runnable() {
                @Override
                public void run() {
                    view.setBackgroundColor(ColorUtil.argb(v / 255f, v1 / 255f, v2 / 255f, v3 / 255f));
                }
            });
        }


    }

    @Override
    public void readValue(View view, float[] upDateValues) {
        Drawable drawable = view.getBackground();
        if (drawable instanceof ColorDrawable) {
            ColorDrawable colorDrawable = (ColorDrawable) drawable;
            int color = colorDrawable.getColor();
            ColorUtil.colorToArray(upDateValues, color);
        } else {
            ColorUtil.colorToArray(upDateValues, -1);
        }
    }

    @Override
    public float getThreshold() {
        return PropertyName.THRESHOLD_COLOR;
    }

}