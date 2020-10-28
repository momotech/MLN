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

public class RotationXAnimatable extends Animatable {

    @Override
    public void writeValue(View view, float[] upDateValues) {
        view.setRotationX(upDateValues[0]);
    }

    @Override
    public void readValue(View view, float[] upDateValues) {
        upDateValues[0] = view.getRotationX();
    }
    @Override
    public float getThreshold() {
        return AnimatableFactory.THRESHOLD_ROTATION;
    }
}