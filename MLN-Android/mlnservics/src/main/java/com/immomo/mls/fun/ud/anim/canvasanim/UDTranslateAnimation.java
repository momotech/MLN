/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.anim.canvasanim;

import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-05-27
 */
@LuaClass
public class UDTranslateAnimation extends UDBaseAnimation {
    public static final String LUA_CLASS_NAME = "TranslateAnimation";

    private int fromXType = AnimationValueType.ABSOLUTE;
    private float fromXValue;
    private int toXType = AnimationValueType.ABSOLUTE;
    private float toXValue;

    private int fromYType = AnimationValueType.ABSOLUTE;
    private float fromYValue;
    private int toYType = AnimationValueType.ABSOLUTE;
    private float toYValue;
    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Float.class),
                    @LuaBridge.Type(value = Float.class),
                    @LuaBridge.Type(value = Float.class),
                    @LuaBridge.Type(value = Float.class)
            }),
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Integer.class),
                    @LuaBridge.Type(value = Float.class),
                    @LuaBridge.Type(value = Integer.class),
                    @LuaBridge.Type(value = Float.class),
                    @LuaBridge.Type(value = Integer.class),
                    @LuaBridge.Type(value = Float.class),
                    @LuaBridge.Type(value = Integer.class),
                    @LuaBridge.Type(value = Float.class)
            })
    })
    public UDTranslateAnimation(Globals g, LuaValue[] init) {
        super(g, init);
        final int len = init != null ? init.length : 0;
        if (len == 4) {
            fromXValue = init[0].toFloat();
            toXValue = init[1].toFloat();
            fromYValue = init[2].toFloat();
            toYValue = init[3].toFloat();
        } else if (len == 8) {
            fromXType = init[0].toInt();
            fromXValue = init[1].toFloat();
            toXType = init[2].toInt();
            toXValue = init[3].toFloat();
            fromYType = init[4].toInt();
            fromYValue = init[5].toFloat();
            toYType = init[6].toInt();
            toYValue = init[7].toFloat();
        }
    }

    //<editor-fold desc="Api">
    @LuaBridge
    public void setFromXType(int type) {
        fromXType = toXType;
    }

    @LuaBridge
    public void setFromX(float x) {
        fromXValue = x;
    }

    @LuaBridge
    public void setToXType(int type) {
        toXType = type;
    }

    @LuaBridge
    public void setToX(float x) {
        toXValue = x;
    }

    @LuaBridge
    public void setFromYType(int type) {
        fromYType = type;
    }

    @LuaBridge
    public void setFromY(float y) {
        fromYValue = y;
    }

    @LuaBridge
    public void setToYType(int type) {
        toYType = type;
    }

    @LuaBridge
    public void setToY(float y) {
        toYValue = y;
    }
    //</editor-fold>

    @Override
    protected Animation build() {
        return new TranslateAnimation(
                fromXType, getRealValue(fromXType, fromXValue),
                toXType, getRealValue(toXType, toXValue),
                fromYType, getRealValue(fromYType, fromYValue),
                toYType, getRealValue(toYType, toYValue));
    }

    @Override
    protected UDBaseAnimation cloneObj() {
        UDTranslateAnimation anim = new UDTranslateAnimation(globals, null);
        anim.fromXType = fromXType;
        anim.fromXValue = fromXValue;
        anim.toXType = toXType;
        anim.toXValue = toXValue;
        anim.fromYType = fromYType;
        anim.fromYValue = fromYValue;
        anim.toYType = toYType;
        anim.toYValue = toYValue;
        return anim;
    }
}