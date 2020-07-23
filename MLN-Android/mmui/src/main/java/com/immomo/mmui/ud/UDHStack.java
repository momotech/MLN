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
public class UDHStack extends UDNodeGroup<LuaNodeLayout> {
    public static final String LUA_CLASS_NAME = "HStack";
    public static final String[] methods = {
        "reverse"
    };

    @LuaApiUsed
    protected UDHStack(long L, LuaValue[] v) {
        super(L, v);//HStack 主轴默认充满父容器
        init();
    }

    public UDHStack(Globals g) {
        super(g);
        init();
    }

//<editor-fold desc="API">

    //</editor-fold>
    private void init() {
        mNode.setFlexDirection(YogaFlexDirection.ROW);
    }

    @LuaApiUsed
    public LuaValue[] reverse(LuaValue[] var) {
        boolean reverse = var.length > 0 && var[0].toBoolean();
        mNode.setFlexDirection(
            reverse ? YogaFlexDirection.ROW_REVERSE : YogaFlexDirection.ROW);
        return null;
    }

    @Override
    public boolean needConvertVirtual() {
        return isAllowVirtual() && !isDisableVirtual()
            && getClass().getSimpleName().equals(UDHStack.class.getSimpleName());
    }
}