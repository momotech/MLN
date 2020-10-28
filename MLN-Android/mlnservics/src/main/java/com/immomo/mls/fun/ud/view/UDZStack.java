/**
 * Created by MomoLuaNative.
 * Copyright (c) 2019, Momo Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
package com.immomo.mls.fun.ud.view;

import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;

import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.fun.ui.LuaViewGroup;
import com.immomo.mls.fun.ui.LuaZStack;
import com.immomo.mls.fun.weight.newui.ZStack;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Created by XiongFangyu on 2018/7/31.
 */
@LuaApiUsed
public class UDZStack<V extends ZStack & ILViewGroup> extends UDBaseStack<V> {
    public static final String LUA_CLASS_NAME = "ZStack";
    public static final String[] methods = {
        "childGravity",
    };

    @LuaApiUsed
    protected UDZStack(long L, LuaValue[] v) {
        super(L, v);
    }

    @Override
    protected V newView(LuaValue[] init) {
        return (V) new LuaZStack<>(getContext(), this);
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] childGravity(LuaValue[] var) {
        int value = var.length > 0 ? var[0].toInt() : Gravity.START | Gravity.TOP;
        getView().setGravity(value);
        return null;
    }

    //</editor-fold>
}
