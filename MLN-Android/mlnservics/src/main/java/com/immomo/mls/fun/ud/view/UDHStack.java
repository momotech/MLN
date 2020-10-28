/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.view;

import android.view.ViewGroup;

import com.immomo.mls.fun.ui.LuaHStack;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


@LuaApiUsed
public class UDHStack<V extends LuaHStack> extends UDBaseHVStack<V> {
    public static final String LUA_CLASS_NAME = "HStack";
    public static final String[] methods = {
        "ellipsize"
    };

    @LuaApiUsed
    protected UDHStack(long L, LuaValue[] v) {
        super(L, v);//HStack 主轴默认充满父容器
        setWidth(ViewGroup.LayoutParams.MATCH_PARENT);
    }

    @Override
    protected V newView(LuaValue[] init) {
        return (V) new LuaHStack<UDHStack>(getContext(), this);
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] ellipsize(LuaValue[] var) {
        boolean enable = var.length > 0 && var[0].toBoolean();
        UDView udview = var.length > 1 && !var[1].isNil() ? (UDView) var[1].toUserdata() : null;

        if (getView().getEllipsizeView() != null) {
            getView().removeView(getView().getEllipsizeView());
        }

        getView().ellipsize(enable, udview == null ? null : udview.getView());

        if (getView().getEllipsizeView() != null && getView().isEllipsize()) {
            insertView(udview, -1);
        }
        return null;
    }
    //</editor-fold>

}
