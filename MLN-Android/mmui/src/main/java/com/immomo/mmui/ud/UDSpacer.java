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
import org.luaj.vm2.LuaTable;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;

/**
 * Spacer 是占位View，使用虚拟布局，不添加在试图中
 */
@LuaApiUsed
public class UDSpacer extends UDNodeGroup<LuaNodeLayout> {
    public static final String LUA_CLASS_NAME = "Spacer";

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDSpacer(long L) {
        super(L);//HStack 主轴默认充满父容器
        init();
    }

    public UDSpacer(Globals g) {
        super(g);
        init();
    }

    //<editor-fold desc="native method">
    /**
     * 初始化方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _init();

    /**
     * 注册到虚拟机方法
     * 反射调用
     * @see com.immomo.mls.wrapper.Register.NewUDHolder
     */
    public static native void _register(long l, String parent);
    //</editor-fold>

    @Override
    protected LuaNodeLayout newView(LuaValue[] init) {
        return new LuaNodeLayout<>(getContext(), this,true);
    }

    private void init() {
        mNode.setFlexGrow(1);
    }
    //<editor-fold desc="API">
    @Override
    public void children(LuaTable t) {
        ErrorUtils.debugUnsupportError("Spacer not support children");
    }

    @Override
    public void insertView(UDView v, int i) {
        ErrorUtils.debugUnsupportError("Spacer not support insertView");
    }

    @Override
    public void addView(UDView v) {
        ErrorUtils.debugUnsupportError("Spacer not support addView");
    }

    //</editor-fold>
}