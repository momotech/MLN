/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import com.immomo.mmui.ui.LuaNodeLayout;
import com.facebook.yoga.YogaFlexDirection;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


@LuaApiUsed
public class UDVStack<V extends LuaNodeLayout> extends UDNodeGroup<V> {
    public static final String LUA_CLASS_NAME = "VStack";
    public static final String[] methods = {
        "reverse"
    };

    @LuaApiUsed
    protected UDVStack(long L, LuaValue[] v) {
        super(L, v);
        init();

    }

    public UDVStack(Globals g) {
        super(g);
        init();
    }

    private void init() {
        mNode.setFlexDirection(YogaFlexDirection.COLUMN);
    }

    @LuaApiUsed
    public LuaValue[] reverse(LuaValue[] var) {
        boolean reverse = var.length > 0 && var[0].toBoolean();
        mNode.setFlexDirection(
            reverse ? YogaFlexDirection.COLUMN_REVERSE : YogaFlexDirection.COLUMN);
        return null;
    }

    @Override
    public boolean needConvertVirtual() {
        return isAllowVirtual() && !isDisableVirtual()
            && getClass().getSimpleName().equals(UDVStack.class.getSimpleName());
    }
}