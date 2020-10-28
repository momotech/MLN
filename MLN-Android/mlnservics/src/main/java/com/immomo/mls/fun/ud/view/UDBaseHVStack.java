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
import com.immomo.mls.fun.weight.newui.BaseRowColumn;
import com.immomo.mls.util.LuaViewUtil;
import com.immomo.mls.utils.AssertUtils;
import com.immomo.mls.utils.ErrorUtils;

import org.luaj.vm2.LuaNumber;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.utils.LuaApiUsed;


@LuaApiUsed
public class UDBaseHVStack<V extends BaseRowColumn & ILViewGroup> extends UDBaseStack<V> {
    public static final String LUA_CLASS_NAME = "_BaseHVStack";
    public static final String[] methods = {
        "mainAxisAlignment",
        "crossAxisAlignment",
        "wrap"
    };

    @LuaApiUsed
    protected UDBaseHVStack(long L, LuaValue[] v) {
        super(L, v);
    }


    @Override
    protected boolean clipToPadding() {
        return MLSConfigs.defaultClipContainer;
    }

    @Override
    protected boolean clipChildren() {
        return MLSConfigs.defaultClipContainer;
    }

    @LuaApiUsed
    public LuaValue[] mainAxisAlignment(LuaValue[] var) {
        if (var.length > 0) {
            int value = var[0].toInt();
            getView().setMainAxisAlignment(value);
            return null;
        }
        return LuaNumber.rNumber(getView().getMainAxisAlignment());
    }

    @LuaApiUsed
    public LuaValue[] crossAxisAlignment(LuaValue[] var) {
        if (var.length > 0) {
            int value = var[0].toInt();
            getView().setCrossAxisAlignment(value);
            return null;
        }
        return LuaNumber.rNumber(getView().getCrossAxisAlignment());
    }

    @LuaApiUsed
    public LuaValue[] wrap(LuaValue[] var) {
        if (var.length > 0) {
            int value = var[0].toInt();
            getView().setWrap(value);
            return null;
        }
        return LuaNumber.rNumber(getView().getWrap());
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
