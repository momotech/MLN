/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.view;

import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.fun.constants.MeasurementType;
import com.immomo.mls.fun.weight.newui.Spacer;
import com.immomo.mls.utils.ErrorUtils;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

import androidx.annotation.NonNull;

/**
 * Created by zhang.ke on 2018/7/31.
 * 占位View
 */
@LuaApiUsed
public class UDSpacer extends UDView<Spacer> {
    public static final String LUA_CLASS_NAME = "Spacer";

    @LuaApiUsed
    protected UDSpacer(long L, LuaValue[] v) {
        super(L, v);
        setHeight(0);//默认为0，isVerExPand默认为true，不影响延展测量
        setWidth(0);//默认为0，isHorExPand默认为true，不影响延展测量
    }

    @NonNull
    @Override
    protected Spacer newView(@NonNull LuaValue[] init) {
        return new Spacer(getContext());
    }

    //<editor-fold desc="API">
    @Override
    public LuaValue[] width(LuaValue[] varargs) {
        LuaValue[] result = super.width(varargs);

        getView().setHorExPand(false);

        //MatchParent 扩展
        ViewGroup.LayoutParams params = view.getLayoutParams();
        if (params.width == MeasurementType.MATCH_PARENT
            || params.width == MeasurementType.WRAP_CONTENT) {
            setWidth(0);
            ErrorUtils.debugDeprecatedMethod("The Spacer's width and height doesn't support MeasurementType property.", globals);
        }
        return result;
    }

    @LuaApiUsed
    @Override
    public LuaValue[] height(LuaValue[] varargs) {
        LuaValue[] result = super.height(varargs);

        getView().setVerExPand(false);

        ViewGroup.LayoutParams params = view.getLayoutParams();
        if (params.width == MeasurementType.MATCH_PARENT
            || params.width == MeasurementType.WRAP_CONTENT) {
            setHeight(0);
            ErrorUtils.debugDeprecatedMethod("Spacer not support MeasurementType!", globals);
        }
        return result;
    }

    //</editor-fold>
}
