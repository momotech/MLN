/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim.canvasanim;

import android.view.animation.Animation;
import android.view.animation.ScaleAnimation;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-05-27
 */
@LuaClass
public class UDScaleAnimation extends UDBaseAnimation {
    public static final String LUA_CLASS_NAME = "ScaleAnimation";

    private float fromX, tox;
    private float fromY, toY;

    private int pivotXType = AnimationValueType.ABSOLUTE;
    private float pivotXValue = 0;
    private int pivotYType = AnimationValueType.ABSOLUTE;
    private float pivotYValue = 0;

    public UDScaleAnimation(Globals g, LuaValue[] init) {
        super(g, init);
        final int len = init != null ? init.length : 0;
        if (len > 0) {
            fromX = (float) init[0].toDouble();
            tox = (float) init[1].toDouble();
            fromY = (float) init[2].toDouble();
            toY = (float) init[3].toDouble();
            if (len == 6) {
                pivotXValue = (float) init[4].toDouble();
                pivotYValue = (int) init[5].toDouble();
            } else if (len == 8) {
                pivotXType = init[4].toInt();
                pivotXValue = (float) init[5].toDouble();
                pivotYType = init[6].toInt();
                pivotYValue = (int) init[7].toDouble();
            }
        }
    }

    //<editor-fold desc="api">
    @LuaBridge
    public void setFromX(float x) {
        fromX = x;
    }

    @LuaBridge
    public void setToX(float x) {
        tox = x;
    }

    @LuaBridge
    public void setFromY(float y) {
        fromY = y;
    }

    @LuaBridge
    public void setToY(float y) {
        toY = y;
    }

    @LuaBridge
    public void setPivotXType(int xt) {
        pivotXType = xt;
    }

    @LuaBridge
    public void setPivotX(float x) {
        pivotXValue = x;
    }

    @LuaBridge
    public void setPivotYType(int yt) {
        pivotYType = yt;
    }

    @LuaBridge
    public void setPivotY(int y) {
        pivotYValue = y;
    }
    //</editor-fold>

    @Override
    protected Animation build() {
        return new ScaleAnimation(fromX, tox,
                fromY, toY,
                pivotXType, getRealValue(pivotXType, pivotXValue),
                pivotYType, getRealValue(pivotYType, pivotYValue));
    }

    @Override
    protected UDBaseAnimation cloneObj() {
        UDScaleAnimation anim = new UDScaleAnimation(globals, null);
        anim.fromX = fromX;
        anim.tox = tox;
        anim.fromY = fromY;
        anim.toY = toY;
        anim.pivotXType = pivotXType;
        anim.pivotXValue = pivotXValue;
        anim.pivotYType = pivotYType;
        anim.pivotYValue = pivotYValue;
        return anim;
    }
}