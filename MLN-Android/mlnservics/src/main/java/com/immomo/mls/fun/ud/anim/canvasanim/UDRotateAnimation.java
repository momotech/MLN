/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim.canvasanim;

import android.view.animation.Animation;
import android.view.animation.RotateAnimation;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-05-27
 */
@LuaClass
public class UDRotateAnimation extends UDBaseAnimation {
    public static final String LUA_CLASS_NAME = "RotateAnimation";

    private float fromDegrees;
    private float toDegrees;
    private float pivotXValue = 0.5f;
    private float pivotYValue = 0.5f;

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Float.class),
                    @LuaBridge.Type(value = Float.class)
            }),
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Float.class),
                    @LuaBridge.Type(value = Float.class),
                    @LuaBridge.Type(value = Double.class),
                    @LuaBridge.Type(value = Double.class)
            })
    })
    public UDRotateAnimation(Globals g, LuaValue[] init) {
        super(g, init);
        final int len = init != null ? init.length : 0;
        if (len > 0) {
            fromDegrees =   init[0].toFloat();
            toDegrees =     init[1].toFloat();
            if (len == 4) {
                pivotXValue = (float) init[2].toDouble();
                pivotYValue = (float) init[3].toDouble();
            }
        }
    }

    //<editor-fold desc="api">
    @LuaBridge
    public void setFromDegrees(float fromDegrees) {
        this.fromDegrees = fromDegrees;
    }

    @LuaBridge
    public void setToDegrees(float toDegrees) {
        this.toDegrees = toDegrees;
    }

    @LuaBridge
    public void setPivotX(float x) {
        pivotXValue = x;
    }

    @LuaBridge
    public void setPivotY(float y) {
        pivotYValue = y;
    }

    //</editor-fold>

    @Override
    protected Animation build() {
        return new RotateAnimation(fromDegrees, toDegrees,
                Animation.RELATIVE_TO_SELF, pivotXValue,
                Animation.RELATIVE_TO_SELF, pivotYValue);
    }

    @Override
    protected UDBaseAnimation cloneObj() {
        UDRotateAnimation anim = new UDRotateAnimation(globals, null);
        anim.fromDegrees = fromDegrees;
        anim.toDegrees = toDegrees;
        anim.pivotXValue = pivotXValue;
        anim.pivotYValue = pivotYValue;
        return anim;
    }
}