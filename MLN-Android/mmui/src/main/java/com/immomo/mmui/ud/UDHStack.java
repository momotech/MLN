/**
  * Created by MomoLuaNative.
  * Copyright (c) 2020, Momo Group. All rights reserved.
  *
  * This source code is licensed under the MIT.
  * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
  */
package com.immomo.mmui.ud;

import com.facebook.yoga.YogaFlexDirection;
import com.immomo.mmui.ui.LuaNodeLayout;

import org.luaj.vm2.Globals;
import org.luaj.vm2.utils.CGenerate;
import org.luaj.vm2.utils.LuaApiUsed;


@LuaApiUsed
public class UDHStack extends UDNodeGroup<LuaNodeLayout> {
    public static final String LUA_CLASS_NAME = "HStack";

    @CGenerate(defaultConstructor = true)
    @LuaApiUsed
    protected UDHStack(long L) {
        super(L);//HStack 主轴默认充满父容器
        init();
    }

    public UDHStack(Globals g) {
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

    //</editor-fold>
    private void init() {
        mNode.setFlexDirection(YogaFlexDirection.ROW);
    }

    //<editor-fold desc="API">
    @LuaApiUsed
    public void reverse(boolean reverse) {
        mNode.setFlexDirection(
            reverse ? YogaFlexDirection.ROW_REVERSE : YogaFlexDirection.ROW);
    }
    //</editor-fold>

    @Override
    public boolean needConvertVirtual() {
        return isAllowVirtual() && !isDisableVirtual()
            && getClass().getSimpleName().equals(UDHStack.class.getSimpleName());
    }
}