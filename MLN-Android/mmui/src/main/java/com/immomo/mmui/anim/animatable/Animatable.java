/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.anim.animatable;

import android.view.View;

import com.immomo.mmui.anim.base.PropertyName;


public abstract class Animatable {
    protected float pivotX;
    protected float pivotY;

    protected String propertyName;
    private static final int VALUES_COUNT = 1;

    public int getValuesCount() {
        return VALUES_COUNT;
    }

    public float getThreshold() {
        return PropertyName.THRESHOLD_POINT;
    }


    public Animatable(String propertyName) {
        this.propertyName = propertyName;

    }

    public void beforeDoValue(View view) {
        pivotX = view.getPivotX();
        pivotY = view.getPivotY();

    }

    public abstract void writeValue(View view, float[] upDateValues);

    public abstract void readValue(View view, float[] upDateValues);


    public void afterDoValue(View view) {

    }


}