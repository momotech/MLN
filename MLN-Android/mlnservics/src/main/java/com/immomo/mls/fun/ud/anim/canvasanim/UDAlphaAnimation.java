/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 * <p>
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.anim.canvasanim;

import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;

import com.immomo.mls.annotation.LuaBridge;
import com.immomo.mls.annotation.LuaClass;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;

/**
 * Created by Xiong.Fangyu on 2019-05-27
 */
@LuaClass
public class UDAlphaAnimation extends UDBaseAnimation {
    public static final String LUA_CLASS_NAME = "AlphaAnimation";

    private float from, to;

    public UDAlphaAnimation(Globals g, LuaValue[] init) {
        super(g, init);
        from = (float) init[0].toDouble();
        to = (float) init[1].toDouble();
    }

    @LuaBridge(value = {
            @LuaBridge.Func(params = {
                    @LuaBridge.Type(value = Double.class),
                    @LuaBridge.Type(value = Double.class)
            })
    })
    private UDAlphaAnimation(Globals g, float from, float to) {
        super(g, null);
        this.from = from;
        this.to = to;
    }

    @Override
    protected Animation build() {
        return new AlphaAnimation(from, to);
    }

    @Override
    protected UDBaseAnimation cloneObj() {
        return new UDAlphaAnimation(globals, from, to);
    }
}