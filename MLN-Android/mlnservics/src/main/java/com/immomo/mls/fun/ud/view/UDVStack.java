/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.view;

import android.view.ViewGroup;

import com.immomo.mls.fun.ui.LuaVStack;

import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


@LuaApiUsed
public class UDVStack<V extends LuaVStack> extends UDBaseHVStack<V> {
    public static final String LUA_CLASS_NAME = "VStack";

    @LuaApiUsed
    protected UDVStack(long L, LuaValue[] v) {
        super(L, v);//VStack 主轴默认充满父容器
        setHeight(ViewGroup.LayoutParams.MATCH_PARENT);
    }

    @Override
    protected V newView(LuaValue[] init) {
        return (V) new LuaVStack<UDVStack>(getContext(), this);
    }

}
