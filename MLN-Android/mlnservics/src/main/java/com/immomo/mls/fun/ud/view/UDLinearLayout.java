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

import com.immomo.mls.MLSConfigs;
import com.immomo.mls.base.ud.lv.ILViewGroup;
import com.immomo.mls.fun.constants.LinearType;
import com.immomo.mls.fun.ud.UDColor;
import com.immomo.mls.fun.ui.LuaLinearLayout;
import com.immomo.mls.fun.weight.LinearLayout;
import com.immomo.mls.util.LuaViewUtil;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


@LuaApiUsed(ignoreTypeArgs = true)
public class UDLinearLayout<V extends ViewGroup & ILViewGroup> extends UDViewGroup<V> {
    public static final String LUA_CLASS_NAME = "LinearLayout";

    @LuaApiUsed({@LuaApiUsed.Func(params = {
            @LuaApiUsed.Type(Integer.class)
    })})
    protected UDLinearLayout(long L, LuaValue[] v) {
        super(L, v);
    }

    public UDLinearLayout(Globals g, int type) {
        super(g);
        ((LuaLinearLayout) view).setOrientation(type);
    }

    @Override
    protected V newView(LuaValue[] init) {
        int type = LinearLayout.HORIZONTAL;
        if (init.length == 1 && init[0] != LuaValue.Nil()) {
            int v = init[0].toInt();
            if (v == LinearType.VERTICAL) {
                type = LinearLayout.VERTICAL;
            }
        }
        return (V) new LuaLinearLayout<UDLinearLayout>(getContext(), this, type);
    }

    @Override
    protected boolean clipToPadding() {
        return MLSConfigs.defaultClipContainer;
    }

    @Override
    protected boolean clipChildren() {
        return MLSConfigs.defaultClipContainer;
    }

    //<editor-fold desc="API">
    @Override
    public void insertView(UDView view, int index) {
        V v = getView();
        if (v == null)
            return;
        View sub = view.getView();
        if (sub == null)
            return;
        ViewGroup.LayoutParams layoutParams = sub.getLayoutParams();
        layoutParams = v.applyLayoutParams(layoutParams,
                view.udLayoutParams);

        if (index > getView().getChildCount()) {
            index = -1;//index越界时，View放在末尾
        }

        v.addView(LuaViewUtil.removeFromParent(sub), index, layoutParams);
    }
    //</editor-fold>
}