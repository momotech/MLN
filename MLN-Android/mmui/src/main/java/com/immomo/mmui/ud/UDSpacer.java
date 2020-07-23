/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import com.immomo.mls.utils.ErrorUtils;
import com.immomo.mmui.ui.LuaNodeLayout;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Spacer 是占位View，使用虚拟布局，不添加在试图中
 */
@LuaApiUsed
public class UDSpacer extends UDNodeGroup<LuaNodeLayout> {
    public static final String LUA_CLASS_NAME = "Spacer";

    @LuaApiUsed
    protected UDSpacer(long L, LuaValue[] v) {
        super(L, v);//HStack 主轴默认充满父容器
        init();
    }

    public UDSpacer(Globals g) {
        super(g);
        init();
    }

    @Override
    protected LuaNodeLayout newView(LuaValue[] init) {
        return new LuaNodeLayout<>(getContext(), this,true);
    }

    private void init() {
        mNode.setFlexGrow(1);
    }
    //<editor-fold desc="API">
    @LuaApiUsed
    public LuaValue[] children(LuaValue[] var) {
        ErrorUtils.debugUnsupportError("Spacer not support children");
        return null;
    }

    @LuaApiUsed
    public LuaValue[] insertView(LuaValue[] var) {
        ErrorUtils.debugUnsupportError("Spacer not support insertView");
        return null;
    }

    @LuaApiUsed
    public LuaValue[] addView(LuaValue[] var) {
        ErrorUtils.debugUnsupportError("Spacer not support addView");
        return null;
    }

    //</editor-fold>
}