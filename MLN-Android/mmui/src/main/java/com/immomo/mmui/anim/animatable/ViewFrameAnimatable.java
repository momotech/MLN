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

public class ViewFrameAnimatable extends Animatable {

    public ViewFrameAnimatable(String propertyName) {
        super(propertyName);
    }

    @Override
    public void beforeDoValue(View view) {
        super.beforeDoValue(view);

        view.setPivotX(0);
        view.setPivotY(0);
    }

    @Override
    public void afterDoValue(View view) {
        view.setPivotX(pivotX);
        view.setPivotY(pivotY);
    }

    @Override
    public void writeValue(View view, float[] upDateValues) {

        view.setX(upDateValues[0]);
        view.setY(upDateValues[1]);

        ViewGroup.LayoutParams layoutParams = view.getLayoutParams();

        view.setScaleX((upDateValues[2] / (float) layoutParams.width));
        view.setScaleY((upDateValues[3] / (float) layoutParams.height));


    }

    @Override
    public void readValue(View view, float[] upDateValues) {
        upDateValues[0] = view.getX();
        upDateValues[1] = view.getY();

        ViewGroup.LayoutParams layoutParams = view.getLayoutParams();

        upDateValues[2] = (float) layoutParams.width;
        upDateValues[3] = (float) layoutParams.height;

    }

    @Override
    public int getValuesCount() {
        return 4;
    }
}