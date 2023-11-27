/**
  * Created by MomoLuaNative.
  * Copyright (c) 2019, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mls.fun.ud.view;

import android.graphics.Paint;
import android.util.ArrayMap;
import android.view.View;

import com.immomo.mls.fun.ud.UDCanvas;
import com.immomo.mls.fun.ud.UDPaint;
import com.immomo.mls.fun.ui.LuaCanvasView;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by zhang.ke
 * on 2019/7/25
 */
@LuaApiUsed
public class UDCanvasView extends UDView {
    public static final String LUA_CLASS_NAME = "CanvasView";
    public static final String[] methods = {
            "closeHardWare",
    };

    private final ArrayMap<String, Runnable> delayTasks;

    @LuaApiUsed(ignore = true)
    protected UDCanvasView(long L, LuaValue[] v) {
        super(L, v);
        delayTasks = new ArrayMap<>();
    }

    @Override
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDCanvasView.class))
    })
    public void __onLuaGc() {
        super.__onLuaGc();
        final View view = getView();
        if (view == null) return;
        for (Runnable r : delayTasks.values()) {
            view.removeCallbacks(r);
        }
        delayTasks.clear();
    }

    @Override
    protected View newView(LuaValue[] init) {
        return new LuaCanvasView<>(getContext(), this);
    }

    @Override
    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
            }, returns = @LuaApiUsed.Type(UDCanvasView.class))
    })
    public LuaValue[] refresh(LuaValue[] p) {
        view.invalidate();
        return null;
    }

    @LuaApiUsed({
            @LuaApiUsed.Func(params = {
                    @LuaApiUsed.Type(UDPaint.class)
            }, returns = @LuaApiUsed.Type(UDCanvasView.class))
    })
    protected LuaValue[] closeHardWare(LuaValue[] v) {
        UDPaint udpait = v.length > 0 && v[0].isUserdata() ? (UDPaint) v[0].toUserdata() : null;
        Paint paint = null;
        if (udpait != null && udpait.getJavaUserdata() != null) {
            paint = udpait.getJavaUserdata();
        }
        getView().setLayerType(View.LAYER_TYPE_SOFTWARE, paint);
        if (udpait != null) {
            udpait.destroy();
        }
        return null;
    }
}
