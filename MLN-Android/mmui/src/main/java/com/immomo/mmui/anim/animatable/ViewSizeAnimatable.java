/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.animatable;

import android.view.View;
import android.view.ViewGroup;

public class ViewSizeAnimatable extends Animatable {
    public ViewSizeAnimatable(String propertyName) {
        super(propertyName);
    }

    @Override
    public void writeValue(View view, float[] upDateValues) {
        ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
        view.setScaleX(upDateValues[0] / (float) layoutParams.width);
        view.setScaleY(upDateValues[1] / (float) layoutParams.height);

    }

    @Override
    public void readValue(View view, float[] upDateValues) {
        upDateValues[0] = 1;
        upDateValues[1] = 1;

    }

    @Override
    public int getValuesCount() {
        return 2;
    }
}